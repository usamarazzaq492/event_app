<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Http\Controllers\Web\HomeController;
use App\Http\Controllers\Web\EventWebController;
use App\Http\Controllers\Web\AuthController;
use App\Http\Controllers\Web\AdsController;
use App\Http\Controllers\Web\TicketController;
use App\Http\Controllers\Web\PromotionWebController;
use App\Http\Controllers\Web\PaymentQrWebController;

// Home and static pages
Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/about', [HomeController::class, 'about'])->name('about');
Route::get('/contact', [HomeController::class, 'contact'])->name('contact');
Route::post('/contact', [HomeController::class, 'contactSubmit'])->name('contact.submit');
Route::get('/faq', [HomeController::class, 'faq'])->name('faq');
Route::get('/terms', [HomeController::class, 'terms'])->name('terms');
Route::get('/privacy', [HomeController::class, 'privacy'])->name('privacy');

// Events routes
Route::get('/events', [EventWebController::class, 'index'])->name('events.index');
Route::get('/events/search', [EventWebController::class, 'search'])->name('events.search');
Route::get('/events/create', [EventWebController::class, 'create'])->name('events.create')->middleware('auth');
Route::post('/events', [EventWebController::class, 'store'])->name('events.store')->middleware('auth');
Route::get('/events/{id}', [EventWebController::class, 'show'])->name('events.show');
Route::get('/events/{id}/edit', [EventWebController::class, 'edit'])->name('events.edit')->middleware('auth');
Route::put('/events/{id}', [EventWebController::class, 'update'])->name('events.update')->middleware('auth');
Route::post('/events/{id}/book', [EventWebController::class, 'book'])->name('events.book')->middleware('auth');

// Promotion routes
Route::get('/promotion/select-event', [PromotionWebController::class, 'selectEvent'])->name('promotion.select-event')->middleware('auth');
Route::get('/events/{id}/promote', [PromotionWebController::class, 'show'])->name('promotion.show')->middleware('auth');
Route::post('/events/{id}/promote/process', [PromotionWebController::class, 'processPayment'])->name('promotion.process')->middleware('auth');

// Payment QR Code routes
Route::get('/events/{id}/payment-qr', [PaymentQrWebController::class, 'showGenerate'])->name('payment-qr.show')->middleware('auth');
Route::post('/events/{id}/payment-qr/generate', [PaymentQrWebController::class, 'generate'])->name('payment-qr.generate')->middleware('auth');
Route::post('/events/{id}/payment-qr/{qrId}/deactivate', [PaymentQrWebController::class, 'deactivate'])->name('payment-qr.deactivate')->middleware('auth');
Route::get('/pay', [PaymentQrWebController::class, 'showPayment'])->name('payment-qr.payment');

// Ads routes
Route::get('/ads', [AdsController::class, 'index'])->name('ads.index');
Route::get('/ads/create', [AdsController::class, 'create'])->name('ads.create')->middleware('auth');
Route::post('/ads', [AdsController::class, 'store'])->name('ads.store')->middleware('auth');
Route::get('/ads/{id}', [AdsController::class, 'show'])->name('ads.show');
Route::get('/ads/{id}/edit', [AdsController::class, 'edit'])->name('ads.edit')->middleware('auth');
Route::put('/ads/{id}', [AdsController::class, 'update'])->name('ads.update')->middleware('auth');
Route::delete('/ads/{id}', [AdsController::class, 'destroy'])->name('ads.destroy')->middleware('auth');
Route::post('/ads/{id}/donate', [AdsController::class, 'donate'])->name('ads.donate')->middleware('auth');

// Authentication routes
Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
Route::post('/register', [AuthController::class, 'register']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// Email verification routes
Route::get('/verify-email', [AuthController::class, 'showVerifyEmail'])->name('verify.email');
Route::post('/verify-email', [AuthController::class, 'verifyEmail'])->name('verify.email.submit');

// Password reset routes (OTP-based)
Route::get('/forgot-password', [AuthController::class, 'showForgotPassword'])->name('password.request');
Route::post('/forgot-password', [AuthController::class, 'sendResetLink'])->name('password.email');
Route::get('/verify-otp', [AuthController::class, 'showVerifyOTP'])->name('password.verify-otp');
Route::post('/verify-otp', [AuthController::class, 'verifyPasswordOTP'])->name('password.verify-otp.submit');
Route::get('/reset-password', [AuthController::class, 'showResetPassword'])->name('password.reset');
Route::post('/reset-password', [AuthController::class, 'resetPassword'])->name('password.update');

// Profile routes
Route::get('/profile', [AuthController::class, 'profile'])->name('profile')->middleware('auth');
Route::post('/profile', [AuthController::class, 'updateProfile'])->name('profile.update')->middleware('auth');
Route::post('/profile/password', [AuthController::class, 'changePassword'])->name('profile.password')->middleware('auth');

// Ticket routes
Route::get('/ticket/{bookingId}', [TicketController::class, 'downloadTicket'])->name('ticket.download')->middleware('auth');

// Square Payment Routes
Route::get('/square-payment/{eventId}', [App\Http\Controllers\Web\SquarePaymentController::class, 'showEventPayment'])->name('square.payment');
Route::post('/square-payment/{eventId}', [App\Http\Controllers\Web\SquarePaymentController::class, 'processEventPayment'])->name('square.payment.process');

Route::get('/square-donate/{transactionId}', [App\Http\Controllers\Web\SquarePaymentController::class, 'showDonationForm'])->name('square.donate');
Route::post('/square-donate/{transactionId}', [App\Http\Controllers\Web\SquarePaymentController::class, 'processDonation'])->name('square.donate.process');

// Square Connect OAuth Routes
Route::middleware('auth')->group(function () {
    Route::get('/square/connect', [App\Http\Controllers\SquareConnectController::class, 'initiateOAuth'])->name('square.connect');
    Route::post('/square/disconnect', [App\Http\Controllers\SquareConnectController::class, 'disconnect'])->name('square.disconnect');
});

// OAuth callback must be accessible without auth (Square redirects here)
// Security is handled via state token validation in the controller
Route::get('/square/callback', [App\Http\Controllers\SquareConnectController::class, 'handleCallback'])->name('square.callback');

// Debug route for testing CSRF
Route::get('/test-csrf', function () {
    return response()->json(['csrf_token' => csrf_token()]);
});

// Debug route for testing user authentication
Route::get('/test-auth', function () {
    $user = DB::table('users')->where('email', 'test@example.com')->first();
    if ($user) {
        $passwordCheck = Hash::check('password123', $user->password);
        return response()->json([
            'user_exists' => true,
            'user_id' => $user->id,
            'user_email' => $user->email,
            'password_valid' => $passwordCheck,
            'password_hash' => $user->password
        ]);
    }
    return response()->json(['user_exists' => false]);
});

// Debug route for testing login
Route::post('/test-login', function (Request $request) {
    $credentials = $request->only('email', 'password');
    $user = DB::table('users')->where('email', $credentials['email'])->first();

    if ($user && Hash::check($credentials['password'], $user->password)) {
        Auth::loginUsingId($user->id);
        return response()->json(['success' => true, 'message' => 'Login successful']);
    }

    return response()->json(['success' => false, 'message' => 'Invalid credentials']);
});

// Test route for toast notifications
Route::get('/test-toast', function () {
    return redirect()->route('home')->with('success', '🎉 Test toast notification! This is a beautiful animated success message!');
});

