@extends('layouts.app')

@section('title', 'Create Ad - EventGo')

@section('content')
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <!-- Header -->
            <div class="text-center mb-5" data-aos="fade-up">
                <h1 class="display-5 fw-bold text-dark mb-3">Create New Ad Campaign</h1>
                <p class="lead text-muted">Share your cause with the community and start raising funds</p>
            </div>

            <!-- Create Form -->
            <div class="card border-0 shadow-lg" data-aos="fade-up" data-aos-delay="100">
                <div class="card-header bg-white border-0 py-4">
                    <h4 class="mb-0 text-center">
                        <i class="fas fa-plus-circle me-2 text-primary"></i>Campaign Details
                    </h4>
                </div>
                <div class="card-body p-5">
                    <form method="POST" action="{{ route('ads.store') }}" enctype="multipart/form-data">
                        @csrf

                        <!-- Campaign Image -->
                        <div class="mb-4">
                            <label for="image" class="form-label fw-bold">
                                <i class="fas fa-image me-2"></i>Campaign Image *
                            </label>
                            <input type="file"
                                   class="form-control @error('image') is-invalid @enderror"
                                   id="image"
                                   name="image"
                                   accept="image/*"
                                   required>
                            @error('image')
                                <div class="invalid-feedback">{{ $error }}</div>
                            @enderror
                            <small class="form-text text-muted">
                                <i class="fas fa-info-circle me-1"></i>
                                Max size: 2MB. Supported formats: JPG, PNG, GIF. Recommended: 800x600px
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
                                   value="{{ old('title') }}"
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
                                      required>{{ old('description') }}</textarea>
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
                                       value="{{ old('amount') }}"
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

                        <!-- Guidelines -->
                        <div class="alert alert-info border-0 mb-4">
                            <h6 class="alert-heading">
                                <i class="fas fa-lightbulb me-2"></i>Campaign Guidelines
                            </h6>
                            <ul class="mb-0 small">
                                <li>Be honest and transparent about your cause</li>
                                <li>Provide clear information about how funds will be used</li>
                                <li>Use high-quality images that represent your campaign</li>
                                <li>Keep your description engaging and easy to understand</li>
                                <li>Set realistic fundraising goals</li>
                            </ul>
                        </div>

                        <!-- Form Actions -->
                        <div class="d-flex justify-content-between">
                            <a href="{{ route('ads.index') }}" class="btn btn-outline-secondary btn-lg text-white">
                                <i class="fas fa-arrow-left me-2"></i>Cancel
                            </a>
                            <button type="submit" class="btn btn-primary btn-lg">
                                <i class="fas fa-rocket me-2"></i>Launch Campaign
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Tips Section -->
            <div class="row mt-5">
                <div class="col-md-4 mb-3" data-aos="fade-up" data-aos-delay="200">
                    <div class="card border-0 shadow-sm h-100 text-center">
                        <div class="card-body">
                            <i class="fas fa-camera fa-3x text-primary mb-3"></i>
                            <h5 class="fw-bold">Great Images</h5>
                            <p class="text-muted small">Use clear, high-quality images that tell your story</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 mb-3" data-aos="fade-up" data-aos-delay="300">
                    <div class="card border-0 shadow-sm h-100 text-center">
                        <div class="card-body">
                            <i class="fas fa-pen-fancy fa-3x text-success mb-3"></i>
                            <h5 class="fw-bold">Compelling Story</h5>
                            <p class="text-muted small">Write a clear, emotional story that connects with donors</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 mb-3" data-aos="fade-up" data-aos-delay="400">
                    <div class="card border-0 shadow-sm h-100 text-center">
                        <div class="card-body">
                            <i class="fas fa-target fa-3x text-warning mb-3"></i>
                            <h5 class="fw-bold">Realistic Goals</h5>
                            <p class="text-muted small">Set achievable targets to build momentum</p>
                        </div>
                    </div>
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
