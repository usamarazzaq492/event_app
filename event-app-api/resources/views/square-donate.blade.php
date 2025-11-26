@extends('layouts.app')

@section('title', 'Donate to ' . $transaction->title . ' - EventGo')

@section('content')
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-6">
            <!-- Donation Header -->
            <div class="text-center mb-5" data-aos="fade-up">
                <h1 class="display-5 fw-bold text-dark mb-3">Support {{ $transaction->title }}</h1>
                <p class="lead text-muted">Your generous donation will help make a difference</p>
            </div>

            <!-- Donation Form -->
            <div class="card border-0 shadow-lg" data-aos="fade-up" data-aos-delay="100">
                <div class="card-header bg-white border-0 py-4">
                    <h4 class="mb-0 text-center">
                        <i class="fas fa-heart me-2 text-danger"></i>Make a Donation
                    </h4>
                </div>
                <div class="card-body p-5">
                    <!-- Donation Amount -->
                    <div class="mb-4">
                        <label for="amount" class="form-label fw-bold">
                            <i class="fas fa-dollar-sign me-2"></i>Donation Amount *
                        </label>
                        <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input type="number"
                                   class="form-control @error('amount') is-invalid @enderror"
                                   id="amount"
                                   name="amount"
                                   value="{{ $transaction->amount }}"
                                   placeholder="0.00"
                                   min="1"
                                   step="0.01"
                                   required>
                        </div>
                        <small class="form-text text-muted">
                            <i class="fas fa-info-circle me-1"></i>
                            Minimum donation: $1.00
                        </small>
                    </div>

                    <!-- Quick Amount Buttons -->
                    <div class="mb-4">
                        <label class="form-label fw-bold">Quick Amounts</label>
                        <div class="row g-2">
                            <div class="col-3">
                                <button type="button" class="btn btn-outline-primary w-100 quick-amount text-white" data-amount="10">$10</button>
                            </div>
                            <div class="col-3">
                                <button type="button" class="btn btn-outline-primary w-100 quick-amount text-white" data-amount="25">$25</button>
                            </div>
                            <div class="col-3">
                                <button type="button" class="btn btn-outline-primary w-100 quick-amount text-white" data-amount="50">$50</button>
                            </div>
                            <div class="col-3">
                                <button type="button" class="btn btn-outline-primary w-100 quick-amount text-white" data-amount="100">$100</button>
                            </div>
                        </div>
                    </div>

                    <!-- Payment Form -->
                    <form id="donation-form">
                        @csrf
                        <input type="hidden" name="transactionId" value="{{ $transaction->id }}">

                        <!-- Square Card Container -->
                        <div class="mb-4">
                            <label class="form-label fw-bold">
                                <i class="fas fa-credit-card me-2"></i>Payment Information *
                            </label>
                            <div id="card-container" class="border rounded p-3" style="min-height: 60px;"></div>
                        </div>

                        <!-- Processing Fee Info -->
                        <div class="alert alert-info border-0 mb-4">
                            <div class="d-flex justify-content-between">
                                <span>Processing Fee (2.9% + $0.30):</span>
                                <span id="processing-fee">$0.00</span>
                            </div>
                            <div class="d-flex justify-content-between fw-bold">
                                <span>Total Amount:</span>
                                <span id="total-amount">$0.00</span>
                            </div>
                        </div>

                        <!-- Submit Button -->
                        <button type="submit" id="donate-button" class="btn btn-primary btn-lg w-100">
                            <i class="fas fa-heart me-2"></i>Donate Now
                        </button>

                        <!-- Error Message -->
                        <div id="error-message" class="alert alert-danger mt-3" style="display: none;"></div>

                        <!-- Success Message -->
                        <div id="success-message" class="alert alert-success mt-3" style="display: none;"></div>
                    </form>
                </div>
            </div>

            <!-- Security Info -->
            <div class="text-center mt-4" data-aos="fade-up" data-aos-delay="200">
                <small class="text-muted">
                    <i class="fas fa-shield-alt me-1"></i>
                    Your payment is secured by Square. We never store your card information.
                </small>
            </div>
        </div>
    </div>
</div>

  <script type="text/javascript" src="https://sandbox.web.squarecdn.com/v1/square.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const appId = "{{ env('SQUARE_APPLICATION_ID') }}";
    const locationId = "{{ env('SQUARE_LOCATION_ID') }}";

    // Debug logging
    console.log('Square Configuration:', { appId, locationId });
    const amountInput = document.getElementById('amount');
    const processingFeeSpan = document.getElementById('processing-fee');
    const totalAmountSpan = document.getElementById('total-amount');
    const quickAmountBtns = document.querySelectorAll('.quick-amount');
    const donateButton = document.getElementById('donate-button');
    const errorMessage = document.getElementById('error-message');
    const successMessage = document.getElementById('success-message');
    const form = document.getElementById('donation-form');

    let card;
    let isProcessing = false;

    // Initialize Square payment form
    async function initializeSquare() {
        try {
            // Check if Square is loaded
            if (typeof window.Square === 'undefined') {
                showError('Square payment system failed to load. Please refresh the page.');
                return;
            }

            // Check if required credentials are available
            if (!appId || !locationId) {
                showError('Payment system configuration error. Please contact support.');
                console.error('Missing Square credentials:', { appId, locationId });
                return;
            }

            const payments = window.Square.payments(appId, locationId);
            card = await payments.card();
            await card.attach('#card-container');

            // Update amounts on load
            updateAmounts();
        } catch (err) {
            showError('Payment system initialization failed: ' + err.message);
            console.error('Square initialization error:', err);
        }
    }

    // Update processing fee and total
    function updateAmounts() {
        const amount = parseFloat(amountInput.value) || 0;
        const processingFee = (amount * 0.029) + 0.30;
        const total = amount + processingFee;

        processingFeeSpan.textContent = '$' + processingFee.toFixed(2);
        totalAmountSpan.textContent = '$' + total.toFixed(2);
    }

    // Quick amount buttons
    quickAmountBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const amount = this.dataset.amount;
            amountInput.value = amount;
            updateAmounts();

            // Update button states
            quickAmountBtns.forEach(b => b.classList.remove('btn-primary', 'active'));
            this.classList.add('btn-primary', 'active');
        });
    });

    // Amount input change
    amountInput.addEventListener('input', function() {
        updateAmounts();
        // Remove active state from quick buttons
        quickAmountBtns.forEach(b => b.classList.remove('btn-primary', 'active'));
    });

    // Form submission
    form.addEventListener('submit', async function(e) {
        e.preventDefault();

        if (isProcessing) return;

        const amount = parseFloat(amountInput.value);
        if (amount < 1) {
            showError('Please enter a valid donation amount.');
            return;
        }

        isProcessing = true;
        donateButton.disabled = true;
        donateButton.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';
        hideMessages();

        try {
            // Tokenize card
            const result = await card.tokenize();

            if (result.status === 'OK') {
                // Send to backend
                const response = await fetch('{{ route("square.donate.process", $transaction->id) }}', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                    },
                    body: JSON.stringify({
                        sourceId: result.token,
                        amount: amount
                    })
                });

                const data = await response.json();

                if (data.success) {
                    showSuccess('🎉 Thank you for your generous donation! You will be redirected shortly.');
                    setTimeout(() => {
                        window.location.href = '{{ route("ads.show", $transaction->donationId) }}';
                    }, 3000);
                } else {
                    showError(data.error || 'Donation failed. Please try again.');
                }
            } else {
                showError(result.errors?.[0]?.message || 'Card processing failed. Please try again.');
            }
        } catch (err) {
            showError('An error occurred. Please try again.');
            console.error('Donation error:', err);
        } finally {
            isProcessing = false;
            donateButton.disabled = false;
            donateButton.innerHTML = '<i class="fas fa-heart me-2"></i>Donate Now';
        }
    });

    function showError(message) {
        errorMessage.textContent = message;
        errorMessage.style.display = 'block';
        successMessage.style.display = 'none';
    }

    function showSuccess(message) {
        successMessage.textContent = message;
        successMessage.style.display = 'block';
        errorMessage.style.display = 'none';
    }

    function hideMessages() {
        errorMessage.style.display = 'none';
        successMessage.style.display = 'none';
    }

    // Initialize Square with fallback
    if (typeof window.Square !== 'undefined') {
        initializeSquare();
    } else {
        // Wait for Square to load
        let attempts = 0;
        const maxAttempts = 10;
        const checkSquare = setInterval(() => {
            attempts++;
            if (typeof window.Square !== 'undefined') {
                clearInterval(checkSquare);
                initializeSquare();
            } else if (attempts >= maxAttempts) {
                clearInterval(checkSquare);
                showError('Square payment system failed to load. Please refresh the page and try again.');
            }
        }, 500);
    }
});
</script>

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

.btn-outline-primary {
    color: #584CF4;
    border-color: #584CF4;
}

.btn-outline-primary:hover,
.btn-outline-primary.active {
    background: #584CF4;
    border-color: #584CF4;
    color: white;
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

#card-container {
    background: #f8f9ff;
    border: 1px solid #e9ecef;
    transition: border-color 0.3s ease;
}

#card-container:focus-within {
    border-color: #584CF4;
    box-shadow: 0 0 0 0.2rem rgba(88, 76, 244, 0.25);
}
</style>
@endsection
