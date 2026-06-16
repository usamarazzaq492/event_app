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
use App\Http\Controllers\PaymentQrController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\ModerationController;
use App\Http\Controllers\TicketTierController;

Route::prefix('v1')->group(function () {
    // 🔐 Auth
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/auth/apple', [AuthController::class, 'signInWithApple']);
    Route::post('/verify-email', [AuthController::class, 'verifyEmail']);
    Route::post('/resend-verification', [AuthController::class, 'resendVerificationCode']);

    // 🔑 Forgot Password
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/verify-password-otp', [AuthController::class, 'verifyPasswordOtp']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);

    // 💰 Promotion Packages (Public - accessible without authentication)
    Route::get('/promotion/packages', [PromotionController::class, 'getPackages']);

    // 📱 Payment QR Code Validation (Public - for scanning)
    Route::post('/payment-qr/validate', [PaymentQrController::class, 'validatePaymentQr']);

    // 📢 Ads / Promoted events (Public - list and view without login)
    Route::prefix('ads')->group(function () {
        Route::get('/', [DonationController::class, 'listAds']);
        Route::get('/{adId}', [DonationController::class, 'getAd']);
    });

    // 📅 Events list (Public - browse without login, same as Explore/Discover)
    Route::get('/events', [EventController::class, 'index']);
    Route::post('/events', [EventController::class, 'index']);
    Route::get('/events/{id}', [EventController::class, 'show'])->where('id', '[0-9]+');  // Public event detail (guests can view)

    // 🎫 Ticket Tiers (Public - read tiers without login)
    Route::get('/events/{id}/tiers', [TicketTierController::class, 'index'])->where('id', '[0-9]+');

    // 👤 Public user/organizer profile (guests can view)
    Route::get('/user/{id}', [UserController::class, 'viewPublicProfile']);
    // 👥 Public user search (guests can search organizers by name)
    Route::get('/users/search', [UserController::class, 'searchUsers']);

    // 🔒 Authenticated User Actions
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/fetchusers', [UserController::class, 'index']);
        // 👤 User Profile
        Route::get('/user', [UserController::class, 'showProfile']);
        Route::post('/user/update', [UserController::class, 'updateProfile']);
        Route::delete('/user/delete', [UserController::class, 'deleteAccount']);

        // 🤝 Follow System
        Route::post('/user/{id}/follow', [FollowController::class, 'followUser']);
        Route::post('/user/{id}/unfollow', [FollowController::class, 'unfollowUser']);
        Route::get('/user/{id}/followers', [FollowController::class, 'getFollowers']);
        Route::get('/user/{id}/following', [FollowController::class, 'getFollowing']);

        // 🛡️ Moderation (Guideline 1.2 - User-Generated Content)
        Route::post('/report/event/{id}', [ModerationController::class, 'reportEvent']);
        Route::post('/report/user/{id}', [ModerationController::class, 'reportUser']);
        Route::post('/user/{id}/block', [ModerationController::class, 'blockUser']);
        Route::post('/user/{id}/unblock', [ModerationController::class, 'unblockUser']);
        Route::get('/moderation/blocked-ids', [ModerationController::class, 'getBlockedUserIds']);

        // 📅 Events (list and GET /events/{id} are public above - no duplicate)
        Route::prefix('events')->group(function () {
            Route::post('/add', [EventController::class, 'store']);             // Create event
            Route::get('/my', [EventController::class, 'myEvents']);         // List my events
            Route::get('/timeline', [EventController::class, 'getTimelineEvents']); // Timeline: events from followed users
            Route::post('/{id}', [EventController::class, 'update']);         // Update event
            Route::delete('/{id}', [EventController::class, 'destroy']);     // Delete event

            // 🎫 Booking
            Route::post('/{id}/book', [BookingController::class, 'bookEvent']);
            Route::get('/bookings/history', [BookingController::class, 'getBookingHistory']);

            // 🎫 Ticket Tier Management (organizer only)
            Route::post('/{id}/tiers', [TicketTierController::class, 'store']);
            Route::put('/{id}/tiers/{tierId}', [TicketTierController::class, 'update']);
            Route::delete('/{id}/tiers/{tierId}', [TicketTierController::class, 'destroy']);

            // 💰 Promotion
            Route::post('/{id}/promote', [PromotionController::class, 'purchasePromotion']);
            Route::get('/{id}/promotion-status', [PromotionController::class, 'getPromotionStatus']);

            // 📱 Payment QR Codes
            Route::post('/{id}/payment-qr/generate', [PaymentQrController::class, 'generatePaymentQr']);
            Route::get('/{id}/payment-qr/list', [PaymentQrController::class, 'getEventQrCodes']);
        });

        // Invites
        Route::prefix('invite')->group(function () {
        Route::post('/{id}', [InviteController::class, 'inviteUsers']);
        Route::get('/get-invites', [InviteController::class, 'getReceivedInvites']);
        Route::post('/{inviteId}/respond', [InviteController::class, 'respond']);
        });

        // Notifications (unified)
        Route::get('/notifications', [NotificationController::class, 'getAllNotifications']);

        // Ads (create & donate require auth)
        Route::prefix('ads')->group(function () {
            Route::post('/add', [DonationController::class, 'createAd']);
            Route::post('/{adId}/donate', [DonationController::class, 'donate']);
        });

        // 📱 Payment QR Code Management
        Route::post('/payment-qr/{qrId}/deactivate', [PaymentQrController::class, 'deactivateQrCode']);

        // 🔗 Square Connect
        Route::prefix('square')->group(function () {
            Route::get('/status', [App\Http\Controllers\SquareConnectController::class, 'checkStatus']);
            Route::get('/connect', [App\Http\Controllers\SquareConnectController::class, 'initiateOAuth']);
            Route::post('/disconnect', [App\Http\Controllers\SquareConnectController::class, 'disconnect']);
        });

        // 🎫 Ticket Check-in (for organizers)
        Route::prefix('tickets')->group(function () {
            Route::post('/checkin', [App\Http\Controllers\TicketCheckInController::class, 'checkIn']);
            Route::post('/verify', [App\Http\Controllers\TicketCheckInController::class, 'verify']);
        });
    });
});




