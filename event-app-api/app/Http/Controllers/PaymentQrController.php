<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Carbon\Carbon;

class PaymentQrController extends Controller
{
    /**
     * Generate a payment QR code for an event (organizer only)
     */
    public function generatePaymentQr(Request $request, $eventId)
    {
        $user = $request->user();

        // Validate event exists and user is organizer
        $event = DB::table('events')
            ->where('eventId', $eventId)
            ->where('userId', $user->userId)
            ->where('isActive', 1)
            ->first();

        if (!$event) {
            return response()->json([
                'success' => false,
                'message' => 'Event not found or you are not the organizer'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'ticket_type' => 'required|in:vip,general',
            'expires_at' => 'nullable|date|after:now',
            'max_uses' => 'nullable|integer|min:1|max:10000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 400);
        }

        // Generate unique token
        $token = Str::random(32);

        // Ensure token is unique
        while (DB::table('payment_qr_codes')->where('token', $token)->exists()) {
            $token = Str::random(32);
        }

        // Generate deep link URL
        $deepLink = $this->generateDeepLink($eventId, $request->ticket_type, $token);

        // Calculate price based on ticket type
        $typeMultipliers = [
            'vip' => 1.5,
            'general' => 1.0
        ];
        $basePrice = $event->eventPrice ?? 0;
        $adjustedPrice = $basePrice * $typeMultipliers[$request->ticket_type];

        // Insert QR code record
        $qrId = DB::table('payment_qr_codes')->insertGetId([
            'eventId' => $eventId,
            'userId' => $user->userId,
            'token' => $token,
            'ticketType' => $request->ticket_type,
            'qrCodeData' => $deepLink,
            'expiresAt' => $request->expires_at ? Carbon::parse($request->expires_at) : null,
            'maxUses' => $request->max_uses,
            'currentUses' => 0,
            'isActive' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $qrCode = DB::table('payment_qr_codes')
            ->where('qrId', $qrId)
            ->first();

        return response()->json([
            'success' => true,
            'message' => 'Payment QR code generated successfully',
            'data' => [
                'qrId' => $qrCode->qrId,
                'eventId' => $qrCode->eventId,
                'ticketType' => $qrCode->ticketType,
                'qrCodeData' => $qrCode->qrCodeData,
                'token' => $qrCode->token,
                'price' => $adjustedPrice,
                'basePrice' => $basePrice,
                'expiresAt' => $qrCode->expiresAt,
                'maxUses' => $qrCode->maxUses,
                'currentUses' => $qrCode->currentUses,
                'createdAt' => $qrCode->created_at,
            ]
        ]);
    }

    /**
     * Validate a scanned payment QR code (public endpoint)
     */
    public function validatePaymentQr(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string|size:32',
            'event_id' => 'required|integer',
            'ticket_type' => 'required|in:vip,general',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid QR code format',
                'errors' => $validator->errors()
            ], 400);
        }

        $qrCode = DB::table('payment_qr_codes')
            ->where('token', $request->token)
            ->where('eventId', $request->event_id)
            ->where('ticketType', $request->ticket_type)
            ->where('isActive', true)
            ->first();

        if (!$qrCode) {
            return response()->json([
                'success' => false,
                'message' => 'QR code not found or inactive'
            ], 404);
        }

        // Check expiry
        if ($qrCode->expiresAt && Carbon::parse($qrCode->expiresAt)->isPast()) {
            return response()->json([
                'success' => false,
                'message' => 'QR code has expired'
            ], 400);
        }

        // Check usage limit
        if ($qrCode->maxUses && $qrCode->currentUses >= $qrCode->maxUses) {
            return response()->json([
                'success' => false,
                'message' => 'QR code has reached maximum usage limit'
            ], 400);
        }

        // Get event details
        $event = DB::table('events')
            ->where('eventId', $qrCode->eventId)
            ->where('isActive', 1)
            ->first();

        if (!$event) {
            return response()->json([
                'success' => false,
                'message' => 'Event not found or inactive'
            ], 404);
        }

        // Calculate price
        $typeMultipliers = [
            'vip' => 1.5,
            'general' => 1.0
        ];
        $basePrice = $event->eventPrice ?? 0;
        $adjustedPrice = $basePrice * $typeMultipliers[$qrCode->ticketType];

        return response()->json([
            'success' => true,
            'message' => 'QR code is valid',
            'data' => [
                'eventId' => $event->eventId,
                'eventTitle' => $event->eventTitle,
                'ticketType' => $qrCode->ticketType,
                'basePrice' => $basePrice,
                'price' => $adjustedPrice,
                'eventImage' => $event->eventImage,
                'startDate' => $event->startDate,
                'startTime' => $event->startTime,
                'address' => $event->address,
                'city' => $event->city,
            ]
        ]);
    }

    /**
     * Get all QR codes for an event (organizer only)
     */
    public function getEventQrCodes(Request $request, $eventId)
    {
        $user = $request->user();

        // Verify user is organizer
        $event = DB::table('events')
            ->where('eventId', $eventId)
            ->where('userId', $user->userId)
            ->first();

        if (!$event) {
            return response()->json([
                'success' => false,
                'message' => 'Event not found or you are not the organizer'
            ], 404);
        }

        $qrCodes = DB::table('payment_qr_codes')
            ->where('eventId', $eventId)
            ->where('isActive', true)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $qrCodes
        ]);
    }

    /**
     * Deactivate a QR code (organizer only)
     */
    public function deactivateQrCode(Request $request, $qrId)
    {
        $user = $request->user();

        $qrCode = DB::table('payment_qr_codes')
            ->where('qrId', $qrId)
            ->first();

        if (!$qrCode) {
            return response()->json([
                'success' => false,
                'message' => 'QR code not found'
            ], 404);
        }

        // Verify user is organizer of the event
        $event = DB::table('events')
            ->where('eventId', $qrCode->eventId)
            ->where('userId', $user->userId)
            ->first();

        if (!$event) {
            return response()->json([
                'success' => false,
                'message' => 'You are not authorized to deactivate this QR code'
            ], 403);
        }

        DB::table('payment_qr_codes')
            ->where('qrId', $qrId)
            ->update([
                'isActive' => false,
                'updated_at' => now()
            ]);

        return response()->json([
            'success' => true,
            'message' => 'QR code deactivated successfully'
        ]);
    }

    /**
     * Generate deep link URL for QR code
     */
    private function generateDeepLink($eventId, $ticketType, $token)
    {
        // App deep link
        $appDeepLink = "eventgo://pay?eventId=$eventId&ticketType=$ticketType&token=$token";

        // Web fallback URL
        $webUrl = "https://eventgo-live.com/pay?eventId=$eventId&ticketType=$ticketType&token=$token";

        // Return both, app can choose which to use
        return json_encode([
            'app' => $appDeepLink,
            'web' => $webUrl
        ]);
    }
}

