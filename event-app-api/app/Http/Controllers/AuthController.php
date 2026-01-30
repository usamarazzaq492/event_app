<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:mstuser,email',
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
            // Mobile app can also send `terms` if you want explicit consent from app registration
        ], [
            'password.regex' => 'Password must include uppercase, lowercase, number, and special character.',
            'password.confirmed' => 'Password confirmation does not match.',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'verificationCode' => rand(1000, 9999),
            'emailVerified' => 0,
            'terms_accepted_at' => now(),
            'terms_version_accepted' => 'v1', // keep in sync with web version
        ]);

    $to = $user->email;
$subject = "Email Verification";

// Basic HTML content (still clean and styled)
$message = '
<html>
  <body style="font-family: Arial, sans-serif; background-color: #f9f9f9; padding: 20px;">
    <div style="background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); max-width: 500px; margin: auto;">
      <h2 style="color: #333;">Email Verification</h2>
      <p>Thank you for signing up with <strong>EventGo</strong>.</p>
      <p>Your verification code is:</p>
      <p style="font-size: 22px; font-weight: bold; color: #2a7ae2;">' . htmlspecialchars($user->verificationCode) . '</p>
      <p>If you didn\'t request this, you can ignore this email.</p>
      <p style="margin-top: 30px; font-size: 12px; color: #aaa;">&copy; ' . date('Y') . ' EventGo Live</p>
    </div>
  </body>
</html>
';

// Minimal headers required for HTML email
$headers = "MIME-Version: 1.0\r\n";
$headers .= "Content-type: text/html; charset=iso-8859-1\r\n";

// You can omit the -f parameter if not working properly
$mailSent = mail($to, $subject, $message, $headers);

    if ($mailSent) {
        return response()->json([
            'message' => 'User registered successfully. Please verify your email.',
            'user' => [
                'userId' => $user->userId,
                'name' => $user->name,
                'email' => $user->email,
            ],
        ], 201);
    } else {
        // Optional: rollback user creation if email failed
        $user->delete();

        return response()->json([
            'message' => 'Registration failed. Could not send verification email.',
        ], 500);
    }
}


    public function resendVerificationCode(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:mstuser,email',
        ]);

        $user = User::where('email', $request->email)->first();

        if ($user->emailVerified == 1) {
            return response()->json(['message' => 'Email already verified.'], 200);
        }

        // Generate new verification code
        $user->verificationCode = rand(1000, 9999);
        $user->save();

        // Send verification email
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

        $mailSent = mail($to, $subject, $message, $headers);

        if ($mailSent) {
            return response()->json([
                'message' => 'Verification code has been resent to your email.',
            ], 200);
        } else {
            return response()->json([
                'message' => 'Failed to send verification email. Please try again.',
            ], 500);
        }
    }

    public function verifyEmail(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:mstuser,email',
            'verificationCode' => 'required|integer',
        ]);

        $user = User::where('email', $request->email)->first();

        if ($user->emailVerified == 1) {
            return response()->json(['message' => 'Email already verified.'], 200);
        }

        if ($user->verificationCode != $request->verificationCode) {
            return response()->json(['message' => 'Invalid verification code.'], 400);
        }

        $user->emailVerified = 1;
        $user->save();

        // Now create token after verification
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Email verified successfully.',
            'token' => $token,
        ], 200);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'remember_me' => 'nullable|in:true,false', // Accept "true" or "false" strings
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $tokenResult = $user->createToken('auth_token');

        // Access the token model properly:
        $token = $tokenResult->accessToken;

        if ($request->has('remember_me') && $request->remember_me) {
            $token->expires_at = now()->addDays(30);
        } else {
            $token->expires_at = now()->addHours(2);
        }
        $token->save();

        return response()->json([
    'message' => 'Login successful',
    'token' => $tokenResult->plainTextToken,
    'expires_at' => $token->expires_at->toDateTimeString(),
    'user' => $user->makeHidden(['password', 'verificationCode']), // This will return all fields except hidden ones
]);
    }

    // 1. Send OTP for password reset
    public function forgotPassword(Request $request)
{
    $request->validate([
        'email' => 'required|email|exists:mstuser,email',
    ]);

    $user = User::where('email', $request->email)->first();

    // Generate and save 4-digit OTP
    $otp = rand(1000, 9999);
    $user->verificationCode = $otp;
    $user->save();

    // Email details
    $to = $user->email;
    $subject = "Password Reset OTP - EventGo Live";

    // HTML Email content (simple and styled)
    $message = '
    <html>
      <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;">
        <div style="background-color: #fff; padding: 20px; border-radius: 8px; max-width: 600px; margin: auto; box-shadow: 0 0 10px rgba(0,0,0,0.05);">
          <h2 style="color: #333;">Reset Your Password</h2>
          <p>Hello,</p>
          <p>You requested to reset your password for <strong>EventGo</strong>. Please use the OTP below to continue:</p>
          <p style="font-size: 24px; font-weight: bold; color: #2a7ae2;">' . htmlspecialchars($otp) . '</p>
          <p>This OTP is valid for a short time. Do not share it with anyone.</p>
          <p>If you did not request this, you can safely ignore this email.</p>
          <p style="margin-top: 30px; font-size: 12px; color: #888;">&copy; ' . date('Y') . ' EventGo Live. All rights reserved.</p>
        </div>
      </body>
    </html>
    ';

    // Minimal headers to allow HTML email
    $headers = "MIME-Version: 1.0\r\n";
    $headers .= "Content-type: text/html; charset=iso-8859-1\r\n";

    // Send the email
    $mailSent = mail($to, $subject, $message, $headers);

    // Optional check if email failed
    if (!$mailSent) {
        return response()->json(['message' => 'Failed to send OTP. Try again.'], 500);
    }

    return response()->json(['message' => 'OTP sent to your email.']);
}


    // 2. Verify OTP
    public function verifyPasswordOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:mstuser,email',
            'otp' => 'required|integer',
        ]);

        $user = User::where('email', $request->email)->first();

        if ($user->verificationCode != $request->otp) {
            return response()->json(['message' => 'Invalid OTP.'], 400);
        }

        return response()->json(['message' => 'OTP verified successfully.']);
    }

    // 3. Reset Password
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:mstuser,email',
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

        $user = User::where('email', $request->email)->first();
        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json(['message' => 'Password reset successful.']);
    }

    public function logout(Request $request)
    {
        // Revoke the token that was used to authenticate the current request
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully'
        ]);
    }
}
