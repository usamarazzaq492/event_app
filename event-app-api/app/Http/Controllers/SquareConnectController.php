<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Crypt;

class SquareConnectController extends Controller
{
    /**
     * Initiate Square OAuth flow
     */
    public function initiateOAuth(Request $request)
    {
        $user = $request->user();

        // Check if user is an organizer, create if doesn't exist
        $organizer = DB::table('organizers')
            ->where('userId', $user->userId)
            ->first();

        if (!$organizer) {
            // Auto-create organizer record for user
            $organizerId = DB::table('organizers')->insertGetId([
                'userId' => $user->userId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $organizer = (object)['organizerId' => $organizerId, 'userId' => $user->userId];
        }

        // Generate state token for security
        $state = Str::random(40);
        session([
            'square_oauth_state' => $state,
            'square_oauth_organizer_id' => $organizer->organizerId
        ]);

        // Build OAuth URL
        // Read from config (works even when cached)
        // If config cache is stale, it will be empty, so we'll handle that in validation
        $appId = config('square.application_id', '');
        $redirectUri = config('square.oauth.redirect_url', '');

        // If config is empty, try to read from .env directly (only works if config not cached)
        // On live server with cached config, env() won't work, so config must be rebuilt
        if (empty($appId) && !app()->configurationIsCached()) {
            $appId = env('SQUARE_APPLICATION_ID', '');
        }
        if (empty($redirectUri) && !app()->configurationIsCached()) {
            $redirectUri = env('SQUARE_OAUTH_REDIRECT_URL', env('APP_URL') . '/square/callback');
        }
        $scopesArray = config('square.oauth.scopes', []);
        $scopes = is_array($scopesArray) ? implode(' ', $scopesArray) : 'MERCHANT_PROFILE_READ PAYMENTS_WRITE PAYMENTS_READ ORDERS_WRITE ORDERS_READ';
        $environment = config('square.environment', 'sandbox');

        // Log config values for debugging (without sensitive data)
        Log::info('Square OAuth Config Check', [
            'has_app_id' => !empty($appId),
            'app_id_length' => $appId ? strlen($appId) : 0,
            'app_id_prefix' => $appId ? substr($appId, 0, 10) . '...' : 'empty',
            'has_redirect_uri' => !empty($redirectUri),
            'redirect_uri' => $redirectUri,
            'environment' => $environment,
            'scopes_count' => is_array($scopesArray) ? count($scopesArray) : 0,
        ]);

        // Validate required config
        if (empty($appId)) {
            // Try reading directly from .env as fallback
            $appId = env('SQUARE_APPLICATION_ID', '');

            Log::error('Square Application ID is not configured', [
                'config_value' => config('square.application_id'),
                'env_value' => env('SQUARE_APPLICATION_ID'),
                'app_id_after_fallback' => $appId,
                'config_cached' => app()->configurationIsCached(),
                'env_file_exists' => file_exists(base_path('.env')),
            ]);

            if (empty($appId)) {
                $errorMessage = app()->configurationIsCached()
                    ? 'Config cache is stale. Please run on server: php artisan config:clear && php artisan config:cache'
                    : 'Please set SQUARE_APPLICATION_ID in .env file';

                if ($request->expectsJson()) {
                    return response()->json([
                        'error' => 'Square Application ID is not configured',
                        'message' => $errorMessage,
                        'config_cached' => app()->configurationIsCached(),
                    ], 500);
                }
                return redirect()->back()->with('error', 'Square Application ID is not configured. ' . $errorMessage);
            }
        }

        if (empty($redirectUri)) {
            // Try reading directly from .env as fallback
            $redirectUri = env('SQUARE_OAUTH_REDIRECT_URL', env('APP_URL') . '/square/callback');

            Log::error('Square OAuth redirect URL is not configured', [
                'config_value' => config('square.oauth.redirect_url'),
                'env_value' => env('SQUARE_OAUTH_REDIRECT_URL'),
                'app_url' => env('APP_URL'),
                'redirect_uri_after_fallback' => $redirectUri,
            ]);

            if (empty($redirectUri)) {
                if ($request->expectsJson()) {
                    return response()->json([
                        'error' => 'Square OAuth redirect URL is not configured',
                        'message' => 'Please set SQUARE_OAUTH_REDIRECT_URL in .env file and run: php artisan config:clear'
                    ], 500);
                }
                return redirect()->back()->with('error', 'Square OAuth redirect URL is not configured. Please check your .env file and run: php artisan config:clear');
            }
        }

        // Use sandbox or production OAuth URL
        $oauthBaseUrl = $environment === 'production'
            ? 'https://squareup.com/oauth2/authorize'
            : 'https://squareupsandbox.com/oauth2/authorize';

        $oauthUrl = $oauthBaseUrl . '?' . http_build_query([
            'client_id' => $appId,
            'response_type' => 'code',
            'scope' => $scopes,
            'state' => $state,  // Square uses 'state' not 'session_id'
            'redirect_uri' => $redirectUri,
        ]);

        // Log OAuth URL for debugging (without sensitive data)
        Log::info('Square OAuth URL generated', [
            'environment' => $environment,
            'base_url' => $oauthBaseUrl,
            'has_app_id' => !empty($appId),
            'redirect_uri' => $redirectUri,
            'scopes_count' => count($scopesArray),
        ]);

        if ($request->expectsJson()) {
            return response()->json([
                'oauth_url' => $oauthUrl
            ]);
        }

        return redirect($oauthUrl);
    }

    /**
     * Handle Square OAuth callback
     */
    public function handleCallback(Request $request)
    {
        // Verify state token
        $state = $request->get('state');
        if ($state !== session('square_oauth_state')) {
            Log::error('Square OAuth state mismatch', [
                'received_state' => $state,
                'session_state' => session('square_oauth_state')
            ]);

            if ($request->expectsJson()) {
                return response()->json(['error' => 'Invalid OAuth state'], 400);
            }
            return redirect()->route('profile')->with('error', 'Invalid OAuth state. Please try again.');
        }

        $code = $request->get('code');
        $error = $request->get('error');

        if ($error) {
            Log::error('Square OAuth error', ['error' => $error]);
            if ($request->expectsJson()) {
                return response()->json(['error' => 'OAuth authorization failed: ' . $error], 400);
            }
            return redirect()->route('profile')->with('error', 'Square authorization failed: ' . $error);
        }

        if (!$code) {
            if ($request->expectsJson()) {
                return response()->json(['error' => 'Authorization code not received'], 400);
            }
            return redirect()->route('profile')->with('error', 'Authorization code not received');
        }

        $organizerId = session('square_oauth_organizer_id');

        try {
            // Exchange code for access token
            $environment = config('square.environment');
            $tokenUrl = $environment === 'production'
                ? 'https://connect.squareup.com/oauth2/token'
                : 'https://connect.squareupsandbox.com/oauth2/token';

            $tokenResponse = Http::asForm()->post($tokenUrl, [
                'client_id' => config('square.application_id'),
                'client_secret' => config('square.application_secret'),
                'code' => $code,
                'grant_type' => 'authorization_code',
            ]);

            if (!$tokenResponse->successful()) {
                $error = $tokenResponse->json();
                Log::error('Square token exchange failed', ['error' => $error]);

                if ($request->expectsJson()) {
                    return response()->json(['error' => 'Failed to exchange authorization code'], 500);
                }
                return redirect()->route('profile')->with('error', 'Failed to connect Square account. Please try again.');
            }

            $tokenData = $tokenResponse->json();
            $accessToken = $tokenData['access_token'];

            // Get merchant info
            $apiBaseUrl = $environment === 'production'
                ? 'https://connect.squareup.com/v2'
                : 'https://connect.squareupsandbox.com/v2';

            $merchantResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Square-Version' => '2023-10-18'
            ])->get($apiBaseUrl . '/merchants');

            if (!$merchantResponse->successful()) {
                Log::error('Failed to fetch merchant info', ['response' => $merchantResponse->json()]);
                if ($request->expectsJson()) {
                    return response()->json(['error' => 'Failed to fetch merchant information'], 500);
                }
                return redirect()->route('profile')->with('error', 'Failed to fetch Square account information.');
            }

            $merchantData = $merchantResponse->json();
            $merchant = $merchantData['merchant'][0] ?? null;

            // Get locations
            $locationsResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Square-Version' => '2023-10-18'
            ])->get($apiBaseUrl . '/locations');

            $locations = [];
            if ($locationsResponse->successful()) {
                $locationsData = $locationsResponse->json();
                $locations = $locationsData['locations'] ?? [];
            }

            // Store Square account info
            $now = now();
            $expiresAt = isset($tokenData['expires_at'])
                ? now()->addSeconds($tokenData['expires_at'])
                : now()->addDays(30);

            DB::table('organizer_square_accounts')->updateOrInsert(
                ['organizerId' => $organizerId],
                [
                    'squareMerchantId' => $merchant['id'] ?? null,
                    'squareLocationId' => $locations[0]['id'] ?? null,
                    'accessToken' => Crypt::encryptString($accessToken),
                    'refreshToken' => isset($tokenData['refresh_token'])
                        ? Crypt::encryptString($tokenData['refresh_token'])
                        : null,
                    'tokenExpiresAt' => $expiresAt,
                    'refreshTokenExpiresAt' => now()->addDays(45),
                    'status' => 'connected',
                    'connectedAt' => $now,
                    'merchantName' => $merchant['business_name'] ?? null,
                    'merchantEmail' => $merchant['business_email'] ?? null,
                    'environment' => $environment,
                    'updated_at' => $now,
                    'created_at' => DB::raw('COALESCE(created_at, NOW())'),
                ]
            );

            session()->forget(['square_oauth_state', 'square_oauth_organizer_id']);

            Log::info('Square account connected', [
                'organizer_id' => $organizerId,
                'merchant_id' => $merchant['id'] ?? null
            ]);

            if ($request->expectsJson()) {
                return response()->json([
                    'success' => true,
                    'message' => 'Square account connected successfully',
                    'merchant_name' => $merchant['business_name'] ?? null
                ]);
            }

            return redirect()->route('profile')->with('success', 'Square account connected successfully!');

        } catch (\Exception $e) {
            Log::error('Square OAuth callback error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            if ($request->expectsJson()) {
                return response()->json(['error' => 'An error occurred: ' . $e->getMessage()], 500);
            }
            return redirect()->route('profile')->with('error', 'An error occurred. Please try again.');
        }
    }

    /**
     * Disconnect Square account
     */
    public function disconnect(Request $request)
    {
        $user = $request->user();

        $organizer = DB::table('organizers')
            ->where('userId', $user->userId)
            ->first();

        if (!$organizer) {
            // Auto-create organizer record if doesn't exist
            $organizerId = DB::table('organizers')->insertGetId([
                'userId' => $user->userId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $organizer = (object)['organizerId' => $organizerId, 'userId' => $user->userId];
        }

        DB::table('organizer_square_accounts')
            ->where('organizerId', $organizer->organizerId)
            ->update([
                'status' => 'disconnected',
                'disconnectedAt' => now(),
                'updated_at' => now()
            ]);

        Log::info('Square account disconnected', ['organizer_id' => $organizer->organizerId]);

        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Square account disconnected'
            ]);
        }

        return redirect()->back()->with('success', 'Square account disconnected');
    }

    /**
     * Check Square connection status (API endpoint)
     */
    public function checkStatus(Request $request)
    {
        $user = $request->user();

        $organizer = DB::table('organizers')
            ->where('userId', $user->userId)
            ->first();

        if (!$organizer) {
            // Auto-create organizer record if doesn't exist
            $organizerId = DB::table('organizers')->insertGetId([
                'userId' => $user->userId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $organizer = (object)['organizerId' => $organizerId, 'userId' => $user->userId];
        }

        $squareAccount = DB::table('organizer_square_accounts')
            ->where('organizerId', $organizer->organizerId)
            ->where('status', 'connected')
            ->first();

        return response()->json([
            'connected' => $squareAccount ? true : false,
            'merchant_name' => $squareAccount->merchantName ?? null,
            'merchant_email' => $squareAccount->merchantEmail ?? null,
            'connected_at' => $squareAccount->connectedAt ?? null,
        ]);
    }
}

