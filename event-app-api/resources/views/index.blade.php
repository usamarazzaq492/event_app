@extends('layouts.app')

@section('title', 'EventGo - Connect. Create. Experience.')

@section('content')
<style>
:root {
    --primary: #584CF4;
    --primary-dark: #4a3dd9;
    --secondary: #ff9500;
    --bg: #ffffff;
    --muted: #6b7280;
    --card-shadow: 0 10px 20px rgba(88, 76, 244, 0.08);
}

/* Hero section styles */
.hero__v6 {
    background: linear-gradient(135deg, #584CF4 0%, #7c6bff 50%, #ff9500 100%);
    color: white;
    padding: 4.5rem 0;
    border-bottom-left-radius: 16px;
    border-bottom-right-radius: 16px;
}

.hero__v6 h1 {
    font-weight: 800;
    letter-spacing: -0.02em;
}

.hero__v6 .lead {
    opacity: 0.95;
}

/* Card styles */
.feature-card {
    border-radius: 12px;
    box-shadow: var(--card-shadow);
    transition: transform .22s cubic-bezier(.2,.9,.3,1), box-shadow .22s;
    background: var(--bg);
    padding: 1.25rem;
    min-height: 180px;
    border: none !important;
}

.feature-card:hover {
    transform: translateY(-8px);
    box-shadow: 0 18px 40px rgba(88, 76, 244, 0.15);
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
    font-size: 1.5rem;
}

/* Search bar styling */
.hero__v6 .input-group {
    border-radius: 12px;
    overflow: hidden;
    background: white;
}

.hero__v6 .input-group-text,
.hero__v6 .form-control {
    border: none;
    background: white;
}

.hero__v6 .btn-primary {
    background: var(--primary);
    border: none;
}

/* Detail hero sections */
.detail-hero {
    background: linear-gradient(180deg, rgba(88, 76, 244, 0.08), rgba(255,255,255,0));
    padding: 3rem 1.5rem;
    border-radius: 12px;
    margin-bottom: 2rem;
}

.py-6 {
    padding-top: 3rem !important;
    padding-bottom: 3rem !important;
}

.py-8 {
    padding-top: 4rem !important;
    padding-bottom: 4rem !important;
}

/* Button styles */
.btn-ghost {
    background: rgba(255,255,255,0.12);
    border: 1px solid rgba(255,255,255,0.18);
    color: white;
}

.btn-ghost:hover {
    background: rgba(255,255,255,0.2);
    color: white;
}
</style>

<!-- Hero Section -->
<section class="hero-section">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-6" data-aos="fade-right" data-aos-delay="100">
                <h1 class="hero-title">
                    EVENTS, MEETUPS & <span class="hero-highlight">CONNECTIONS</span>
                </h1>
                <div class="hero-meta mb-4">
                    <span class="me-4"><i class="bi bi-calendar me-2"></i>{{ \Carbon\Carbon::now()->format('F d, Y') }}</span>
                    <span><i class="bi bi-geo-alt me-2"></i>Global Events</span>
                </div>
                <div class="hero-buttons">
                    <a href="{{ route('events.index') }}" class="btn btn-explore">Explore Events</a>
                </div>
            </div>
            <div class="col-lg-6 mt-5 mt-lg-0" data-aos="fade-left" data-aos-delay="200">
                <!-- Bootstrap carousel -->
                <div id="heroCarousel" class="carousel slide rounded-4 shadow-lg" data-bs-ride="carousel">
                    <div class="carousel-inner">
                        <div class="carousel-item active">
                            <img src="https://images.unsplash.com/photo-1507874457470-272b3c8d8ee2?auto=format&fit=crop&w=1200&q=80"
                                class="d-block w-100 rounded-4" alt="Concert" />
                            <div class="carousel-caption d-none d-md-block text-start">
                                <h5>Summer Music Festival</h5>
                                <p>Live bands • Outdoor stage • Open-air</p>
                            </div>
                        </div>
                        <div class="carousel-item">
                            <img src="https://images.unsplash.com/photo-1531058020387-3be344556be6?auto=format&fit=crop&w=1200&q=80"
                                class="d-block w-100 rounded-4" alt="Conference" />
                            <div class="carousel-caption d-none d-md-block text-start">
                                <h5>Global Tech Conference</h5>
                                <p>Keynotes • Workshops • Networking</p>
                            </div>
                        </div>
                        <div class="carousel-item">
                            <img src="https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=1200&q=80"
                                class="d-block w-100 rounded-4" alt="Meetup" />
                            <div class="carousel-caption d-none d-md-block text-start">
                                <h5>Startups & Meetups</h5>
                                <p>Pitch nights • Demo tables • Meet founders</p>
                            </div>
                        </div>
                    </div>
                    <button class="carousel-control-prev" type="button" data-bs-target="#heroCarousel" data-bs-slide="prev">
                        <span class="carousel-control-prev-icon"></span>
                    </button>
                    <button class="carousel-control-next" type="button" data-bs-target="#heroCarousel" data-bs-slide="next">
                        <span class="carousel-control-next-icon"></span>
                    </button>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Search Filter Section -->
<section class="search-filter" data-aos="fade-up" data-aos-delay="300">
    <div class="container">
        <div class="row">
            <div class="col-md-4">
                <input type="text" class="search-input" placeholder="Event Name">
            </div>
            <div class="col-md-3">
                <input type="text" class="search-input" placeholder="Location">
            </div>
            <div class="col-md-3">
                <select class="search-input">
                    <option>Category</option>
                    <option>Music</option>
                    <option>Business</option>
                    <option>Technology</option>
                    <option>Education</option>
                </select>
            </div>
            <div class="col-md-2">
                <button class="search-btn w-100">Search</button>
            </div>
        </div>
    </div>
</section>

<!-- Upcoming Events Section -->
<section class="py-6">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="mb-0">Upcoming Events</h3>
        </div>

        <div class="row g-3">
            @forelse($upcomingEvents->take(4) as $index => $event)
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
                                <i class="bi bi-calendar-event me-1"></i>{{ \Carbon\Carbon::parse($event->startDate)->format('M d, Y') }}
                            </p>
                            <p class="card-text text-muted small mb-2">
                                <i class="bi bi-geo-alt me-1"></i>{{ $event->location ?? 'Location TBA' }}
                            </p>
                            <p class="card-text text-muted small">
                                <i class="bi bi-currency-dollar me-1"></i>
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

<!-- Why Choose EventGo: Feature Cards -->
<section id="features" class="mb-5">
    <div class="container mt-5">
        <h2 class="text-center mb-5" data-aos="fade-up">
            Why Choose EventGo?
        </h2>

        <div class="row g-4">
            <!-- Discover Events -->
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="60">
                <a href="{{ route('events.index') }}" class="text-decoration-none text-reset">
                    <div class="feature-card">
                        <div class="feature-icon" style="background:linear-gradient(135deg,#ff7ab6,#ff5fa1);">
                            <i class="bi bi-search"></i>
                        </div>
                        <h5>Discover Events</h5>
                        <p class="text-muted small">Find curated events near you, tailored to your interests — concerts, meetups, workshops and more.</p>
                        <div class="mt-3">
                            <span class="btn btn-sm btn-outline-primary">Learn more</span>
                        </div>
                    </div>
                </a>
            </div>

            <!-- Create & Host -->
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="120">
                <a href="{{ route('events.create') }}" class="text-decoration-none text-reset">
                    <div class="feature-card">
                        <div class="feature-icon" style="background: linear-gradient(135deg, #7c6bff, #5a9bff);">
                            <i class="bi bi-calendar-plus"></i>
                        </div>
                        <h5>Create & Host</h5>
                        <p class="text-muted small">Create events with flexible ticketing, custom descriptions, media galleries and promotion tools.</p>
                        <div class="mt-3">
                            <span class="btn btn-sm btn-outline-primary">Learn more</span>
                        </div>
                    </div>
                </a>
            </div>

            <!-- Connect & Follow -->
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="180">
                <a href="{{ route('about') }}" class="text-decoration-none text-reset">
                    <div class="feature-card">
                        <div class="feature-icon" style="background: linear-gradient(135deg, #5ad7ff, #6b8bff);">
                            <i class="bi bi-people"></i>
                        </div>
                        <h5>Connect & Follow</h5>
                        <p class="text-muted small">Follow organizers and attendees, receive updates and build a network of like-minded people.</p>
                        <div class="mt-3">
                            <span class="btn btn-sm btn-outline-primary">Learn more</span>
                        </div>
                    </div>
                </a>
            </div>

            <!-- Easy Booking -->
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="240">
                <a href="{{ route('events.index') }}" class="text-decoration-none text-reset">
                    <div class="feature-card">
                        <div class="feature-icon" style="background: linear-gradient(135deg, #8a7bff, #6fd4ff);">
                            <i class="bi bi-ticket-perforated"></i>
                        </div>
                        <h5>Easy Booking</h5>
                        <p class="text-muted small">Fast, secure checkout with multiple payment methods and digital ticket delivery.</p>
                        <div class="mt-3">
                            <span class="btn btn-sm btn-outline-primary">Learn more</span>
                        </div>
                    </div>
                </a>
            </div>

            <!-- Real-time Messaging -->
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="300">
                <a href="{{ route('contact') }}" class="text-decoration-none text-reset">
                    <div class="feature-card">
                        <div class="feature-icon" style="background: linear-gradient(135deg, #b67cff, #7ad9ff);">
                            <i class="bi bi-chat-dots"></i>
                        </div>
                        <h5>Real-time Messaging</h5>
                        <p class="text-muted small">Direct messages, group chats for events, push updates and announcements in real-time.</p>
                        <div class="mt-3">
                            <span class="btn btn-sm btn-outline-primary">Learn more</span>
                        </div>
                    </div>
                </a>
            </div>

            <!-- Create Ads -->
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="360">
                <a href="{{ route('ads.index') }}" class="text-decoration-none text-reset">
                    <div class="feature-card">
                        <div class="feature-icon" style="background: linear-gradient(135deg, #ff9980, #ff6b6b);">
                            <i class="bi bi-megaphone"></i>
                        </div>
                        <h5>Create Ads</h5>
                        <p class="text-muted small">Promote your event with targeted ads, audience controls and ROI tracking tools.</p>
                        <div class="mt-3">
                            <span class="btn btn-sm btn-outline-primary">Learn more</span>
                        </div>
                    </div>
                </a>
            </div>
        </div>
    </div>
</section>

<!-- Detailed Feature Sections -->
<div class="container mt-5 mb-0">

    <!-- Discover Section -->
    <section id="discover" class="my-5" data-aos="fade-up">
        <div class="detail-hero p-4 mb-4">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h3>Discover Events</h3>
                    <p class="text-muted">Use powerful filters — date, category, distance — and personalized recommendations so you never miss the events you care about.</p>
                    <ul class="list-unstyled small text-muted">
                        <li><i class="bi bi-check-circle-fill text-primary me-2"></i> Personalized suggestions</li>
                        <li><i class="bi bi-check-circle-fill text-primary me-2"></i> Nearby events with maps & directions</li>
                        <li><i class="bi bi-check-circle-fill text-primary me-2"></i> Save favorites and get alerts</li>
                    </ul>
                </div>
                <div class="col-md-4 text-md-end mt-3 mt-md-0">
                    <a class="btn btn-primary" href="{{ route('events.index') }}">Explore Events</a>
                </div>
            </div>
        </div>

        <div class="row g-3">
            @forelse($upcomingEvents->take(3) as $index => $event)
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="{{ 60 * ($index + 1) }}">
                <div class="card rounded-3 shadow-sm h-100">
                    @if($event->eventImage)
                        <img src="{{ asset($event->eventImage) }}" class="card-img-top" alt="{{ $event->eventTitle }}" style="height: 200px; object-fit: cover;" onerror="this.src='https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=1200&q=80'">
                    @else
                        <img src="https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=1200&q=80" class="card-img-top" alt="{{ $event->eventTitle }}" style="height: 200px; object-fit: cover;">
                    @endif
                    <div class="card-body">
                        <h5 class="card-title">{{ \Illuminate\Support\Str::limit($event->eventTitle, 30) }}</h5>
                        <p class="text-muted small">{{ $event->location ?? 'Location TBA' }} — {{ \Carbon\Carbon::parse($event->startDate)->format('M d') }} • ${{ $event->eventPrice ?? 'Free' }}</p>
                        <a class="btn btn-sm btn-outline-primary" href="{{ route('events.show', $event->eventId) }}">Book Now</a>
                    </div>
                </div>
            </div>
            @empty
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="60">
                <div class="card rounded-3 shadow-sm">
                    <img src="https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=1200&q=80" class="card-img-top" alt="" style="height: 200px; object-fit: cover;">
                    <div class="card-body">
                        <h5 class="card-title">Indie Summer Concert</h5>
                        <p class="text-muted small">Central Park — July 20 • $35</p>
                        <a class="btn btn-sm btn-outline-primary" href="{{ route('events.index') }}">Book</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="120">
                <div class="card rounded-3 shadow-sm">
                    <img src="https://images.unsplash.com/photo-1487014679447-9f8336841d58?auto=format&fit=crop&w=1200&q=80" class="card-img-top" alt="" style="height: 200px; object-fit: cover;">
                    <div class="card-body">
                        <h5 class="card-title">Artisan Market</h5>
                        <p class="text-muted small">Downtown — Aug 8 • Free</p>
                        <a class="btn btn-sm btn-outline-primary" href="{{ route('events.index') }}">RSVP</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="180">
                <div class="card rounded-3 shadow-sm">
                    <img src="https://images.unsplash.com/photo-1497032628192-86f99bcd76bc?auto=format&fit=crop&w=1200&q=80" class="card-img-top" alt="" style="height: 200px; object-fit: cover;">
                    <div class="card-body">
                        <h5 class="card-title">Startup Pitch Night</h5>
                        <p class="text-muted small">Tech Hub — Sep 12 • $10</p>
                        <a class="btn btn-sm btn-outline-primary" href="{{ route('events.index') }}">Buy Ticket</a>
                    </div>
                </div>
            </div>
            @endforelse
        </div>
    </section>

    <!-- Create & Host Section -->
    <section id="create" class="my-5" data-aos="fade-up">
        <div class="detail-hero p-4 mb-4">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h3>Create & Host Events</h3>
                    <p class="text-muted">Tools to create event pages, manage ticket types, set capacity, and promote across channels.</p>
                    <ol class="small text-muted">
                        <li>Create event page with images, agenda, speaker bios</li>
                        <li>Set tiered tickets: Early bird, General, VIP</li>
                        <li>Promotion tools and analytics dashboard</li>
                    </ol>
                </div>
                <div class="col-md-4 text-md-end mt-3 mt-md-0">
                    <a class="btn btn-outline-primary" href="{{ route('events.create') }}">Create Event</a>
                </div>
            </div>
        </div>
    </section>

    <!-- Connect & Follow Section -->
    <section id="connect" class="my-5" data-aos="fade-up">
        <div class="detail-hero p-4 mb-4">
            <h3>Connect & Follow</h3>
            <p class="text-muted">Follow people and organizers, join groups, and keep track of your favorite hosts.</p>
        </div>

        <div class="row g-3">
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="60">
                <div class="card p-3 h-100">
                    <h6>Follow Organizers</h6>
                    <p class="small text-muted">Get notified when organizers publish new events.</p>
                </div>
            </div>
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="120">
                <div class="card p-3 h-100">
                    <h6>Profiles & Social</h6>
                    <p class="small text-muted">User profiles with event history and badges for engagement.</p>
                </div>
            </div>
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="180">
                <div class="card p-3 h-100">
                    <h6>Network</h6>
                    <p class="small text-muted">See who else is attending and message other attendees.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Booking Section -->
    <section id="booking" class="my-5" data-aos="fade-up">
        <div class="detail-hero p-4 mb-4">
            <h3>Easy Booking & Tickets</h3>
            <p class="text-muted">Quick checkout, multiple payment methods, and digital tickets with QR codes.</p>
        </div>

        <div class="row g-3">
            <div class="col-md-6" data-aos="fade-up" data-aos-delay="80">
                <div class="card p-3 h-100">
                    <h6>Ticketing Types</h6>
                    <p class="small text-muted">General, VIP, Group passes, promo codes and refund options.</p>
                </div>
            </div>
            <div class="col-md-6" data-aos="fade-up" data-aos-delay="140">
                <div class="card p-3 h-100">
                    <h6>Secure Checkout</h6>
                    <p class="small text-muted">A secure checkout flow with Stripe/PayPal integration for seamless payments.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Messaging Section -->
    <section id="messaging" class="my-5" data-aos="fade-up">
        <div class="detail-hero p-4 mb-4">
            <h3>Real-time Messaging</h3>
            <p class="text-muted">Group chat for each event, private messages, and push notifications.</p>
        </div>

        <div class="row g-3">
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="60">
                <div class="card p-3 h-100">
                    <h6>Event Chat</h6>
                    <p class="small text-muted">Join conversations with other attendees before and during the event.</p>
                </div>
            </div>

            <div class="col-md-4" data-aos="fade-up" data-aos-delay="120">
                <div class="card p-3 h-100">
                    <h6>DMs & Notifications</h6>
                    <p class="small text-muted">Direct messages with search and push alerts.</p>
                </div>
            </div>

            <div class="col-md-4" data-aos="fade-up" data-aos-delay="180">
                <div class="card p-3 h-100">
                    <h6>Moderation</h6>
                    <p class="small text-muted">Moderation tools for organizers and community controls.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Ads Section -->
    <section id="ads" class="mt-5 mb-5" data-aos="fade-up">
        <div class="detail-hero p-4 mb-4">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h3>Create Ads</h3>
                    <p class="text-muted">Promote events with targeted campaigns, budgets, and audience filters.</p>
                </div>
                <div class="col-md-4 text-md-end mt-3 mt-md-0">
                    <a class="btn btn-primary" href="{{ route('ads.index') }}">Create Ad</a>
                </div>
            </div>
        </div>

        <div class="row g-3">
            <div class="col-md-4" data-aos="fade-up" data-aos-delay="60">
                <div class="card p-3 h-100">
                    <h6>Ad Builder</h6>
                    <p class="small text-muted">Create visuals, copy, and audience targeting in a few steps.</p>
                </div>
            </div>

            <div class="col-md-4" data-aos="fade-up" data-aos-delay="120">
                <div class="card p-3 h-100">
                    <h6>Analytics</h6>
                    <p class="small text-muted">Track impressions, clicks, and ticket conversion from ad campaigns.</p>
                </div>
            </div>

            <div class="col-md-4" data-aos="fade-up" data-aos-delay="180">
                <div class="card p-3 h-100">
                    <h6>Sponsored Listings</h6>
                    <p class="small text-muted">Promote event spots in the discovery feeds and search results.</p>
                </div>
            </div>
        </div>
    </section>

</div>

<style>
/* Remove extra spacing at bottom */
.container.mt-5.mb-0 {
    padding-bottom: 0 !important;
    margin-bottom: 0 !important;
}

#ads {
    margin-bottom: 0 !important;
    padding-bottom: 2rem !important;
}
</style>

@endsection
