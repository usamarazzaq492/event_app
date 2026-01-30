<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Storage;
use Illuminate\Auth\Events\PasswordReset;

class AuthController extends Controller
{
    public function showLogin(Request $request)
    {
        // Store redirect URL if provided
        if ($request->has('redirect')) {
            session(['url.intended' => $request->get('redirect')]);
        }

        return view('auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string|min:6',
            'remember' => 'nullable|boolean',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return back()->withErrors([
                'email' => 'Invalid credentials. Please check your email and password.',
            ])->onlyInput('email');
        }

        if ($user->emailVerified == 0) {
            // Resend verification code and redirect to verification page
            $this->sendVerificationEmail($user);
            return redirect()->route('verify.email')->with('info', '📧 Please verify your email before logging in. A new verification code has been sent to your email address.');
        }

        if ($user->isActive == 0) {
            return back()->withErrors([
                'email' => 'Your account is inactive. Please contact support.',
            ])->onlyInput('email');
        }

        Auth::login($user, $request->has('remember'));
        $request->session()->regenerate();

        // Get intended URL from session, request parameter, or default to home
        $redirectUrl = session()->pull('url.intended', $request->get('redirect', route('home')));

        // Validate and redirect
        if ($redirectUrl && $redirectUrl !== route('home')) {
            // Check if it's a full URL or relative path
            if (filter_var($redirectUrl, FILTER_VALIDATE_URL)) {
                // Full URL - validate it's from same domain (security)
                $parsedUrl = parse_url($redirectUrl);
                $appUrl = parse_url(config('app.url'));
                if (isset($parsedUrl['host']) && $parsedUrl['host'] === $appUrl['host']) {
                    return redirect($redirectUrl)->with('success', '👋 Welcome back! You have successfully logged in to EventGo!');
                }
            } else {
                // Relative path - safe to redirect
                return redirect($redirectUrl)->with('success', '👋 Welcome back! You have successfully logged in to EventGo!');
            }
        }

        return redirect(route('home'))->with('success', '👋 Welcome back! You have successfully logged in to EventGo!');
    }

    public function showRegister()
    {
        return view('auth.login');
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:mstuser,email',
            'password' => [
                'required',
                'string',
                'min:8',
                'regex:/[a-z]/',
                'regex:/[A-Z]/',
                'regex:/[0-9]/',
                'regex:/[@$!%*#?&]/',
                'confirmed',
            ],
            'phone' => 'nullable|string|max:20',
            'terms' => 'accepted', // require agreeing to disclaimer / terms
        ], [
            'password.regex' => 'Password must include uppercase, lowercase, number, and special character.',
            'password.confirmed' => 'Password confirmation does not match.',
            'terms.accepted' => 'You must agree to the terms and disclaimer to create an account.',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phoneNumber' => $request->phone,
            'isActive' => 1,
            'emailVerified' => 0,
            'verificationCode' => rand(1000, 9999),
            'terms_accepted_at' => now(),
            'terms_version_accepted' => 'v1', // adjust when you change your legal text
        ]);

        // Send verification email
        $this->sendVerificationEmail($user);

        return redirect()->route('verify.email')->with('success', '🎉 Registration successful! Please check your email for verification code to complete your account setup.');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect(route('home'))->with('success', '👋 You have been successfully logged out. See you next time!');
    }

    public function showVerifyEmail()
    {
        return view('auth.verify-email');
    }

    public function verifyEmail(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:mstuser,email',
            'verificationCode' => 'required|integer',
        ]);

        $user = User::where('email', $request->email)->first();

        if ($user->emailVerified == 1) {
            return back()->with('info', 'Email already verified. You can now login.');
        }

        if ($user->verificationCode != $request->verificationCode) {
            return back()->withErrors([
                'verificationCode' => 'Invalid verification code. Please check and try again.',
            ])->onlyInput('email', 'verificationCode');
        }

        $user->emailVerified = 1;
        $user->save();

        Auth::login($user);
        $request->session()->regenerate();

        return redirect()->route('home')->with('success', '🎉 Email verified successfully! Welcome to EventGo!');
    }

    private function sendVerificationEmail($user)
    {
        $to = $user->email;
        $subject = "Email Verification - EventGo";

        $message = '
        <html>
          <body style="font-family: Arial, sans-serif; background-color: #f9f9f9; padding: 20px;">
            <div style="background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); max-width: 500px; margin: auto;">
              <h2 style="color: #584CF4;">Email Verification</h2>
              <p>Thank you for signing up with <strong>EventGo</strong>.</p>
              <p>Your verification code is:</p>
              <p style="font-size: 22px; font-weight: bold; color: #ff9500; background: #f8f9ff; padding: 10px; border-radius: 5px; text-align: center;">' . htmlspecialchars($user->verificationCode) . '</p>
              <p>If you didn\'t request this, you can ignore this email.</p>
              <p style="margin-top: 30px; font-size: 12px; color: #aaa;">&copy; ' . date('Y') . ' EventGo Live</p>
            </div>
          </body>
        </html>
        ';

        $headers = "MIME-Version: 1.0\r\n";
        $headers .= "Content-type: text/html; charset=iso-8859-1\r\n";

        mail($to, $subject, $message, $headers);
    }

    public function showForgotPassword()
    {
        return view('auth.forgot-password');
    }

    public function sendResetLink(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:mstuser,email',
        ]);

        $user = User::where('email', $request->email)->first();

        // Generate and save 4-digit OTP
        $otp = rand(1000, 9999);
        $user->verificationCode = $otp;
        $user->save();

        // Send OTP email
        $this->sendPasswordResetOTP($user, $otp);

        return redirect()->route('password.verify-otp')->with('email', $request->email)->with('success', 'OTP sent to your email address. Please check your inbox.');
    }

    public function showVerifyOTP()
    {
        return view('auth.verify-otp');
    }

    public function verifyPasswordOTP(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:mstuser,email',
            'otp' => 'required|integer',
        ]);

        $user = User::where('email', $request->email)->first();

        if ($user->verificationCode != $request->otp) {
            return back()->withErrors([
                'otp' => 'Invalid OTP. Please check and try again.',
            ])->onlyInput('email', 'otp');
        }

        // Store email in session for password reset
        session(['password_reset_email' => $request->email]);

        return redirect()->route('password.reset')->with('success', 'OTP verified successfully! You can now set your new password.');
    }

    public function showResetPassword()
    {
        if (!session('password_reset_email')) {
            return redirect()->route('password.request');
        }

        return view('auth.reset-password');
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'password' => [
                'required',
                'string',
                'min:8',
                'regex:/[a-z]/',
                'regex:/[A-Z]/',
                'regex:/[0-9]/',
                'regex:/[@$!%*#?&]/',
                'confirmed',
            ],
        ], [
            'password.regex' => 'Password must include uppercase, lowercase, number, and special character.',
            'password.confirmed' => 'Password confirmation does not match.',
        ]);

        $email = session('password_reset_email');

        if (!$email) {
            return redirect()->route('password.request');
        }

        $user = User::where('email', $email)->first();
        $user->password = Hash::make($request->password);
        $user->save();

        // Clear session
        session()->forget('password_reset_email');

        return redirect()->route('login')->with('success', '🎉 Password reset successfully! You can now login with your new password.');
    }

    private function sendPasswordResetOTP($user, $otp)
    {
        $to = $user->email;
        $subject = "Password Reset OTP - EventGo";

        $message = '
        <html>
          <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
            <div style="background-color: #fff; padding: 20px; border-radius: 8px; max-width: 600px; margin: auto; box-shadow: 0 0 10px rgba(0,0,0,0.05);">
              <h2 style="color: #584CF4;">Reset Your Password</h2>
              <p>Hello,</p>
              <p>You requested to reset your password for <strong>EventGo</strong>. Please use the OTP below to continue:</p>
              <p style="font-size: 24px; font-weight: bold; color: #ff9500; background: #f8f9ff; padding: 15px; border-radius: 5px; text-align: center;">' . htmlspecialchars($otp) . '</p>
              <p>This OTP is valid for a short time. Do not share it with anyone.</p>
              <p>If you did not request this, you can safely ignore this email.</p>
              <p style="margin-top: 30px; font-size: 12px; color: #888;">&copy; ' . date('Y') . ' EventGo Live. All rights reserved.</p>
            </div>
          </body>
        </html>
        ';

        $headers = "MIME-Version: 1.0\r\n";
        $headers .= "Content-type: text/html; charset=iso-8859-1\r\n";

        mail($to, $subject, $message, $headers);
    }

    public function profile()
    {
        $user = Auth::user();

        // Fetch user's bookings with event details
        $bookings = DB::table('booking')
            ->join('events', 'booking.eventId', '=', 'events.eventId')
            ->where('booking.userId', $user->userId)
            ->select('booking.*', 'events.eventTitle', 'events.startDate', 'events.endDate', 'events.startTime', 'events.endTime', 'events.city', 'events.eventImage')
            ->orderBy('booking.bookingDate', 'desc')
            ->get();

        // Fetch user's created events
        $userEvents = DB::table('events')
            ->where('userId', $user->userId)
            ->orderBy('addDate', 'desc')
            ->get();

        // Fetch user's ads/donations
        $userAds = DB::table('donation')
            ->where('userId', $user->userId)
            ->orderBy('addDate', 'desc')
            ->get();

        // Check if user is an organizer, create if doesn't exist
        $organizer = DB::table('organizers')
            ->where('userId', $user->userId)
            ->first();

        // Auto-create organizer record if doesn't exist (so Square section always shows)
        if (!$organizer) {
            $organizerId = DB::table('organizers')->insertGetId([
                'userId' => $user->userId,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $organizer = (object)['organizerId' => $organizerId, 'userId' => $user->userId];
        }

        // Check for Square account connection
        $squareAccount = null;
        if ($organizer) {
            $squareAccount = DB::table('organizer_square_accounts')
                ->where('organizerId', $organizer->organizerId)
                ->where('status', 'connected')
                ->first();
        }

        return view('auth.profile', compact('user', 'bookings', 'userEvents', 'userAds', 'organizer', 'squareAccount'));
    }

    public function updateProfile(Request $request)
    {
        $user = Auth::user();

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:mstuser,email,' . $user->userId . ',userId',
            'phone' => 'nullable|string|max:20',
            'profile_image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'shortBio' => 'nullable|string|max:500',
            'interests' => 'nullable|array',
            'interests.*' => 'string|max:50',
        ]);

        $updateData = [
            'name' => $request->name,
            'email' => $request->email,
            'phoneNumber' => $request->phone,
            'shortBio' => $request->shortBio,
            'interests' => $request->interests ? json_encode($request->interests) : null,
            'updated_at' => now(),
        ];

        // Handle profile image upload
        if ($request->hasFile('profile_image')) {
            // Delete old image if exists
            if ($user->profileImageUrl) {
                Storage::disk('public')->delete($user->profileImageUrl);
            }

            $image = $request->file('profile_image')->store('profiles', 'public');
            $updateData['profileImageUrl'] = "/storage/public/$image";
        }

        DB::table('mstuser')
            ->where('userId', $user->userId)
            ->update($updateData);

        return back()->with('success', '🎉 Profile updated successfully!');
    }

    public function changePassword(Request $request)
    {
        $user = Auth::user();

        $request->validate([
            'current_password' => 'required|string',
            'new_password' => [
                'required',
                'string',
                'min:8',
                'regex:/[a-z]/',
                'regex:/[A-Z]/',
                'regex:/[0-9]/',
                'regex:/[@$!%*#?&]/',
                'confirmed',
            ],
        ], [
            'new_password.regex' => 'Password must include uppercase, lowercase, number, and special character.',
            'new_password.confirmed' => 'Password confirmation does not match.',
        ]);

        // Verify current password
        if (!Hash::check($request->current_password, $user->password)) {
            return back()->withErrors([
                'current_password' => 'Current password is incorrect.',
            ]);
        }

        // Update password
        DB::table('mstuser')
            ->where('userId', $user->userId)
            ->update([
                'password' => Hash::make($request->new_password),
                'updated_at' => now(),
            ]);

        return back()->with('success', '🔐 Password changed successfully!');
    }

    /**
     * Delete user account and all associated data
     *
     * @param Request $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function deleteAccount(Request $request)
    {
        $user = Auth::user();

        if (!$user) {
            return redirect()->route('login')->with('error', 'Unauthorized. Please log in again.');
        }

        $userId = $user->userId;

        // Use database transaction to ensure data consistency
        DB::beginTransaction();

        try {
            // 1. Delete user's profile image
            if ($user->profileImageUrl) {
                Storage::disk('public')->delete($user->profileImageUrl);
            }

            // 2. Delete user's events (and their associated data)
            $userEvents = DB::table('events')->where('userId', $userId)->get();
            foreach ($userEvents as $event) {
                // Delete event images if they exist
                if ($event->eventImage) {
                    Storage::disk('public')->delete($event->eventImage);
                }
            }
            DB::table('events')->where('userId', $userId)->delete();

            // 3. Delete user's bookings
            DB::table('booking')->where('userId', $userId)->delete();

            // 4. Delete user's follows (both as follower and followee)
            DB::table('follows')->where('follower_id', $userId)->delete();
            DB::table('follows')->where('followee_id', $userId)->delete();

            // 5. Delete user's event invites (both sent and received)
            DB::table('event_invites')->where('inviterId', $userId)->delete();
            DB::table('event_invites')->where('inviteeId', $userId)->delete();

            // 6. Delete user's ads/donations
            $userAds = DB::table('donation')->where('userId', $userId)->get();
            foreach ($userAds as $ad) {
                // Delete ad images if they exist
                if ($ad->imageUrl) {
                    Storage::disk('public')->delete($ad->imageUrl);
                }
            }
            DB::table('donation')->where('userId', $userId)->delete();
            
            // Delete donation transactions
            DB::table('donation_transactions')->where('userId', $userId)->delete();

            // 7. Delete user's payment QR codes
            DB::table('payment_qr_codes')->where('userId', $userId)->delete();

            // 8. Delete user's promotion transactions
            DB::table('promotion_transactions')->where('userId', $userId)->delete();

            // 9. Delete user's Square account connections (if any)
            $organizerIds = DB::table('organizers')->where('userId', $userId)->pluck('organizerId');
            if ($organizerIds->isNotEmpty()) {
                DB::table('organizer_square_accounts')
                    ->whereIn('organizerId', $organizerIds)
                    ->delete();
                DB::table('organizers')->where('userId', $userId)->delete();
            }

            // 10. Delete user's Sanctum tokens (if using API tokens)
            if (method_exists($user, 'tokens')) {
                $user->tokens()->delete();
            }

            // 11. Logout user before deleting account
            Auth::logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            // 12. Finally, delete the user
            DB::table('mstuser')->where('userId', $userId)->delete();

            DB::commit();

            return redirect()->route('home')->with('success', 'Your account has been permanently deleted. All your data has been removed.');

        } catch (\Exception $e) {
            DB::rollBack();
            
            return back()->with('error', 'Failed to delete account: ' . $e->getMessage());
        }
    }
}
