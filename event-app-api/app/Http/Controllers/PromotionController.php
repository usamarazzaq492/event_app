<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use Square\SquareClient;
use Square\Environments;
use Square\Payments\Requests\CreatePaymentRequest;
use Square\Types\Money;
use Illuminate\Support\Str;

class PromotionController extends Controller
{
    // Single boost option: $35 for 10 days
    const BOOST_PRICE = 35.00;
    const BOOST_DURATION_DAYS = 10;

    private $squareClient;

    /**
     * Get or initialize SquareClient (lazy initialization)
     */
    private function getSquareClient(): SquareClient
    {
        if ($this->squareClient === null) {
            // Use config() with fallbacks for better compatibility with cached configurations
            $accessToken = config('square.access_token', '') ?: env('SQUARE_ACCESS_TOKEN', '') ?: env('SQUARE_TOKEN', '');
            $environment = config('square.environment', '') ?: env('SQUARE_ENVIRONMENT', 'sandbox');

            // Log for debugging (remove sensitive data in production)
            Log::debug('Initializing SquareClient', [
                'has_access_token' => !empty($accessToken),
                'access_token_length' => strlen($accessToken ?? ''),
                'environment' => $environment,
                'config_cached' => app()->configurationIsCached(),
            ]);

            if (empty($accessToken)) {
                Log::error('Square access token not found', [
                    'config_square_access_token' => config('square.access_token'),
                    'env_square_access_token' => env('SQUARE_ACCESS_TOKEN'),
                    'env_square_token' => env('SQUARE_TOKEN'),
                ]);
                throw new \Exception('Square access token not configured. Please set SQUARE_ACCESS_TOKEN or SQUARE_TOKEN in your .env file.');
            }

            try {
                $this->squareClient = new SquareClient(
                    token: $accessToken,
                    options: [
                        'baseUrl' => $environment === 'production'
                            ? Environments::Production->value
                            : Environments::Sandbox->value,
                    ]
                );
            } catch (\Exception $e) {
                Log::error('Failed to initialize SquareClient', [
                    'error' => $e->getMessage(),
                    'has_token' => !empty($accessToken),
                    'token_length' => strlen($accessToken ?? ''),
                ]);
                throw $e;
            }
        }

        return $this->squareClient;
    }

    /**
     * Purchase promotion for an event
     */
    public function purchasePromotion(Request $request, $eventId)
    {
        $validator = Validator::make($request->all(), [
            'package' => 'required|in:boost',
            'payment_nonce' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        return DB::transaction(function () use ($request, $eventId) {
            $user = $request->user();

            // Verify event exists and belongs to user
            $event = DB::table('events')
                ->where('eventId', $eventId)
                ->where('userId', $user->userId)
                ->where('isActive', 1)
                ->first();

            if (!$event) {
                return response()->json([
                    'success' => false,
                    'message' => 'Event not found or you do not have permission'
                ], 404);
            }

            // Check if promotion is already active - prevent promoting again
            $isPromoted = $event->isPromoted == 1;
            $isActive = false;

            if ($isPromoted && $event->promotionEndDate) {
                $endDate = \Carbon\Carbon::parse($event->promotionEndDate);
                $isActive = $endDate->isFuture();
            }

            if ($isActive) {
                return response()->json([
                    'success' => false,
                    'message' => 'Your event is already promoted. You can promote again after the current promotion expires.'
                ], 400);
            }

            // Single boost option: $35 for 10 days
            $package = 'boost'; // Always 'boost' for new system
            $amount = self::BOOST_PRICE;
            $durationDays = self::BOOST_DURATION_DAYS;

            // Process PayPal payment
            $paymentResponse = $this->processPayPalPayment(
                $request->payment_nonce,
                $amount,
                "Event Promotion: {$event->eventTitle}",
                $user->userId
            );

            if (!$paymentResponse) {
                throw new \Exception('Payment processing failed', 500);
            }

            $paymentId = $paymentResponse; // Use the PayPal order/capture ID

            // Calculate promotion dates (store in UTC for consistency across timezones)
            $startDate = now()->utc();
            $endDate = now()->utc()->addDays($durationDays);

            // Create promotion transaction record
            $transactionId = DB::table('promotion_transactions')->insertGetId([
                'eventId' => $eventId,
                'userId' => $user->userId,
                'package' => $package,
                'amount' => $amount,
                'duration_days' => $durationDays,
                'squarePaymentId' => $paymentId, // Keep legacy column name for now
                'status' => 'completed',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Update event with promotion
            DB::table('events')
                ->where('eventId', $eventId)
                ->update([
                    'isPromoted' => 1,
                    'promotionStartDate' => $startDate,
                    'promotionEndDate' => $endDate,
                    'promotionPackage' => $package,
                    'editDate' => now(),
                ]);

            return response()->json([
                'success' => true,
                'message' => 'Event promoted successfully!',
                'data' => [
                    'transactionId' => $transactionId,
                    'eventId' => $eventId,
                    'package' => $package,
                    'durationDays' => $durationDays,
                    'promotionEndDate' => $endDate->toIso8601String(), // ISO 8601 format with UTC timezone
                ]
            ]);
        });
    }

    /**
     * Get promotion status for an event
     */
    public function getPromotionStatus($eventId)
    {
        $event = DB::table('events')
            ->where('eventId', $eventId)
            ->first();

        if (!$event) {
            return response()->json([
                'success' => false,
                'message' => 'Event not found'
            ], 404);
        }

        $isPromoted = $event->isPromoted == 1;
        $isActive = false;
        $daysRemaining = 0;

        if ($isPromoted && $event->promotionEndDate) {
            $endDate = \Carbon\Carbon::parse($event->promotionEndDate);
            $isActive = $endDate->isFuture();

            if ($isActive) {
                $daysRemaining = max(0, (int)ceil(now()->diffInDays($endDate, false)));
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'isPromoted' => $isPromoted,
                'isActive' => $isActive,
                'package' => $event->promotionPackage,
                'startDate' => $event->promotionStartDate,
                'endDate' => $event->promotionEndDate,
                'daysRemaining' => $daysRemaining,
            ]
        ]);
    }

    /**
     * Get boost package pricing (single option: $35 for 10 days)
     */
    public function getPackages()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'boost' => [
                    'price' => self::BOOST_PRICE,
                    'durationDays' => self::BOOST_DURATION_DAYS,
                    'name' => 'Event Go-Live Boost',
                    'description' => 'Boost your event for 10 days to increase visibility',
                ],
            ]
        ]);
    }

    /**
     * Process PayPal payment
     */
    private function processPayPalPayment($orderId, $amount, $note, $userId)
    {
        try {
            $environment = config('paypal.environment', 'sandbox');
            $accessToken = $this->getPayPalAccessToken($environment);
            
            $url = $environment === 'production' 
                ? "https://api-m.paypal.com/v2/checkout/orders/{$orderId}/capture" 
                : "https://api-m.sandbox.paypal.com/v2/checkout/orders/{$orderId}/capture";

            $headers = [
                'Authorization' => "Bearer {$accessToken}",
                'Content-Type' => 'application/json'
            ];

            // Use an empty object so it encodes as '{}' instead of '[]'
            $response = \Illuminate\Support\Facades\Http::withHeaders($headers)
                ->post($url, (object)[]);

            if (!$response->successful()) {
                \Illuminate\Support\Facades\Log::error('PayPal capture error', ['error' => $response->json()]);
                throw new \Exception('PayPal payment failed: ' . json_encode($response->json()));
            }

            $captureData = $response->json();
            
            // Log successful capture
            \Illuminate\Support\Facades\Log::info('PayPal payment captured', [
                'orderId' => $orderId,
                'status' => $captureData['status'] ?? 'UNKNOWN'
            ]);

            return $orderId;

        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('PayPal processing error', [
                'error' => $e->getMessage(),
                'orderId' => $orderId
            ]);
            throw $e;
        }
    }

    private function getPayPalAccessToken($environment)
    {
        $clientId = config('paypal.client_id');
        $clientSecret = config('paypal.secret');
        
        $url = $environment === 'production' 
            ? 'https://api-m.paypal.com/v1/oauth2/token' 
            : 'https://api-m.sandbox.paypal.com/v1/oauth2/token';

        $response = \Illuminate\Support\Facades\Http::asForm()
            ->withBasicAuth($clientId, $clientSecret)
            ->post($url, [
                'grant_type' => 'client_credentials'
            ]);

        if ($response->successful()) {
            return $response->json()['access_token'];
        }

        throw new \Exception('Failed to obtain PayPal access token');
    }

}




