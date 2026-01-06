@extends('layouts.app')

@section('title', 'Generate Payment QR - ' . $event->eventTitle)

@push('styles')
<style>
.qr-code-container {
    background: white;
    padding: 2rem;
    border-radius: 12px;
    text-align: center;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.qr-code-display {
    margin: 1rem 0;
}

.qr-code-display img {
    max-width: 300px;
    height: auto;
}

.ticket-type-badge {
    display: inline-block;
    padding: 0.5rem 1rem;
    border-radius: 8px;
    font-weight: bold;
    margin: 0.5rem;
}

.ticket-type-badge.general {
    background: #6c757d;
    color: white;
}

.ticket-type-badge.silver {
    background: #c0c0c0;
    color: #333;
}

.ticket-type-badge.gold {
    background: #ffd700;
    color: #333;
}
</style>
@endpush

@section('content')
<section class="section contact__v2" id="contact">
    <div class="container py-4">
        <div class="row">
            <div class="col-lg-8 mx-auto">
                <div class="feature-card">
                    <h4 class="mb-4">
                        <i class="bi bi-qr-code-scan"></i> Generate Payment QR Code
                    </h4>
                    <p class="text-muted mb-4">Generate a QR code for your event. Users can scan it to quickly purchase tickets.</p>

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

                    <!-- Generate Form -->
                    <form action="{{ route('payment-qr.generate', $event->eventId) }}" method="POST" class="mb-4">
                        @csrf
                        <div class="mb-3">
                            <label class="form-label">Ticket Type</label>
                            <select name="ticket_type" class="form-select" required>
                                <option value="general">General Admission</option>
                                <option value="vip">VIP (Very Important Person)</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Expires At (Optional)</label>
                            <input type="datetime-local" name="expires_at" class="form-control">
                            <small class="text-muted">Leave empty for no expiration</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Max Uses (Optional)</label>
                            <input type="number" name="max_uses" class="form-control" min="1" max="10000">
                            <small class="text-muted">Leave empty for unlimited uses</small>
                        </div>

                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-qr-code"></i> Generate QR Code
                        </button>
                    </form>

                    <!-- Existing QR Codes -->
                    @if($qrCodes->count() > 0)
                        <hr class="my-4">
                        <h5 class="mb-3">Existing QR Codes</h5>
                        <div class="row">
                            @foreach($qrCodes as $qr)
                                <div class="col-md-6 mb-3">
                                    <div class="qr-code-container">
                                        @php
                                            $qrData = json_decode($qr->qrCodeData, true);
                                            // Use web URL for QR code (works with all scanners, including iPhone)
                                            $qrString = $qrData['web'] ?? ($qrData['app'] ?? $qr->qrCodeData);
                                        @endphp
                                        <div class="qr-code-display">
                                            <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data={{ urlencode($qrString) }}" alt="QR Code">
                                        </div>
                                        <div>
                                            <span class="ticket-type-badge {{ $qr->ticketType }}">
                                                {{ strtoupper($qr->ticketType) }}
                                            </span>
                                            @if($qr->maxUses && $qr->currentUses >= $qr->maxUses)
                                                <span class="badge bg-danger ms-1">Limit Reached</span>
                                            @endif
                                        </div>
                                        @if($qr->expiresAt)
                                            <p class="small text-muted mb-2">
                                                Expires: {{ \Carbon\Carbon::parse($qr->expiresAt)->format('M d, Y H:i') }}
                                            </p>
                                        @endif
                                        <form action="{{ route('payment-qr.deactivate', [$event->eventId, $qr->qrId]) }}" method="POST" class="mt-2">
                                            @csrf
                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                Deactivate
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            @endforeach
                        </div>
                    @endif

                    <div class="mt-4">
                        <a href="{{ route('events.show', $event->eventId) }}" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left"></i> Back to Event
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection

