@extends('layouts.app')

@section('title', 'Purchase Tickets - ' . $event->eventTitle)

@push('styles')
<style>
.qr-payment-banner {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 2rem;
    border-radius: 12px;
    margin-bottom: 2rem;
    text-align: center;
}

.qr-payment-banner i {
    font-size: 3rem;
    margin-bottom: 1rem;
}
</style>
@endpush

@push('scripts')
<script>
// Try to open app if user came from QR code scan
document.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const eventId = urlParams.get('eventId');
    const ticketType = urlParams.get('ticketType');
    const token = urlParams.get('token');

    if (eventId && ticketType && token) {
        // Try to open the app with deep link
        const appDeepLink = `eventgo://pay?eventId=${eventId}&ticketType=${ticketType}&token=${token}`;

        // Attempt to open app (will fail silently if app not installed)
        window.location.href = appDeepLink;

        // Fallback: if app doesn't open within 2 seconds, stay on web page
        setTimeout(function() {
            // User stays on web page to complete purchase
        }, 2000);
    }
});
</script>
@endpush

@section('content')
<section class="section contact__v2" id="contact">
    <div class="container py-4">
        <div class="row">
            <div class="col-lg-6 mx-auto">
                <div class="qr-payment-banner">
                    <i class="bi bi-qr-code-scan"></i>
                    <h4>Quick Payment via QR Code</h4>
                    <p class="mb-0">Complete your ticket purchase below</p>
                </div>

                <div class="feature-card">
                    <h5 class="mb-3">{{ $event->eventTitle }}</h5>

                    <div class="mb-3">
                        <strong>Ticket Type:</strong>
                        <span class="badge bg-primary">{{ ucfirst($ticketType) }}</span>
                    </div>

                    <div class="mb-3">
                        <strong>Price per ticket:</strong>
                        <span class="h5 text-primary">${{ number_format($ticketPrice, 2) }}</span>
                    </div>

                    @if(!Auth::check())
                        <div class="alert alert-warning">
                            <i class="bi bi-info-circle"></i> Please login to complete your purchase.
                        </div>
                        <a href="{{ route('login') }}?redirect={{ urlencode(request()->fullUrl()) }}" class="btn btn-primary w-100">
                            Login to Continue
                        </a>
                    @else
                        <form action="{{ route('events.book', $event->eventId) }}" method="POST">
                            @csrf
                            <input type="hidden" name="ticket_type" value="{{ $ticketType }}">
                            <input type="hidden" name="quantity" value="1">

                            <div class="mb-3">
                                <label class="form-label">Quantity</label>
                                <select name="quantity" class="form-select">
                                    @for($i = 1; $i <= 10; $i++)
                                        <option value="{{ $i }}">{{ $i }} {{ $i == 1 ? 'ticket' : 'tickets' }}</option>
                                    @endfor
                                </select>
                            </div>

                            <button type="submit" class="btn btn-primary w-100">
                                <i class="bi bi-credit-card"></i> Proceed to Payment
                            </button>
                        </form>
                    @endif

                    <div class="mt-3">
                        <a href="{{ route('events.show', $event->eventId) }}" class="btn btn-outline-secondary w-100">
                            <i class="bi bi-arrow-left"></i> Back to Event Details
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection

