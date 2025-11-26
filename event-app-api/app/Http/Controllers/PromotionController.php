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
    const BASIC_PACKAGE_PRICE = 35.00;
    const PREMIUM_PACKAGE_PRICE = 75.00;
    const BASIC_DURATION_DAYS = 10;
    const PREMIUM_DURATION_DAYS = 30;

    private $squareClient;

    public function __construct()
    {
        $square = new SquareClient(options: [
            'accessToken' => env('SQUARE_TOKEN'),
            'baseUrl' => Environments::Sandbox->value, // Change to Production when ready
        ]);
        $this->squareClient = $square;
    }

    /**
     * Purchase promotion for an event
     */
    public function purchasePromotion(Request $request, $eventId)
    {
        $validator = Validator::make($request->all(), [
            'package' => 'required|in:basic,premium',
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

            // Determine package details
            $package = $request->package;
            $amount = $package === 'premium' ? self::PREMIUM_PACKAGE_PRICE : self::BASIC_PACKAGE_PRICE;
            $durationDays = $package === 'premium' ? self::PREMIUM_DURATION_DAYS : self::BASIC_DURATION_DAYS;

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
                $daysRemaining = now()->diffInDays($endDate, false);
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
                'daysRemaining' => $daysRemaining > 0 ? $daysRemaining : 0,
            ]
        ]);
    }

    /**
     * Get promotion packages pricing
     */
    public function getPackages()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'basic' => [
                    'price' => self::BASIC_PACKAGE_PRICE,
                    'durationDays' => self::BASIC_DURATION_DAYS,
                    'name' => 'Basic Package',
                ],
                'premium' => [
                    'price' => self::PREMIUM_PACKAGE_PRICE,
                    'durationDays' => self::PREMIUM_DURATION_DAYS,
                    'name' => 'Premium Package',
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
            $amountMoney = new Money();
            $amountMoney->setAmount((int)($amount * 100)); // Convert to cents
            $amountMoney->setCurrency('USD');

            $paymentRequest = new CreatePaymentRequest([
                'idempotencyKey' => Str::uuid()->toString(),
                'sourceId' => $paymentNonce,
                'amountMoney' => $amountMoney,
                'note' => $note,
            ]);

            $response = $this->squareClient->payments->createPayment($paymentRequest);

            if ($response->isError()) {
                Log::error('Square payment error', [
                    'errors' => $response->getErrors(),
                    'user_id' => $userId,
                ]);
                throw new \Exception('Payment processing failed: ' . json_encode($response->getErrors()));
            }

            return $response;

        } catch (\Exception $e) {
            Log::error('Square payment exception', [
                'message' => $e->getMessage(),
                'user_id' => $userId,
            ]);
            throw $e;
        }
    }
}




