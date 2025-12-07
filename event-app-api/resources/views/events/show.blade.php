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
                <h3>{{ $event->eventTitle }}</h3>
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
                        <h5 class="mb-2">Applications</h5>
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
                        <div class="d-flex gap-2 mt-2">
                            <a href="https://instagram.com" target="_blank"
                                class="btn btn-outline-primary btn-sm"><i class="bi bi-instagram"></i></a>
                            <a href="mailto:info@eventgo.com" class="btn btn-outline-primary btn-sm"><i
                                    class="bi bi-envelope"></i></a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Apply -->
            <div class="col-lg-4">
                <div class="feature-card text-center">
                    @auth
                        @if(isset($isOwner) && $isOwner)
                            <!-- Owner View - Only show promotion, never show booking -->
                            <h5>Your Event</h5>
                            @if(isset($promotionStatus) && $promotionStatus['isActive'])
                                <div class="alert alert-success mb-3">
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
                                <p class="small text-muted mb-0">Your event is currently promoted. You can promote again after this promotion expires.</p>
                            @else
                                <a href="{{ route('promotion.show', $event->eventId) }}" class="btn btn-warning btn-sm w-100 mb-2">
                                    <i class="bi bi-megaphone-fill"></i>
                                    Promote Event
                                </a>
                                <p class="small text-muted mb-0">Promote your event to reach more people!</p>
                            @endif
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
                                            <option value="general">General - ${{ number_format($event->eventPrice, 2) }}</option>
                                            <option value="silver">Silver - ${{ number_format($event->eventPrice * 1.2, 2) }}</option>
                                            <option value="gold">Gold - ${{ number_format($event->eventPrice * 1.5, 2) }}</option>
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
                        <a href="{{ route('login') }}" class="btn btn-primary btn-sm w-100">
                            Login to Book <i class="bi bi-arrow-right"></i>
                        </a>
                    @endauth
                </div>
            </div>
        </div>

        <!-- Inspire Section -->
        <div class="col-md-12 aos-init aos-animate" data-aos="fade-up" data-aos-delay="80">
            <div class="feature-card my-4">
                <h5>{{ $event->eventTitle }}</h5>
                <p style="white-space: pre-wrap;">{{ $event->description }}</p>
            </div>
        </div>

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
                    After the conference, participants will be asked to leave a review. Once the first
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
