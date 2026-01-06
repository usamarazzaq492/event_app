<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

class TicketCheckInController extends Controller
{
    /**
     * Verify and check-in a ticket using QR code data
     * This prevents screenshot sharing by marking tickets as used
     */
    public function checkIn(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'qr_data' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid QR code data',
                'errors' => $validator->errors()
            ], 400);
        }

        try {
            $qrData = json_decode($request->qr_data, true);

            if (!$qrData || !isset($qrData['booking_id'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid QR code format - missing booking_id'
                ], 400);
            }

            $bookingId = $qrData['booking_id'];
            $ticketNum = $qrData['ticket_num'] ?? null;
            $providedHash = $qrData['hash'] ?? null;
            $eventId = $qrData['event_id'] ?? null;
            $userId = $qrData['user_id'] ?? null;

            // Check if this is a new format ticket (with hash) or old format (without hash)
            $isNewFormat = ($ticketNum !== null && $providedHash !== null);

            if ($isNewFormat) {
                // New format: Verify hash for security
                $expectedHash = hash_hmac('sha256', "{$bookingId}|{$ticketNum}", env('TICKET_SECRET'));
                if (!hash_equals($expectedHash, $providedHash)) {
                    Log::warning('QR Code Hash Mismatch', [
                        'booking_id' => $bookingId,
                        'ticket_num' => $ticketNum,
                        'received_hash' => $providedHash,
                        'expected_hash' => $expectedHash,
                    ]);
                    return response()->json([
                        'success' => false,
                        'message' => 'Invalid QR code - security verification failed'
                    ], 403);
                }

                // Find the ticket using new format
                // Ticket number format: EVT-XXX-{bookingId}-{ticketNum}
                $ticket = DB::table('tickets')
                    ->where('bookingId', $bookingId)
                    ->where('qrCodeData', 'LIKE', "%\"booking_id\":{$bookingId},\"ticket_num\":{$ticketNum}%")
                    ->first();
            } else {
                // Old format: No hash verification, but still check if ticket exists
                // This is for backward compatibility with old tickets
                Log::info('Old format QR code detected (no hash)', ['booking_id' => $bookingId]);

                // Verify booking exists first
                $booking = DB::table('booking')
                    ->where('bookingId', $bookingId)
                    ->where('status', 'confirmed')
                    ->first();

                if (!$booking) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Booking not found or not confirmed'
                    ], 404);
                }

                // Find any ticket for this booking (old format doesn't have ticket_num in QR)
                $ticket = DB::table('tickets')
                    ->where('bookingId', $bookingId)
                    ->first();

                // If no ticket exists, create one on-the-fly for old bookings
                if (!$ticket) {
                    Log::info('Creating ticket record for old booking', ['booking_id' => $bookingId]);

                    // Generate a ticket number for old format
                    $ticketNumber = "EVT-OLD-{$bookingId}-001";

                    // Create ticket record with old format QR data
                    $ticketId = DB::table('tickets')->insertGetId([
                        'bookingId' => $bookingId,
                        'ticketNumber' => $ticketNumber,
                        'qrCodeData' => $request->qr_data, // Use the scanned QR data
                        'checked_in' => false,
                        'created_at' => now()
                    ]);

                    // Fetch the created ticket
                    $ticket = DB::table('tickets')->where('ticketId', $ticketId)->first();
                }
            }

            if (!$ticket) {
                return response()->json([
                    'success' => false,
                    'message' => 'Ticket not found'
                ], 404);
            }

            // Check if already checked in
            if ($ticket->checked_in ?? false) {
                $checkedInAt = $ticket->checked_in_at ?? 'Unknown';
                return response()->json([
                    'success' => false,
                    'message' => 'This ticket has already been checked in',
                    'checked_in_at' => $checkedInAt,
                    'warning' => 'This ticket may have been shared. Please verify the attendee\'s identity.'
                ], 409);
            }

            // Get booking info (already verified for old format, but need it for new format too)
            if (!isset($booking)) {
                $booking = DB::table('booking')
                    ->where('bookingId', $bookingId)
                    ->where('status', 'confirmed')
                    ->first();

                if (!$booking) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Booking not found or not confirmed'
                    ], 404);
                }
            }

            // Verify event exists and is active
            if ($eventId) {
                $event = DB::table('events')
                    ->where('eventId', $eventId)
                    ->where('isActive', 1)
                    ->first();

                if (!$event) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Event not found or inactive'
                    ], 404);
                }
            }

            // Get the user who is checking in (organizer)
            $checkedInBy = null;
            if (Auth::check()) {
                $checkedInBy = Auth::id();
            } elseif ($request->hasHeader('Authorization')) {
                // Try to get user from token if provided
                try {
                    $user = $request->user();
                    $checkedInBy = $user?->userId ?? null;
                } catch (\Exception $e) {
                    // If auth fails, continue without checked_in_by
                }
            }

            // Check in the ticket
            $updated = DB::table('tickets')
                ->where('ticketId', $ticket->ticketId)
                ->update([
                    'checked_in' => true,
                    'checked_in_at' => now(),
                    'checked_in_by' => $checkedInBy,
                ]);

            Log::info('Ticket checked in', [
                'ticket_id' => $ticket->ticketId,
                'booking_id' => $bookingId,
                'checked_in_by' => $checkedInBy,
                'updated' => $updated
            ]);

            // Get user info for response
            $user = null;
            if ($userId) {
                $user = DB::table('mstuser')
                    ->where('userId', $userId)
                    ->select('name', 'email')
                    ->first();
            }

            return response()->json([
                'success' => true,
                'message' => 'Ticket checked in successfully',
                'data' => [
                    'ticket_number' => $ticket->ticketNumber,
                    'checked_in_at' => now()->toDateTimeString(),
                    'user_name' => $user->name ?? 'Unknown',
                    'user_email' => $user->email ?? null,
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Ticket check-in error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error processing check-in: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Verify a ticket without checking it in (for preview)
     */
    public function verify(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'qr_data' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid QR code data',
                'errors' => $validator->errors()
            ], 400);
        }

        try {
            $qrData = json_decode($request->qr_data, true);

            if (!$qrData || !isset($qrData['booking_id']) || !isset($qrData['ticket_num']) || !isset($qrData['hash'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid QR code format'
                ], 400);
            }

            $bookingId = $qrData['booking_id'];
            $ticketNum = $qrData['ticket_num'];
            $providedHash = $qrData['hash'];

            // Verify hash
            $expectedHash = hash_hmac('sha256', "{$bookingId}|{$ticketNum}", env('TICKET_SECRET'));
            if (!hash_equals($expectedHash, $providedHash)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid QR code - security verification failed'
                ], 403);
            }

            // Find the ticket
            // Ticket number format: EVT-XXX-{bookingId}-{ticketNum}
            // We use LIKE to match the pattern since the middle part is random
            $ticket = DB::table('tickets')
                ->where('bookingId', $bookingId)
                ->where('ticketNumber', 'LIKE', "EVT-%-{$bookingId}-" . str_pad($ticketNum, 3, '0', STR_PAD_LEFT))
                ->first();

            if (!$ticket) {
                return response()->json([
                    'success' => false,
                    'message' => 'Ticket not found'
                ], 404);
            }

            // Get booking and event info
            $booking = DB::table('booking')
                ->join('events', 'booking.eventId', '=', 'events.eventId')
                ->where('booking.bookingId', $bookingId)
                ->select('booking.*', 'events.eventTitle', 'events.startDate', 'events.startTime')
                ->first();

            $user = null;
            if ($booking && $booking->userId) {
                $user = DB::table('mstuser')
                    ->where('userId', $booking->userId)
                    ->select('name', 'email')
                    ->first();
            }

            return response()->json([
                'success' => true,
                'message' => 'Ticket verified',
                'data' => [
                    'ticket_number' => $ticket->ticketNumber,
                    'checked_in' => $ticket->checked_in ?? false,
                    'checked_in_at' => $ticket->checked_in_at ?? null,
                    'event_title' => $booking->eventTitle ?? null,
                    'event_date' => $booking->startDate ?? null,
                    'event_time' => $booking->startTime ?? null,
                    'user_name' => $user->name ?? null,
                    'user_email' => $user->email ?? null,
                ]
            ]);

        } catch (\Exception $e) {
            Log::error('Ticket verification error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error verifying ticket: ' . $e->getMessage()
            ], 500);
        }
    }
}

