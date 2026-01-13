@extends('layouts.app')

@section('title', 'Promoted Events - EventGo')

@section('content')
<div class="container py-5">
    <!-- Header Section -->
    <div class="row mb-5" data-aos="fade-up">
        <div class="col-12 text-center">
            <h1 class="display-4 fw-bold text-dark mb-3">Promoted Events</h1>
            <p class="lead text-muted mb-4">Discover events that are currently being promoted and boosted for maximum visibility</p>
            @auth
                <a href="{{ route('promotion.select-event') }}" class="btn btn-primary btn-lg">
                    <i class="fas fa-rocket me-2"></i>Promote Your Event
                </a>
            @else
                <a href="{{ route('login') }}?redirect={{ urlencode(route('promotion.select-event')) }}" class="btn btn-primary btn-lg text-white">
                    <i class="fas fa-sign-in-alt me-2"></i>Login to Promote Event
                </a>
            @endauth
        </div>
    </div>

    <!-- Promoted Events Grid -->
    <div class="row">
        @forelse($ads as $event)
            <div class="col-lg-4 col-md-6 mb-4" data-aos="fade-up" data-aos-delay="{{ $loop->index * 100 }}">
                <div class="card border-0 shadow-sm h-100 campaign-card">
                    <div class="position-relative overflow-hidden">
                        @if($event->eventImage)
                            <img src="{{ asset($event->eventImage) }}"
                                 class="card-img-top campaign-image"
                                 alt="{{ $event->eventTitle }}">
                        @else
                            <div class="card-img-top bg-light d-flex align-items-center justify-content-center campaign-placeholder">
                                <i class="fas fa-calendar-alt fa-3x text-muted"></i>
                            </div>
                        @endif
                        <div class="position-absolute top-0 end-0 m-2">
                            <span class="badge bg-warning pulse-animation">
                                <i class="fas fa-rocket me-1"></i>Promoted
                            </span>
                        </div>
                        <div class="campaign-overlay">
                            <a href="{{ route('events.show', $event->eventId) }}" class="btn btn-light btn-sm">
                                <i class="fas fa-eye me-1"></i>View Event
                            </a>
                        </div>
                    </div>

                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title fw-bold text-dark mb-2">{{ $event->eventTitle }}</h5>
                        <p class="card-text text-muted flex-grow-1 small">
                            {{ Str::limit($event->description ?? 'No description available', 120) }}
                        </p>

                        <div class="mt-auto">
                            @php
                                $startDate = \Carbon\Carbon::parse($event->startDate);
                                $endDate = $event->promotionEndDate ? \Carbon\Carbon::parse($event->promotionEndDate) : null;
                            @endphp

                            <!-- Event Date -->
                            <div class="mb-3">
                                <div class="d-flex align-items-center mb-2">
                                    <i class="fas fa-calendar-alt text-primary me-2"></i>
                                    <small class="text-muted">
                                        <strong>{{ $startDate->format('M d, Y') }}</strong>
                                        @if($event->startTime)
                                            at {{ \Carbon\Carbon::parse($event->startTime)->format('g:i A') }}
                                        @endif
                                    </small>
                                </div>
                                @if($event->city)
                                <div class="d-flex align-items-center">
                                    <i class="fas fa-map-marker-alt text-danger me-2"></i>
                                    <small class="text-muted">{{ $event->city }}</small>
                                </div>
                                @endif
                            </div>

                            <!-- Promotion Status - Only show timer to event owner -->
                            @if($endDate && $endDate->isFuture())
                                @auth
                                    @if(Auth::user()->userId == $event->userId)
                                    <div class="mb-3">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <small class="text-muted fw-bold">Promotion Active</small>
                                            <small class="text-warning fw-bold" id="timer-{{ $event->eventId }}" data-end-date="{{ $endDate->toIso8601String() }}">
                                                Calculating...
                                            </small>
                                        </div>
                                        <div class="progress campaign-progress" style="height: 8px;">
                                            @php
                                                $totalDays = 10; // BOOST_DURATION_DAYS
                                                $daysRemaining = max(0, floor(now()->diffInDays($endDate, false)));
                                                $daysUsed = max(0, $totalDays - $daysRemaining);
                                                $progress = min(100, max(0, ($daysUsed / $totalDays) * 100));
                                            @endphp
                                            <div class="progress-bar bg-gradient-warning"
                                                 style="width: {{ $progress }}%"
                                                 data-aos="fade-right"
                                                 data-aos-delay="300"></div>
                                        </div>
                                    </div>
                                    @endif
                                @endauth
                            @endif

                            <!-- Event Price -->
                            @if($event->eventPrice && $event->eventPrice > 0)
                            <div class="row text-center mb-3">
                                <div class="col-12">
                                    <h6 class="fw-bold text-primary mb-0">${{ number_format($event->eventPrice, 2) }}</h6>
                                    <small class="text-muted">Ticket Price</small>
                                </div>
                            </div>
                            @else
                            <div class="row text-center mb-3">
                                <div class="col-12">
                                    <h6 class="fw-bold text-success mb-0">FREE</h6>
                                    <small class="text-muted">Event</small>
                                </div>
                            </div>
                            @endif

                            <!-- Creator Info -->
                            <div class="d-flex align-items-center mb-3">
                                <div class="profile-avatar-tiny me-2">
                                    @php
                                        $user = DB::table('mstuser')->where('userId', $event->userId)->first();
                                    @endphp
                                    @if($user && $user->profileImageUrl)
                                        <img src="{{ asset($user->profileImageUrl) }}"
                                             alt="{{ $user->name }}"
                                             class="profile-image-tiny">
                                    @else
                                        <div class="profile-image-placeholder-tiny">
                                            <i class="fas fa-user"></i>
                                        </div>
                                    @endif
                                </div>
                                <div>
                                    <small class="text-muted">by <strong>{{ $event->userName }}</strong></small>
                                </div>
                            </div>

                            <!-- Actions -->
                            <div class="d-grid">
                                <a href="{{ route('events.show', $event->eventId) }}"
                                   class="btn btn-primary btn-sm">
                                    <i class="fas fa-eye me-2"></i>View Event
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        @empty
            <div class="col-12 text-center py-5" data-aos="fade-up">
                <div class="empty-state-icon mb-4">
                    <i class="fas fa-rocket"></i>
                </div>
                <h3 class="text-muted mb-3">No Promoted Events</h3>
                <p class="text-muted mb-4">There are currently no events being promoted. Be the first to promote your event and increase visibility!</p>
                @auth
                    <a href="{{ route('promotion.select-event') }}" class="btn btn-primary btn-lg">
                        <i class="fas fa-rocket me-2"></i>Promote Your Event
                    </a>
                @else
                    <a href="{{ route('login') }}?redirect={{ urlencode(route('promotion.select-event')) }}" class="btn btn-primary btn-lg">
                        <i class="fas fa-sign-in-alt me-2"></i>Login to Promote Event
                    </a>
                @endauth
            </div>
        @endforelse
    </div>

    <!-- Pagination -->
    @if($ads->hasPages())
        <div class="row mt-5">
            <div class="col-12 d-flex justify-content-center">
                {{ $ads->links() }}
            </div>
        </div>
    @endif
</div>

<style>
.ad-card {
    transition: all 0.3s ease;
    border-radius: 15px;
    overflow: hidden;
}

.ad-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15) !important;
}

.ad-card .card-img-top {
    transition: transform 0.3s ease;
}

.ad-card:hover .card-img-top {
    transform: scale(1.05);
}

.progress {
    border-radius: 10px;
}

.progress-bar {
    border-radius: 10px;
}

.btn-primary {
    background: #584CF4;
    border-color: #584CF4;
}

.btn-primary:hover {
    background: #4a3dd1;
    border-color: #4a3dd1;
}

.btn-outline-primary {
    color: #584CF4;
    border-color: #584CF4;
}

.btn-outline-primary:hover {
    background: #584CF4;
    border-color: #584CF4;
}

/* Enhanced Campaign Styles */
.campaign-card {
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    border-radius: 20px;
    overflow: hidden;
    position: relative;
}

.campaign-card:hover {
    transform: translateY(-8px) scale(1.02);
    box-shadow: 0 20px 40px rgba(88, 76, 244, 0.15);
}

.campaign-image {
    height: 200px;
    object-fit: cover;
    transition: transform 0.4s ease;
}

.campaign-card:hover .campaign-image {
    transform: scale(1.1);
}

.campaign-placeholder {
    height: 200px;
    background: linear-gradient(135deg, #f8f9ff 0%, #e9ecef 100%);
}

.campaign-overlay {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(88, 76, 244, 0.9);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    transition: opacity 0.3s ease;
}

.campaign-card:hover .campaign-overlay {
    opacity: 1;
}

.campaign-progress {
    border-radius: 10px;
    background: #f8f9ff;
    overflow: hidden;
}

.campaign-progress .progress-bar {
    border-radius: 10px;
    background: linear-gradient(90deg, #584CF4 0%, #ff9500 100%);
    transition: width 0.6s ease;
}

.profile-avatar-tiny {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    overflow: hidden;
    border: 2px solid #584CF4;
}

.profile-image-tiny {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.profile-image-placeholder-tiny {
    width: 100%;
    height: 100%;
    background: #584CF4;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 10px;
}

.pulse-animation {
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.05); }
    100% { transform: scale(1); }
}

.empty-state-icon {
    font-size: 4rem;
    color: #cbd5e1;
    animation: float 3s ease-in-out infinite;
}

@keyframes float {
    0%, 100% { transform: translateY(0px); }
    50% { transform: translateY(-10px); }
}

.text-warning {
    color: #ff9500 !important;
}

.text-success {
    color: #22c55e !important;
}

@media (max-width: 768px) {
    .campaign-card:hover {
        transform: translateY(-4px) scale(1.01);
    }

    .campaign-overlay {
        opacity: 1;
        background: rgba(88, 76, 244, 0.8);
    }
}
</style>

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Get all timer elements
    const timerElements = document.querySelectorAll('[id^="timer-"]');

    timerElements.forEach(function(timerElement) {
        const endDateAttr = timerElement.getAttribute('data-end-date');

        if (!endDateAttr) return;

        const endDate = new Date(endDateAttr);

        function updateTimer() {
            const now = new Date();
            const diff = endDate - now;

            if (diff <= 0) {
                timerElement.textContent = 'Expired';
                return;
            }

            const days = Math.floor(diff / (1000 * 60 * 60 * 24));
            const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((diff % (1000 * 60)) / 1000);

            // Format: "X days HH:MM:SS"
            const daysText = days + ' day' + (days !== 1 ? 's' : '');
            const timeText = String(hours).padStart(2, '0') + ':' +
                            String(minutes).padStart(2, '0') + ':' +
                            String(seconds).padStart(2, '0');

            timerElement.textContent = daysText + ' ' + timeText;
        }

        // Update immediately
        updateTimer();

        // Update every second
        setInterval(updateTimer, 1000);
    });
});
</script>
@endpush

@endsection
