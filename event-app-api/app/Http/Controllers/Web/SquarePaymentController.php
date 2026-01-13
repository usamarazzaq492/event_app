<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Crypt;

class SquarePaymentController extends Controller
{
    private $squareApiUrl;
    private $accessToken;
    private $applicationId;
    private $locationId;

    public function __construct()
    {
        // Use config() which works even when cached, with fallback to env()
        $this->accessToken = config('square.access_token', '')
            ?: env('SQUARE_ACCESS_TOKEN', '')
            ?: env('SQUARE_TOKEN', '');

        $this->applicationId = config('square.application_id', env('SQUARE_APPLICATION_ID', ''));
        $this->locationId = config('square.location_id', env('SQUARE_LOCATION_ID', ''));

        // Set API URL based on environment
        $environment = config('square.environment', env('SQUARE_ENVIRONMENT', 'sandbox'));
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

    private function processSquarePayment($paymentData, $event = null, $commission = 0)
    {
        try {
            // Determine if we should use split payment
            $useSplitPayment = false;
            $accessToken = $this->accessToken;
            $locationId = $this->locationId;
            $applicationId = $this->applicationId;

            // Check if organizer has Square connected (for split payments)
            if ($event) {
                $organizerSquareAccount = DB::table('organizer_square_accounts')
                    ->join('organizers', 'organizer_square_accounts.organizerId', '=', 'organizers.organizerId')
                    ->where('organizers.userId', $event->userId)
                    ->where('organizer_square_accounts.status', 'connected')
                    ->select('organizer_square_accounts.*')
                    ->first();

                if ($organizerSquareAccount && $commission > 0) {
                    try {
                        // Decrypt organizer's access token
                        $accessToken = Crypt::decryptString($organizerSquareAccount->accessToken);
                        $locationId = $organizerSquareAccount->squareLocationId;
                        $useSplitPayment = true;

                        // Application ID is required for split payments
                        if (empty($this->applicationId)) {
                            throw new \RuntimeException('Square Application ID is required for split payments. Please set SQUARE_APPLICATION_ID in your .env file.');
                        }
                        $applicationId = $this->applicationId;

                        Log::info('Using split payment for web', [
                            'organizer_id' => $event->userId,
                            'merchant_id' => $organizerSquareAccount->squareMerchantId,
                            'commission' => $commission
                        ]);
                    } catch (\Exception $e) {
                        Log::warning('Failed to use organizer Square account for web payment, falling back to direct', [
                            'error' => $e->getMessage(),
                            'organizer_id' => $event->userId
                        ]);
                        // Fall back to direct payment
                    }
                }
            }

            // Validate required credentials
            if (empty($accessToken)) {
                Log::error('Square access token not configured', [
                    'config_value' => config('square.access_token'),
                    'env_square_access_token' => env('SQUARE_ACCESS_TOKEN'),
                    'env_square_token' => env('SQUARE_TOKEN'),
                    'config_cached' => app()->configurationIsCached(),
                ]);
                return [
                    'success' => false,
                    'error' => 'Square access token not configured. Please set SQUARE_ACCESS_TOKEN or SQUARE_TOKEN in your .env file.'
                ];
            }

            if (empty($locationId)) {
                Log::error('Square location ID not configured', [
                    'config_value' => config('square.location_id'),
                    'env_value' => env('SQUARE_LOCATION_ID'),
                    'config_cached' => app()->configurationIsCached(),
                ]);
                return [
                    'success' => false,
                    'error' => 'Square location ID not configured. Please set SQUARE_LOCATION_ID in your .env file.'
                ];
            }

            // Build payment request payload
            $paymentPayload = [
                'source_id' => $paymentData['sourceId'],
                'amount_money' => [
                    'amount' => $paymentData['amount'],
                    'currency' => $paymentData['currency']
                ],
                'idempotency_key' => $paymentData['idempotencyKey'],
                'location_id' => $locationId
            ];

            // Add application fee for split payments
            if ($useSplitPayment && $commission > 0) {
                $commissionCents = (int)round($commission * 100);
                $paymentPayload['application_fee_money'] = [
                    'amount' => $commissionCents,
                    'currency' => 'USD'
                ];

                // Application ID is required when using application_fee_money
                // Note: Square API v2 requires this in the request, not headers
                // But actually, applicationId should be set in SquareClient, not in HTTP request
                // For HTTP requests, we need to ensure the access token is from the platform app
                Log::debug('Split payment with application fee', [
                    'commission' => $commission,
                    'commission_cents' => $commissionCents,
                    'application_id' => $applicationId
                ]);
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
                'Square-Version' => '2023-10-18'
            ])->post($this->squareApiUrl . '/payments', $paymentPayload);

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

        // Check if this is a promotion payment
        $isPromotion = $request->get('is_promotion', false) == true || $request->get('is_promotion') === 'true';
        $package = $request->get('package', 'boost');

        if ($isPromotion) {
            // Promotion payment: $35 for boost package
            $promotionPrice = 35.00;
            $processingFee = ($promotionPrice * 2.9 / 100) + 0.30; // Square's processing fee
            $totalAmount = $promotionPrice + $processingFee;

            return view('square-payment', [
                'eventName' => $event->eventTitle ?? 'Event',
                'amount' => '$' . number_format($totalAmount, 2),
                'eventId' => (int)$eventId,
                'isPromotion' => true,
                'package' => $package,
                'promotionPrice' => $promotionPrice,
                'processingFee' => $processingFee,
                'totalAmount' => $totalAmount,
            ]);
        }

        // Regular booking payment
        // Get booking details from URL parameters (for mobile app) or session (for web)
        $quantity = $request->get('quantity', session('quantity', 1));
        $ticketType = $request->get('ticket_type', session('ticket_type', 'general'));

        // Get the correct price based on ticket type
        $ticketPrice = $ticketType === 'vip'
            ? ($event->vipPrice ?? $event->eventPrice ?? 0)
            : ($event->eventPrice ?? 0);

        $subtotal = $ticketPrice * $quantity;

        // Calculate fees (service fee removed, only Square's processing fee)
        $serviceFee = 0; // Service fee removed
        $processingFee = ($subtotal * 2.9 / 100) + 0.30; // Square's actual fee
        $totalAmount = $subtotal + $processingFee;

        return view('square-payment', [
            'eventName' => $event->eventTitle ?? 'Event',
            'amount' => '$' . number_format($totalAmount, 2),
            'eventId' => (int)$eventId,
            'quantity' => $quantity,
            'ticketType' => $ticketType,
            'ticketPrice' => $ticketPrice,
            'subtotal' => $subtotal,
            'serviceFee' => $serviceFee,
            'processingFee' => $processingFee,
            'totalAmount' => $totalAmount,
            'isPromotion' => false,
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

            // Get the correct price based on ticket type
            $ticketPrice = $ticketType === 'vip'
                ? ($event->vipPrice ?? $event->eventPrice ?? 0)
                : ($event->eventPrice ?? 0);

            $subtotal = $ticketPrice * $quantity;

            // Calculate fees (service fee removed, only Square's processing fee)
            $serviceFee = 0; // Service fee removed
            $processingFee = ($subtotal * 2.9 / 100) + 0.30; // Square's actual fee
            $totalAmount = $subtotal + $processingFee;

            // Calculate commission and payout
            $commissionRate = config('square.commission_rate', 10.0);
            $commission = $subtotal * ($commissionRate / 100);
            $organizerPayout = ($subtotal - $commission) + $processingFee;

            // Log payment details before processing
            Log::info('Payment details calculated', [
                'ticketPrice' => $ticketPrice,
                'ticketType' => $ticketType,
                'quantity' => $quantity,
                'subtotal' => $subtotal,
                'serviceFee' => $serviceFee,
                'processingFee' => $processingFee,
                'totalAmount' => $totalAmount,
                'amountInCents' => (int)round($totalAmount * 100)
            ]);

            // Process payment with Square (pass event and commission for split payments)
            $paymentResult = $this->processSquarePayment([
                'sourceId' => $request->sourceId,
                'amount' => (int)round($totalAmount * 100), // Convert to cents and ensure integer
                'currency' => 'USD',
                'idempotencyKey' => Str::uuid()->toString(),
            ], $event, $commission);

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

                // Get organizer's Square account info (if connected)
                $organizerSquareAccount = DB::table('organizer_square_accounts')
                    ->join('organizers', 'organizer_square_accounts.organizerId', '=', 'organizers.organizerId')
                    ->where('organizers.userId', $event->userId)
                    ->where('organizer_square_accounts.status', 'connected')
                    ->select('organizer_square_accounts.squareMerchantId', 'organizer_square_accounts.squareLocationId')
                    ->first();

                // Create booking record with detailed fee breakdown
                $bookingId = DB::table('booking')->insertGetId([
                    'eventId' => (int)$eventId,
                    'userId' => (int)Auth::id(),
                    'ticketType' => $ticketType,
                    'quantity' => $quantity,
                    'basePrice' => $ticketPrice,
                    'subtotal' => $subtotal,
                    'serviceFee' => 0, // Service fee removed
                    'processingFee' => $processingFee,
                    'totalAmount' => $totalAmount,
                    'squarePaymentId' => $paymentResult['paymentId'],
                    'appOwnerCommission' => $commission,
                    'organizerPayout' => $organizerPayout,
                    'organizerSquareMerchantId' => $organizerSquareAccount->squareMerchantId ?? null,
                    'organizerSquareLocationId' => $organizerSquareAccount->squareLocationId ?? null,
                    'paymentType' => $organizerSquareAccount ? 'split' : 'direct',
                    'splitPaymentDetails' => json_encode([
                        'commission_rate' => $commissionRate,
                        'commission_amount' => $commission,
                        'organizer_payout_amount' => $organizerPayout,
                        'organizer_has_square' => $organizerSquareAccount ? true : false,
                    ]),
                    'feeBreakdown' => json_encode([
                        'base_price' => $ticketPrice,
                        'ticket_type' => $ticketType,
                        'service_fee' => 0, // Removed
                        'processing_fee_percentage' => 2.9,
                        'fixed_processing_fee' => 0.30,
                        'commission_rate' => $commissionRate,
                        'commission_amount' => $commission,
                        'organizer_payout_amount' => $organizerPayout
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
