@extends('layouts.app')

@section('title', 'Edit Campaign - EventGo')

@section('content')
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <!-- Header -->
            <div class="text-center mb-5" data-aos="fade-up">
                <h1 class="display-5 fw-bold text-dark mb-3">Edit Campaign</h1>
                <p class="lead text-muted">Update your campaign details and keep it fresh</p>
            </div>

            <!-- Edit Form -->
            <div class="card border-0 shadow-lg" data-aos="fade-up" data-aos-delay="100">
                <div class="card-header bg-white border-0 py-4">
                    <h4 class="mb-0 text-center">
                        <i class="fas fa-edit me-2 text-primary"></i>Campaign Details
                    </h4>
                </div>
                <div class="card-body p-5">
                    <form method="POST" action="{{ route('ads.update', $ad->donationId) }}" enctype="multipart/form-data">
                        @csrf
                        @method('PUT')

                        <!-- Current Image Preview -->
                        @if($ad->imageUrl)
                        <div class="mb-4">
                            <label class="form-label fw-bold">
                                <i class="fas fa-image me-2"></i>Current Image
                            </label>
                            <div class="text-center">
                                <img src="{{ asset($ad->imageUrl) }}"
                                     alt="{{ $ad->title }}"
                                     class="img-fluid rounded shadow-sm"
                                     style="max-height: 200px;">
                            </div>
                        </div>
                        @endif

                        <!-- Campaign Image -->
                        <div class="mb-4">
                            <label for="image" class="form-label fw-bold">
                                <i class="fas fa-image me-2"></i>Update Campaign Image
                            </label>
                            <input type="file"
                                   class="form-control @error('image') is-invalid @enderror"
                                   id="image"
                                   name="image"
                                   accept="image/*">
                            @error('image')
                                <div class="invalid-feedback">{{ $error }}</div>
                            @enderror
                            <small class="form-text text-muted">
                                <i class="fas fa-info-circle me-1"></i>
                                Leave empty to keep current image. Max size: 2MB. Supported formats: JPG, PNG, GIF.
                            </small>
                        </div>

                        <!-- Campaign Title -->
                        <div class="mb-4">
                            <label for="title" class="form-label fw-bold">
                                <i class="fas fa-heading me-2"></i>Campaign Title *
                            </label>
                            <input type="text"
                                   class="form-control @error('title') is-invalid @enderror"
                                   id="title"
                                   name="title"
                                   value="{{ old('title', $ad->title) }}"
                                   placeholder="Enter a compelling title for your campaign"
                                   required>
                            @error('title')
                                <div class="invalid-feedback">{{ $error }}</div>
                            @enderror
                        </div>

                        <!-- Campaign Description -->
                        <div class="mb-4">
                            <label for="description" class="form-label fw-bold">
                                <i class="fas fa-align-left me-2"></i>Campaign Description *
                            </label>
                            <textarea class="form-control @error('description') is-invalid @enderror"
                                      id="description"
                                      name="description"
                                      rows="6"
                                      placeholder="Tell your story. Explain why this cause matters and how the funds will be used..."
                                      required>{{ old('description', $ad->description) }}</textarea>
                            @error('description')
                                <div class="invalid-feedback">{{ $error }}</div>
                            @enderror
                            <small class="form-text text-muted">
                                <i class="fas fa-info-circle me-1"></i>
                                Be specific about your goals and how donations will help. Max 3000 characters.
                            </small>
                        </div>

                        <!-- Fundraising Goal -->
                        <div class="mb-4">
                            <label for="amount" class="form-label fw-bold">
                                <i class="fas fa-dollar-sign me-2"></i>Fundraising Goal *
                            </label>
                            <div class="input-group">
                                <span class="input-group-text">$</span>
                                <input type="number"
                                       class="form-control @error('amount') is-invalid @enderror"
                                       id="amount"
                                       name="amount"
                                       value="{{ old('amount', $ad->amount) }}"
                                       placeholder="0.00"
                                       min="1"
                                       step="0.01"
                                       required>
                                @error('amount')
                                    <div class="invalid-feedback">{{ $error }}</div>
                                @enderror
                            </div>
                            <small class="form-text text-muted">
                                <i class="fas fa-info-circle me-1"></i>
                                Set a realistic goal. You can always raise more than your target!
                            </small>
                        </div>

                        <!-- Campaign Stats -->
                        <div class="alert alert-info border-0 mb-4">
                            <h6 class="alert-heading">
                                <i class="fas fa-chart-line me-2"></i>Campaign Statistics
                            </h6>
                            <div class="row">
                                <div class="col-md-4 text-center">
                                    <h5 class="fw-bold text-primary mb-1">${{ number_format($ad->amount, 0) }}</h5>
                                    <small class="text-muted">Goal Amount</small>
                                </div>
                                <div class="col-md-4 text-center">
                                    <h5 class="fw-bold text-success mb-1">$0</h5>
                                    <small class="text-muted">Raised So Far</small>
                                </div>
                                <div class="col-md-4 text-center">
                                    <h5 class="fw-bold text-info mb-1">0</h5>
                                    <small class="text-muted">Total Donors</small>
                                </div>
                            </div>
                        </div>

                        <!-- Form Actions -->
                        <div class="d-flex justify-content-between">
                            <a href="{{ route('ads.show', $ad->donationId) }}" class="btn btn-outline-secondary btn-lg text-white">
                                <i class="fas fa-arrow-left me-2"></i>Cancel
                            </a>
                            <button type="submit" class="btn btn-primary btn-lg">
                                <i class="fas fa-save me-2"></i>Update Campaign
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Danger Zone -->
            <div class="card border-danger mt-4" data-aos="fade-up" data-aos-delay="200">
                <div class="card-header bg-danger text-white">
                    <h5 class="mb-0">
                        <i class="fas fa-exclamation-triangle me-2"></i>Danger Zone
                    </h5>
                </div>
                <div class="card-body">
                    <p class="text-muted mb-3">Once you delete a campaign, there is no going back. Please be certain.</p>
                    <form method="POST" action="{{ route('ads.destroy', $ad->donationId) }}"
                          onsubmit="return confirm('Are you sure you want to delete this campaign? This action cannot be undone.')">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-danger">
                            <i class="fas fa-trash me-2"></i>Delete Campaign
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
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

.btn-outline-secondary {
    color: #6c757d;
    border-color: #6c757d;
}

.btn-outline-secondary:hover {
    background: #6c757d;
    border-color: #6c757d;
}

.card {
    border-radius: 15px;
}

.alert {
    border-radius: 10px;
}

.input-group-text {
    background: #f8f9ff;
    border-color: #e9ecef;
    color: #584CF4;
    font-weight: 600;
}
</style>
@endsection
