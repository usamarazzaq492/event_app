<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Http\Controllers\PromotionController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class PromotionWebController extends Controller
{
    private $squareApiUrl;
    private $accessToken;
    private $applicationId;
    private $locationId;

    public function __construct()
    {
        // Use config() with fallbacks for better compatibility with cached configurations
        $this->accessToken = config('square.access_token', '') ?: env('SQUARE_ACCESS_TOKEN', '') ?: env('SQUARE_TOKEN', '');
        $this->applicationId = config('square.application_id', '') ?: env('SQUARE_APPLICATION_ID', '');
        $this->locationId = config('square.location_id', '') ?: env('SQUARE_LOCATION_ID', '');

        // Set API URL based on environment
        $environment = config('square.environment', '') ?: env('SQUARE_ENVIRONMENT', 'sandbox');
        $this->squareApiUrl = $environment === 'production'
            ? 'https://connect.squareup.com/v2'
            : 'https://connect.squareupsandbox.com/v2';
    }

    /**
     * Show page to select event to promote (matches app flow)
     */
    public function selectEvent()
    {
        if (!Auth::check()) {
            return redirect()->guest(route('login'))->with('error', 'Please login to promote your event.');
        }

        // Get user's active upcoming events
        $events = DB::table('events')
            ->where('userId', Auth::user()->userId)
            ->where('isActive', 1)
            ->where('startDate', '>=', now())
            ->orderBy('startDate', 'asc')
            ->get();

        return view('promotion.select-event', compact('events'));
    }

    /**
     * Show promotion purchase page
     */
    public function show($eventId)
    {
        $event = Event::findOrFail((int)$eventId);

        // Check if user is authenticated and owns the event
        if (!Auth::check()) {
            return redirect()->guest(route('login'))->with('error', 'Please login to promote your event.');
        }

        if ($event->userId != Auth::user()->userId) {
            abort(403, 'You do not have permission to promote this event.');
        }

        // Check if promotion is already active - prevent promoting again
        $isPromoted = $event->isPromoted == 1;
        $isActive = false;

        if ($isPromoted && $event->promotionEndDate) {
            $endDate = \Carbon\Carbon::parse($event->promotionEndDate);
            $isActive = $endDate->isFuture();
        }

        if ($isActive) {
            return redirect()->route('events.show', $eventId)
                ->with('info', 'Your event is already promoted. You can promote again after the current promotion expires.');
        }

        // Single boost package: $35 for 10 days
        $packages = [
            'boost' => [
                'price' => PromotionController::BOOST_PRICE,
                'durationDays' => PromotionController::BOOST_DURATION_DAYS,
                'name' => 'Event Go-Live Boost',
                'description' => 'Boost your event for 10 days to increase visibility',
            ],
        ];

        // Check current promotion status
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

        return view('promotion.purchase', compact('event', 'packages', 'isPromoted', 'isActive', 'daysRemaining'));
    }

    /**
     * Process promotion payment
     */
    public function processPayment(Request $request, $eventId)
    {
        // Ensure JSON response for AJAX requests
        if ($request->expectsJson() || $request->ajax()) {
            $request->headers->set('Accept', 'application/json');
        }

        try {
            $request->validate([
                'package' => 'required|in:boost',
                'sourceId' => 'required|string',
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        }

        $event = Event::findOrFail((int)$eventId);

        // Verify ownership
        if (!Auth::check() || $event->userId != Auth::user()->userId) {
            return response()->json([
                'success' => false,
                'error' => 'You do not have permission to promote this event.'
            ], 403);
        }

        // Single boost option: $35 for 10 days
        $package = 'boost'; // Always 'boost' for new system
        $amount = PromotionController::BOOST_PRICE;

        try {
            // Process payment with Square
            $paymentResult = $this->processSquarePayment([
                'sourceId' => $request->sourceId,
                'amount' => (int)round($amount * 100), // Convert to cents
                'currency' => 'USD',
                'idempotencyKey' => Str::uuid()->toString(),
            ]);

            if ($paymentResult['success']) {
                // Payment successful, now create promotion record directly
                $durationDays = PromotionController::BOOST_DURATION_DAYS;

                // Calculate promotion dates (store in UTC for consistency across timezones)
                $startDate = now()->utc();
                $endDate = now()->utc()->addDays($durationDays);

                // Create promotion transaction record
                $transactionId = DB::table('promotion_transactions')->insertGetId([
                    'eventId' => $eventId,
                    'userId' => Auth::user()->userId,
                    'package' => $package,
                    'amount' => $amount,
                    'duration_days' => $durationDays,
                    'squarePaymentId' => $paymentResult['paymentId'],
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
            } else {
                return response()->json([
                    'success' => false,
                    'error' => $paymentResult['error']
                ], 400);
            }
        } catch (\Exception $e) {
            Log::error('Promotion payment processing failed', [
                'error' => $e->getMessage(),
                'eventId' => $eventId,
                'userId' => Auth::id(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Payment processing failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Process Square payment
     */
    private function processSquarePayment($paymentData)
    {
        try {
            // Validate required credentials - check at runtime to handle config cache issues
            $accessToken = $this->accessToken ?: config('square.access_token', '') ?: env('SQUARE_ACCESS_TOKEN', '') ?: env('SQUARE_TOKEN', '');
            $locationId = $this->locationId ?: config('square.location_id', '') ?: env('SQUARE_LOCATION_ID', '');

            if (empty($accessToken)) {
                Log::error('Square access token not configured', [
                    'config_square_access_token' => config('square.access_token'),
                    'env_square_access_token' => env('SQUARE_ACCESS_TOKEN'),
                    'env_square_token' => env('SQUARE_TOKEN'),
                ]);
                return [
                    'success' => false,
                    'error' => 'Square access token not configured. Please set SQUARE_ACCESS_TOKEN or SQUARE_TOKEN in your .env file.'
                ];
            }

            if (empty($locationId)) {
                Log::error('Square location ID not configured', [
                    'config_square_location_id' => config('square.location_id'),
                    'env_square_location_id' => env('SQUARE_LOCATION_ID'),
                ]);
                return [
                    'success' => false,
                    'error' => 'Square location ID not configured. Please set SQUARE_LOCATION_ID in your .env file.'
                ];
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
                'Square-Version' => '2023-10-18'
            ])->post($this->squareApiUrl . '/payments', [
                'source_id' => $paymentData['sourceId'],
                'amount_money' => [
                    'amount' => $paymentData['amount'],
                    'currency' => $paymentData['currency']
                ],
                'idempotency_key' => $paymentData['idempotencyKey'],
                'location_id' => $locationId
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
}

