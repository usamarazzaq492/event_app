<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class TicketController extends Controller
{
    public function downloadTicket($bookingId)
    {
        // Get booking details with event information
        $booking = DB::table('booking')
            ->join('events', 'booking.eventId', '=', 'events.eventId')
            ->join('mstuser', 'booking.userId', '=', 'mstuser.userId')
            ->where('booking.bookingId', $bookingId)
            ->where('booking.userId', Auth::id())
            ->select(
                'booking.*',
                'events.eventTitle',
                'events.startDate',
                'events.endDate',
                'events.startTime',
                'events.endTime',
                'events.city',
                'events.address',
                'events.eventImage',
                'mstuser.name as userName',
                'mstuser.email as userEmail'
            )
            ->first();

        if (!$booking) {
            abort(404, 'Booking not found');
        }

        // Get actual tickets from database (they have proper QR code data with hash)
        $ticketRecords = DB::table('tickets')
            ->where('bookingId', $bookingId)
            ->orderBy('ticketNumber')
            ->get();

        // If tickets don't exist in database, generate them (fallback for old bookings)
        if ($ticketRecords->isEmpty()) {
            // Generate QR code data (without hash for old tickets)
            $qrData = json_encode([
                'booking_id' => $booking->bookingId,
                'event_id' => $booking->eventId,
                'user_id' => $booking->userId,
                'ticket_type' => $booking->ticketType,
                'quantity' => $booking->quantity
            ]);

            // Generate tickets based on quantity
            $tickets = [];
            for ($i = 1; $i <= $booking->quantity; $i++) {
                $tickets[] = [
                    'ticket_number' => $booking->bookingId . '-' . str_pad($i, 3, '0', STR_PAD_LEFT),
                    'qr_data' => $qrData,
                    'ticket_type' => $booking->ticketType,
                    'price' => $booking->basePrice,
                    'total_amount' => $booking->totalAmount / $booking->quantity
                ];
            }
        } else {
            // Use actual tickets from database with proper QR code data
            $tickets = [];
            foreach ($ticketRecords as $ticketRecord) {
                $tickets[] = [
                    'ticket_number' => $ticketRecord->ticketNumber,
                    'qr_data' => $ticketRecord->qrCodeData, // This has the hash for check-in
                    'ticket_type' => $booking->ticketType,
                    'price' => $booking->basePrice,
                    'total_amount' => $booking->totalAmount / $booking->quantity
                ];
            }
        }

        // Return HTML that can be printed as PDF
        return response()
            ->view('tickets.pdf', compact('booking', 'tickets'))
            ->header('Content-Type', 'text/html')
            ->header('Content-Disposition', 'inline; filename="ticket-' . $bookingId . '.html"');
    }
}
