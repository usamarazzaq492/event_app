@extends('layouts.app')

@section('title', $event->eventTitle . ' - EventGo')

@push('styles')
<style>
:root {
    --primary: #4da6ff;
    --primary-dark: #247fd9;
    --bg: #ffffff;
    --muted: #6b7280;
    --card-shadow: 0 10px 20px rgba(13, 42, 86, 0.06);
}

.feature-card {
    border-radius: 12px;
    box-shadow: var(--card-shadow);
    transition: transform .22s cubic-bezier(.2, .9, .3, 1), box-shadow .22s;
    background: var(--bg);
    padding: 1.25rem;
    min-height: 180px;
}

.feature-card:hover {
    transform: translateY(-8px);
    box-shadow: 0 18px 40px rgba(13, 42, 86, 0.12);
}

.feature-icon {
    width: 56px;
    height: 56px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
    color: white;
    margin-bottom: .75rem;
    font-size: 1.2rem;
}

.banner {
    position: relative;
    border-radius: 16px;
    overflow: hidden;
}

.banner img {
    width: 100%;
    height: 250px;
    object-fit: cover;
}

.banner-title {
    position: absolute;
    bottom: 20px;
    left: 20px;
    color: #fff;
    background: rgba(0, 0, 0, 0.5);
    padding: 10px 20px;
    border-radius: 12px;
}

.banner-title h3 {
    margin: 0;
}

.rating i {
    color: #f59e0b;
    font-size: 1.2rem;
}

.rating i.text-muted {
    color: #ccc;
}
</style>
@endpush

@section('content')
<!-- Event Detail -->
<section class="section contact__v2" id="contact">
    <div class="container py-4">

        <!-- Banner -->
        <div class="banner mb-4">
            @if($event->eventImage)
                <img src="{{ asset($event->eventImage) }}" alt="{{ $event->eventTitle }}"
                    onerror="this.onerror=null; this.src='https://via.placeholder.com/1200x250/4da6ff/ffffff?text={{ urlencode($event->eventTitle) }}';">
            @else
                <img src="https://via.placeholder.com/1200x250/4da6ff/ffffff?text={{ urlencode($event->eventTitle) }}"
                    alt="{{ $event->eventTitle }}">
            @endif
            <div class="banner-title">
                <h3 class="text-white">{{ $event->eventTitle }}</h3>
                <p>{{ $event->category ?? 'Event' }} {{ \Carbon\Carbon::parse($event->startDate)->format('Y') }}</p>
                @if(isset($promotionStatus) && $promotionStatus['isActive'])
                    <span class="badge bg-warning text-dark ms-2">
                        <i class="bi bi-star-fill"></i> PROMOTED
                    </span>
                @endif
            </div>
        </div>

        <div class="row g-4">
            <!-- Left Info -->
            <div class="col-lg-8">
                <div class="feature-card d-flex gap-3 align-items-start">
                    @if($event->eventImage)
                        <img src="{{ asset($event->eventImage) }}"
                            class="rounded-circle bg-light p-2" alt="Logo" width="120" height="120"
                            onerror="this.onerror=null; this.src='https://via.placeholder.com/120/4da6ff/ffffff?text=Event';">
                    @else
                        <img src="https://via.placeholder.com/120/4da6ff/ffffff?text=Event"
                            class="rounded-circle bg-light p-2" alt="Logo" width="120" height="120">
                    @endif
                    <div>
                        <h5 class="mb-2">{{ $event->eventTitle }}</h5>
                        <p class="mb-1"><i class="bi bi-geo-alt-fill"></i> {{ $event->city ?? 'Location TBA' }}</p>
                        <p class="mb-1">
                            <i class="bi bi-calendar-event"></i>
                            {{ \Carbon\Carbon::parse($event->startDate)->format('M d') }} -
                            {{ \Carbon\Carbon::parse($event->endDate)->format('M d Y') }}
                        </p>
                        @if($event->category)
                            <p class="mb-1"><i class="bi bi-mortarboard-fill"></i> {{ $event->category }}</p>
                        @endif
                        @if($event->bookings && $event->bookings->count() > 0)
                            <p class="mb-1"><i class="bi bi-people-fill"></i> {{ $event->bookings->count() }} Bookings</p>
                        @endif
                    </div>
                </div>
            </div>

            <!-- Right Apply -->
            <div class="col-lg-4">
                <div class="feature-card text-center">
                    @auth
                        @if(isset($isOwner) && $isOwner)
                            <!-- Owner View - Show management options -->
                            <h5>Your Event</h5>

                            <!-- Action Buttons -->
                            <div class="d-grid gap-2 mb-3">
                                <a href="{{ route('events.edit', $event->eventId) }}" class="btn btn-outline-primary btn-sm">
                                    <i class="bi bi-pencil-square"></i> Edit Event
                                </a>
                                <a href="{{ route('payment-qr.show', $event->eventId) }}" class="btn btn-primary btn-sm">
                                    <i class="bi bi-qr-code-scan"></i> Generate Payment QR
                                </a>
                                @if(isset($promotionStatus) && $promotionStatus['isActive'])
                                    <div class="alert alert-success mb-0">
                                        <i class="bi bi-star-fill"></i> <strong>Promoted!</strong>
                                        <p class="mb-0 small">
                                            {{ ucfirst($promotionStatus['package']) }} Package
                                            <br>
                                            @if($promotionStatus['daysRemaining'] > 0)
                                                {{ $promotionStatus['daysRemaining'] }} days remaining
                                            @else
                                                Active
                                            @endif
                                        </p>
                                    </div>
                                @else
                                    <a href="{{ route('promotion.show', $event->eventId) }}" class="btn btn-warning btn-sm">
                                        <i class="bi bi-megaphone-fill"></i> Promote Event
                                    </a>
                                @endif
                            </div>

                            <p class="small text-muted mb-0">Manage your event, generate QR codes, or promote it to reach more people!</p>
                        @else
                            <!-- Non-Owner Authenticated View - Only show booking if NOT owner -->
                            <h5>Apply Now!</h5>
                            @if($event->eventPrice > 0)
                                <p class="small">Price: ${{ number_format($event->eventPrice, 2) }}</p>
                            @else
                                <p class="small">Free Event</p>
                            @endif
                            <form action="{{ route('events.book', $event->eventId) }}" method="POST">
                                @csrf

                                @if($event->eventPrice > 0)
                                    <div class="mb-3">
                                        <label class="form-label small">Ticket Type</label>
                                        <select name="ticket_type" class="form-select form-select-sm" required>
                                            <option value="general">General Admission - ${{ number_format($event->eventPrice, 2) }}</option>
                                            <option value="vip">VIP (Very Important Person) - ${{ number_format($event->vipPrice ?? $event->eventPrice ?? 0, 2) }}</option>
                                        </select>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label small">Quantity</label>
                                        <select name="quantity" class="form-select form-select-sm" required>
                                            @for($i = 1; $i <= 10; $i++)
                                                <option value="{{ $i }}">{{ $i }} {{ $i == 1 ? 'ticket' : 'tickets' }}</option>
                                            @endfor
                                        </select>
                                    </div>
                                @else
                                    <input type="hidden" name="ticket_type" value="general">
                                    <input type="hidden" name="quantity" value="1">
                                @endif

                                <button type="submit" class="btn btn-primary btn-sm w-100">
                                    @if($event->eventPrice > 0)
                                        Book Now! <i class="bi bi-arrow-right"></i>
                                    @else
                                        Register Now! <i class="bi bi-arrow-right"></i>
                                    @endif
                                </button>
                            </form>
                        @endif
                    @else
                        <!-- Guest View -->
                        <h5>Apply Now!</h5>
                        @if($event->eventPrice > 0)
                            <p class="small">Price: ${{ number_format($event->eventPrice, 2) }}</p>
                        @else
                            <p class="small">Free Event</p>
                        @endif
                        <a href="{{ route('login') }}?redirect={{ urlencode(request()->fullUrl()) }}" class="btn btn-primary btn-sm w-100">
                            Login to Book <i class="bi bi-arrow-right"></i>
                        </a>
                    @endauth
                </div>
            </div>
        </div>

        <!-- Inspire Section -->
        <div class="col-md-12 aos-init aos-animate" data-aos="fade-up" data-aos-delay="80">
            <div class="feature-card my-4">
                <h5>Description</h5>
                <p style="white-space: pre-wrap;">{{ $event->description }}</p>
            </div>
        </div>

        <!-- QR Codes Section (for organizers) -->
        @if(isset($isOwner) && $isOwner && $qrCodes->count() > 0)
        <div class="col-md-12 aos-init aos-animate" data-aos="fade-up" data-aos-delay="80">
            <div class="feature-card my-4">
                <h5 class="mb-3">
                    <i class="bi bi-qr-code-scan"></i> Payment QR Codes
                </h5>
                <div class="row g-3">
                    @foreach($qrCodes as $qr)
                        @php
                            $qrData = json_decode($qr->qrCodeData, true);
                            // Use web URL for QR code (works with all scanners, including iPhone)
                            $qrString = $qrData['web'] ?? ($qrData['app'] ?? $qr->qrCodeData);
                        @endphp
                        <div class="col-md-3 col-sm-4 col-6">
                            <div class="text-center p-2 border rounded">
                                <h6 class="small mb-2">
                                    <span class="badge
                                        @if($qr->ticketType == 'gold') bg-warning text-dark
                                        @elseif($qr->ticketType == 'silver') bg-secondary
                                        @else bg-dark
                                        @endif">
                                        {{ strtoupper($qr->ticketType) }}
                                    </span>
                                    @if($qr->maxUses && $qr->currentUses >= $qr->maxUses)
                                        <span class="badge bg-danger ms-1">Limit Reached</span>
                                    @endif
                                </h6>
                                <img src="https://api.qrserver.com/v1/create-qr-code/?size=100x100&data={{ urlencode($qrString) }}"
                                     alt="QR Code"
                                     class="img-fluid"
                                     style="max-width: 100px;">
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        </div>
        @endif

        <!-- Reviews -->
        <div class="col-md-12 aos-init aos-animate" data-aos="fade-up" data-aos-delay="80">
            <div class="feature-card">
                <h5>Reviews</h5>
                <div class="rating my-2">
                    <i class="bi bi-star-fill"></i>
                    <i class="bi bi-star-fill"></i>
                    <i class="bi bi-star-fill"></i>
                    <i class="bi bi-star-half"></i>
                    <i class="bi bi-star text-muted"></i>
                </div>
                <p class="mb-0">
                    After the event, participants will be asked to leave a review. Once the first
                    one comes in, you will see it here.
                </p>
            </div>
        </div>
    </div>
</section>
@endsection

@push('scripts')
<script>
    AOS.init({
        duration: 800,
        easing: 'ease-in-out',
        once: true
    });
</script>
@endpush
