@extends('layouts.app')

@section('title', 'Ads & Donations - EventGo')

@section('content')
<div class="container py-5">
    <!-- Header Section -->
    <div class="row mb-5" data-aos="fade-up">
        <div class="col-12 text-center">
            <h1 class="display-4 fw-bold text-dark mb-3">Ads & Donations</h1>
            <p class="lead text-muted mb-4">Support meaningful causes and campaigns in your community</p>
            @auth
                <a href="{{ route('ads.create') }}" class="btn btn-primary btn-lg">
                    <i class="fas fa-plus me-2"></i>Create New Ad
                </a>
            @else
                <a href="{{ route('login') }}?redirect={{ urlencode(route('ads.create')) }}" class="btn btn-primary btn-lg">
                    <i class="fas fa-sign-in-alt me-2"></i>Login to Create Ad
                </a>
            @endauth
        </div>
    </div>

    <!-- Stats Section -->
    <div class="row mb-5" data-aos="fade-up" data-aos-delay="100">
        <div class="col-md-4 mb-3">
            <div class="card border-0 shadow-sm text-center h-100">
                <div class="card-body">
                    <i class="fas fa-hand-holding-heart fa-3x text-primary mb-3"></i>
                    <h3 class="fw-bold">{{ $stats['active_campaigns'] }}</h3>
                    <p class="text-muted mb-0">Active Campaigns</p>
                </div>
            </div>
        </div>
        <div class="col-md-4 mb-3">
            <div class="card border-0 shadow-sm text-center h-100">
                <div class="card-body">
                    <i class="fas fa-dollar-sign fa-3x text-success mb-3"></i>
                    <h3 class="fw-bold">${{ number_format($stats['total_raised'], 0) }}</h3>
                    <p class="text-muted mb-0">Total Raised</p>
                </div>
            </div>
        </div>
        <div class="col-md-4 mb-3">
            <div class="card border-0 shadow-sm text-center h-100">
                <div class="card-body">
                    <i class="fas fa-users fa-3x text-info mb-3"></i>
                    <h3 class="fw-bold">{{ $stats['total_donations'] }}</h3>
                    <p class="text-muted mb-0">Total Donations</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Ads Grid -->
    <div class="row">
        @forelse($ads as $ad)
            <div class="col-lg-4 col-md-6 mb-4" data-aos="fade-up" data-aos-delay="{{ $loop->index * 100 }}">
                <div class="card border-0 shadow-sm h-100 campaign-card">
                    <div class="position-relative overflow-hidden">
                        @if($ad->imageUrl)
                            <img src="{{ asset($ad->imageUrl) }}"
                                 class="card-img-top campaign-image"
                                 alt="{{ $ad->title }}">
                        @else
                            <div class="card-img-top bg-light d-flex align-items-center justify-content-center campaign-placeholder">
                                <i class="fas fa-image fa-3x text-muted"></i>
                            </div>
                        @endif
                        <div class="position-absolute top-0 end-0 m-2">
                            <span class="badge bg-success pulse-animation">Active</span>
                        </div>
                        <div class="campaign-overlay">
                            <a href="{{ route('ads.show', $ad->donationId) }}" class="btn btn-light btn-sm">
                                <i class="fas fa-heart me-1"></i>Support
                            </a>
                        </div>
                    </div>

                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title fw-bold text-dark mb-2">{{ $ad->title }}</h5>
                        <p class="card-text text-muted flex-grow-1 small">
                            {{ Str::limit($ad->description, 120) }}
                        </p>

                        <div class="mt-auto">
                            @php
                                $totalRaised = DB::table('donation_transactions')
                                    ->where('donationId', $ad->donationId)
                                    ->sum('amount');
                                $donationCount = DB::table('donation_transactions')
                                    ->where('donationId', $ad->donationId)
                                    ->count();
                                $progress = $ad->amount > 0 ? min(($totalRaised / $ad->amount) * 100, 100) : 0;
                            @endphp

                            <!-- Progress -->
                            <div class="mb-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <small class="text-muted fw-bold">Progress</small>
                                    <small class="text-muted fw-bold">{{ number_format($progress, 1) }}%</small>
                                </div>
                                <div class="progress campaign-progress" style="height: 8px;">
                                    <div class="progress-bar bg-gradient-primary"
                                         style="width: {{ $progress }}%"
                                         data-aos="fade-right"
                                         data-aos-delay="300"></div>
                                </div>
                            </div>

                            <!-- Stats -->
                            <div class="row text-center mb-3">
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

                            <!-- Creator Info -->
                            <div class="d-flex align-items-center mb-3">
                                <div class="profile-avatar-tiny me-2">
                                    @php
                                        $user = DB::table('mstuser')->where('userId', $ad->userId)->first();
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
                                    <small class="text-muted">by <strong>{{ $ad->userName }}</strong></small>
                                </div>
                            </div>

                            <!-- Actions -->
                            <div class="d-grid">
                                <a href="{{ route('ads.show', $ad->donationId) }}"
                                   class="btn btn-primary btn-sm">
                                    <i class="fas fa-heart me-2"></i>Support Campaign
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        @empty
            <div class="col-12 text-center py-5" data-aos="fade-up">
                <div class="empty-state-icon mb-4">
                    <i class="fas fa-hand-holding-heart"></i>
                </div>
                <h3 class="text-muted mb-3">No Active Campaigns</h3>
                <p class="text-muted mb-4">Be the first to create a meaningful campaign and make a difference!</p>
                @auth
                    <a href="{{ route('ads.create') }}" class="btn btn-primary btn-lg">
                        <i class="fas fa-plus me-2"></i>Create First Campaign
                    </a>
                @else
                    <a href="{{ route('login') }}?redirect={{ urlencode(route('ads.create')) }}" class="btn btn-primary btn-lg">
                        <i class="fas fa-sign-in-alt me-2"></i>Login to Create Campaign
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
@endsection
