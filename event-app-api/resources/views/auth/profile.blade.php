@extends('layouts.app')

@section('title', 'Profile - EventGo')

@section('content')
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <!-- Profile Header -->
            <div class="profile-header text-center mb-5" data-aos="fade-up">
                <div class="profile-avatar mb-3">
                    @if(Auth::user()->profileImageUrl)
                        <img src="{{ asset(Auth::user()->profileImageUrl) }}"
                             alt="{{ Auth::user()->name }}"
                             class="profile-image-large">
                    @else
                        <div class="profile-image-placeholder-large">
                            <i class="fas fa-user"></i>
                        </div>
                    @endif
                </div>
                <h2 class="profile-name">{{ Auth::user()->name }}</h2>
                <p class="profile-email text-muted">{{ Auth::user()->email }}</p>
                <div class="profile-status">
                    @if(Auth::user()->emailVerified == 1)
                        <span class="badge bg-success">
                            <i class="fas fa-check-circle me-1"></i>Email Verified
                        </span>
                    @else
                        <span class="badge bg-warning">
                            <i class="fas fa-exclamation-triangle me-1"></i>Email Not Verified
                        </span>
                    @endif
                    @if(Auth::user()->isActive == 1)
                        <span class="badge bg-primary ms-2">
                            <i class="fas fa-user-check me-1"></i>Active
                        </span>
                    @else
                        <span class="badge bg-danger ms-2">
                            <i class="fas fa-user-times me-1"></i>Inactive
                        </span>
                    @endif
                </div>
                <div class="mt-4">
                    <form method="POST" action="{{ route('logout') }}" class="d-inline">
                        @csrf
                        <button type="submit" class="btn btn-outline-danger">
                            <i class="fas fa-sign-out-alt me-2"></i>Logout
                        </button>
                    </form>
                </div>
            </div>

            <!-- Profile Tabs -->
            <div class="profile-tabs" data-aos="fade-up" data-aos-delay="100">
                <ul class="nav nav-tabs" id="profileTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="info-tab" data-bs-toggle="tab" data-bs-target="#info" type="button" role="tab">
                            <i class="fas fa-user me-2"></i>Personal Info
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="events-tab" data-bs-toggle="tab" data-bs-target="#events" type="button" role="tab">
                            <i class="fas fa-calendar me-2"></i>My Events
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="bookings-tab" data-bs-toggle="tab" data-bs-target="#bookings" type="button" role="tab">
                            <i class="fas fa-ticket-alt me-2"></i>My Bookings
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="ads-tab" data-bs-toggle="tab" data-bs-target="#ads" type="button" role="tab">
                            <i class="fas fa-bullhorn me-2"></i>My Ads
                        </button>
                    </li>
                </ul>

                <div class="tab-content" id="profileTabsContent">
                    <!-- Personal Info Tab -->
                    <div class="tab-pane fade show active" id="info" role="tabpanel">
                        <div class="card border-0 shadow-sm mt-3">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">
                                    <i class="fas fa-edit me-2"></i>Edit Profile Information
                                </h5>
                            </div>
                            <div class="card-body">
                                <form method="POST" action="{{ route('profile.update') }}" enctype="multipart/form-data">
                                    @csrf

                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label for="name" class="form-label">Full Name</label>
                                            <input type="text" class="form-control @error('name') is-invalid @enderror"
                                                   id="name" name="name" value="{{ old('name', Auth::user()->name) }}" required>
                                            @error('name')
                                                <div class="invalid-feedback">{{ $error }}</div>
                                            @enderror
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label for="email" class="form-label">Email Address</label>
                                            <input type="email" class="form-control @error('email') is-invalid @enderror"
                                                   id="email" name="email" value="{{ old('email', Auth::user()->email) }}" required>
                                            @error('email')
                                                <div class="invalid-feedback">{{ $error }}</div>
                                            @enderror
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label for="phone" class="form-label">Phone Number</label>
                                            <input type="tel" class="form-control @error('phone') is-invalid @enderror"
                                                   id="phone" name="phone" value="{{ old('phone', Auth::user()->phoneNumber) }}">
                                            @error('phone')
                                                <div class="invalid-feedback">{{ $error }}</div>
                                            @enderror
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label for="profile_image" class="form-label">Profile Image</label>

                                            <!-- Current Image Preview -->
                                            @if(Auth::user()->profileImageUrl)
                                                <div class="current-image-preview mb-3">
                                                    <img src="{{ asset(Auth::user()->profileImageUrl) }}"
                                                         alt="Current Profile"
                                                         style="width: 80px; height: 80px; object-fit: cover; border-radius: 50%; border: 2px solid #e9ecef;">
                                                    <div class="mt-2">
                                                        <small class="text-muted">Current profile image</small>
                                                    </div>
                                                </div>
                                            @endif

                                            <!-- Custom File Input -->
                                            <div class="custom-file-input">
                                                <input type="file"
                                                       class="form-control @error('profile_image') is-invalid @enderror"
                                                       id="profile_image"
                                                       name="profile_image"
                                                       accept="image/*"
                                                       onchange="previewImage(this)">
                                                <label for="profile_image" class="custom-file-label">
                                                    <i class="fas fa-camera me-2"></i>Choose Profile Image
                                                </label>
                                            </div>

                                            <!-- Image Preview -->
                                            <div id="imagePreview" class="mt-3" style="display: none;">
                                                <img id="preview" style="width: 80px; height: 80px; object-fit: cover; border-radius: 50%; border: 2px solid #584CF4;">
                                                <div class="mt-2">
                                                    <small class="text-muted">New profile image preview</small>
                                                </div>
                                            </div>

                                            @error('profile_image')
                                                <div class="invalid-feedback d-block">{{ $error }}</div>
                                            @enderror
                                            <small class="form-text text-muted">Max size: 2MB. Supported formats: JPG, PNG, GIF</small>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label for="shortBio" class="form-label">Bio</label>
                                        <textarea class="form-control @error('shortBio') is-invalid @enderror"
                                                  id="shortBio" name="shortBio" rows="3"
                                                  placeholder="Tell us about yourself...">{{ old('shortBio', Auth::user()->shortBio) }}</textarea>
                                        @error('shortBio')
                                            <div class="invalid-feedback">{{ $error }}</div>
                                        @enderror
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Interests</label>
                                        <div class="row">
                                            @php
                                                $interests = ['Music', 'Sports', 'Technology', 'Art', 'Food', 'Travel', 'Education', 'Business', 'Health', 'Entertainment'];
                                                $userInterests = Auth::user()->interests ?? [];
                                            @endphp
                                            @foreach($interests as $interest)
                                                <div class="col-md-4 col-sm-6 mb-2">
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="checkbox"
                                                               name="interests[]" value="{{ $interest }}"
                                                               id="interest_{{ $loop->index }}"
                                                               {{ in_array($interest, $userInterests) ? 'checked' : '' }}>
                                                        <label class="form-check-label" for="interest_{{ $loop->index }}">
                                                            {{ $interest }}
                                                        </label>
                                                    </div>
                                                </div>
                                            @endforeach
                                        </div>
                                    </div>

                                    <div class="d-flex justify-content-between">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-save me-2"></i>Update Profile
                                        </button>
                                        <a href="{{ route('home') }}" class="btn btn-outline-secondary">
                                            <i class="fas fa-arrow-left me-2"></i>Back to Home
                                        </a>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <!-- Square Payment Connection Section (for Organizers) -->
                        @if($organizer)
                        <div class="card border-0 shadow-sm mt-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">
                                    <i class="fas fa-credit-card me-2"></i>Square Payment Account
                                </h5>
                            </div>
                            <div class="card-body">
                                @if($squareAccount)
                                    <div class="alert alert-success d-flex align-items-center" role="alert">
                                        <i class="fas fa-check-circle me-2 fa-lg"></i>
                                        <div>
                                            <strong>Square Account Connected!</strong>
                                            <p class="mb-0 small">
                                                @if($squareAccount->merchantName)
                                                    Merchant: {{ $squareAccount->merchantName }}
                                                @endif
                                                <br>
                                                <small class="text-muted">Connected on {{ \Carbon\Carbon::parse($squareAccount->connectedAt)->format('M d, Y') }}</small>
                                            </p>
                                            <p class="mb-0 mt-2 small text-muted">
                                                You'll receive payments directly to your Square account. App owner commission ({{ config('square.commission_rate', 10) }}%) will be automatically deducted.
                                            </p>
                                        </div>
                                    </div>
                                    <form method="POST" action="{{ route('square.disconnect') }}" class="mt-3">
                                        @csrf
                                        <button type="submit" class="btn btn-outline-danger btn-sm" onclick="return confirm('Are you sure you want to disconnect your Square account?')">
                                            <i class="fas fa-unlink me-2"></i>Disconnect Square Account
                                        </button>
                                    </form>
                                @else
                                    <div class="alert alert-info d-flex align-items-start" role="alert">
                                        <i class="fas fa-info-circle me-2 fa-lg mt-1"></i>
                                        <div>
                                            <strong>Connect Your Square Account</strong>
                                            <p class="mb-2 small">
                                                Connect your Square account to receive payments directly when customers book your events.
                                                The app owner commission ({{ config('square.commission_rate', 10) }}%) will be automatically deducted.
                                            </p>
                                            <a href="{{ route('square.connect') }}" class="btn btn-primary btn-sm">
                                                <i class="fas fa-link me-2"></i>Connect Square Account
                                            </a>
                                        </div>
                                    </div>
                                    <div class="mt-3">
                                        <small class="text-muted">
                                            <i class="fas fa-shield-alt me-1"></i>
                                            Your payment information is securely handled by Square. We never store your card details.
                                        </small>
                                    </div>
                                @endif
                            </div>
                        </div>
                        @endif

                        <!-- Change Password Section -->
                        <div class="card border-0 shadow-sm mt-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">
                                    <i class="fas fa-lock me-2"></i>Change Password
                                </h5>
                            </div>
                            <div class="card-body">
                                <form method="POST" action="{{ route('profile.password') }}">
                                    @csrf

                                    <div class="row">
                                        <div class="col-md-4 mb-3">
                                            <label for="current_password" class="form-label">Current Password</label>
                                            <input type="password" class="form-control @error('current_password') is-invalid @enderror"
                                                   id="current_password" name="current_password" required>
                                            @error('current_password')
                                                <div class="invalid-feedback">{{ $error }}</div>
                                            @enderror
                                        </div>
                                        <div class="col-md-4 mb-3">
                                            <label for="new_password" class="form-label">New Password</label>
                                            <input type="password" class="form-control @error('new_password') is-invalid @enderror"
                                                   id="new_password" name="new_password" required>
                                            @error('new_password')
                                                <div class="invalid-feedback">{{ $error }}</div>
                                            @enderror
                                        </div>
                                        <div class="col-md-4 mb-3">
                                            <label for="new_password_confirmation" class="form-label">Confirm New Password</label>
                                            <input type="password" class="form-control @error('new_password_confirmation') is-invalid @enderror"
                                                   id="new_password_confirmation" name="new_password_confirmation" required>
                                            @error('new_password_confirmation')
                                                <div class="invalid-feedback">{{ $error }}</div>
                                            @enderror
                                        </div>
                                    </div>

                                    <div style="font-size: 0.75rem; color: #666; margin-bottom: 1rem; padding: 0.5rem; background: #f8f9ff; border-radius: 5px;">
                                        <strong>Password Requirements:</strong><br>
                                        • At least 8 characters<br>
                                        • Uppercase letter (A-Z)<br>
                                        • Lowercase letter (a-z)<br>
                                        • Number (0-9)<br>
                                        • Special character (@$!%*#?&)
                                    </div>

                                    <button type="submit" class="btn btn-warning">
                                        <i class="fas fa-key me-2"></i>Change Password
                                    </button>
                                </form>
                            </div>
                        </div>

                        <!-- Delete Account Section -->
                        <div class="card border-0 shadow-sm mt-4 border-danger" style="border-width: 2px !important;">
                            <div class="card-header bg-white">
                                <h5 class="mb-0 text-danger">
                                    <i class="fas fa-exclamation-triangle me-2"></i>Delete Account
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="alert alert-danger d-flex align-items-start" role="alert">
                                    <i class="fas fa-exclamation-circle me-2 fa-lg mt-1"></i>
                                    <div>
                                        <strong>Warning: This action cannot be undone!</strong>
                                        <p class="mb-2 small">
                                            Deleting your account will permanently remove all your data, including:
                                        </p>
                                        <ul class="small mb-0">
                                            <li>Your profile and personal information</li>
                                            <li>All events you've created</li>
                                            <li>All your bookings and tickets</li>
                                            <li>Your followers and following relationships</li>
                                            <li>All your ads and campaigns</li>
                                            <li>Your payment and transaction history</li>
                                        </ul>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#deleteAccountModal">
                                    <i class="fas fa-trash-alt me-2"></i>Delete My Account
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- My Events Tab -->
                    <div class="tab-pane fade" id="events" role="tabpanel">
                        <div class="card border-0 shadow-sm mt-3">
                            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">
                                    <i class="fas fa-calendar me-2"></i>Events Created by You
                                </h5>
                                <a href="{{ route('events.create') }}" class="btn btn-primary btn-sm">
                                    <i class="fas fa-plus me-1"></i>Create Event
                                </a>
                            </div>
                            <div class="card-body">
                                @if($userEvents && $userEvents->count() > 0)
                                    <div class="row">
                                        @foreach($userEvents as $event)
                                            <div class="col-12 mb-4">
                                                <div class="card border-0 shadow-sm event-card">
                                                    <div class="row g-0">
                                                        <div class="col-md-4 position-relative">
                                                            @if($event->eventImage)
                                                                <img src="{{ asset($event->eventImage) }}"
                                                                     alt="{{ $event->eventTitle }}"
                                                                     class="img-fluid rounded-start"
                                                                     style="height: 200px; width: 100%; object-fit: cover;"
                                                                     onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=400&q=80';">
                                                            @else
                                                                <img src="https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=400&q=80"
                                                                     alt="{{ $event->eventTitle }}"
                                                                     class="img-fluid rounded-start"
                                                                     style="height: 200px; width: 100%; object-fit: cover;">
                                                            @endif
                                                            <div class="position-absolute top-0 end-0 m-2">
                                                                <span class="badge bg-{{ $event->eventPrice > 0 ? 'success' : 'info' }}">
                                                                    {{ $event->eventPrice > 0 ? '$' . number_format($event->eventPrice, 2) : 'Free' }}
                                                                </span>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-8">
                                                            <div class="card-body h-100 d-flex flex-column">
                                                        <h6 class="card-title text-truncate">{{ $event->eventTitle }}</h6>
                                                        <div class="mb-2">
                                                            <small class="text-muted">
                                                                <i class="fas fa-calendar me-1"></i>
                                                                {{ \Carbon\Carbon::parse($event->startDate)->format('M d, Y') }}
                                                            </small>
                                                        </div>
                                                        <div class="mb-2">
                                                            <small class="text-muted">
                                                                <i class="fas fa-clock me-1"></i>
                                                                {{ \Carbon\Carbon::parse($event->startTime)->format('g:i A') }}
                                                            </small>
                                                        </div>
                                                        <div class="mb-3">
                                                            <small class="text-muted">
                                                                <i class="fas fa-map-marker-alt me-1"></i>
                                                                {{ $event->city ?? 'Location TBA' }}
                                                            </small>
                                                        </div>
                                                        <div class="mt-auto">
                                                            <div class="d-grid gap-2">
                                                                <a href="{{ route('events.show', $event->eventId) }}" class="btn btn-outline-primary btn-sm">
                                                                    <i class="fas fa-eye me-1"></i>View Event
                                                                </a>
                                                            </div>
                                                        </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        @endforeach
                                    </div>
                                @else
                                    <div class="text-center text-muted py-5">
                                        <i class="fas fa-calendar-plus fa-3x mb-3"></i>
                                        <h5>No events created yet</h5>
                                        <p>Start creating amazing events for your community!</p>
                                        <a href="{{ route('events.create') }}" class="btn btn-primary">
                                            <i class="fas fa-plus me-2"></i>Create Your First Event
                                        </a>
                                    </div>
                                @endif
                            </div>
                        </div>
                    </div>

                    <!-- My Bookings Tab -->
                    <div class="tab-pane fade" id="bookings" role="tabpanel">
                        <div class="card border-0 shadow-sm mt-3">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">
                                    <i class="fas fa-ticket-alt me-2"></i>Your Event Bookings
                                </h5>
                            </div>
                            <div class="card-body">
                                @if($bookings && $bookings->count() > 0)
                                    <div class="row">
                                        @foreach($bookings as $booking)
                                            <div class="col-12 mb-4">
                                                <div class="card border-0 shadow-sm booking-card">
                                                    <div class="row g-0">
                                                        <div class="col-md-4 position-relative">
                                                            @if($booking->eventImage)
                                                                <img src="{{ asset($booking->eventImage) }}"
                                                                     alt="{{ $booking->eventTitle }}"
                                                                     class="img-fluid rounded-start"
                                                                     style="height: 200px; width: 100%; object-fit: cover;"
                                                                     onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=400&q=80';">
                                                            @else
                                                                <img src="https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=400&q=80"
                                                                     alt="{{ $booking->eventTitle }}"
                                                                     class="img-fluid rounded-start"
                                                                     style="height: 200px; width: 100%; object-fit: cover;">
                                                            @endif
                                                            <div class="position-absolute top-0 end-0 m-2">
                                                                <span class="badge bg-success">{{ ucfirst($booking->status ?? 'confirmed') }}</span>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-8">
                                                            <div class="card-body h-100 d-flex flex-column">
                                                        <h6 class="card-title text-truncate">{{ $booking->eventTitle }}</h6>
                                                        <div class="mb-2">
                                                            <small class="text-muted">
                                                                <i class="fas fa-calendar me-1"></i>
                                                                {{ \Carbon\Carbon::parse($booking->startDate)->format('M d, Y') }}
                                                            </small>
                                                        </div>
                                                        <div class="mb-2">
                                                            <small class="text-muted">
                                                                <i class="fas fa-clock me-1"></i>
                                                                {{ \Carbon\Carbon::parse($booking->startTime)->format('g:i A') }}
                                                            </small>
                                                        </div>
                                                        <div class="mb-2">
                                                            <small class="text-muted">
                                                                <i class="fas fa-map-marker-alt me-1"></i>
                                                                {{ $booking->city ?? 'Location TBA' }}
                                                            </small>
                                                        </div>
                                                        <div class="mb-3">
                                                            <small class="text-muted">
                                                                <i class="fas fa-ticket-alt me-1"></i>
                                                                {{ $booking->quantity }}x {{ ucfirst($booking->ticketType) }} Ticket(s)
                                                            </small>
                                                        </div>
                                                        <div class="mt-auto">
                                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                                <strong class="text-primary">${{ number_format($booking->totalAmount, 2) }}</strong>
                                                                <small class="text-muted">Booking #{{ $booking->bookingId }}</small>
                                                            </div>
                                                            <div class="d-grid gap-2">
                                                                <button class="btn btn-primary btn-sm" onclick="downloadTicket({{ $booking->bookingId }})">
                                                                    <i class="fas fa-download me-1"></i>Download Ticket
                                                                </button>
                                                            </div>
                                                        </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        @endforeach
                                    </div>
                                @else
                                    <div class="text-center text-muted py-5">
                                        <i class="fas fa-ticket-alt fa-3x mb-3"></i>
                                        <h5>No bookings yet</h5>
                                        <p>Discover and book amazing events!</p>
                                        <a href="{{ route('events.index') }}" class="btn btn-primary">
                                            <i class="fas fa-search me-2"></i>Browse Events
                                        </a>
                                    </div>
                                @endif
                            </div>
                        </div>
                    </div>

                    <!-- My Ads Tab -->
                    <div class="tab-pane fade" id="ads" role="tabpanel">
                        <div class="card border-0 shadow-sm mt-3">
                            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">
                                    <i class="fas fa-bullhorn me-2"></i>Your Campaigns
                                </h5>
                            </div>
                            <div class="card-body">
                                @php
                                    $userAds = DB::table('donation')
                                        ->where('userId', Auth::id())
                                        ->orderBy('addDate', 'desc')
                                        ->get();
                                @endphp

                                @if($userAds->count() > 0)
                                    <div class="row">
                                        @foreach($userAds as $ad)
                                            @php
                                                $totalRaised = DB::table('donation_transactions')
                                                    ->where('donationId', $ad->donationId)
                                                    ->sum('amount');
                                                $donationCount = DB::table('donation_transactions')
                                                    ->where('donationId', $ad->donationId)
                                                    ->count();
                                                $progress = $ad->amount > 0 ? min(($totalRaised / $ad->amount) * 100, 100) : 0;
                                            @endphp

                                            <div class="col-md-6 mb-3">
                                                <div class="card border-0 shadow-sm h-100">
                                                    <div class="position-relative">
                                                        @if($ad->imageUrl)
                                                            <img src="{{ asset($ad->imageUrl) }}"
                                                                 class="card-img-top"
                                                                 alt="{{ $ad->title }}"
                                                                 style="height: 150px; object-fit: cover;">
                                                        @else
                                                            <div class="card-img-top bg-light d-flex align-items-center justify-content-center"
                                                                 style="height: 150px;">
                                                                <i class="fas fa-image fa-2x text-muted"></i>
                                                            </div>
                                                        @endif
                                                        <div class="position-absolute top-0 end-0 m-2">
                                                            @if($ad->isActive == 1)
                                                                <span class="badge bg-success">Active</span>
                                                            @else
                                                                <span class="badge bg-secondary">Inactive</span>
                                                            @endif
                                                        </div>
                                                    </div>

                                                    <div class="card-body d-flex flex-column">
                                                        <h6 class="card-title fw-bold">{{ $ad->title }}</h6>
                                                        <p class="card-text text-muted small flex-grow-1">
                                                            {{ Str::limit($ad->description, 80) }}
                                                        </p>

                                                        <div class="mt-auto">
                                                            <!-- Progress -->
                                                            <div class="mb-2">
                                                                <div class="d-flex justify-content-between mb-1">
                                                                    <small class="text-muted">Progress</small>
                                                                    <small class="text-muted">{{ number_format($progress, 1) }}%</small>
                                                                </div>
                                                                <div class="progress" style="height: 6px;">
                                                                    <div class="progress-bar bg-primary"
                                                                         style="width: {{ $progress }}%"></div>
                                                                </div>
                                                            </div>

                                                            <!-- Stats -->
                                                            <div class="row text-center mb-2">
                                                                <div class="col-4">
                                                                    <h6 class="fw-bold text-primary mb-0 small">${{ number_format($totalRaised, 0) }}</h6>
                                                                    <small class="text-muted">Raised</small>
                                                                </div>
                                                                <div class="col-4">
                                                                    <h6 class="fw-bold text-warning mb-0 small">${{ number_format($ad->amount, 0) }}</h6>
                                                                    <small class="text-muted">Goal</small>
                                                                </div>
                                                                <div class="col-4">
                                                                    <h6 class="fw-bold text-success mb-0 small">{{ $donationCount }}</h6>
                                                                    <small class="text-muted">Donors</small>
                                                                </div>
                                                            </div>

                                                            <!-- Actions -->
                                                            <div class="d-flex gap-1">
                                                                <a href="{{ route('ads.show', $ad->donationId) }}"
                                                                   class="btn btn-outline-primary btn-sm flex-grow-1">
                                                                    <i class="fas fa-eye"></i>
                                                                </a>
                                                                <a href="{{ route('ads.edit', $ad->donationId) }}"
                                                                   class="btn btn-outline-secondary btn-sm">
                                                                    <i class="fas fa-edit"></i>
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        @endforeach
                                    </div>
                                @else
                                    <div class="text-center text-muted py-5">
                                        <i class="fas fa-bullhorn fa-3x mb-3"></i>
                                        <h5>No campaigns yet</h5>
                                        <p>Start your first fundraising campaign!</p>
                                        <a href="{{ route('ads.create') }}" class="btn btn-primary">
                                            <i class="fas fa-plus me-2"></i>Create Your First Campaign
                                        </a>
                                    </div>
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.profile-header {
    background: white;
    border-radius: 20px;
    padding: 2rem;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.profile-avatar {
    position: relative;
    display: inline-block;
}

.profile-image-large {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    object-fit: cover;
    border: 4px solid #584CF4;
    box-shadow: 0 8px 32px rgba(88, 76, 244, 0.3);
}

.profile-image-placeholder-large {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    background: #584CF4;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 48px;
    border: 4px solid #584CF4;
    box-shadow: 0 8px 32px rgba(88, 76, 244, 0.3);
}

.profile-name {
    color: #2c2c2c;
    font-weight: 700;
    margin-bottom: 0.5rem;
}

.profile-email {
    font-size: 1.1rem;
    margin-bottom: 1rem;
}

.profile-tabs .nav-tabs {
    border-bottom: 2px solid #e9ecef;
}

.profile-tabs .nav-tabs .nav-link {
    border: none;
    color: #6c757d;
    font-weight: 500;
    padding: 1rem 1.5rem;
    border-radius: 0;
    transition: all 0.3s ease;
}

.profile-tabs .nav-tabs .nav-link:hover {
    color: #584CF4;
    background: #f8f9ff;
}

.profile-tabs .nav-tabs .nav-link.active {
    color: #584CF4;
    background: #f8f9ff;
    border-bottom: 2px solid #584CF4;
}

.card {
    border-radius: 15px;
    transition: all 0.3s ease;
}

.card:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15) !important;
}

.form-control:focus {
    border-color: #584CF4;
    box-shadow: 0 0 0 0.2rem rgba(88, 76, 244, 0.25);
}

.btn-primary {
    background: #584CF4;
    border-color: #584CF4;
}

.btn-primary:hover {
    background: #4a3dd1;
    border-color: #4a3dd1;
}

.btn-warning {
    background: #ff9500;
    border-color: #ff9500;
}

.btn-warning:hover {
    background: #e6850e;
    border-color: #e6850e;
}

.badge {
    font-size: 0.8rem;
    padding: 0.5rem 0.8rem;
}

@media (max-width: 768px) {
    .profile-header {
        padding: 1.5rem;
    }

    .profile-image-large,
    .profile-image-placeholder-large {
        width: 80px;
        height: 80px;
        font-size: 32px;
    }

    .profile-tabs .nav-tabs .nav-link {
        padding: 0.8rem 1rem;
        font-size: 0.9rem;
    }
}

/* Booking Cards */
.booking-card {
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    border-radius: 12px;
    overflow: hidden;
}

.booking-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15) !important;
}

.booking-card .img-fluid {
    border-radius: 12px 0 0 12px;
}

.booking-card .badge {
    font-size: 0.75rem;
    padding: 0.4rem 0.6rem;
}

/* Event Cards */
.event-card {
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    border-radius: 12px;
    overflow: hidden;
}

.event-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15) !important;
}

.event-card .img-fluid {
    border-radius: 12px 0 0 12px;
}

.event-card .badge {
    font-size: 0.75rem;
    padding: 0.4rem 0.6rem;
}

/* Toast Notifications */
.toast-notification {
    position: fixed;
    top: 20px;
    right: 20px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    padding: 1rem 1.5rem;
    z-index: 9999;
    transform: translateX(100%);
    transition: transform 0.3s ease;
    border-left: 4px solid #584CF4;
    min-width: 300px;
}

.toast-notification.show {
    transform: translateX(0);
}

.toast-success {
    border-left-color: #28a745;
}

.toast-error {
    border-left-color: #dc3545;
}

.toast-warning {
    border-left-color: #ffc107;
}

.toast-info {
    border-left-color: #17a2b8;
}

.toast-content {
    display: flex;
    align-items: center;
    font-weight: 500;
    color: #333;
}

/* Custom File Input Styles */
.custom-file-input {
    position: relative;
    display: inline-block;
    width: 100%;
}

.custom-file-input input[type="file"] {
    position: absolute;
    opacity: 0;
    width: 100%;
    height: 100%;
    cursor: pointer;
    z-index: 2;
}

.custom-file-label {
    display: block;
    padding: 0.75rem 1rem;
    background: #f8f9fa;
    border: 2px dashed #584CF4;
    border-radius: 8px;
    text-align: center;
    cursor: pointer;
    transition: all 0.3s ease;
    color: #584CF4;
    font-weight: 500;
}

.custom-file-label:hover {
    background: #f0f0ff;
    border-color: #4a3bc7;
}

.custom-file-input:hover .custom-file-label {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(88, 76, 244, 0.15);
}

.current-image-preview {
    text-align: center;
}
</style>

<script>
function previewImage(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();

        reader.onload = function(e) {
            document.getElementById('preview').src = e.target.result;
            document.getElementById('imagePreview').style.display = 'block';
        }

        reader.readAsDataURL(input.files[0]);
    }
}

// Update file label when file is selected
document.getElementById('profile_image').addEventListener('change', function(e) {
    const fileName = e.target.files[0] ? e.target.files[0].name : 'Choose Profile Image';
    const label = document.querySelector('.custom-file-label');
    label.innerHTML = '<i class="fas fa-camera me-2"></i>' + fileName;
});

// Download ticket functionality
function downloadTicket(bookingId) {
    // Show loading state
    const button = event.target;
    const originalText = button.innerHTML;
    button.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Generating...';
    button.disabled = true;

    // Open PDF in new window for download
    const ticketUrl = `{{ url('/ticket') }}/${bookingId}`;
    window.open(ticketUrl, '_blank');

    // Reset button after a short delay
    setTimeout(() => {
        button.innerHTML = originalText;
        button.disabled = false;

        // Show success message
        showToast('Ticket PDF generated successfully!', 'success');
    }, 2000);
}

// Toast notification function
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast-notification toast-${type}`;
    toast.innerHTML = `
        <div class="toast-content">
            <i class="fas fa-${type === 'success' ? 'check-circle' : 'info-circle'} me-2"></i>
            ${message}
        </div>
    `;

    document.body.appendChild(toast);

    // Show toast
    setTimeout(() => toast.classList.add('show'), 100);

    // Hide toast after 3 seconds
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => document.body.removeChild(toast), 300);
    }, 3000);
}
</script>

<!-- Delete Account Confirmation Modal -->
<div class="modal fade" id="deleteAccountModal" tabindex="-1" aria-labelledby="deleteAccountModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-danger" style="border-width: 2px;">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title text-white" id="deleteAccountModalLabel">
                    <i class="fas fa-exclamation-triangle me-2"></i>Confirm Account Deletion
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="alert alert-danger mb-3">
                    <strong>⚠️ This action is permanent and cannot be undone!</strong>
                </div>
                <p>Are you absolutely sure you want to delete your account? This will permanently remove:</p>
                <ul class="mb-3">
                    <li>Your profile and personal information</li>
                    <li>All events you've created</li>
                    <li>All your bookings and tickets</li>
                    <li>Your followers and following relationships</li>
                    <li>All your ads and campaigns</li>
                    <li>Your payment and transaction history</li>
                </ul>
                <p class="text-danger fw-bold">Once deleted, you will not be able to recover any of this data.</p>
                <form method="POST" action="{{ route('profile.delete') }}" id="deleteAccountForm">
                    @csrf
                    <div class="mb-3">
                        <label for="confirmDelete" class="form-label">Type <strong>"DELETE"</strong> to confirm:</label>
                        <input type="text" class="form-control" id="confirmDelete" name="confirmDelete" required>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="fas fa-times me-2"></i>Cancel
                </button>
                <button type="button" class="btn btn-danger" id="confirmDeleteBtn" disabled>
                    <i class="fas fa-trash-alt me-2"></i>Delete My Account
                </button>
            </div>
        </div>
    </div>
</div>

<script>
// Enable delete button only when user types "DELETE"
document.getElementById('confirmDelete').addEventListener('input', function(e) {
    const confirmBtn = document.getElementById('confirmDeleteBtn');
    if (e.target.value === 'DELETE') {
        confirmBtn.disabled = false;
        confirmBtn.classList.remove('btn-secondary');
        confirmBtn.classList.add('btn-danger');
    } else {
        confirmBtn.disabled = true;
        confirmBtn.classList.remove('btn-danger');
        confirmBtn.classList.add('btn-secondary');
    }
});

// Handle form submission
document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
    const confirmInput = document.getElementById('confirmDelete').value;
    if (confirmInput === 'DELETE') {
        // Show loading state
        this.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Deleting...';
        this.disabled = true;
        
        // Submit the form
        document.getElementById('deleteAccountForm').submit();
    }
});
</script>
@endsection
