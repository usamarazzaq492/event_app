<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Crypt;
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
    const PROCESSING_FEE_PERCENT = 2.9;
    const FIXED_PROCESSING_FEE = 0.30;
    const COMMISSION_RATE = 10.0; // App owner commission rate (percentage of subtotal)

    private $squareClient;

    /**
     * Get or initialize SquareClient (lazy initialization)
     */
    private function getSquareClient()
    {
        if ($this->squareClient === null) {
            // Use config() with fallbacks for better compatibility with cached configurations
            $accessToken = config('square.access_token', '') ?: env('SQUARE_ACCESS_TOKEN', '') ?: env('SQUARE_TOKEN', '');
            $environment = config('square.environment', '') ?: env('SQUARE_ENVIRONMENT', 'sandbox');

            if (empty($accessToken)) {
                throw new \Exception('Square access token not configured. Please set SQUARE_ACCESS_TOKEN or SQUARE_TOKEN in your .env file.');
            }

            $this->squareClient = new SquareClient(options: [
                'accessToken' => $accessToken,
                'baseUrl' => $environment === 'production'
                    ? Environments::Production->value
                    : Environments::Sandbox->value,
            ]);
        }

        return $this->squareClient;
    }

    /**
     * Book tickets for an event with Square payment processing
     */
    public function bookEvent(Request $request, $eventId)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'ticket_type' => 'required|in:vip,general',
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

            // Get the correct price based on ticket type
            $ticketPrice = $request->ticket_type === 'vip'
                ? ($event->vipPrice ?? $event->eventPrice)
                : ($event->eventPrice ?? 0);

            $pricing = $this->calculatePricing(
                $ticketPrice,
                $request->ticket_type,
                $request->quantity
            );

            $paymentResponse = $this->processSquarePayment(
                $request->payment_nonce,
                $pricing['total_amount'],
                $pricing['commission'],
                "Event: {$event->eventTitle}",
                $user->userId,
                $event
            );

            if (!$paymentResponse->getPayment() || !$paymentResponse->getPayment()->getId()) {
                throw new \Exception('Invalid payment response from Square', 500);
            }

            // Get organizer's Square account info (if connected)
            $organizerSquareAccount = DB::table('organizer_square_accounts')
                ->join('organizers', 'organizer_square_accounts.organizerId', '=', 'organizers.organizerId')
                ->where('organizers.userId', $event->userId)
                ->where('organizer_square_accounts.status', 'connected')
                ->select('organizer_square_accounts.squareMerchantId', 'organizer_square_accounts.squareLocationId')
                ->first();

            $bookingId = DB::table('booking')->insertGetId([
                'eventId' => $eventId,
                'userId' => $user->userId,
                'ticketType' => $request->ticket_type,
                'quantity' => $request->quantity,
                'basePrice' => $event->eventPrice,
                'subtotal' => $pricing['subtotal'],
                'serviceFee' => 0, // Service fee removed
                'processingFee' => $pricing['processing_fee'],
                'totalAmount' => $pricing['total_amount'],
                'squarePaymentId' => $paymentResponse->getPayment()->getId(),
                'appOwnerCommission' => $pricing['commission'],
                'organizerPayout' => $pricing['organizer_payout'],
                'organizerSquareMerchantId' => $organizerSquareAccount->squareMerchantId ?? null,
                'organizerSquareLocationId' => $organizerSquareAccount->squareLocationId ?? null,
                'paymentType' => $organizerSquareAccount ? 'split' : 'direct',
                'splitPaymentDetails' => json_encode([
                    'commission_rate' => self::COMMISSION_RATE,
                    'commission_amount' => $pricing['commission'],
                    'organizer_payout_amount' => $pricing['organizer_payout'],
                    'organizer_has_square' => $organizerSquareAccount ? true : false,
                ]),
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

            $paymentResponse = $this->getSquareClient()->payments->create($paymentRequest);

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
        // basePrice is already the correct price for the ticket type (no multiplier needed)
        $subtotal = $basePrice * $quantity;

        // Service fee removed - no longer charged
        $serviceFee = 0;

        // Processing fee: Square's actual fee (2.9% + $0.30) calculated on subtotal only
        $processingFee = ($subtotal * self::PROCESSING_FEE_PERCENT / 100) + self::FIXED_PROCESSING_FEE;
        $totalAmount = $subtotal + $processingFee;

        // Calculate commission and payout for split payment
        $commission = $subtotal * (self::COMMISSION_RATE / 100);
        $organizerPayout = ($subtotal - $commission) + $processingFee;

        return [
            'subtotal' => round($subtotal, 2),
            'service_fee' => 0, // Removed
            'processing_fee' => round($processingFee, 2),
            'total_amount' => round($totalAmount, 2),
            'commission' => round($commission, 2),
            'organizer_payout' => round($organizerPayout, 2),
            'fee_breakdown' => [
                'base_price' => $basePrice,
                'ticket_type' => $ticketType,
                'service_fee' => 0, // Removed
                'processing_fee_percentage' => self::PROCESSING_FEE_PERCENT,
                'fixed_processing_fee' => self::FIXED_PROCESSING_FEE,
                'commission_rate' => self::COMMISSION_RATE,
                'commission_amount' => round($commission, 2),
                'organizer_payout_amount' => round($organizerPayout, 2)
            ]
        ];
    }

    private function processSquarePayment($paymentNonce, $amount, $commission, $note, $customerId, $event)
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

        // Get organizer's Square account (if connected)
        $organizerSquareAccount = DB::table('organizer_square_accounts')
            ->join('organizers', 'organizer_square_accounts.organizerId', '=', 'organizers.organizerId')
            ->where('organizers.userId', $event->userId)
            ->where('organizer_square_accounts.status', 'connected')
            ->select('organizer_square_accounts.*')
            ->first();

        $useSplitPayment = false;
        $squareClient = $this->getSquareClient();
        $locationId = config('square.location_id', '') ?: env('SQUARE_LOCATION_ID', '');

        if ($organizerSquareAccount) {
            try {
                // Decrypt access token
                $accessToken = Crypt::decryptString($organizerSquareAccount->accessToken);

                // Get application ID for split payments (required when using applicationFeeMoney)
                $applicationId = config('square.application_id', env('SQUARE_APPLICATION_ID', ''));

                if (empty($applicationId)) {
                    throw new \RuntimeException('Square Application ID is required for split payments. Please set SQUARE_APPLICATION_ID in your .env file.');
                }

                // Create Square client with organizer's token and application ID
                $squareClientOptions = [
                    'accessToken' => $accessToken,
                    'baseUrl' => $organizerSquareAccount->environment === 'production'
                        ? Environments::Production->value
                        : Environments::Sandbox->value,
                ];

                // Add applicationId for split payments
                $squareClientOptions['applicationId'] = $applicationId;

                $squareClient = new SquareClient(options: $squareClientOptions);

                $locationId = $organizerSquareAccount->squareLocationId;
                $useSplitPayment = true;

                Log::info('Using split payment', [
                    'organizer_id' => $event->userId,
                    'merchant_id' => $organizerSquareAccount->squareMerchantId,
                    'application_id' => $applicationId
                ]);
            } catch (\Exception $e) {
                Log::warning('Failed to use organizer Square account, falling back to direct payment', [
                    'error' => $e->getMessage(),
                    'organizer_id' => $event->userId
                ]);
                // Fall back to direct payment
            }
        }

        if (empty($locationId)) {
            throw new \RuntimeException('Square location ID is not configured');
        }

        // Prepare payment request data
        $paymentRequestData = [
            'idempotencyKey' => Str::uuid()->toString(),
            'sourceId' => $paymentNonce,
            'amountMoney' => $amountMoney
        ];

        // If split payment, set application fee (app owner's commission)
        if ($useSplitPayment && $commission > 0) {
            $commissionCents = (int)round($commission * 100);
            $applicationFeeMoney = new Money();
            $applicationFeeMoney->setAmount($commissionCents);
            $applicationFeeMoney->setCurrency('USD');
            $paymentRequestData['applicationFeeMoney'] = $applicationFeeMoney;

            Log::debug('Split payment with application fee', [
                'commission' => $commission,
                'commission_cents' => $commissionCents
            ]);
        }

        // Create payment request
        $paymentRequest = new CreatePaymentRequest($paymentRequestData);

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
            'location_id' => $locationId,
            'split_payment' => $useSplitPayment,
            'application_fee' => $useSplitPayment ? $commission : null
        ]);

        // Process payment using the Payments API
        $paymentsApi = $squareClient->payments;
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

            $customerResponse = $this->getSquareClient()->customers->create($customerRequest);
            $customerId = $customerResponse->getCustomer()->getId();

            $cardRequest = new CreateCardRequest([
                'idempotencyKey' => Str::uuid()->toString(),
                'sourceId' => $paymentNonce,
                'card' => [
                    'customer_id' => $customerId,
                    'cardholder_name' => $user->name
                ]
            ]);

            $cardResponse = $this->getSquareClient()->cards->create($cardRequest);

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
            'tickets.qrCodeData', // Include QR code data for check-in
            DB::raw("CONCAT('" . url('/tickets') . "/', tickets.ticketNumber, '/download') as download_url")
        ])
        ->orderBy('booking.bookingDate', 'desc')
        ->get(); // 🔄 replace paginate with get()
}
}
