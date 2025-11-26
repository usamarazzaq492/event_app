@extends('layouts.app')

@section('title', $ad->title . ' - EventGo')

@section('content')
<div class="container py-5">
    <div class="row">
        <!-- Main Content -->
        <div class="col-lg-8 mb-4">
            <!-- Campaign Header -->
            <div class="card border-0 shadow-sm mb-4" data-aos="fade-up">
                <div class="position-relative">
                    @if($ad->imageUrl)
                        <img src="{{ asset($ad->imageUrl) }}"
                             class="card-img-top"
                             alt="{{ $ad->title }}"
                             style="height: 400px; object-fit: cover;">
                    @else
                        <div class="card-img-top bg-light d-flex align-items-center justify-content-center"
                             style="height: 400px;">
                            <i class="fas fa-image fa-4x text-muted"></i>
                        </div>
                    @endif
                    <div class="position-absolute top-0 end-0 m-3">
                        <span class="badge bg-success fs-6">Active Campaign</span>
                    </div>
                </div>

                <div class="card-body p-4">
                    <h1 class="display-5 fw-bold text-dark mb-3">{{ $ad->title }}</h1>
                    <div class="d-flex align-items-center mb-4">
                        <div class="me-3">
                            <div class="profile-avatar-small">
                                @php
                                    $user = DB::table('mstuser')->where('userId', $ad->userId)->first();
                                @endphp
                                @if($user && $user->profileImageUrl)
                                    <img src="{{ asset($user->profileImageUrl) }}"
                                         alt="{{ $user->name }}"
                                         class="profile-image-small">
                                @else
                                    <div class="profile-image-placeholder-small">
                                        <i class="fas fa-user"></i>
                                    </div>
                                @endif
                            </div>
                        </div>
                        <div>
                            <h6 class="mb-1 fw-bold">Created by {{ $ad->userName }}</h6>
                            <small class="text-muted">
                                <i class="fas fa-calendar me-1"></i>
                                {{ \Carbon\Carbon::parse($ad->addDate)->format('M d, Y') }}
                            </small>
                        </div>
                    </div>

                    <div class="campaign-description">
                        {!! nl2br(e($ad->description)) !!}
                    </div>
                </div>
            </div>

            <!-- Recent Donations -->
            @if($recentDonations->count() > 0)
                <div class="card border-0 shadow-sm" data-aos="fade-up" data-aos-delay="200">
                    <div class="card-header bg-white border-0">
                        <h5 class="mb-0">
                            <i class="fas fa-heart me-2 text-danger"></i>Recent Donations
                        </h5>
                    </div>
                    <div class="card-body">
                        @foreach($recentDonations as $donation)
                            <div class="d-flex align-items-center mb-3 p-3 bg-light rounded">
                                <div class="me-3">
                                    <div class="donor-avatar">
                                        @php
                                            $donor = DB::table('mstuser')->where('userId', $donation->userId)->first();
                                        @endphp
                                        @if($donor && $donor->profileImageUrl)
                                            <img src="{{ asset($donor->profileImageUrl) }}"
                                                 alt="{{ $donor->name }}"
                                                 class="donor-image">
                                        @else
                                            <div class="donor-image-placeholder">
                                                <i class="fas fa-user"></i>
                                            </div>
                                        @endif
                                    </div>
                                </div>
                                <div class="flex-grow-1">
                                    <h6 class="mb-1 fw-bold">{{ $donation->donorName }}</h6>
                                    <small class="text-muted">
                                        <i class="fas fa-clock me-1"></i>
                                        {{ \Carbon\Carbon::parse($donation->created_at)->diffForHumans() }}
                                    </small>
                                </div>
                                <div class="text-end">
                                    <h5 class="mb-0 text-success fw-bold">${{ number_format($donation->amount, 2) }}</h5>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>
            @endif
        </div>

        <!-- Sidebar -->
        <div class="col-lg-4">
            <!-- Donation Card -->
            <div class="card border-0 shadow-sm mb-4" data-aos="fade-up" data-aos-delay="100">
                <div class="card-header bg-primary text-white border-0">
                    <h5 class="mb-0 text-white">
                        <i class="fas fa-hand-holding-heart me-2"></i>Support This Campaign
                    </h5>
                </div>
                <div class="card-body p-4">
                    <!-- Progress -->
                    @php
                        $progress = $ad->amount > 0 ? min(($totalDonations / $ad->amount) * 100, 100) : 0;
                    @endphp

                    <div class="mb-4">
                        <div class="d-flex justify-content-between mb-2">
                            <span class="fw-bold">Progress</span>
                            <span class="text-muted">{{ number_format($progress, 1) }}%</span>
                        </div>
                        <div class="progress" style="height: 12px;">
                            <div class="progress-bar bg-primary"
                                 style="width: {{ $progress }}%"></div>
                        </div>
                    </div>

                    <!-- Stats -->
                    <div class="row text-center mb-4">
                        <div class="col-6">
                            <h4 class="fw-bold text-primary mb-1">${{ number_format($totalDonations, 0) }}</h4>
                            <small class="text-muted">Raised</small>
                        </div>
                        <div class="col-6">
                            <h4 class="fw-bold text-success mb-1">{{ $donationCount }}</h4>
                            <small class="text-muted">Donations</small>
                        </div>
                    </div>

                    <div class="row text-center mb-4">
                        <div class="col-6">
                            <h4 class="fw-bold text-warning mb-1">${{ number_format($ad->amount, 0) }}</h4>
                            <small class="text-muted">Goal</small>
                        </div>
                        <div class="col-6">
                            <h4 class="fw-bold text-info mb-1">${{ number_format($ad->amount - $totalDonations, 0) }}</h4>
                            <small class="text-muted">Remaining</small>
                        </div>
                    </div>

                    <!-- Donation Form -->
                    @auth
                        <form method="POST" action="{{ route('ads.donate', $ad->donationId) }}">
                            @csrf
                            <div class="mb-3">
                                <label for="amount" class="form-label fw-bold">Donation Amount</label>
                                <div class="input-group">
                                    <span class="input-group-text">$</span>
                                    <input type="number"
                                           class="form-control @error('amount') is-invalid @enderror"
                                           id="amount"
                                           name="amount"
                                           value="{{ old('amount') }}"
                                           placeholder="0.00"
                                           min="1"
                                           step="0.01"
                                           required>
                                    @error('amount')
                                        <div class="invalid-feedback">{{ $error }}</div>
                                    @enderror
                                </div>
                            </div>

                            <button type="submit" class="btn btn-success btn-lg w-100 mb-3">
                                <i class="fas fa-heart me-2"></i>Donate Now
                            </button>
                        </form>
                    @else
                        <div class="text-center">
                            <p class="text-muted mb-3">Login to make a donation</p>
                            <a href="{{ route('login') }}" class="btn btn-primary btn-lg w-100">
                                <i class="fas fa-sign-in-alt me-2"></i>Login to Donate
                            </a>
                        </div>
                    @endauth
                </div>
            </div>

            <!-- Campaign Actions -->
            @if(Auth::check() && Auth::id() == $ad->userId)
                <div class="card border-0 shadow-sm mb-4" data-aos="fade-up" data-aos-delay="200">
                    <div class="card-header bg-white border-0">
                        <h5 class="mb-0">
                            <i class="fas fa-cog me-2"></i>Campaign Management
                        </h5>
                    </div>
                    <div class="card-body">
                        <div class="d-grid gap-2">
                            <a href="{{ route('ads.edit', $ad->donationId) }}" class="btn btn-outline-primary">
                                <i class="fas fa-edit me-2"></i>Edit Campaign
                            </a>
                            <form method="POST" action="{{ route('ads.destroy', $ad->donationId) }}"
                                  onsubmit="return confirm('Are you sure you want to delete this campaign?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-outline-danger w-100">
                                    <i class="fas fa-trash me-2"></i>Delete Campaign
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            @endif

            <!-- Share Campaign -->
            <div class="card border-0 shadow-sm" data-aos="fade-up" data-aos-delay="300">
                <div class="card-header bg-white border-0">
                    <h5 class="mb-0">
                        <i class="fas fa-share-alt me-2"></i>Share Campaign
                    </h5>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-2">
                        <button class="btn btn-outline-primary" onclick="shareOnFacebook()">
                            <i class="fab fa-facebook me-2"></i>Share on Facebook
                        </button>
                        <button class="btn btn-outline-info" onclick="shareOnTwitter()">
                            <i class="fab fa-twitter me-2"></i>Share on Twitter
                        </button>
                        <button class="btn btn-outline-success" onclick="copyLink()">
                            <i class="fas fa-link me-2"></i>Copy Link
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.profile-avatar-small {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    overflow: hidden;
    border: 2px solid #584CF4;
}

.profile-image-small {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.profile-image-placeholder-small {
    width: 100%;
    height: 100%;
    background: #584CF4;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 20px;
}

.donor-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    overflow: hidden;
    border: 2px solid #e9ecef;
}

.donor-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.donor-image-placeholder {
    width: 100%;
    height: 100%;
    background: #f8f9fa;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #6c757d;
    font-size: 16px;
}

.campaign-description {
    line-height: 1.6;
    font-size: 1.1rem;
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

.btn-success {
    background: #22c55e;
    border-color: #22c55e;
}

.btn-success:hover {
    background: #16a34a;
    border-color: #16a34a;
}

.form-control:focus {
    border-color: #584CF4;
    box-shadow: 0 0 0 0.2rem rgba(88, 76, 244, 0.25);
}

.input-group-text {
    background: #f8f9ff;
    border-color: #e9ecef;
    color: #584CF4;
    font-weight: 600;
}
</style>

<script>
function shareOnFacebook() {
    const url = encodeURIComponent(window.location.href);
    window.open(`https://www.facebook.com/sharer/sharer.php?u=${url}`, '_blank');
}

function shareOnTwitter() {
    const url = encodeURIComponent(window.location.href);
    const text = encodeURIComponent('{{ $ad->title }}');
    window.open(`https://twitter.com/intent/tweet?url=${url}&text=${text}`, '_blank');
}

function copyLink() {
    navigator.clipboard.writeText(window.location.href).then(() => {
        alert('Link copied to clipboard!');
    });
}
</script>
@endsection
