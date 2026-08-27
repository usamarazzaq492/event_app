<?php

return [
    /*
    |--------------------------------------------------------------------------
    | PayPal Application Credentials
    |--------------------------------------------------------------------------
    |
    | These credentials are for the PayPal REST API integration.
    | They are used for both direct checkouts and Partner Onboarding (split payments).
    |
    */

    'client_id' => env('PAYPAL_CLIENT_ID', ''),
    'secret' => env('PAYPAL_SECRET', ''),

    /*
    |--------------------------------------------------------------------------
    | PayPal Environment
    |--------------------------------------------------------------------------
    |
    | Determines which PayPal API environment to use.
    | Options: 'sandbox' or 'production'
    |
    */
    'environment' => env('PAYPAL_ENVIRONMENT', 'sandbox'),

    /*
    |--------------------------------------------------------------------------
    | Partner Onboarding & OAuth Settings
    |--------------------------------------------------------------------------
    |
    | Settings for PayPal Commerce Platform / Partner integrations.
    | Note: Partner integrations require a verified PayPal business account.
    |
    */
    'partner_id' => env('PAYPAL_PARTNER_ID', ''),
    'partner_client_id' => env('PAYPAL_PARTNER_CLIENT_ID', env('PAYPAL_CLIENT_ID', '')),
    'bn_code' => env('PAYPAL_BN_CODE', ''), // Build Notation Code (tracking ID)

    /*
    |--------------------------------------------------------------------------
    | Commission Settings
    |--------------------------------------------------------------------------
    |
    | The default percentage commission rate taken from ticket sales.
    | E.g., 10.0 means 10%.
    |
    */
    'commission_rate' => env('PAYPAL_COMMISSION_RATE', 10.0),
];
