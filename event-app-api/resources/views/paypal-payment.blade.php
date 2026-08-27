<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Complete Payment - EventGo</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #0070BA;
            --background-color: #F8F9FA;
            --card-color: #FFFFFF;
            --text-primary: #111827;
            --text-secondary: #6B7280;
            --border-color: #E5E7EB;
            --success-color: #10B981;
            --error-color: #EF4444;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Montserrat', sans-serif;
        }

        body {
            background-color: var(--background-color);
            color: var(--text-primary);
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
        }

        .container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }

        .header {
            text-align: center;
            margin-bottom: 24px;
        }

        .header h1 {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
        }

        .card {
            background: var(--card-color);
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            margin-bottom: 24px;
        }

        .order-summary {
            margin-bottom: 24px;
            padding-bottom: 24px;
            border-bottom: 1px solid var(--border-color);
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            font-size: 14px;
        }

        .summary-row.total {
            font-weight: 700;
            font-size: 18px;
            margin-top: 16px;
            margin-bottom: 0;
            padding-top: 16px;
            border-top: 1px dashed var(--border-color);
        }

        .summary-label {
            color: var(--text-secondary);
        }

        .summary-value {
            font-weight: 600;
        }

        .total .summary-label {
            color: var(--text-primary);
        }

        /* PayPal Container */
        #paypal-button-container {
            margin-top: 20px;
            min-height: 150px;
        }

        .loading-overlay {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(255,255,255,0.9);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 1000;
            visibility: hidden;
            opacity: 0;
            transition: all 0.3s;
        }

        .loading-overlay.active {
            visibility: visible;
            opacity: 1;
        }

        .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid var(--border-color);
            border-top-color: var(--primary-color);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin { 100% { transform: rotate(360deg); } }

        .message {
            margin-top: 16px;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            text-align: center;
            display: none;
        }

        .message.error {
            background-color: #FEE2E2;
            color: var(--error-color);
            border: 1px solid #FCA5A5;
            display: block;
        }

        .message.success {
            background-color: #D1FAE5;
            color: var(--success-color);
            border: 1px solid #6EE7B7;
            display: block;
        }
    </style>
</head>
<body>
    <div class="loading-overlay" id="loading-overlay">
        <div class="spinner"></div>
        <p style="margin-top: 16px; font-weight: 600;">Processing payment...</p>
    </div>

    <div class="container">
        <div class="header">
            <h1>Complete Your Payment</h1>
        </div>

        <div class="card">
            <div class="order-summary">
                <div class="summary-row">
                    <span class="summary-label">Item</span>
                    <span class="summary-value">{{ $eventName }}</span>
                </div>
                
                @if(isset($isPromotion) && $isPromotion)
                    <div class="summary-row">
                        <span class="summary-label">Promotion Package</span>
                        <span class="summary-value" style="text-transform: capitalize;">{{ $package }}</span>
                    </div>
                    <div class="summary-row">
                        <span class="summary-label">Price</span>
                        <span class="summary-value">${{ number_format($promotionPrice, 2) }}</span>
                    </div>
                @else
                    <div class="summary-row">
                        <span class="summary-label">Ticket Type</span>
                        <span class="summary-value" style="text-transform: capitalize;">{{ $ticketType }}</span>
                    </div>
                    <div class="summary-row">
                        <span class="summary-label">Quantity</span>
                        <span class="summary-value">{{ $quantity }}</span>
                    </div>
                    <div class="summary-row">
                        <span class="summary-label">Price per Ticket</span>
                        <span class="summary-value">${{ number_format($ticketPrice, 2) }}</span>
                    </div>
                    <div class="summary-row">
                        <span class="summary-label">Subtotal</span>
                        <span class="summary-value">${{ number_format($subtotal, 2) }}</span>
                    </div>
                @endif
                
                <div class="summary-row">
                    <span class="summary-label">Processing Fee</span>
                    <span class="summary-value">${{ number_format($processingFee, 2) }}</span>
                </div>
                
                <div class="summary-row total">
                    <span class="summary-label">Total Amount</span>
                    <span class="summary-value">{{ $amount }}</span>
                </div>
            </div>

            <div id="payment-message" class="message"></div>
            
            <div id="paypal-button-container"></div>
        </div>
    </div>

    <!-- Load PayPal JS SDK -->
    <!-- Payee info is used for split payments if merchantId is available -->
    @php
        $sdkUrl = "https://www.paypal.com/sdk/js?client-id=" . $clientId . "&currency=USD";
        if(isset($merchantId) && !empty($merchantId)) {
            // For advanced commerce platform split payments
            $sdkUrl .= "&merchant-id=" . $merchantId;
        }
    @endphp
    
    <script src="{{ $sdkUrl }}"></script>

    <script>
        const totalAmount = "{{ number_format($totalAmount, 2, '.', '') }}";
        const processUrl = "{{ route('paypal.payment.process', $eventId) }}";
        const isPromotion = {{ isset($isPromotion) && $isPromotion ? 'true' : 'false' }};
        
        // Data for backend
        const requestData = {
            _token: "{{ csrf_token() }}",
            amount: totalAmount,
            is_promotion: isPromotion
        };

        @if(isset($isPromotion) && $isPromotion)
            requestData.package = "{{ $package }}";
        @else
            requestData.quantity = {{ $quantity ?? 1 }};
            requestData.ticket_type = "{{ $ticketType ?? 'general' }}";
        @endif

        function showMessage(msg, isError = false) {
            const msgEl = document.getElementById('payment-message');
            msgEl.textContent = msg;
            msgEl.className = 'message ' + (isError ? 'error' : 'success');
        }

        function toggleLoading(show) {
            document.getElementById('loading-overlay').classList.toggle('active', show);
        }

        function notifyFlutter(message) {
            try {
                if (window.FlutterWebView) {
                    window.FlutterWebView.postMessage(message.toString());
                } else if (window.opener && window.opener.FlutterWebView) {
                    window.opener.FlutterWebView.postMessage(message.toString());
                } else if (window.parent && window.parent.FlutterWebView) {
                    window.parent.FlutterWebView.postMessage(message.toString());
                } else {
                    console.log('FlutterWebView channel not found', message);
                }
            } catch (e) {
                console.error('Error notifying Flutter:', e);
            }
        }

        // Render PayPal buttons
        paypal.Buttons({
            createOrder: function(data, actions) {
                // Set up the transaction
                let purchaseUnit = {
                    amount: {
                        value: totalAmount,
                        currency_code: "USD"
                    }
                };

                @if(isset($merchantId) && !empty($merchantId))
                purchaseUnit.payee = {
                    merchant_id: "{{ $merchantId }}"
                };
                purchaseUnit.payment_instruction = {
                    disbursement_mode: "INSTANT",
                    platform_fees: [{
                        amount: {
                            currency_code: "USD",
                            value: "{{ number_format($processingFee, 2, '.', '') }}"
                        }
                    }]
                };
                @endif

                return actions.order.create({
                    intent: 'CAPTURE',
                    purchase_units: [purchaseUnit]
                });
            },
            onApprove: function(data, actions) {
                toggleLoading(true);
                // Return the Order ID to Flutter as the 'nonce'
                // The Flutter app will then call the /events/{id}/book endpoint
                // which will capture the payment and generate tickets
                notifyFlutter(data.orderID);
                showMessage('Payment authorized. Completing booking...');
                
                // Attempt to close the popup if it opened one
                setTimeout(() => {
                    try { window.close(); } catch(e) {}
                }, 1500);

                // Keep loading state until Flutter closes the webview
                setTimeout(() => {
                    toggleLoading(false);
                }, 10000);
            },
            onError: function(err) {
                showMessage('An error occurred during payment processing.', true);
                console.error(err);
            },
            onCancel: function(data) {
                console.log('User cancelled payment');
            }
        }).render('#paypal-button-container');
    </script>
</body>
</html>
