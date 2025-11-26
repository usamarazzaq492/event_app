<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Square Access Token
    |--------------------------------------------------------------------------
    |
    | This token is used to authenticate with the Square API. You can generate
    | a personal access token or use the sandbox one for testing. Set this in
    | your .env file as SQUARE_ACCESS_TOKEN.
    |
    */
    'access_token' => env('SQUARE_ACCESS_TOKEN', ''),

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
    | Square Location ID
    |--------------------------------------------------------------------------
    |
    | This is your Square location ID, required for processing payments.
    |
    */
    'location_id' => env('SQUARE_LOCATION_ID', ''),

];
