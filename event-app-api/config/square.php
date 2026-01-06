<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Square Platform Application Credentials
    |--------------------------------------------------------------------------
    |
    | These credentials are for the Square Platform Application (not personal access token).
    | Used for OAuth flow to connect organizer Square accounts.
    |
    */
    'application_id' => env('SQUARE_APPLICATION_ID', ''),
    'application_secret' => env('SQUARE_APPLICATION_SECRET', ''),

    /*
    |--------------------------------------------------------------------------
    | Square Access Token (Legacy - for non-OAuth payments)
    |--------------------------------------------------------------------------
    |
    | This token is used to authenticate with the Square API. You can generate
    | a personal access token or use the sandbox one for testing. Set this in
    | your .env file as SQUARE_ACCESS_TOKEN.
    |
    */
    'access_token' => env('SQUARE_ACCESS_TOKEN', '') ?: env('SQUARE_TOKEN', ''),

    /*
    |--------------------------------------------------------------------------
    | Square Environment
    |--------------------------------------------------------------------------
    |
    | This should be either 'sandbox' or 'production' depending on your setup.
    |
    */
    'environment' => env('SQUARE_ENVIRONMENT', 'sandbox'),

    /*
    |--------------------------------------------------------------------------
    | Square Location ID (Legacy)
    |--------------------------------------------------------------------------
    |
    | This is your Square location ID, required for processing payments.
    | With OAuth, each organizer will have their own location ID.
    |
    */
    'location_id' => env('SQUARE_LOCATION_ID', ''),

    /*
    |--------------------------------------------------------------------------
    | Square OAuth Configuration
    |--------------------------------------------------------------------------
    |
    | OAuth redirect URL and scopes for platform application.
    |
    */
    'oauth' => [
        'redirect_url' => env('SQUARE_OAUTH_REDIRECT_URL', env('APP_URL') . '/square/callback'),
        'scopes' => [
            'MERCHANT_PROFILE_READ',
            'PAYMENTS_WRITE',
            'PAYMENTS_READ',
            'ORDERS_WRITE',
            'ORDERS_READ',
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | App Owner Commission Rate
    |--------------------------------------------------------------------------
    |
    | The percentage commission that the app owner takes from each ticket sale.
    | This is a percentage of the subtotal (before service/processing fees).
    | Example: 10.0 means 10% commission
    |
    */
    'commission_rate' => env('SQUARE_COMMISSION_RATE', 10.0), // 10% default

    /*
    |--------------------------------------------------------------------------
    | Minimum Commission Amount
    |--------------------------------------------------------------------------
    |
    | Minimum commission amount in USD. If calculated commission is less than
    | this, use this minimum instead.
    |
    */
    'minimum_commission' => env('SQUARE_MINIMUM_COMMISSION', 0.50), // $0.50 minimum

];

