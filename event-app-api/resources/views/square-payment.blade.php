<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Pay for {{ $eventName ?? 'Event' }} - EventGo</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="csrf-token" content="{{ csrf_token() }}">
  <link rel="icon" href="{{ asset('fav.png') }}" type="image/png">
  <script type="text/javascript" src="https://sandbox.web.squarecdn.com/v1/square.js"></script>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background: #fff;
      color: #333;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      padding: 2rem;
    }

    .payment-container {
      background: #ffffff;
      border-radius: 20px;
      border: 1px solid #e0e0e0;
      box-shadow: 0 4px 25px rgba(0, 0, 0, 0.06);
      max-width: 420px;
      width: 100%;
      padding: 2rem;
      text-align: center;
      transition: border-color 0.4s ease, box-shadow 0.4s ease;
    }

    .payment-container:focus-within {
      border-color: #667eea;
      box-shadow: 0 0 12px rgba(102, 126, 234, 0.4);
    }

    .logo img {
      width: 70px;
      height: 70px;
      object-fit: contain;
      margin-bottom: 1rem;
    }

    h2 {
      font-size: 1.6rem;
      margin-bottom: 0.5rem;
      color: #667eea;
    }

    .intro {
      font-size: 0.95rem;
      color: #666;
      margin-bottom: 1.5rem;
    }

    .booking-details {
      background: #f8f9fa;
      border-radius: 12px;
      padding: 1.5rem;
      margin-bottom: 2rem;
      text-align: left;
    }

    .booking-details h3 {
      margin: 0 0 1rem 0;
      color: #333;
      font-size: 1.1rem;
    }

    .booking-details p {
      margin: 0.5rem 0;
      color: #666;
    }

    #card-container {
      margin-bottom: 20px;
    }

    #pay-button {
      width: 100%;
      padding: 12px;
      border: none;
      border-radius: 25px;
      background: linear-gradient(135deg, #667eea, #764ba2);
      color: #fff;
      font-size: 1rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s ease;
    }

    #pay-button:hover {
      background: linear-gradient(135deg, #5b6dea, #683caa);
    }

    #error-message {
      color: red;
      margin-top: 10px;
      font-size: 0.9rem;
    }

    @media (max-width: 480px) {
      .payment-container {
        padding: 1.5rem;
      }

      h2 {
        font-size: 1.4rem;
      }
    }
  </style>
</head>
<body>
  <div class="payment-container">
    <div class="logo">
      <img src="{{ asset('fav.png') }}" alt="EventGo Logo">
    </div>
    <h2>Pay for {{ $eventName ?? 'Your Event' }}</h2>
    <p class="intro">Securely pay {{ $amount ?? '$0.00' }} using your card below.</p>

    @if(isset($quantity) && isset($ticketType))
    <div class="booking-details">
      <h3>Booking Details</h3>
      <p><strong>Ticket Type:</strong> {{ ucfirst($ticketType) }}</p>
      <p><strong>Quantity:</strong> {{ $quantity }}</p>
      @if(isset($subtotal))
      <p><strong>Subtotal:</strong> ${{ number_format($subtotal, 2) }}</p>
      <p><strong>Service Fee:</strong> ${{ number_format($serviceFee, 2) }}</p>
      <p><strong>Processing Fee:</strong> ${{ number_format($processingFee, 2) }}</p>
      <p><strong>Total:</strong> ${{ number_format($totalAmount, 2) }}</p>
      @endif
    </div>
    @endif

    <div id="card-container"></div>
    <button id="pay-button">Pay Now</button>
    <div id="error-message"></div>
    <div id="success-message"></div>
  </div>

  <script>
    const appId = "{{ env('SQUARE_APPLICATION_ID') }}";
    const locationId = "{{ env('SQUARE_LOCATION_ID') }}";

    async function main() {
      try {
        const payments = window.Square.payments(appId, locationId);
        const card = await payments.card();
        await card.attach('#card-container');

        document.getElementById('pay-button').addEventListener('click', async () => {
          console.log("Pay button clicked");
          const result = await card.tokenize();
          console.log(result); // See what result contains
          if (result.status === 'OK') {
            const nonce = result.token;
            console.log("Nonce generated:", nonce);

            // Check if this is a mobile app (Flutter WebView)
            if (window.FlutterWebView?.postMessage) {
              window.FlutterWebView.postMessage(nonce);
            } else {
              // This is a web browser - send to backend
              try {
                const urlParams = new URLSearchParams(window.location.search);
                const quantity = urlParams.get('quantity') || {{ $quantity ?? 1 }};
                const ticketType = urlParams.get('ticket_type') || '{{ $ticketType ?? 'general' }}';

                // Debug logging
                console.log('Payment Debug Info:', {
                  eventId: {{ $eventId ?? 'null' }},
                  eventId_type: typeof {{ $eventId ?? 'null' }},
                  quantity: quantity,
                  ticketType: ticketType,
                  totalAmount: {{ $totalAmount ?? 0 }},
                  sourceId: nonce,
                  route: '{{ route("square.payment.process", $eventId) }}'
                });

                const response = await fetch('{{ route("square.payment.process", $eventId) }}?quantity=' + quantity + '&ticket_type=' + ticketType, {
                  method: 'POST',
                  headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
                  },
                  body: JSON.stringify({
                    sourceId: nonce,
                    amount: {{ $totalAmount ?? 0 }}
                  })
                });

                const data = await response.json();
                console.log('Payment response:', data);

                if (data.success) {
                  document.getElementById('success-message').innerText = 'Payment successful! Redirecting...';
                  setTimeout(() => {
                    window.location.href = '{{ route("events.show", $eventId) }}';
                  }, 2000);
                } else {
                  // Show detailed error information
                  let errorMessage = data.error || 'Payment failed.';
                  if (data.debug_info) {
                    errorMessage += '\nDebug Info: ' + JSON.stringify(data.debug_info, null, 2);
                  }
                  document.getElementById('error-message').innerText = errorMessage;
                  console.error('Payment failed:', data);
                }
              } catch (error) {
                console.error('Payment error:', error);
                document.getElementById('error-message').innerText = 'Payment failed. Please try again. Error: ' + error.message;
              }
            }
          } else {
            console.error(result.errors);
            document.getElementById('error-message').innerText =
              result.errors?.[0]?.message || 'Payment failed.';
          }
        });

      } catch (err) {
        document.getElementById('error-message').innerText = "Init error: " + err.message;
      }
    }

    main();
  </script>
</body>
</html>
