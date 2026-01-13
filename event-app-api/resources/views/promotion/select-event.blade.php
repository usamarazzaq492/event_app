@extends('layouts.app')

@section('title', 'Select Event to Promote - EventGo')

@section('content')
<div class="container py-5">
    <!-- Header Section -->
    <div class="row mb-4">
        <div class="col-12">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="{{ route('home') }}">Home</a></li>
                    <li class="breadcrumb-item"><a href="{{ route('ads.index') }}">Promoted Events</a></li>
                    <li class="breadcrumb-item active">Select Event</li>
                </ol>
            </nav>
            <h2 class="fw-bold mb-3">
                <i class="fas fa-rocket text-primary me-2"></i>Select Event to Promote
            </h2>
            <p class="text-muted">Choose an event to boost its visibility and reach more attendees</p>
        </div>
    </div>

    <!-- Events List -->
    <div class="row">
        @forelse($events as $event)
            @php
                $isPromoted = $event->isPromoted == 1;
                $isActive = false;
                $timeRemaining = '';

                if ($isPromoted && $event->promotionEndDate) {
                    $endDate = \Carbon\Carbon::parse($event->promotionEndDate);
                    $isActive = $endDate->isFuture();

                    if ($isActive) {
                        $now = now();
                        $diff = $now->diff($endDate);

                        $days = $diff->days;
                        $hours = $diff->h;
                        $minutes = $diff->i;

                        if ($days > 0) {
                            $timeRemaining = $days . ' day' . ($days != 1 ? 's' : '');
                            if ($hours > 0) {
                                $timeRemaining .= ' ' . $hours . 'h';
                            }
                        } else if ($hours > 0) {
                            $timeRemaining = $hours . 'h';
                            if ($minutes > 0) {
                                $timeRemaining .= ' ' . $minutes . 'm';
                            }
                        } else if ($minutes > 0) {
                            $timeRemaining = $minutes . 'm';
                        } else {
                            $timeRemaining = 'Expiring soon';
                        }
                    }
                }

                $canPromote = !$isActive;
                $startDate = \Carbon\Carbon::parse($event->startDate);
            @endphp

            <div class="col-md-6 col-lg-4 mb-4">
                <div class="card h-100 shadow-sm {{ $isActive ? 'border-warning' : '' }}" style="{{ $isActive ? 'border-width: 2px;' : '' }}">
                    @if($event->eventImage)
                        <img src="{{ asset($event->eventImage) }}" class="card-img-top" alt="{{ $event->eventTitle }}" style="height: 200px; object-fit: cover;">
                    @else
                        <div class="card-img-top bg-light d-flex align-items-center justify-content-center" style="height: 200px;">
                            <i class="fas fa-calendar-alt fa-3x text-muted"></i>
                        </div>
                    @endif

                    @if($isActive)
                        <div class="position-absolute top-0 end-0 m-2">
                            <span class="badge bg-warning text-dark">
                                <i class="fas fa-rocket me-1"></i>Promoted
                            </span>
                        </div>
                    @endif

                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title fw-bold">{{ $event->eventTitle }}</h5>
                        <p class="card-text text-muted small flex-grow-1">
                            {{ Str::limit($event->description ?? 'No description', 100) }}
                        </p>

                        <div class="mb-3">
                            <small class="text-muted d-block">
                                <i class="fas fa-calendar-alt me-1"></i>
                                {{ $startDate->format('M d, Y') }}
                                @if($event->startTime)
                                    at {{ \Carbon\Carbon::parse($event->startTime)->format('g:i A') }}
                                @endif
                            </small>
                            @if($event->city)
                            <small class="text-muted d-block">
                                <i class="fas fa-map-marker-alt me-1"></i>{{ $event->city }}
                            </small>
                            @endif
                        </div>

                        @if($isActive)
                            <div class="alert alert-warning mb-3">
                                <small class="d-block fw-bold mb-1">
                                    <i class="fas fa-clock me-1"></i>Promotion Active
                                </small>
                                <small class="d-block">{{ $timeRemaining }} left</small>
                            </div>
                            <button class="btn btn-outline-secondary w-100" disabled>
                                <i class="fas fa-lock me-2"></i>Already Promoted
                            </button>
                        @else
                            <a href="{{ route('promotion.show', $event->eventId) }}" class="btn btn-primary w-100">
                                <i class="fas fa-rocket me-2"></i>Promote This Event
                            </a>
                        @endif
                    </div>
                </div>
            </div>
        @empty
            <div class="col-12">
                <div class="text-center py-5">
                    <i class="fas fa-calendar-times fa-4x text-muted mb-3"></i>
                    <h4 class="text-muted">No Events Available</h4>
                    <p class="text-muted">You don't have any upcoming events to promote yet.</p>
                    <a href="{{ route('events.create') }}" class="btn btn-primary">
                        <i class="fas fa-plus me-2"></i>Create Your First Event
                    </a>
                </div>
            </div>
        @endforelse
    </div>
</div>
@endsection
