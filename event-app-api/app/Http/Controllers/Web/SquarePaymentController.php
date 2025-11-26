<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;

class SquarePaymentController extends Controller
{
    private $squareApiUrl;
    private $accessToken;
    private $applicationId;
    private $locationId;

    public function __construct()
    {
        $this->accessToken = env('SQUARE_ACCESS_TOKEN') ?: env('SQUARE_TOKEN');
        $this->applicationId = env('SQUARE_APPLICATION_ID');
        $this->locationId = env('SQUARE_LOCATION_ID');

        // Set API URL based on environment
        $environment = env('SQUARE_ENVIRONMENT', 'sandbox');
        $this->squareApiUrl = $environment === 'production'
            ? 'https://connect.squareup.com/v2'
            : 'https://connect.squareupsandbox.com/v2';
    }

    public function showDonationForm($transactionId)
    {
        $transaction = DB::table('donation_transactions')
            ->join('donation', 'donation_transactions.donationId', '=', 'donation.donationId')
            ->select('donation_transactions.*', 'donation.title', 'donation.amount as goalAmount')
            ->where('donation_transactions.id', $transactionId)
            ->where('donation_transactions.userId', Auth::id())
            ->first();

        if (!$transaction) {
            abort(404, 'Transaction not found');
        }

        return view('square-donate', compact('transaction'));
    }

    public function processDonation(Request $request, $transactionId)
    {
        $request->validate([
            'sourceId' => 'required|string',
            'amount' => 'required|numeric|min:1',
        ]);

        $transaction = DB::table('donation_transactions')
            ->where('id', $transactionId)
            ->where('userId', Auth::id())
            ->first();

        if (!$transaction) {
            return response()->json(['error' => 'Transaction not found'], 404);
        }

        try {
            // Process payment with Square
            $paymentResult = $this->processSquarePayment([
                'sourceId' => $request->sourceId,
                'amount' => (int)round($request->amount * 100), // Convert to cents and ensure integer
                'currency' => 'USD',
                'idempotencyKey' => Str::uuid()->toString(),
            ]);

            if ($paymentResult['success']) {
                // Update transaction with Square payment ID
                DB::table('donation_transactions')
                    ->where('id', $transactionId)
                    ->update([
                        'squarePaymentId' => $paymentResult['paymentId'],
                        'updated_at' => now(),
                    ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Donation processed successfully!',
                    'paymentId' => $paymentResult['paymentId']
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'error' => $paymentResult['error']
                ], 400);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Payment processing failed: ' . $e->getMessage()
            ], 500);
        }
    }

    private function processSquarePayment($paymentData)
    {
        try {
            // Validate required credentials
            if (!$this->accessToken) {
                return [
                    'success' => false,
                    'error' => 'Square access token not configured'
                ];
            }

            if (!$this->locationId) {
                return [
                    'success' => false,
                    'error' => 'Square location ID not configured'
                ];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->accessToken,
                'Content-Type' => 'application/json',
                'Square-Version' => '2023-10-18'
            ])->post($this->squareApiUrl . '/payments', [
                'source_id' => $paymentData['sourceId'],
                'amount_money' => [
                    'amount' => $paymentData['amount'],
                    'currency' => $paymentData['currency']
                ],
                'idempotency_key' => $paymentData['idempotencyKey'],
                'location_id' => $this->locationId
            ]);

            if ($response->successful()) {
                $data = $response->json();
                if (isset($data['payment']['id'])) {
                    return [
                        'success' => true,
                        'paymentId' => $data['payment']['id']
                    ];
                } else {
                    return [
                        'success' => false,
                        'error' => 'Invalid payment response from Square'
                    ];
                }
            } else {
                $error = $response->json();
                $errorMessage = 'Payment failed';
                if (isset($error['errors']) && is_array($error['errors']) && count($error['errors']) > 0) {
                    $errorMessage = $error['errors'][0]['detail'] ?? $error['errors'][0]['message'] ?? 'Payment failed';
                }
                return [
                    'success' => false,
                    'error' => $errorMessage
                ];
            }
        } catch (\Exception $e) {
            Log::error('Square payment processing error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => 'Payment processing failed. Please try again.'
            ];
        }
    }

    public function showEventPayment($eventId, Request $request)
    {
        $event = DB::table('events')->where('eventId', (int)$eventId)->first();

        if (!$event) {
            abort(404, 'Event not found');
        }

        // Get booking details from URL parameters (for mobile app) or session (for web)
        $quantity = $request->get('quantity', session('quantity', 1));
        $ticketType = $request->get('ticket_type', session('ticket_type', 'general'));

        // Calculate pricing based on ticket type
        $typeMultipliers = [
            'gold' => 1.5,
            'silver' => 1.2,
            'general' => 1.0
        ];

        $basePrice = $event->eventPrice ?? 0;
        $adjustedPrice = $basePrice * $typeMultipliers[$ticketType];
        $subtotal = $adjustedPrice * $quantity;

        // Calculate fees (same as BookingController)
        $serviceFee = ($subtotal * 1.5 / 100) + (0.99 * $quantity);
        $processingFee = ($subtotal + $serviceFee) * 2.9 / 100 + 0.30;
        $totalAmount = $subtotal + $serviceFee + $processingFee;

        return view('square-payment', [
            'eventName' => $event->eventTitle ?? 'Event',
            'amount' => '$' . number_format($totalAmount, 2),
            'eventId' => (int)$eventId,
            'quantity' => $quantity,
            'ticketType' => $ticketType,
            'basePrice' => $basePrice,
            'subtotal' => $subtotal,
            'serviceFee' => $serviceFee,
            'processingFee' => $processingFee,
            'totalAmount' => $totalAmount,
        ]);
    }

    public function processEventPayment(Request $request, $eventId)
    {
        // Add comprehensive logging
        Log::info('Payment processing started', [
            'eventId' => $eventId,
            'eventId_type' => gettype($eventId),
            'eventId_casted' => (int)$eventId,
            'request_data' => $request->all(),
            'user_id' => Auth::id(),
            'user_id_type' => gettype(Auth::id())
        ]);

        $request->validate([
            'sourceId' => 'required|string',
            'amount' => 'required|numeric|min:1',
        ]);

        $event = DB::table('events')->where('eventId', (int)$eventId)->first();

        if (!$event) {
            return response()->json(['error' => 'Event not found'], 404);
        }

        try {
            // Get booking details from URL parameters (for mobile app) or session (for web)
            $quantity = $request->get('quantity', session('quantity', 1));
            $ticketType = $request->get('ticket_type', session('ticket_type', 'general'));

            // Calculate pricing based on ticket type (same as showEventPayment)
            $typeMultipliers = [
                'gold' => 1.5,
                'silver' => 1.2,
                'general' => 1.0
            ];

            $basePrice = $event->eventPrice ?? 0;
            $adjustedPrice = $basePrice * $typeMultipliers[$ticketType];
            $subtotal = $adjustedPrice * $quantity;

            // Calculate fees
            $serviceFee = ($subtotal * 1.5 / 100) + (0.99 * $quantity);
            $processingFee = ($subtotal + $serviceFee) * 2.9 / 100 + 0.30;
            $totalAmount = $subtotal + $serviceFee + $processingFee;

            // Log payment details before processing
            Log::info('Payment details calculated', [
                'basePrice' => $basePrice,
                'ticketType' => $ticketType,
                'quantity' => $quantity,
                'subtotal' => $subtotal,
                'serviceFee' => $serviceFee,
                'processingFee' => $processingFee,
                'totalAmount' => $totalAmount,
                'amountInCents' => (int)round($totalAmount * 100)
            ]);

            // Process payment with Square
            $paymentResult = $this->processSquarePayment([
                'sourceId' => $request->sourceId,
                'amount' => (int)round($totalAmount * 100), // Convert to cents and ensure integer
                'currency' => 'USD',
                'idempotencyKey' => Str::uuid()->toString(),
            ]);

            Log::info('Square payment result', ['result' => $paymentResult]);

            if ($paymentResult['success']) {
                // Log database insertion details
                Log::info('Creating booking record', [
                    'eventId' => (int)$eventId,
                    'userId' => (int)Auth::id(),
                    'ticketType' => $ticketType,
                    'quantity' => $quantity,
                    'totalAmount' => $totalAmount
                ]);

                // Create booking record with detailed fee breakdown
                $bookingId = DB::table('booking')->insertGetId([
                    'eventId' => (int)$eventId,
                    'userId' => (int)Auth::id(),
                    'ticketType' => $ticketType,
                    'quantity' => $quantity,
                    'basePrice' => $basePrice,
                    'subtotal' => $subtotal,
                    'serviceFee' => $serviceFee,
                    'processingFee' => $processingFee,
                    'totalAmount' => $totalAmount,
                    'squarePaymentId' => $paymentResult['paymentId'],
                    'feeBreakdown' => json_encode([
                        'base_price' => $basePrice,
                        'ticket_type_multiplier' => $typeMultipliers[$ticketType],
                        'per_ticket_fee' => 0.99,
                        'service_fee_percentage' => 1.5,
                        'processing_fee_percentage' => 2.9,
                        'fixed_processing_fee' => 0.30
                    ]),
                    'bookingDate' => now(),
                    'status' => 'confirmed'
                ]);

                // Clear session data
                session()->forget(['quantity', 'ticket_type']);

                return response()->json([
                    'success' => true,
                    'message' => 'Payment processed successfully!',
                    'bookingId' => $bookingId,
                    'paymentId' => $paymentResult['paymentId']
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'error' => $paymentResult['error']
                ], 400);
            }
        } catch (\Exception $e) {
            // Log detailed error information
            Log::error('Payment processing failed', [
                'error_message' => $e->getMessage(),
                'error_file' => $e->getFile(),
                'error_line' => $e->getLine(),
                'error_trace' => $e->getTraceAsString(),
                'eventId' => $eventId,
                'user_id' => Auth::id(),
                'request_data' => $request->all()
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Payment processing failed: ' . $e->getMessage(),
                'debug_info' => [
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                    'eventId' => $eventId,
                    'eventId_type' => gettype($eventId)
                ]
            ], 500);
        }
    }
}
