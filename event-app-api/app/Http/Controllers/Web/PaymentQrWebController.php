<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class PaymentQrWebController extends Controller
{
    /**
     * Show the generate QR code page for an event
     */
    public function showGenerate($id)
    {
        $event = Event::findOrFail((int)$id);

        // Check if user is authenticated and is the organizer
        if (!Auth::check()) {
            return redirect()->guest(route('login'))->with('error', 'Please login to generate QR codes.');
        }

        if ((int)$event->userId !== (int)Auth::user()->userId) {
            return redirect()->route('events.show', $id)
                ->with('error', 'You are not authorized to generate QR codes for this event.');
        }

        // Get existing QR codes for this event
        $qrCodes = DB::table('payment_qr_codes')
            ->where('eventId', $event->eventId)
            ->where('isActive', true)
            ->orderBy('created_at', 'desc')
            ->get();

        return view('payment-qr.generate', compact('event', 'qrCodes'));
    }

    /**
     * Generate a new payment QR code
     */
    public function generate(Request $request, $id)
    {
        $request->validate([
            'ticket_type' => 'required|in:vip,general',
            'expires_at' => 'nullable|date|after:now',
            'max_uses' => 'nullable|integer|min:1|max:10000',
        ]);

        $event = Event::findOrFail((int)$id);

        // Verify user is organizer
        if (!Auth::check() || (int)$event->userId !== (int)Auth::user()->userId) {
            return back()->with('error', 'You are not authorized to generate QR codes for this event.');
        }

        // Generate unique token
        $token = Str::random(32);
        while (DB::table('payment_qr_codes')->where('token', $token)->exists()) {
            $token = Str::random(32);
        }

        // Generate deep link URL
        $appDeepLink = "eventgo://pay?eventId={$event->eventId}&ticketType={$request->ticket_type}&token={$token}";
        $webUrl = url("/pay?eventId={$event->eventId}&ticketType={$request->ticket_type}&token={$token}");

        $qrCodeData = json_encode([
            'app' => $appDeepLink,
            'web' => $webUrl
        ]);

        // Get the correct price based on ticket type
        $ticketPrice = $request->ticket_type === 'vip'
            ? ($event->vipPrice ?? $event->eventPrice ?? 0)
            : ($event->eventPrice ?? 0);

        // Insert QR code record
        $qrId = DB::table('payment_qr_codes')->insertGetId([
            'eventId' => $event->eventId,
            'userId' => Auth::user()->userId,
            'token' => $token,
            'ticketType' => $request->ticket_type,
            'qrCodeData' => $qrCodeData,
            'expiresAt' => $request->expires_at ? Carbon::parse($request->expires_at) : null,
            'maxUses' => $request->max_uses,
            'currentUses' => 0,
            'isActive' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Reload QR codes to show the new one
        return redirect()->route('payment-qr.show', $id)
            ->with('success', 'QR code generated successfully!')
            ->with('newQrId', $qrId);
    }

    /**
     * Deactivate a QR code
     */
    public function deactivate(Request $request, $id, $qrId)
    {
        $event = Event::findOrFail((int)$id);

        // Verify user is organizer
        if (!Auth::check() || (int)$event->userId !== (int)Auth::user()->userId) {
            return back()->with('error', 'You are not authorized.');
        }

        DB::table('payment_qr_codes')
            ->where('qrId', $qrId)
            ->where('eventId', $event->eventId)
            ->update([
                'isActive' => false,
                'updated_at' => now()
            ]);

        return back()->with('success', 'QR code deactivated successfully.');
    }

    /**
     * Show QR code payment page (for scanning/clicking QR codes)
     */
    public function showPayment(Request $request)
    {
        $eventId = $request->get('eventId');
        $ticketType = $request->get('ticketType', 'general');
        $token = $request->get('token');

        if (!$eventId || !$token) {
            return redirect()->route('home')->with('error', 'Invalid QR code link.');
        }

        // Validate QR code
        $qrCode = DB::table('payment_qr_codes')
            ->where('token', $token)
            ->where('eventId', $eventId)
            ->where('ticketType', $ticketType)
            ->where('isActive', true)
            ->first();

        if (!$qrCode) {
            return redirect()->route('home')->with('error', 'QR code not found or inactive.');
        }

        // Check expiry
        if ($qrCode->expiresAt && Carbon::parse($qrCode->expiresAt)->isPast()) {
            return redirect()->route('home')->with('error', 'QR code has expired.');
        }

        // Check usage limit
        if ($qrCode->maxUses && $qrCode->currentUses >= $qrCode->maxUses) {
            return redirect()->route('home')->with('error', 'QR code has reached maximum usage limit.');
        }

        // Get event details
        $event = Event::findOrFail($eventId);

        // Get the correct price based on ticket type
        $ticketPrice = $ticketType === 'vip'
            ? ($event->vipPrice ?? $event->eventPrice ?? 0)
            : ($event->eventPrice ?? 0);

        return view('payment-qr.payment', compact('event', 'ticketType', 'ticketPrice', 'token'));
    }
}

