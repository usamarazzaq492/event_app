@extends('layouts.app')

@section('title', 'Promote Event - ' . $event->eventTitle)

@push('styles')
<style>
:root {
    --primary: #4da6ff;
    --primary-dark: #247fd9;
    --warning: #ffc107;
    --warning-dark: #ff9800;
}

.package-card {
    border: 2px solid #e0e0e0;
    border-radius: 12px;
    padding: 1.5rem;
    transition: all 0.3s ease;
    cursor: pointer;
    background: #fff;
}

.package-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.package-card.selected {
    border-color: var(--primary);
    background: #f0f8ff;
}

.package-card.premium {
    border-color: var(--warning);
}

.package-card.premium.selected {
    background: #fffbf0;
}

.package-badge {
    position: absolute;
    top: -10px;
    right: 20px;
    background: var(--warning);
    color: #000;
    padding: 5px 15px;
    border-radius: 20px;
    font-size: 0.85rem;
    font-weight: bold;
}

.promotion-status {
    background: #d4edda;
    border: 1px solid #c3e6cb;
    border-radius: 8px;
    padding: 1rem;
    margin-bottom: 2rem;
}

.promotion-status.active {
    background: #d1ecf1;
    border-color: #bee5eb;
}
</style>
@endpush

@section('content')
<section class="section contact__v2" id="contact">
    <div class="container py-4">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <div class="feature-card">
                    <h3 class="mb-4">
                        <i class="bi bi-megaphone-fill text-warning"></i> Promote Your Event
                    </h3>
                    <p class="text-muted mb-4">
                        Boost your event's visibility and reach more attendees! Promoted events appear first in search results and get a special "PROMOTED" badge.
                    </p>

                    <div class="mb-4">
                        <h5>{{ $event->eventTitle }}</h5>
                        <p class="text-muted small mb-0">
                            <i class="bi bi-calendar-event"></i>
                            {{ \Carbon\Carbon::parse($event->startDate)->format('M d, Y') }}
                            @if($event->city)
                                <span class="ms-2"><i class="bi bi-geo-alt"></i> {{ $event->city }}</span>
                            @endif
                        </p>
                    </div>

                    @if($isPromoted && $isActive)
                        <div class="promotion-status active">
                            <h6><i class="bi bi-check-circle-fill text-success"></i> Your Event is Currently Promoted!</h6>
                            <p class="mb-0">
                                <strong>Package:</strong> {{ ucfirst($event->promotionPackage ?? 'Unknown') }}<br>
                                <strong>Days Remaining:</strong> {{ $daysRemaining }} days<br>
                                @if($event->promotionEndDate)
                                    <strong>Ends:</strong> {{ \Carbon\Carbon::parse($event->promotionEndDate)->format('M d, Y') }}
                                @endif
                            </p>
                        </div>
                    @endif

                    <h5 class="mb-3">Boost Your Event</h5>
                    <div class="row g-3 mb-4" id="package-selection">
                        <!-- Single Boost Package: $35 for 10 days -->
                        <div class="col-md-12">
                            <div class="package-card position-relative" data-package="boost" onclick="selectPackage('boost')" style="background: linear-gradient(135deg, #4da6ff 0%, #247fd9 100%); color: white; border-color: #4da6ff;">
                                <div class="d-flex align-items-center mb-3">
                                    <i class="bi bi-rocket-takeoff-fill me-2" style="font-size: 2rem;"></i>
                                    <h4 class="mb-0">{{ $packages['boost']['name'] ?? 'Event Go-Live Boost' }}</h4>
                                </div>
                                <h2 class="mb-3">${{ number_format($packages['boost']['price'], 2) }}</h2>
                                <p class="mb-3" style="font-size: 1.1rem;">
                                    <i class="bi bi-calendar-check"></i> {{ $packages['boost']['durationDays'] }} days of promotion
                                </p>
                                <p class="mb-3" style="opacity: 0.9;">
                                    {{ $packages['boost']['description'] ?? 'Boost your event for 10 days to increase visibility' }}
                                </p>
                                <ul class="list-unstyled small">
                                    <li class="mb-2"><i class="bi bi-check-circle-fill"></i> Appear in Ads section</li>
                                    <li class="mb-2"><i class="bi bi-check-circle-fill"></i> "PROMOTED" badge</li>
                                    <li class="mb-2"><i class="bi bi-check-circle-fill"></i> Increased visibility</li>
                                    <li class="mb-2"><i class="bi bi-check-circle-fill"></i> Featured on homepage</li>
                                </ul>
                            </div>
                        </div>
                    </div>

                    <!-- Payment Section -->
                    <div id="payment-section" style="display: none;">
                        <div class="border-top pt-4">
                            <h5 class="mb-3">Payment Details</h5>
                            <div id="card-container" class="mb-3"></div>
                            <button id="pay-button" class="btn btn-primary w-100">
                                <i class="bi bi-credit-card"></i> Pay Now
                            </button>
                            <div id="error-message" class="text-danger mt-2"></div>
                            <div id="success-message" class="text-success mt-2"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection

@push('scripts')
<script type="text/javascript" src="https://sandbox.web.squarecdn.com/v1/square.js"></script>
<script>
    const appId = "{{ env('SQUARE_APPLICATION_ID') }}";
    const locationId = "{{ env('SQUARE_LOCATION_ID') }}";
    let selectedPackage = null;
    let card = null;

    function selectPackage(package) {
        // Always use 'boost' for new system
        selectedPackage = 'boost';

        // Update UI
        document.querySelectorAll('.package-card').forEach(card => {
            card.classList.remove('selected');
        });
        document.querySelector(`[data-package="boost"]`).classList.add('selected');

        // Show payment section
        document.getElementById('payment-section').style.display = 'block';

        // Initialize Square payment if not already done
        if (!card) {
            initializePayment();
        }
    }

    // Auto-select boost package on page load
    window.addEventListener('DOMContentLoaded', function() {
        selectPackage('boost');
    });

    async function initializePayment() {
        try {
            const payments = window.Square.payments(appId, locationId);
            card = await payments.card();
            await card.attach('#card-container');

            document.getElementById('pay-button').addEventListener('click', async () => {
                if (!selectedPackage) {
                    document.getElementById('error-message').innerText = 'Please select a package first.';
                    return;
                }

                const result = await card.tokenize();

                if (result.status === 'OK') {
                    const nonce = result.token;

                    // Disable button
                    const payButton = document.getElementById('pay-button');
                    payButton.disabled = true;
                    payButton.innerText = 'Processing...';

                    try {
                        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
                        if (!csrfToken) {
                            throw new Error('CSRF token not found. Please refresh the page.');
                        }

                        const response = await fetch('{{ route("promotion.process", $event->eventId) }}', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'Accept': 'application/json',
                                'X-CSRF-TOKEN': csrfToken,
                                'X-Requested-With': 'XMLHttpRequest'
                            },
                            credentials: 'same-origin',
                            body: JSON.stringify({
                                package: selectedPackage,
                                sourceId: nonce
                            })
                        });

                        // Check if response is OK
                        if (!response.ok) {
                            // Try to get error message from response
                            const contentType = response.headers.get('content-type');
                            if (contentType && contentType.includes('application/json')) {
                                const errorData = await response.json();
                                throw new Error(errorData.error || errorData.message || `Server error: ${response.status}`);
                            } else {
                                // Response is HTML (likely an error page)
                                const text = await response.text();
                                if (text.includes('419') || text.includes('CSRF')) {
                                    throw new Error('Session expired. Please refresh the page and try again.');
                                } else if (text.includes('403') || text.includes('Forbidden')) {
                                    throw new Error('You do not have permission to perform this action.');
                                } else if (text.includes('401') || text.includes('Unauthorized')) {
                                    throw new Error('Please login to continue.');
                                } else {
                                    throw new Error(`Server error (${response.status}). Please try again.`);
                                }
                            }
                        }

                        // Parse JSON response
                        const contentType = response.headers.get('content-type');
                        if (!contentType || !contentType.includes('application/json')) {
                            throw new Error('Invalid response from server. Please try again.');
                        }

                        const data = await response.json();

                        if (data.success) {
                            document.getElementById('success-message').innerText = 'Payment successful! Redirecting...';
                            setTimeout(() => {
                                window.location.href = '{{ route("events.show", $event->eventId) }}';
                            }, 2000);
                        } else {
                            document.getElementById('error-message').innerText = data.error || data.message || 'Payment failed. Please try again.';
                            payButton.disabled = false;
                            payButton.innerText = '<i class="bi bi-credit-card"></i> Pay Now';
                        }
                    } catch (error) {
                        console.error('Payment error:', error);
                        document.getElementById('error-message').innerText = error.message || 'Payment failed. Please try again.';
                        payButton.disabled = false;
                        payButton.innerText = '<i class="bi bi-credit-card"></i> Pay Now';
                    }
                } else {
                    document.getElementById('error-message').innerText =
                        result.errors?.[0]?.message || 'Payment failed.';
                }
            });
        } catch (err) {
            document.getElementById('error-message').innerText = "Payment initialization error: " + err.message;
        }
    }
</script>
@endpush

