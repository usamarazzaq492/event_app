@extends('layouts.app')

@section('title', 'Events - EventGo')

@push('styles')
<style>
.event-card {
  border-radius: 16px;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border: 1px solid rgba(77, 166, 255, 0.1);
  padding: 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 4px 20px rgba(13, 42, 86, 0.08);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  min-height: 160px;
  margin-bottom: 16px;
}
.event-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 12px 32px rgba(77, 166, 255, 0.2);
  border-color: rgba(77, 166, 255, 0.3);
}
.event-info {
  display: flex;
  align-items: center;
  gap: 20px;
  flex: 1;
}
.event-logo {
  flex-shrink: 0;
}
.event-logo img {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
  background: #fff;
  padding: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  border: 2px solid rgba(77, 166, 255, 0.15);
}
.event-text h5 {
  margin: 0 0 8px 0;
  font-size: 1.15rem;
  font-weight: 700;
  color: #1f2937;
  line-height: 1.4;
}
.event-text .meta {
  font-size: 0.9rem;
  color: #6b7280;
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: center;
}
.event-text .meta i {
  color: #4da6ff;
}
.btn-apply {
  flex-shrink: 0;
  padding: 12px 24px;
  font-weight: 600;
  border-radius: 10px;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(77, 166, 255, 0.3);
}
.btn-apply:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 16px rgba(77, 166, 255, 0.4);
}
.search-section {
  background: linear-gradient(135deg, rgba(79, 110, 247, 0.05) 0%, rgba(77, 166, 255, 0.05) 100%);
  padding: 40px 0;
  margin-bottom: 30px;
}
.search-section .input-group {
  max-width: 720px;
  margin: 0 auto;
  border-radius: 12px;
  overflow: hidden;
}
@media (max-width: 768px) {
  .event-card {
    flex-direction: column;
    text-align: center;
    min-height: auto;
    padding: 20px;
  }
  .event-info {
    flex-direction: column;
    gap: 15px;
  }
  .btn-apply {
    width: 100%;
    margin-top: 15px;
  }
}
</style>
@endpush

@section('content')
<!--Start Recent Event-->
<section class="section contact__v2" id="contact">
    <div class="container">
        <div class="row mb-5">
            <div class="col-md-6 col-lg-7 mt-4 mx-auto text-center">
                <span class="subtitle text-uppercase mb-3" data-aos="fade-up" data-aos-delay="0">Events</span>
                <h2 class="h2 fw-bold mb-3" data-aos="fade-up" data-aos-delay="0">Events</h2>
            </div>
        </div>
    </div>
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="mb-0">Upcoming Events</h3>
        </div>

        <div class="row">
            @forelse($events->take(4) as $index => $event)
            <div class="col-md-3" data-aos="fade-up" data-aos-delay="{{ 80 * ($index + 1) }}">
                <a href="{{ route('events.show', $event->eventId) }}" class="text-decoration-none">
                    <div class="card rounded-3 border-0 shadow-sm h-100">
                        @if($event->eventImage)
                            <img src="{{ asset($event->eventImage) }}"
                                 class="card-img-top"
                                 alt="{{ $event->eventTitle }}"
                                 style="height: 200px; object-fit: cover;"
                                 onerror="this.src='https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=800&q=80'">
                        @else
                            <img src="https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=800&q=80"
                                 class="card-img-top"
                                 style="height: 200px; object-fit: cover;"
                                 alt="{{ $event->eventTitle }}">
                        @endif
                        <div class="card-body">
                            <h5 class="card-title text-dark">{{ \Illuminate\Support\Str::limit($event->eventTitle, 30) }}</h5>
                            <p class="card-text text-muted small mb-2">
                                <i class="fas fa-calendar-alt me-1"></i>{{ \Carbon\Carbon::parse($event->startDate)->format('M d, Y') }}
                            </p>
                            <p class="card-text text-muted small mb-2">
                                <i class="fas fa-map-marker-alt me-1"></i>{{ $event->city ?? 'Location TBA' }}
                            </p>
                            <p class="card-text text-muted small">
                                <i class="fas fa-dollar-sign me-1"></i>
                                @if($event->eventPrice && $event->eventPrice > 0)
                                    ${{ number_format($event->eventPrice, 2) }}
                                @else
                                    Free
                                @endif
                            </p>
                        </div>
                    </div>
                </a>
            </div>
            @empty
            <div class="col-md-3" data-aos="fade-up" data-aos-delay="80">
                <a href="{{ route('events.index') }}" class="text-decoration-none">
                    <div class="card rounded-3 border-0 shadow-sm">
                        <img src="https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=800&q=80"
                            class="card-img-top" alt="Concert" style="height: 200px; object-fit: cover;">
                        <div class="card-body">
                            <h5 class="card-title text-dark">Concerts</h5>
                            <p class="card-text text-muted small">Live music, festivals, acoustic nights, and more.</p>
                        </div>
                    </div>
                </a>
            </div>
            <div class="col-md-3" data-aos="fade-up" data-aos-delay="160">
                <a href="{{ route('events.index') }}" class="text-decoration-none">
                    <div class="card rounded-3 border-0 shadow-sm">
                        <img src="https://images.unsplash.com/photo-1542744173-8e7e53415bb0?auto=format&fit=crop&w=800&q=80"
                            class="card-img-top" alt="Workshop" style="height: 200px; object-fit: cover;">
                        <div class="card-body">
                            <h5 class="card-title text-dark">Workshops</h5>
                            <p class="card-text text-muted small">Hands-on sessions — tech, art, cooking & more.</p>
                        </div>
                    </div>
                </a>
            </div>
            <div class="col-md-3" data-aos="fade-up" data-aos-delay="240">
                <a href="{{ route('events.index') }}" class="text-decoration-none">
                    <div class="card rounded-3 border-0 shadow-sm">
                        <img src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80"
                            class="card-img-top" alt="Conference" style="height: 200px; object-fit: cover;">
                        <div class="card-body">
                            <h5 class="card-title text-dark">Conferences</h5>
                            <p class="card-text text-muted small">Industry events, seminars, and professional gatherings.</p>
                        </div>
                    </div>
                </a>
            </div>
            <div class="col-md-3" data-aos="fade-up" data-aos-delay="320">
                <a href="{{ route('events.index') }}" class="text-decoration-none">
                    <div class="card rounded-3 border-0 shadow-sm">
                        <img src="https://images.unsplash.com/photo-1546182990-dffeafbe841d?auto=format&fit=crop&w=800&q=80"
                            class="card-img-top" alt="Sports" style="height: 200px; object-fit: cover;">
                        <div class="card-body">
                            <h5 class="card-title text-dark">Sports</h5>
                            <p class="card-text text-muted small">Matches, tournaments, and fitness events.</p>
                        </div>
                    </div>
                </a>
            </div>
            @endforelse
        </div>
    </div>
</section>
<!--End Recent Event-->

<!-- Search Bar -->
<section class="search-section">
    <div class="container">
        <form action="{{ route('events.search') }}" method="GET">
            <div class="input-group shadow-lg">
                <span class="input-group-text bg-white border-end-0 px-4">
                    <i class="fa fa-search text-primary"></i>
                </span>
                <input name="q" class="form-control form-control-lg border-start-0 border-end-0"
                    placeholder="Search events, categories, locations..."
                    aria-label="Search events"
                    value="{{ request('q') }}">
                <button class="btn btn-primary btn-lg px-5" type="submit">
                    <i class="fa fa-search me-2"></i>Search
                </button>
            </div>
        </form>
    </div>
</section>
<!-- End Search Bar -->

<!-- Event Cards -->
<div class="container pb-5">
    <div class="mb-4" data-aos="fade-up">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h3 class="fw-bold mb-1">All Upcoming Events</h3>
                <p class="text-muted mb-0">{{ $events->total() }} upcoming events</p>
            </div>
            @auth
                <a href="{{ route('events.create') }}" class="btn btn-primary">
                    <i class="fas fa-plus me-2"></i>Create Event
                </a>
            @else
                <a href="{{ route('login') }}" class="btn btn-outline-primary">
                    <i class="fas fa-sign-in-alt me-2"></i>Login to Create Event
                </a>
            @endauth
        </div>
    </div>

    <div class="d-flex flex-column">
        @forelse($events as $event)
        <div class="event-card" data-aos="fade-up" data-aos-delay="{{ $loop->index * 50 }}">
            <div class="event-info">
                <div class="event-logo position-relative">
                    @if($event->eventImage)
                        <img src="{{ asset($event->eventImage) }}" alt="{{ $event->eventTitle }}"
                            onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=80&q=80';">
                    @else
                        <img src="https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=80&q=80" alt="{{ $event->eventTitle }}">
                    @endif
                    @if($event->isPromoted == 1 && $event->promotionEndDate)
                        @php
                            $endDate = \Carbon\Carbon::parse($event->promotionEndDate);
                            $isActive = $endDate->isFuture();
                        @endphp
                        @if($isActive)
                            <span class="badge bg-warning text-dark position-absolute top-0 end-0" style="font-size: 0.7rem; padding: 4px 8px; z-index: 10;">
                                <i class="bi bi-star-fill"></i> PROMOTED
                            </span>
                        @endif
                    @endif
                </div>
                <div class="event-text">
                    <h5>{{ strtoupper($event->eventTitle) }}</h5>
                    <div class="meta">
                        <span><i class="fas fa-map-marker-alt me-1"></i>{{ $event->city ?? 'Location TBA' }}</span>
                        <span>|</span>
                        <span><i class="fas fa-calendar-alt me-1"></i>{{ \Carbon\Carbon::parse($event->startDate)->format('M d') }} - {{ \Carbon\Carbon::parse($event->endDate)->format('M d Y') }}</span>
                        @if($event->category)
                            <span>|</span>
                            <span><i class="fas fa-tag me-1"></i>{{ $event->category }}</span>
                        @endif
                    </div>
                </div>
            </div>
            <a href="{{ route('events.show', $event->eventId) }}" class="btn btn-primary btn-apply">
                <i class="fas fa-arrow-right me-2"></i>View Details
            </a>
        </div>
        @empty
        <div class="text-center py-5" data-aos="fade-up">
            <i class="fas fa-calendar-times" style="font-size: 4rem; color: #cbd5e1;"></i>
            <h4 class="mt-3 text-muted">No Events Found</h4>
            <p class="text-muted">Try adjusting your search or explore all events</p>
            <div class="d-flex justify-content-center gap-3 mt-3">
                <a href="{{ route('events.index') }}" class="btn btn-outline-primary">
                    <i class="fas fa-redo me-2"></i>Show All Events
                </a>
                @auth
                    <a href="{{ route('events.create') }}" class="btn btn-primary">
                        <i class="fas fa-plus me-2"></i>Create Event
                    </a>
                @else
                    <a href="{{ route('login') }}" class="btn btn-primary">
                        <i class="fas fa-sign-in-alt me-2"></i>Login to Create Event
                    </a>
                @endauth
            </div>
        </div>
        @endforelse
    </div>

    <!-- Pagination -->
    @if($events->hasPages())
        <div class="mt-5 d-flex justify-content-center" data-aos="fade-up">
            {{ $events->links() }}
        </div>
    @endif
</div>
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
