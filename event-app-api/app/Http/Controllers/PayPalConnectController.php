<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class PayPalConnectController extends Controller
{
    /**
     * Initiate PayPal Partner Onboarding (OAuth) flow
     */
    public function initiateOAuth(Request $request)
    {
        $user = $request->user();

        // Check if user is an organizer, create if doesn't exist
        $organizer = DB::table('organizers')
            ->where('userId', $user->userId)
            ->first();

        if (!$organizer) {
            $organizerId = DB::table('organizers')->insertGetId([
                'userId' => $user->userId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $organizer = (object)['organizerId' => $organizerId, 'userId' => $user->userId];
        }

        $state = Str::random(40);
        session([
            'paypal_oauth_state' => $state,
            'paypal_oauth_organizer_id' => $organizer->organizerId
        ]);

        $clientId = config('paypal.client_id');
        $redirectUri = env('APP_URL') . '/paypal/callback';
        $environment = config('paypal.environment', 'sandbox');

        if (empty($clientId)) {
            if ($request->expectsJson()) {
                return response()->json([
                    'error' => 'PayPal Client ID is not configured'
                ], 500);
            }
            return redirect()->back()->with('error', 'PayPal Client ID is not configured.');
        }

        // PayPal Identity/Partner onboarding URL
        // In a real integration, you would call the Partner Referrals API to generate an Action URL.
        // For a generic OAuth-like approach to just get consent:
        $oauthBaseUrl = $environment === 'production'
            ? 'https://www.paypal.com/connect'
            : 'https://www.sandbox.paypal.com/connect';

        $oauthUrl = $oauthBaseUrl . '?' . http_build_query([
            'flowEntry' => 'static',
            'client_id' => $clientId,
            'response_type' => 'code',
            'scope' => 'openid profile email https://uri.paypal.com/services/paypalattributes',
            'state' => $state,
            'redirect_uri' => $redirectUri,
        ]);

        if ($request->expectsJson()) {
            return response()->json([
                'oauth_url' => $oauthUrl
            ]);
        }

        return redirect($oauthUrl);
    }

    /**
     * Handle PayPal OAuth callback
     */
    public function handleCallback(Request $request)
    {
        $state = $request->get('state');
        if ($state !== session('paypal_oauth_state')) {
            Log::error('PayPal OAuth state mismatch');
            if ($request->expectsJson()) {
                return response()->json(['error' => 'Invalid OAuth state'], 400);
            }
            return redirect()->route('profile')->with('error', 'Invalid OAuth state. Please try again.');
        }

        $code = $request->get('code');
        if (!$code) {
            return redirect()->route('profile')->with('error', 'Authorization code not received');
        }

        $organizerId = session('paypal_oauth_organizer_id');

        try {
            $environment = config('paypal.environment');
            $tokenUrl = $environment === 'production'
                ? 'https://api-m.paypal.com/v1/oauth2/token'
                : 'https://api-m.sandbox.paypal.com/v1/oauth2/token';

            $response = Http::withBasicAuth(config('paypal.client_id'), config('paypal.secret'))
                ->asForm()
                ->post($tokenUrl, [
                    'grant_type' => 'authorization_code',
                    'code' => $code,
                ]);

            if (!$response->successful()) {
                Log::error('PayPal token exchange failed', ['error' => $response->json()]);
                return redirect()->route('profile')->with('error', 'Failed to connect PayPal account.');
            }

            $tokenData = $response->json();
            $accessToken = $tokenData['access_token'];

            // Get user info to get merchant details/email
            $userInfoUrl = $environment === 'production'
                ? 'https://api-m.paypal.com/v1/identity/oauth2/userinfo'
                : 'https://api-m.sandbox.paypal.com/v1/identity/oauth2/userinfo';

            $userResponse = Http::withHeaders(['Authorization' => 'Bearer ' . $accessToken])->get($userInfoUrl);
            $userInfo = $userResponse->json();
            $paypalEmail = $userInfo['emails'][0]['value'] ?? null;
            $paypalMerchantId = $userInfo['payer_id'] ?? null;

            DB::table('organizer_paypal_accounts')->updateOrInsert(
                ['organizerId' => $organizerId],
                [
                    'paypalMerchantId' => $paypalMerchantId,
                    'paypalEmail' => $paypalEmail,
                    'accessToken' => $accessToken,
                    'refreshToken' => $tokenData['refresh_token'] ?? null,
                    'status' => 'connected',
                    'connectedAt' => now(),
                    'environment' => $environment,
                    'updated_at' => now(),
                    'created_at' => DB::raw('COALESCE(created_at, NOW())'),
                ]
            );

            session()->forget(['paypal_oauth_state', 'paypal_oauth_organizer_id']);

            if ($request->expectsJson()) {
                return response()->json([
                    'success' => true,
                    'message' => 'PayPal account connected successfully',
                    'paypal_email' => $paypalEmail
                ]);
            }

            return redirect()->route('profile')->with('success', 'PayPal account connected successfully!');

        } catch (\Exception $e) {
            Log::error('PayPal OAuth error', ['error' => $e->getMessage()]);
            return redirect()->route('profile')->with('error', 'An error occurred during connection.');
        }
    }

    /**
     * Disconnect PayPal account
     */
    public function disconnect(Request $request)
    {
        $user = $request->user();
        $organizer = DB::table('organizers')->where('userId', $user->userId)->first();

        if ($organizer) {
            DB::table('organizer_paypal_accounts')
                ->where('organizerId', $organizer->organizerId)
                ->update([
                    'status' => 'disconnected',
                    'disconnectedAt' => now(),
                    'updated_at' => now()
                ]);
        }

        if ($request->expectsJson()) {
            return response()->json(['success' => true, 'message' => 'PayPal account disconnected']);
        }

        return redirect()->back()->with('success', 'PayPal account disconnected');
    }

    /**
     * Check PayPal connection status (API endpoint)
     */
    public function checkStatus(Request $request)
    {
        $user = $request->user();
        $organizer = DB::table('organizers')->where('userId', $user->userId)->first();
        
        $paypalAccount = null;
        if ($organizer) {
            $paypalAccount = DB::table('organizer_paypal_accounts')
                ->where('organizerId', $organizer->organizerId)
                ->where('status', 'connected')
                ->first();
        }

        return response()->json([
            'connected' => $paypalAccount ? true : false,
            'merchant_email' => $paypalAccount->paypalEmail ?? null,
            'connected_at' => $paypalAccount->connectedAt ?? null,
        ]);
    }
}
