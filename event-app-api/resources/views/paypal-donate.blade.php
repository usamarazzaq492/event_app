<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Complete Donation - EventGo</title>
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
            <h1>Complete Your Donation</h1>
        </div>

        <div class="card">
            <div class="order-summary">
                <div class="summary-row">
                    <span class="summary-label">Campaign</span>
                    <span class="summary-value">{{ $transaction->title }}</span>
                </div>
                
                <div class="summary-row total">
                    <span class="summary-label">Donation Amount</span>
                    <span class="summary-value">${{ number_format($transaction->amount, 2) }}</span>
                </div>
            </div>

            <div id="payment-message" class="message"></div>
            
            <div id="paypal-button-container"></div>
        </div>
    </div>

    <!-- Load PayPal JS SDK -->
    @php
        $clientId = config('paypal.client_id');
        $sdkUrl = "https://www.paypal.com/sdk/js?client-id=" . $clientId . "&currency=USD";
    @endphp
    
    <script src="{{ $sdkUrl }}"></script>

    <script>
        const totalAmount = "{{ number_format($transaction->amount, 2, '.', '') }}";
        const processUrl = "{{ route('paypal.donate.process', $transaction->id) }}";
        
        // Data for backend
        const requestData = {
            _token: "{{ csrf_token() }}",
            amount: totalAmount
        };

        function showMessage(msg, isError = false) {
            const msgEl = document.getElementById('payment-message');
            msgEl.textContent = msg;
            msgEl.className = 'message ' + (isError ? 'error' : 'success');
        }

        function toggleLoading(show) {
            document.getElementById('loading-overlay').classList.toggle('active', show);
        }

        // Send message to Flutter WebView
        function notifyFlutter(message) {
            if (window.FlutterWebView) {
                window.FlutterWebView.postMessage(message);
            } else {
                console.log('FlutterWebView channel not found', message);
            }
        }

        // Render PayPal buttons
        paypal.Buttons({
            createOrder: function(data, actions) {
                return actions.order.create({
                    purchase_units: [{
                        amount: {
                            value: totalAmount
                        }
                    }]
                });
            },
            onApprove: function(data, actions) {
                toggleLoading(true);
                notifyFlutter(data.orderID);
                showMessage('Payment authorized. Completing donation...');
                
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
