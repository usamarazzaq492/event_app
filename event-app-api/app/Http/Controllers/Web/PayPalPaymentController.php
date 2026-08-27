<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PayPalPaymentController extends Controller
{
    public function showDonationForm($transactionId)
    {
        $transaction = DB::table('donation_transactions')
            ->join('donation', 'donation_transactions.donationId', '=', 'donation.donationId')
            ->select('donation_transactions.*', 'donation.title', 'donation.amount as goalAmount')
            ->where('donation_transactions.id', $transactionId)
            ->where('donation_transactions.userId', Auth::id())
            ->first();

        if (!$transaction) {
            abort(404, 'Transaction not found');
        }

        return view('paypal-donate', compact('transaction'));
    }

    public function processDonation(Request $request, $transactionId)
    {
        $request->validate([
            'paypalOrderId' => 'required|string',
            'amount' => 'required|numeric|min:1',
        ]);

        $transaction = DB::table('donation_transactions')
            ->where('id', $transactionId)
            ->where('userId', Auth::id())
            ->first();

        if (!$transaction) {
            return response()->json(['error' => 'Transaction not found'], 404);
        }

        try {
            DB::table('donation_transactions')
                ->where('id', $transactionId)
                ->update([
                    'squarePaymentId' => $request->paypalOrderId,
                    'updated_at' => now(),
                ]);

            return response()->json([
                'success' => true,
                'message' => 'Donation processed successfully!',
                'paymentId' => $request->paypalOrderId
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Payment processing failed: ' . $e->getMessage()
            ], 500);
        }
    }

    public function showEventPayment($eventId, Request $request)
    {
        $event = DB::table('events')->where('eventId', (int)$eventId)->first();

        if (!$event) {
            abort(404, 'Event not found');
        }

        $isPromotion = $request->get('is_promotion', false) == true || $request->get('is_promotion') === 'true';
        $package = $request->get('package', 'boost');

        if ($isPromotion) {
            $promotionPrice = 35.00;
            $processingFee = ($promotionPrice * 3.49 / 100) + 0.49; // PayPal typical processing fee
            $totalAmount = $promotionPrice + $processingFee;

            return view('paypal-payment', [
                'eventName' => $event->eventTitle ?? 'Event',
                'amount' => '$' . number_format($totalAmount, 2),
                'eventId' => (int)$eventId,
                'isPromotion' => true,
                'package' => $package,
                'promotionPrice' => $promotionPrice,
                'processingFee' => $processingFee,
                'totalAmount' => $totalAmount,
                'clientId' => config('paypal.client_id'),
                'merchantId' => null, // No split payment for promotion (goes to platform)
                'commission' => 0,
            ]);
        }

        // Regular booking payment
        $quantity = $request->get('quantity', session('quantity', 1));
        $ticketType = $request->get('ticket_type', session('ticket_type', 'general'));

        if ($request->has('subtotal')) {
            $subtotal = (float) $request->get('subtotal');
            $ticketPrice = $quantity > 0 ? $subtotal / $quantity : $subtotal;
        } else {
            $ticketPrice = $ticketType === 'vip'
                ? ($event->vipPrice ?? $event->eventPrice ?? 0)
                : ($event->eventPrice ?? 0);
            $subtotal = $ticketPrice * $quantity;
        }

        $processingFee = ($subtotal * 3.49 / 100) + 0.49; // PayPal typical fee
        $totalAmount = $subtotal + $processingFee;

        // Check if organizer has PayPal connected for split payments
        $organizerPaypal = DB::table('organizer_paypal_accounts')
            ->join('organizers', 'organizer_paypal_accounts.organizerId', '=', 'organizers.organizerId')
            ->where('organizers.userId', $event->userId)
            ->where('organizer_paypal_accounts.status', 'connected')
            ->select('organizer_paypal_accounts.paypalMerchantId')
            ->first();

        $merchantId = $organizerPaypal ? $organizerPaypal->paypalMerchantId : null;
        
        $commissionRate = config('paypal.commission_rate', 10.0);
        $commission = $subtotal * ($commissionRate / 100);

        return view('paypal-payment', [
            'eventName' => $event->eventTitle ?? 'Event',
            'amount' => '$' . number_format($totalAmount, 2),
            'eventId' => (int)$eventId,
            'quantity' => $quantity,
            'ticketType' => $ticketType,
            'ticketPrice' => $ticketPrice,
            'subtotal' => $subtotal,
            'serviceFee' => 0,
            'processingFee' => $processingFee,
            'totalAmount' => $totalAmount,
            'isPromotion' => false,
            'clientId' => config('paypal.client_id'),
            'merchantId' => $merchantId,
            'commission' => $commission,
        ]);
    }

    public function processEventPayment(Request $request, $eventId)
    {
        $request->validate([
            'paypalOrderId' => 'required|string',
            'amount' => 'required|numeric|min:1',
        ]);

        $event = DB::table('events')->where('eventId', (int)$eventId)->first();

        if (!$event) {
            return response()->json(['error' => 'Event not found'], 404);
        }

        try {
            $quantity = $request->get('quantity', session('quantity', 1));
            $ticketType = $request->get('ticket_type', session('ticket_type', 'general'));

            $ticketPrice = $ticketType === 'vip'
                ? ($event->vipPrice ?? $event->eventPrice ?? 0)
                : ($event->eventPrice ?? 0);

            $subtotal = $ticketPrice * $quantity;
            $processingFee = ($subtotal * 3.49 / 100) + 0.49;
            $totalAmount = $subtotal + $processingFee;

            $commissionRate = config('paypal.commission_rate', 10.0);
            $commission = $subtotal * ($commissionRate / 100);
            $organizerPayout = ($subtotal - $commission) + $processingFee;

            $organizerPaypal = DB::table('organizer_paypal_accounts')
                ->join('organizers', 'organizer_paypal_accounts.organizerId', '=', 'organizers.organizerId')
                ->where('organizers.userId', $event->userId)
                ->where('organizer_paypal_accounts.status', 'connected')
                ->select('organizer_paypal_accounts.paypalMerchantId')
                ->first();

            $bookingId = DB::table('booking')->insertGetId([
                'eventId' => (int)$eventId,
                'userId' => (int)Auth::id(),
                'ticketType' => $ticketType,
                'quantity' => $quantity,
                'basePrice' => $ticketPrice,
                'subtotal' => $subtotal,
                'serviceFee' => 0,
                'processingFee' => $processingFee,
                'totalAmount' => $totalAmount,
                'squarePaymentId' => $request->paypalOrderId,
                'appOwnerCommission' => $commission,
                'organizerPayout' => $organizerPayout,
                'organizerSquareMerchantId' => $organizerPaypal->paypalMerchantId ?? null,
                'paymentType' => $organizerPaypal ? 'split' : 'direct',
                'splitPaymentDetails' => json_encode([
                    'commission_rate' => $commissionRate,
                    'commission_amount' => $commission,
                    'organizer_payout_amount' => $organizerPayout,
                    'organizer_has_paypal' => $organizerPaypal ? true : false,
                ]),
                'feeBreakdown' => json_encode([
                    'base_price' => $ticketPrice,
                    'ticket_type' => $ticketType,
                    'service_fee' => 0,
                    'processing_fee_percentage' => 3.49,
                    'fixed_processing_fee' => 0.49,
                    'commission_rate' => $commissionRate,
                    'commission_amount' => $commission,
                    'organizer_payout_amount' => $organizerPayout
                ]),
                'bookingDate' => now(),
                'status' => 'confirmed'
            ]);

            session()->forget(['quantity', 'ticket_type']);

            return response()->json([
                'success' => true,
                'message' => 'Payment processed successfully!',
                'bookingId' => $bookingId,
                'paymentId' => $request->paypalOrderId
            ]);

        } catch (\Exception $e) {
            Log::error('PayPal payment processing failed', [
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Payment processing failed: ' . $e->getMessage(),
            ], 500);
        }
    }
}
