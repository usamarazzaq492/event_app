<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Square\SquareClient;
use Square\Environments;
use Square\Types\Money;
use Square\Payments\Requests\CreatePaymentRequest;
use Square\Customers\Requests\CreateCustomerRequest;
use Square\Cards\Requests\CreateCardRequest;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    // Constants for fee structure
    const FEE_PER_TICKET = 0.99;
    const SERVICE_FEE_PERCENT = 1.5;
    const PROCESSING_FEE_PERCENT = 2.9;
    const FIXED_PROCESSING_FEE = 0.30;

    private $squareClient;

    public function __construct()
    {
        $square = new SquareClient(options: [
    'accessToken' => env('SQUARE_TOKEN'),
    'baseUrl' => Environments::Sandbox->value, // or Production
]);
        $this->squareClient = $square;
    }

    /**
     * Book tickets for an event with Square payment processing
     */
    public function bookEvent(Request $request, $eventId)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'ticket_type' => 'required|in:gold,silver,general',
            'quantity' => 'required|integer|min:1|max:10',
            'payment_nonce' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 422);
        }

        return DB::transaction(function () use ($request, $eventId, $user) {
            $event = DB::table('events')
                ->where('eventId', $eventId)
                ->where('isActive', 1)
                ->lockForUpdate()
                ->first();

            if (!$event) {
                throw new \Exception('Event not found or inactive', 404);
            }

            $pricing = $this->calculatePricing(
                $event->eventPrice,
                $request->ticket_type,
                $request->quantity
            );

            $paymentResponse = $this->processSquarePayment(
                $request->payment_nonce,
                $pricing['total_amount'],
                "Event: {$event->eventTitle}",
                $user->userId
            );

            if (!$paymentResponse->getPayment() || !$paymentResponse->getPayment()->getId()) {
                throw new \Exception('Invalid payment response from Square', 500);
            }

            $bookingId = DB::table('booking')->insertGetId([
                'eventId' => $eventId,
                'userId' => $user->userId,
                'ticketType' => $request->ticket_type,
                'quantity' => $request->quantity,
                'basePrice' => $event->eventPrice,
                'subtotal' => $pricing['subtotal'],
                'serviceFee' => $pricing['service_fee'],
                'processingFee' => $pricing['processing_fee'],
                'totalAmount' => $pricing['total_amount'],
                'squarePaymentId' => $paymentResponse->getPayment()->getId(),
                'feeBreakdown' => json_encode($pricing['fee_breakdown']),
                'bookingDate' => now(),
                'status' => 'confirmed'
            ]);

            $tickets = $this->generateTickets($bookingId, $request->quantity, $event, $user);

            if ($request->save_card) {
                $this->saveCustomerCard($user->userId, $request->payment_nonce);
            }

            Log::info('Booking created', [
                'booking_id' => $bookingId,
                'user_id' => $user->userId,
                'amount' => $pricing['total_amount']
            ]);

            return response()->json([
                'success' => true,
                'booking_id' => $bookingId,
                'tickets' => $tickets,
                'receipt_url' => $this->generateReceiptUrl($bookingId),
                'amount_charged' => $pricing['total_amount'],
                'fee_breakdown' => $pricing['fee_breakdown']
            ]);

        }, 3); // Retry transaction up to 3 times
    }

    /**
     * Charge using saved card
     */
    public function chargeWithSavedCard(Request $request, $eventId)
    {
        $validated = $request->validate([
            'amount' => 'required|numeric|min:0.50',
            'card_id' => 'required|string'
        ]);

        $user = $request->user();
        $event = DB::table('events')->find($eventId);

        return DB::transaction(function () use ($validated, $user, $event) {
            $paymentMethod = DB::table('user_payment_methods')
                ->where('userId', $user->userId)
                ->where('square_card_id', $validated['card_id'])
                ->first();

            if (!$paymentMethod) {
                throw new \Exception('Payment method not found', 404);
            }

            $amountMoney = new Money();
            $amountMoney->setAmount((int) round($validated['amount'] * 100));
            $amountMoney->setCurrency('USD');

            $paymentRequest = new CreatePaymentRequest([
                'idempotencyKey' => Str::uuid()->toString(),
                'sourceId' => $paymentMethod->square_card_id,
                'amount_money' => $amountMoney,
                'customer_id' => $paymentMethod->square_customer_id,
                'note' => "Event booking: {$event->eventTitle}",
                'autocomplete' => true
            ]);

            $paymentResponse = $this->squareClient->payments->create($paymentRequest);

            if (!$paymentResponse->getPayment() || !$paymentResponse->getPayment()->getId()) {
                throw new \Exception('Invalid payment response from Square', 500);
            }

            return response()->json([
                'success' => true,
                'payment_id' => $paymentResponse->getPayment()->getId()
            ]);

        }, 3);
    }

    private function calculatePricing($basePrice, $ticketType, $quantity)
    {
        $typeMultipliers = [
            'gold' => 1.5,
            'silver' => 1.2,
            'general' => 1.0
        ];

        $adjustedBasePrice = $basePrice * $typeMultipliers[$ticketType];
        $subtotal = $adjustedBasePrice * $quantity;
        $serviceFee = ($subtotal * self::SERVICE_FEE_PERCENT / 100) +
            (self::FEE_PER_TICKET * $quantity);
        $processingFee = ($subtotal + $serviceFee) * self::PROCESSING_FEE_PERCENT / 100 +
            self::FIXED_PROCESSING_FEE;
        $totalAmount = $subtotal + $serviceFee + $processingFee;

        return [
            'subtotal' => round($subtotal, 2),
            'service_fee' => round($serviceFee, 2),
            'processing_fee' => round($processingFee, 2),
            'total_amount' => round($totalAmount, 2),
            'fee_breakdown' => [
                'base_price' => $basePrice,
                'ticket_type_multiplier' => $typeMultipliers[$ticketType],
                'per_ticket_fee' => self::FEE_PER_TICKET,
                'service_fee_percentage' => self::SERVICE_FEE_PERCENT,
                'processing_fee_percentage' => self::PROCESSING_FEE_PERCENT,
                'fixed_processing_fee' => self::FIXED_PROCESSING_FEE
            ]
        ];
    }

    private function processSquarePayment($paymentNonce, $amount, $note, $customerId)
{
    try {
        // Validate amount
        if (!is_numeric($amount) || $amount <= 0) {
            throw new \InvalidArgumentException('Invalid payment amount: must be a positive number');
        }

        // Convert to cents and ensure it's an integer
        $amountCents = (int)round($amount * 100);

        // Create Money object using SDK 42.0+ syntax
         $amountMoney = new Money();
        $amountMoney->setAmount($amountCents);
        $amountMoney->setCurrency('USD');

        // Verify location ID
        $locationId = env('SQUARE_LOCATION_ID');
        if (empty($locationId)) {
            throw new \RuntimeException('Square location ID is not configured');
        }

        // Create payment request with newer SDK syntax
        $paymentRequest = new CreatePaymentRequest([
    'idempotencyKey' => Str::uuid()->toString(),
    'sourceId' => $paymentNonce,
    'amountMoney' => $amountMoney
]);

        // Set additional parameters
        $paymentRequest->setNote(substr($note, 0, 500));
        $paymentRequest->setCustomerId((string)$customerId);
        $paymentRequest->setAutocomplete(true);
        $paymentRequest->setLocationId($locationId);

        // Debug the final request payload
        Log::debug('Square Payment Request', [
            'amount_money' => [
                'amount' => $amountMoney->getAmount(),
                'currency' => $amountMoney->getCurrency()
            ],
            'sourceId' => $paymentNonce,
            'customer_id' => $customerId,
            'location_id' => $locationId
        ]);

        // Process payment using the Payments API
        $paymentsApi = $this->squareClient->payments;
        $response = $paymentsApi->create($paymentRequest);

        // Check for errors in response
        if ($response->getErrors()) {
            $errors = $response->getErrors();
            Log::error('Square payment error', ['errors' => $errors]);
            throw new \RuntimeException('Square payment failed: ' . json_encode($errors));
        }

        return $response;

    } catch (\Square\Exceptions\SquareApiException $e) {
        Log::error('Square API Exception', [
            'message' => $e->getMessage(),
            'errors' => $e->getErrors(),
            'trace' => $e->getTraceAsString()
        ]);
        throw new \RuntimeException('Payment processing failed: ' . $e->getMessage());
    } catch (\Exception $e) {
        Log::error('Payment Processing Error', [
            'error' => $e->getMessage(),
            'trace' => $e->getTraceAsString(),
            'amount' => $amount,
            'customer' => $customerId
        ]);
        throw $e;
    }
}

    private function generateTickets($bookingId, $quantity, $event, $user)
    {
        $tickets = [];

        for ($i = 1; $i <= $quantity; $i++) {
            $ticketNumber = "EVT-" . strtoupper(Str::random(3)) . "-{$bookingId}-" . str_pad($i, 3, '0', STR_PAD_LEFT);

            $tickets[] = [
                'ticket_id' => $ticketNumber,
                'qr_code_data' => json_encode([
                    'event_id' => $event->eventId,
                    'booking_id' => $bookingId,
                    'ticket_num' => $i,
                    'user_id' => $user->userId,
                    'hash' => hash_hmac('sha256', "{$bookingId}|{$i}", env('TICKET_SECRET'))
                ]),
                'download_url' => url("/tickets/{$ticketNumber}/download")
            ];
        }

        DB::table('tickets')->insert(array_map(function ($ticket) use ($bookingId) {
            return [
                'bookingId' => $bookingId,
                'ticketNumber' => $ticket['ticket_id'],
                'qrCodeData' => $ticket['qr_code_data'],
                'created_at' => now()
            ];
        }, $tickets));

        return $tickets;
    }

    private function saveCustomerCard($userId, $paymentNonce)
    {
        try {
            $user = DB::table('mstuser')->where('userId', $userId)->first();
            if (!$user) {
                throw new \Exception("User not found");
            }

            $customerRequest = new CreateCustomerRequest([
                'reference_id' => (string) $userId,
                'email_address' => $user->email,
                'given_name' => $user->name,
                'idempotencyKey' => Str::uuid()->toString()
            ]);

            $customerResponse = $this->squareClient->customers->create($customerRequest);
            $customerId = $customerResponse->getCustomer()->getId();

            $cardRequest = new CreateCardRequest([
                'idempotencyKey' => Str::uuid()->toString(),
                'sourceId' => $paymentNonce,
                'card' => [
                    'customer_id' => $customerId,
                    'cardholder_name' => $user->name
                ]
            ]);

            $cardResponse = $this->squareClient->cards->create($cardRequest);

            DB::table('user_payment_methods')->insert([
                'userId' => $userId,
                'square_customer_id' => $customerId,
                'square_card_id' => $cardResponse->getCard()->getId(),
                'last_four' => $cardResponse->getCard()->getLast4(),
                'brand' => $cardResponse->getCard()->getCardBrand(),
                'exp_date' => $cardResponse->getCard()->getExpMonth() . '/' . $cardResponse->getCard()->getExpYear(),
                'created_at' => now()
            ]);

            return true;

        } catch (\Exception $e) {
            Log::error("Card save failed", [
                'user_id' => $userId,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return false;
        }
    }

    private function generateReceiptUrl($bookingId)
    {
        return url("/receipts/{$bookingId}?" . http_build_query([
            'token' => encrypt([
                'booking_id' => $bookingId,
                'expires' => now()->addDays(7)->timestamp,
                'ip' => request()->ip()
            ])
        ]));
    }

    public function getBookingHistory(Request $request)
{
    return DB::table('booking')
        ->join('events', 'booking.eventId', '=', 'events.eventId')
        ->leftJoin('tickets', 'booking.bookingId', '=', 'tickets.bookingId')
        ->where('booking.userId', $request->user()->userId)
        ->select([
            'booking.bookingId',
            'booking.ticketType',
            'booking.quantity',
            'booking.totalAmount',
            'booking.bookingDate',
            'booking.status',
            'events.eventTitle',
            'events.startDate',
            'events.endDate',
            'events.startTime',
            'events.endTime',
            'events.eventPrice',
            'events.eventImage',
            'events.address',
            'events.city',
            'tickets.ticketNumber',
            DB::raw("CONCAT('" . url('/tickets') . "/', tickets.ticketNumber, '/download') as download_url")
        ])
        ->orderBy('booking.bookingDate', 'desc')
        ->get(); // 🔄 replace paginate with get()
}
}
