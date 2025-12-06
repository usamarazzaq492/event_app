<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\FollowController;
use App\Http\Controllers\EventController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\InviteController;
use App\Http\Controllers\DonationController;
use App\Http\Controllers\PromotionController;

Route::prefix('v1')->group(function () {
    // 🔐 Auth
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/verify-email', [AuthController::class, 'verifyEmail']);

    // 🔑 Forgot Password
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/verify-password-otp', [AuthController::class, 'verifyPasswordOtp']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);

    // 💰 Promotion Packages (Public - accessible without authentication)
    Route::get('/promotion/packages', [PromotionController::class, 'getPackages']);

    // 🔒 Authenticated User Actions
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/fetchusers', [UserController::class, 'index']);
        // 👤 User Profile
        Route::get('/user', [UserController::class, 'showProfile']);
        Route::post('/user/update', [UserController::class, 'updateProfile']);
        Route::get('/user/{id}', [UserController::class, 'viewPublicProfile']);

        // 🤝 Follow System
        Route::post('/user/{id}/follow', [FollowController::class, 'followUser']);
        Route::post('/user/{id}/unfollow', [FollowController::class, 'unfollowUser']);
        Route::get('/user/{id}/followers', [FollowController::class, 'getFollowers']);
        Route::get('/user/{id}/following', [FollowController::class, 'getFollowing']);

        // 📅 Events
        Route::prefix('events')->group(function () {
            Route::post('/add', [EventController::class, 'store']);             // Create event
            Route::post('/', [EventController::class, 'index']);              // List all events
            Route::get('/my', [EventController::class, 'myEvents']);         // List my events
            Route::get('/{id}', [EventController::class, 'show']);           // View single event
            Route::post('/{id}', [EventController::class, 'update']);         // Update event
            Route::delete('/{id}', [EventController::class, 'destroy']);     // Delete event

            // 🎟️ Booking
            Route::post('/{id}/book', [BookingController::class, 'bookEvent']);
            Route::get('/bookings/history', [BookingController::class, 'getBookingHistory']);

            // 💰 Promotion
            Route::post('/{id}/promote', [PromotionController::class, 'purchasePromotion']);
            Route::get('/{id}/promotion-status', [PromotionController::class, 'getPromotionStatus']);
        });

        // Invites
        Route::prefix('invite')->group(function () {
        Route::post('/{id}', [InviteController::class, 'inviteUsers']);
        Route::get('/get-invites', [InviteController::class, 'getReceivedInvites']);
        Route::post('/{inviteId}/respond', [InviteController::class, 'respond']);
        });
        
        // Ads
        Route::prefix('ads')->group(function () {
    Route::post('/add', [DonationController::class, 'createAd']);
    Route::get('/', [DonationController::class, 'listAds']);
    Route::get('/{adId}', [DonationController::class, 'getAd']);
    Route::post('/{adId}/donate', [DonationController::class, 'donate']);
});
    });
});




