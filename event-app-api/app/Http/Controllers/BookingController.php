<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    const PROCESSING_FEE_PERCENT = 2.9;
    const FIXED_PROCESSING_FEE = 0.30;


    /**
     * Helper to get PayPal Access Token
     */
    private function getPayPalAccessToken($environment = null)
    {
        $clientId = config('paypal.client_id');
        $secret = config('paypal.secret');
        $env = $environment ?? config('paypal.environment', 'sandbox');
        
        $url = $env === 'production' 
            ? 'https://api-m.paypal.com/v1/oauth2/token' 
            : 'https://api-m.sandbox.paypal.com/v1/oauth2/token';

        $response = Http::withBasicAuth($clientId, $secret)
            ->asForm()
            ->post($url, [
                'grant_type' => 'client_credentials'
            ]);

        if ($response->successful()) {
            return $response->json()['access_token'];
        }

        throw new \Exception('Failed to get PayPal access token');
    }

    /**
     * Book tickets for an event — supports multiple tiers in one transaction.
     * Request body: { tiers: [{tier_id, quantity}], payment_nonce, save_card }
     */
    public function bookEvent(Request $request, $eventId)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'tiers'             => 'required|array|min:1',
            'tiers.*.tier_id'   => 'required|integer',
            'tiers.*.quantity'  => 'required|integer|min:1|max:50',
            'payment_nonce'     => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error'   => 'Validation failed',
                'details' => $validator->errors(),
            ], 422);
        }

        return DB::transaction(function () use ($request, $eventId, $user) {

            // ── Load & lock the event ────────────────────────────────────────
            $event = DB::table('events')
                ->where('eventId', $eventId)
                ->where('isActive', 1)
                ->lockForUpdate()
                ->first();

            if (!$event) {
                throw new \Exception('Event not found or inactive', 404);
            }

            // ── Load & lock requested tiers ──────────────────────────────────
            $requestedTierIds = collect($request->tiers)->pluck('tier_id');

            $tiersFromDb = DB::table('event_ticket_tiers')
                ->whereIn('tierId', $requestedTierIds)
                ->where('eventId', $eventId)
                ->where('isActive', 1)
                ->lockForUpdate()
                ->get()
                ->keyBy('tierId');

            foreach ($request->tiers as $requestedTier) {
                if (!$tiersFromDb->has($requestedTier['tier_id'])) {
                    throw new \Exception(
                        "Tier ID {$requestedTier['tier_id']} is not valid for this event.",
                        422
                    );
                }
            }

            // ── Validate capacity and build line items ───────────────────────
            $selectedTiers    = [];
            $subtotal         = 0;
            $tierSummaryParts = [];

            foreach ($request->tiers as $item) {
                $tier = $tiersFromDb[$item['tier_id']];
                $qty  = (int) $item['quantity'];

                if ($tier->quantityCap !== null) {
                    $remaining = $tier->quantityCap - $tier->quantitySold;
                    if ($qty > $remaining) {
                        throw new \Exception(
                            "Not enough '{$tier->tierName}' tickets available. "
                            . "Requested: {$qty}, Available: {$remaining}.",
                            422
                        );
                    }
                }

                $lineTotal = round((float) $tier->price * $qty, 2);
                $subtotal += $lineTotal;

                $selectedTiers[]    = ['tier' => $tier, 'quantity' => $qty, 'lineTotal' => $lineTotal];
                $tierSummaryParts[] = "{$tier->tierName} x{$qty}";
            }

            $subtotal    = round($subtotal, 2);
            $tierSummary = implode(', ', $tierSummaryParts);
            $isFree      = $subtotal == 0;

            // ── Calculate fees ───────────────────────────────────────────────
            $commissionRate = config('paypal.commission_rate', 10.0);
            $processingFee   = $isFree ? 0 : round(($subtotal * self::PROCESSING_FEE_PERCENT / 100) + self::FIXED_PROCESSING_FEE, 2);
            $totalAmount     = round($subtotal + $processingFee, 2);
            $commission      = round($subtotal * ($commissionRate / 100), 2);
            $organizerPayout = round(($subtotal - $commission) + $processingFee, 2);

            // ── Process PayPal payment (skip for free bookings) ──────────────
            $paypalPaymentId = null;

            if (!$isFree) {
                if (empty($request->payment_nonce)) {
                    throw new \Exception('payment_nonce (PayPal Order ID) is required for paid events.', 422);
                }

                $paypalPaymentId = $this->processPayPalPayment(
                    $request->payment_nonce,
                    $totalAmount,
                    $commission,
                    "Event: {$event->eventTitle}",
                    $user->userId,
                    $event
                );
            }

            // ── Get organizer PayPal account metadata ────────────────────────
            $organizerPaypalAccount = DB::table('organizer_paypal_accounts')
                ->join('organizers', 'organizer_paypal_accounts.organizerId', '=', 'organizers.organizerId')
                ->where('organizers.userId', $event->userId)
                ->where('organizer_paypal_accounts.status', 'connected')
                ->select('organizer_paypal_accounts.paypalMerchantId')
                ->first();

            // ── Insert booking row ───────────────────────────────────────────
            $bookingId = DB::table('booking')->insertGetId([
                'eventId'                   => $eventId,
                'userId'                    => $user->userId,
                'ticketType'                => $tierSummary,
                'quantity'                  => collect($selectedTiers)->sum('quantity'),
                'basePrice'                 => $selectedTiers[0]['tier']->price ?? 0,
                'subtotal'                  => $subtotal,
                'serviceFee'                => 0,
                'processingFee'             => $processingFee,
                'totalAmount'               => $totalAmount,
                'paypalPaymentId'           => $paypalPaymentId,
                'appOwnerCommission'        => $commission,
                'organizerPayout'           => $organizerPayout,
                'organizerPaypalMerchantId' => $organizerPaypalAccount->paypalMerchantId ?? null,
                'paymentType'               => $organizerPaypalAccount ? 'split' : 'direct',
                'splitPaymentDetails'       => json_encode([
                    'commission_rate'         => $commissionRate,
                    'commission_amount'       => $commission,
                    'organizer_payout_amount' => $organizerPayout,
                    'organizer_has_paypal'    => $organizerPaypalAccount ? true : false,
                ]),
                'feeBreakdown' => json_encode([
                    'tiers'                     => $tierSummary,
                    'subtotal'                  => $subtotal,
                    'processing_fee_percentage' => self::PROCESSING_FEE_PERCENT,
                    'fixed_processing_fee'      => self::FIXED_PROCESSING_FEE,
                    'processing_fee'            => $processingFee,
                    'commission_rate'           => $commissionRate,
                    'commission_amount'         => $commission,
                    'organizer_payout_amount'   => $organizerPayout,
                    'is_free'                   => $isFree,
                ]),
                'bookingDate' => now(),
                'status'      => 'confirmed',
            ]);

            // ── Insert booking_tiers rows + increment quantitySold ───────────
            foreach ($selectedTiers as $item) {
                DB::table('booking_tiers')->insert([
                    'bookingId' => $bookingId,
                    'tierId'    => $item['tier']->tierId,
                    'tierName'  => $item['tier']->tierName,
                    'unitPrice' => $item['tier']->price,
                    'quantity'  => $item['quantity'],
                    'lineTotal' => $item['lineTotal'],
                ]);

                DB::table('event_ticket_tiers')
                    ->where('tierId', $item['tier']->tierId)
                    ->increment('quantitySold', $item['quantity']);
            }

            // ── Generate tickets (one per ticket per tier) ───────────────────
            $allTickets = [];
            foreach ($selectedTiers as $item) {
                $tierTickets = $this->generateTickets(
                    $bookingId,
                    $item['quantity'],
                    $event,
                    $user,
                    $item['tier']->tierName,
                    (float) $item['tier']->price
                );
                $allTickets = array_merge($allTickets, $tierTickets);
            }

            if ($request->save_card && !$isFree) {
                $this->saveCustomerCard($user->userId, $request->payment_nonce);
            }

            Log::info('Booking created (multi-tier)', [
                'booking_id'   => $bookingId,
                'user_id'      => $user->userId,
                'tier_summary' => $tierSummary,
                'amount'       => $totalAmount,
                'is_free'      => $isFree,
            ]);

            return response()->json([
                'success'        => true,
                'booking_id'     => $bookingId,
                'tier_summary'   => $tierSummary,
                'tickets'        => $allTickets,
                'receipt_url'    => $this->generateReceiptUrl($bookingId),
                'amount_charged' => $totalAmount,
                'fee_breakdown'  => [
                    'subtotal'       => $subtotal,
                    'processing_fee' => $processingFee,
                    'total'          => $totalAmount,
                    'is_free'        => $isFree,
                ],
            ]);

        }, 3); // Retry up to 3 times on deadlock
    }

    /**
     * Charge using saved card (Not Supported for PayPal initially)
     */
    public function chargeWithSavedCard(Request $request, $eventId)
    {
        return response()->json([
            'success' => false,
            'error' => 'Saved cards are not supported with PayPal.'
        ], 400);
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
        $commissionRate = config('paypal.commission_rate', 10.0);
        $commission = $subtotal * ($commissionRate / 100);
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
                'commission_rate' => $commissionRate,
                'commission_amount' => round($commission, 2),
                'organizer_payout_amount' => round($organizerPayout, 2)
            ]
        ];
    }

    private function processPayPalPayment($orderId, $amount, $commission, $note, $customerId, $event)
    {
        try {
            $environment = config('paypal.environment', 'sandbox');
            $accessToken = $this->getPayPalAccessToken($environment);
            
            $url = $environment === 'production' 
                ? "https://api-m.paypal.com/v2/checkout/orders/{$orderId}/capture" 
                : "https://api-m.sandbox.paypal.com/v2/checkout/orders/{$orderId}/capture";

            // Get organizer's PayPal account
            $organizerPaypalAccount = DB::table('organizer_paypal_accounts')
                ->join('organizers', 'organizer_paypal_accounts.organizerId', '=', 'organizers.organizerId')
                ->where('organizers.userId', $event->userId)
                ->where('organizer_paypal_accounts.status', 'connected')
                ->select('organizer_paypal_accounts.*')
                ->first();

            $headers = [
                'Authorization' => "Bearer {$accessToken}",
                'Content-Type' => 'application/json'
            ];

            // If split payment is enabled and merchant ID is present, set the Payee Header
            if ($organizerPaypalAccount && !empty($organizerPaypalAccount->paypalMerchantId)) {
                $headers['PayPal-Auth-Assertion'] = $this->generatePayPalAuthAssertion(
                    config('paypal.client_id'), 
                    $organizerPaypalAccount->paypalMerchantId
                );
            }

            // Use an empty object so it encodes as '{}' instead of '[]'
            $response = Http::withHeaders($headers)
                ->post($url, (object)[]);

            if (!$response->successful()) {
                Log::error('PayPal capture error', ['error' => $response->json()]);
                throw new \Exception('PayPal payment failed: ' . json_encode($response->json()));
            }

            $captureData = $response->json();
            
            if ($captureData['status'] !== 'COMPLETED') {
                throw new \Exception('PayPal order not completed. Status: ' . $captureData['status']);
            }

            return $captureData['purchase_units'][0]['payments']['captures'][0]['id'] ?? $orderId;
            
        } catch (\Exception $e) {
            Log::error('PayPal Processing Error', [
                'error' => $e->getMessage(),
                'order_id' => $orderId
            ]);
            throw $e;
        }
    }

    private function generatePayPalAuthAssertion($clientId, $merchantId) {
        $header = base64_encode(json_encode(["alg" => "none"]));
        $payload = base64_encode(json_encode(["iss" => $clientId, "payer_id" => $merchantId]));
        return "{$header}.{$payload}.";
    }

    private function generateTickets($bookingId, $quantity, $event, $user, string $tierName = 'general', float $tierPrice = 0)
    {
        $tickets = [];
        // Build a short 3-letter prefix from the tier name (e.g. "VIP" → "VIP", "Adult" → "ADL", "Child" → "CHD")
        $prefix = strtoupper(substr(preg_replace('/[^A-Za-z]/', '', $tierName), 0, 3));
        if (strlen($prefix) < 3) $prefix = str_pad($prefix, 3, 'X');

        for ($i = 1; $i <= $quantity; $i++) {
            $ticketNumber = "EVT-{$prefix}-{$bookingId}-" . str_pad($i, 3, '0', STR_PAD_LEFT);

            $tickets[] = [
                'ticket_id'    => $ticketNumber,
                'tier'         => $tierName,
                'tier_price'   => $tierPrice,
                'qr_code_data' => json_encode([
                    'event_id'   => $event->eventId,
                    'booking_id' => $bookingId,
                    'ticket_num' => $i,
                    'user_id'    => $user->userId,
                    'tier_name'  => $tierName,
                    'tier_price' => $tierPrice,
                    'hash'       => hash_hmac('sha256', "{$bookingId}|{$i}|{$tierName}", env('TICKET_SECRET')),
                ]),
                'download_url' => url("/tickets/{$ticketNumber}/download"),
            ];
        }

        DB::table('tickets')->insert(array_map(function ($ticket) use ($bookingId) {
            return [
                'bookingId'    => $bookingId,
                'ticketNumber' => $ticket['ticket_id'],
                'qrCodeData'   => $ticket['qr_code_data'],
                'created_at'   => now(),
            ];
        }, $tickets));

        return $tickets;
    }

    private function saveCustomerCard($userId, $paymentNonce)
    {
        // Saved cards logic via PayPal requires Vault integration which is out of scope.
        // Silently return false.
        return false;
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
            'events.state',
            'tickets.ticketNumber',
            'tickets.qrCodeData', // Include QR code data for check-in
            DB::raw("CONCAT('" . url('/tickets') . "/', tickets.ticketNumber, '/download') as download_url")
        ])
        ->orderBy('booking.bookingDate', 'desc')
        ->get(); // 🔄 replace paginate with get()
}
}
