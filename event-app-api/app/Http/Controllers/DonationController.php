<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Square\SquareClient;
use Square\Environments;
use Square\Types\Money;
use Square\Payments\Requests\CreatePaymentRequest;
use Square\Customers\Requests\CreateCustomerRequest;
use Square\Cards\Requests\CreateCardRequest;
use Illuminate\Support\Str;

class DonationController extends Controller
{
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

    // Create new ad
    public function createAd(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string|max:1000',
            'imageUrl' => 'required|image|max:2048', // 2MB max
            'target_amount' => 'nullable|numeric|min:0'
        ]);

        $imagePath = $request->file('imageUrl')->store('ads', 'public');

        $adId = DB::table('donation')->insertGetId([
            'userId' => $request->user()->userId,
            'title' => $validated['title'],
            'description' => $validated['description'],
            'imageUrl' => "/storage/public/$imagePath",
            'amount' => $validated['target_amount'] ?? 0,
            'isActive' => true,
            'addDate' => now(),
            'updated_at' => now()
        ]);

        return response()->json([
            'success' => true,
            'ad_id' => $adId,
            'message' => 'Ad created successfully'
        ]);
    }

    // List active ads
    public function listAds()
    {
        $ads = DB::table('donation')
            ->where('isActive', true)
            ->orderBy('addDate', 'desc')
            ->get();

        return response()->json($ads);
    }

    // Process donation
    public function donate(Request $request, $donationId)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:1',
            'payment_nonce' => 'required|string',
            'save_card' => 'sometimes|boolean'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 422);
        }

        return DB::transaction(function () use ($request, $donationId) {
            $donation = DB::table('donation')
                ->where('donationId', $donationId)
                ->where('isActive', 1)
                ->first();

            if (!$donation) {
                throw new \Exception('Donation campaign not found or inactive', 404);
            }

            // Calculate processing fees like BookingController
            $processingFee = ($request->amount * self::PROCESSING_FEE_PERCENT / 100) + self::FIXED_PROCESSING_FEE;
            $totalAmount = $request->amount + $processingFee;

            $paymentResponse = $this->processSquarePayment(
                $request->payment_nonce,
                $totalAmount,
                "Donation to: {$donation->title}",
                $request->user()->userId
            );

            if (!$paymentResponse->getPayment() || !$paymentResponse->getPayment()->getId()) {
                throw new \Exception('Invalid payment response from Square', 500);
            }

            // Record donation
            DB::table('donation_transactions')->insert([
                'donationId' => $donationId,
                'userId' => $request->user()->userId,
                'amount' => $request->amount,
                'processingFee' => $processingFee,
                'totalAmount' => $totalAmount,
                'squarePaymentId' => $paymentResponse->getPayment()->getId(),
                'created_at' => now()
            ]);

            // Save card if requested (same as BookingController)
            if ($request->save_card) {
                $this->saveCustomerCard($request->user()->userId, $request->payment_nonce);
            }

            return response()->json([
                'success' => true,
                'donation_id' => $donationId,
                'amount' => $request->amount,
                'processing_fee' => $processingFee,
                'total_charged' => $totalAmount,
                'transaction_id' => $paymentResponse->getPayment()->getId()
            ]);

        }, 3); // Same retry logic as BookingController
    }

    private function processSquarePayment($paymentNonce, $amount, $note, $customerId)
    {
        try {
            // Identical to BookingController's implementation
            if (!is_numeric($amount) || $amount <= 0) {
                throw new \InvalidArgumentException('Invalid payment amount');
            }

            $amountMoney = new Money();
            $amountMoney->setAmount((int)($amount * 100));
            $amountMoney->setCurrency('USD');

            $locationId = env('SQUARE_LOCATION_ID');
            if (empty($locationId)) {
                throw new \RuntimeException('Square location ID missing');
            }

            $paymentRequest = new CreatePaymentRequest([
                'idempotencyKey' => Str::uuid()->toString(),
                'sourceId' => $paymentNonce,
                'amountMoney' => $amountMoney
            ]);
            $paymentRequest->setNote(substr($note, 0, 500));
            $paymentRequest->setCustomerId((string)$customerId);
            $paymentRequest->setAutocomplete(true);
            $paymentRequest->setLocationId($locationId);

            $paymentsApi = $this->squareClient->payments;
        $response = $paymentsApi->create($paymentRequest);

            if ($response->getErrors()) {
                throw new \RuntimeException('Square payment failed: ' . json_encode($response->getErrors()));
            }

            return $response;

        } catch (\Exception $e) {
            Log::error('Donation Payment Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            throw $e;
        }
    }

    private function saveCustomerCard($userId, $paymentNonce)
    {
        // Identical to BookingController's implementation
        try {
            $user = DB::table('mstuser')->where('userId', $userId)->first();
            if (!$user) {
                throw new \Exception("User not found");
            }

            $customerRequest = new CreateCustomerRequest([
                'reference_id' => (string)$userId,
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
                'exp_date' => $cardResponse->getCard()->getExpMonth().'/'.$cardResponse->getCard()->getExpYear(),
                'created_at' => now()
            ]);

            return true;

        } catch (\Exception $e) {
            Log::error("Card save failed", [
                'user_id' => $userId,
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }

    // Get ad details
    public function getAd($adId)
    {
        $ad = DB::table('donation')
            ->where('donationId', $adId)
            ->where('isActive', true)
            ->first();

        if (!$ad) {
            return response()->json(['error' => 'Ad not found'], 404);
        }

        $donations = DB::table('donation_transactions')
            ->where('donationId', $adId)
            ->sum('amount');

        return response()->json([
            'ad' => $ad,
            'total_raised' => $donations,
            'progress' => $ad->amount > 0 ? ($donations / $ad->amount) * 100 : 0
        ]);
    }
}
