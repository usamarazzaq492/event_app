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

    public function __construct()
    {
        $accessToken = config('square.access_token') ?: env('SQUARE_ACCESS_TOKEN') ?: env('SQUARE_TOKEN');
        $environment = config('square.environment', 'sandbox');

        $square = new SquareClient(options: [
            'accessToken' => $accessToken,
            'baseUrl' => $environment === 'production'
                ? Environments::Production->value
                : Environments::Sandbox->value,
        ]);
        $this->squareClient = $square;
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

            // Process Square payment
            $paymentResponse = $this->processSquarePayment(
                $request->payment_nonce,
                $amount,
                "Event Promotion: {$event->eventTitle}",
                $user->userId
            );

            if (!$paymentResponse->getPayment() || !$paymentResponse->getPayment()->getId()) {
                throw new \Exception('Payment processing failed', 500);
            }

            $paymentId = $paymentResponse->getPayment()->getId();

            // Calculate promotion dates
            $startDate = now();
            $endDate = now()->addDays($durationDays);

            // Create promotion transaction record
            $transactionId = DB::table('promotion_transactions')->insertGetId([
                'eventId' => $eventId,
                'userId' => $user->userId,
                'package' => $package,
                'amount' => $amount,
                'duration_days' => $durationDays,
                'squarePaymentId' => $paymentId,
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
                    'promotionEndDate' => $endDate->format('Y-m-d H:i:s'),
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
     * Process Square payment
     */
    private function processSquarePayment($paymentNonce, $amount, $note, $userId)
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
                'amountMoney' => $amountMoney,
            ]);

            // Set additional parameters
            $paymentRequest->setNote(substr($note, 0, 500));
            $paymentRequest->setCustomerId((string)$userId);
            $paymentRequest->setAutocomplete(true);
            $paymentRequest->setLocationId($locationId);

            // Debug the final request payload
            Log::debug('Square Payment Request', [
                'amount_money' => [
                    'amount' => $amountMoney->getAmount(),
                    'currency' => $amountMoney->getCurrency()
                ],
                'sourceId' => $paymentNonce,
                'customer_id' => $userId,
                'location_id' => $locationId
            ]);

            // Process payment using the Payments API - use create() not createPayment()
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
            Log::error('Square payment exception', [
                'message' => $e->getMessage(),
                'user_id' => $userId,
                'trace' => $e->getTraceAsString()
            ]);
            throw $e;
        }
    }
}




