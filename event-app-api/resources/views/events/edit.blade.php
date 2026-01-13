@extends('layouts.app')

@section('title', 'Edit Event - ' . $event->eventTitle)

@push('styles')
<style>
:root {
    --primary: #584CF4;
    --secondary: #ff9500;
    --bg: #ffffff;
    --muted: #6b7280;
    --card-shadow: 0 10px 20px rgba(88, 76, 244, 0.06);
}

.create-event-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
}

.form-card {
    background: var(--bg);
    border-radius: 20px;
    box-shadow: var(--card-shadow);
    padding: 2rem;
    margin-bottom: 2rem;
}

.form-group {
    margin-bottom: 1.5rem;
}

.form-label {
    font-weight: 600;
    color: #333;
    margin-bottom: 0.5rem;
    display: block;
}

.form-control {
    width: 100%;
    padding: 12px 16px;
    border: 2px solid #e5e7eb;
    border-radius: 12px;
    font-size: 16px;
    transition: border-color 0.3s ease;
}

.form-control:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(88, 76, 244, 0.1);
}

.form-select {
    width: 100%;
    padding: 12px 16px;
    border: 2px solid #e5e7eb;
    border-radius: 12px;
    font-size: 16px;
    background-color: white;
    transition: border-color 0.3s ease;
}

.form-select:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(88, 76, 244, 0.1);
}

.btn-primary {
    background: var(--primary);
    border: none;
    color: white;
    padding: 12px 24px;
    border-radius: 12px;
    font-weight: 600;
    transition: all 0.3s ease;
}

.btn-primary:hover {
    background: #4a3dd1;
    transform: translateY(-2px);
}

.btn-secondary {
    background: var(--secondary);
    border: none;
    color: white;
    padding: 12px 24px;
    border-radius: 12px;
    font-weight: 600;
    transition: all 0.3s ease;
}

.btn-secondary:hover {
    background: #e6850e;
    transform: translateY(-2px);
}

.image-preview {
    max-width: 200px;
    max-height: 200px;
    border-radius: 12px;
    margin-top: 1rem;
}

.required {
    color: #ef4444;
}

@media (max-width: 768px) {
    .create-event-container {
        padding: 1rem;
    }

    .form-card {
        padding: 1.5rem;
    }
}
</style>
@endpush

@section('content')
<div class="create-event-container">
    <div class="text-center mb-4">
        <h1 class="display-4 fw-bold text-primary">Edit Event</h1>
        <p class="lead text-muted">Update your event details</p>
    </div>

    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            {{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    @endif

    @if(session('error'))
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            {{ session('error') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    @endif

    <div class="form-card">
        <form action="{{ route('events.update', $event->eventId) }}" method="POST" enctype="multipart/form-data">
            @csrf
            @method('PUT')

            <div class="row">
                <div class="col-md-8">
                    <div class="form-group">
                        <label for="eventTitle" class="form-label">Event Title <span class="required">*</span></label>
                        <input type="text"
                               class="form-control @error('eventTitle') is-invalid @enderror"
                               id="eventTitle"
                               name="eventTitle"
                               value="{{ old('eventTitle', $event->eventTitle) }}"
                               placeholder="Enter your event title"
                               required>
                        @error('eventTitle')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label for="eventPrice" class="form-label">General Admission Price <span class="required">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input type="number"
                                   class="form-control @error('eventPrice') is-invalid @enderror"
                                   id="eventPrice"
                                   name="eventPrice"
                                   value="{{ old('eventPrice', $event->eventPrice) }}"
                                   min="0"
                                   step="0.01"
                                   placeholder="0.00"
                                   required>
                        </div>
                        <small class="text-muted">Price for General Admission tickets</small>
                        @error('eventPrice')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label for="vipPrice" class="form-label">VIP Price <span class="required">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input type="number"
                                   class="form-control @error('vipPrice') is-invalid @enderror"
                                   id="vipPrice"
                                   name="vipPrice"
                                   value="{{ old('vipPrice', $event->vipPrice ?? $event->eventPrice) }}"
                                   min="0"
                                   step="0.01"
                                   placeholder="0.00"
                                   required>
                        </div>
                        <small class="text-muted">Price for VIP tickets</small>
                        @error('vipPrice')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label for="description" class="form-label">Event Description <span class="required">*</span></label>
                <textarea class="form-control @error('description') is-invalid @enderror"
                          id="description"
                          name="description"
                          rows="4"
                          placeholder="Describe your event in detail..."
                          required>{{ old('description', $event->description) }}</textarea>
                @error('description')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label for="category" class="form-label">Category <span class="required">*</span></label>
                        <select class="form-select @error('category') is-invalid @enderror"
                                id="category"
                                name="category"
                                required>
                            <option value="">Select a category</option>
                            <option value="Music" {{ old('category', $event->category) == 'Music' ? 'selected' : '' }}>Music</option>
                            <option value="Sports" {{ old('category', $event->category) == 'Sports' ? 'selected' : '' }}>Sports</option>
                            <option value="Technology" {{ old('category', $event->category) == 'Technology' ? 'selected' : '' }}>Technology</option>
                            <option value="Business" {{ old('category', $event->category) == 'Business' ? 'selected' : '' }}>Business</option>
                            <option value="Education" {{ old('category', $event->category) == 'Education' ? 'selected' : '' }}>Education</option>
                            <option value="Health" {{ old('category', $event->category) == 'Health' ? 'selected' : '' }}>Health</option>
                            <option value="Food" {{ old('category', $event->category) == 'Food' ? 'selected' : '' }}>Food & Drink</option>
                            <option value="Art" {{ old('category', $event->category) == 'Art' ? 'selected' : '' }}>Art & Culture</option>
                            <option value="Other" {{ old('category', $event->category) == 'Other' ? 'selected' : '' }}>Other</option>
                        </select>
                        @error('category')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label for="city" class="form-label">City <span class="required">*</span></label>
                        <input type="text"
                               class="form-control @error('city') is-invalid @enderror"
                               id="city"
                               name="city"
                               value="{{ old('city', $event->city) }}"
                               placeholder="Enter city name"
                               required>
                        @error('city')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label for="startDate" class="form-label">Start Date <span class="required">*</span></label>
                        <input type="date"
                               class="form-control @error('startDate') is-invalid @enderror"
                               id="startDate"
                               name="startDate"
                               value="{{ old('startDate', \Carbon\Carbon::parse($event->startDate)->format('Y-m-d')) }}"
                               required>
                        @error('startDate')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label for="endDate" class="form-label">End Date <span class="required">*</span></label>
                        <input type="date"
                               class="form-control @error('endDate') is-invalid @enderror"
                               id="endDate"
                               name="endDate"
                               value="{{ old('endDate', \Carbon\Carbon::parse($event->endDate)->format('Y-m-d')) }}"
                               required>
                        @error('endDate')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label for="startTime" class="form-label">Start Time <span class="required">*</span></label>
                        <input type="time"
                               class="form-control @error('startTime') is-invalid @enderror"
                               id="startTime"
                               name="startTime"
                               value="{{ old('startTime', \Carbon\Carbon::parse($event->startTime)->format('H:i')) }}"
                               required>
                        @error('startTime')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group">
                        <label for="endTime" class="form-label">End Time <span class="required">*</span></label>
                        <input type="time"
                               class="form-control @error('endTime') is-invalid @enderror"
                               id="endTime"
                               name="endTime"
                               value="{{ old('endTime', \Carbon\Carbon::parse($event->endTime)->format('H:i')) }}"
                               required>
                        @error('endTime')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label for="address" class="form-label">Event Address <span class="required">*</span></label>
                <input type="text"
                       class="form-control @error('address') is-invalid @enderror"
                       id="address"
                       name="address"
                       value="{{ old('address', $event->address) }}"
                       placeholder="Enter full address"
                       required>
                @error('address')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="form-group">
                <label for="eventImage" class="form-label">Event Image</label>
                <input type="file"
                       class="form-control @error('eventImage') is-invalid @enderror"
                       id="eventImage"
                       name="eventImage"
                       accept="image/*"
                       onchange="previewImage(this)">
                @error('eventImage')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
                <small class="form-text text-muted">Leave empty to keep current image</small>
                @if($event->eventImage)
                    <div class="mt-2">
                        <p class="small text-muted">Current image:</p>
                        <img src="{{ asset($event->eventImage) }}" alt="Current event image" class="image-preview">
                    </div>
                @endif
                <div id="imagePreview" class="mt-2"></div>
            </div>

            <div class="form-group">
                <label for="live_stream_url" class="form-label">Live Stream URL (Optional)</label>
                <input type="url"
                       class="form-control @error('live_stream_url') is-invalid @enderror"
                       id="live_stream_url"
                       name="live_stream_url"
                       value="{{ old('live_stream_url', $event->live_stream_url) }}"
                       placeholder="https://youtube.com/watch?v=... or https://facebook.com/...">
                @error('live_stream_url')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
                <small class="form-text text-muted">YouTube or Facebook Live URLs are supported</small>
            </div>

            <div class="d-flex gap-3 justify-content-end">
                <a href="{{ route('events.show', $event->eventId) }}" class="btn btn-secondary">Cancel</a>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save me-2"></i>Update Event
                </button>
            </div>
        </form>
    </div>
</div>
@endsection

@push('scripts')
<script>
function previewImage(input) {
    const preview = document.getElementById('imagePreview');
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.innerHTML = '<img src="' + e.target.result + '" class="image-preview" alt="Preview">';
        }
        reader.readAsDataURL(input.files[0]);
    } else {
        preview.innerHTML = '';
    }
}

// Set minimum date to today
document.getElementById('startDate').min = new Date().toISOString().split('T')[0];
document.getElementById('endDate').min = new Date().toISOString().split('T')[0];

// Validate end date is after start date
document.getElementById('startDate').addEventListener('change', function() {
    const startDate = this.value;
    const endDateInput = document.getElementById('endDate');
    endDateInput.min = startDate;
    if (endDateInput.value && endDateInput.value < startDate) {
        endDateInput.value = startDate;
    }
});
</script>
@endpush

