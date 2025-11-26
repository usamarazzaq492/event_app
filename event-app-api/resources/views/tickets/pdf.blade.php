<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Event Ticket - {{ $booking->eventTitle }}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Arial', sans-serif;
            background: #f8f9fa;
            color: #333;
        }

        .ticket-container {
            max-width: 400px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }

        .ticket-header {
            background: linear-gradient(135deg, #584CF4 0%, #ff9500 100%);
            color: white;
            padding: 20px;
            text-align: center;
            position: relative;
        }

        .ticket-header::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 20px;
            height: 20px;
            background: #f8f9fa;
            border-radius: 50%;
        }

        .event-title {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 8px;
        }

        .event-date {
            font-size: 16px;
            opacity: 0.9;
        }

        .ticket-body {
            padding: 25px;
        }

        .ticket-info {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 12px;
        }

        .info-item {
            text-align: center;
        }

        .info-label {
            font-size: 12px;
            color: #666;
            margin-bottom: 4px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .info-value {
            font-size: 16px;
            font-weight: bold;
            color: #333;
        }

        .ticket-details {
            margin-bottom: 25px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #eee;
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            font-size: 14px;
            color: #666;
            font-weight: 500;
        }

        .detail-value {
            font-size: 14px;
            color: #333;
            font-weight: 600;
        }

        .qr-section {
            text-align: center;
            margin: 25px 0;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 12px;
        }

        .qr-code {
            width: 120px;
            height: 120px;
            background: #333;
            margin: 0 auto 15px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 12px;
            text-align: center;
            line-height: 1.2;
        }

        .qr-label {
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
        }

        .ticket-number {
            font-size: 18px;
            font-weight: bold;
            color: #584CF4;
            margin-bottom: 10px;
        }

        .ticket-footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            border-top: 1px solid #eee;
        }

        .footer-text {
            font-size: 12px;
            color: #666;
            line-height: 1.4;
        }

        .ticket-type-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .ticket-type-gold {
            background: #ffd700;
            color: #333;
        }

        .ticket-type-silver {
            background: #c0c0c0;
            color: #333;
        }

        .ticket-type-general {
            background: #584CF4;
            color: white;
        }

        .price-highlight {
            font-size: 20px;
            font-weight: bold;
            color: #584CF4;
        }

        .event-image {
            width: 100%;
            height: 150px;
            object-fit: cover;
            border-radius: 8px;
            margin-bottom: 15px;
        }

        .page-break {
            page-break-before: always;
        }

        @media print {
            body {
                background: white;
            }

            .ticket-container {
                box-shadow: none;
                margin-bottom: 0;
            }
        }

        .print-instructions {
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: #584CF4;
            color: white;
            padding: 15px 25px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            z-index: 1000;
            text-align: center;
            font-size: 14px;
            max-width: 400px;
        }

        .print-instructions .close-btn {
            position: absolute;
            top: 5px;
            right: 10px;
            background: none;
            border: none;
            color: white;
            font-size: 18px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <!-- Print Instructions -->
    <div class="print-instructions" id="printInstructions">
        <button class="close-btn" onclick="closeInstructions()">&times;</button>
        <strong>📄 Print Your Tickets</strong><br>
        Press <kbd>Ctrl+P</kbd> (Windows) or <kbd>Cmd+P</kbd> (Mac) to print as PDF<br>
        <small>Make sure to select "Save as PDF" in the print dialog</small>
    </div>

    @foreach($tickets as $index => $ticket)
        <div class="ticket-container {{ $index > 0 ? 'page-break' : '' }}">
            <!-- Event Image -->
            @if($booking->eventImage)
                <img src="{{ asset($booking->eventImage) }}" alt="{{ $booking->eventTitle }}" class="event-image">
            @endif

            <!-- Ticket Header -->
            <div class="ticket-header">
                <div class="event-title">{{ $booking->eventTitle }}</div>
                <div class="event-date">
                    {{ \Carbon\Carbon::parse($booking->startDate)->format('M d, Y') }} at
                    {{ \Carbon\Carbon::parse($booking->startTime)->format('g:i A') }}
                </div>
            </div>

            <!-- Ticket Body -->
            <div class="ticket-body">
                <!-- Ticket Number -->
                <div class="ticket-number">Ticket #{{ $ticket['ticket_number'] }}</div>

                <!-- Ticket Info -->
                <div class="ticket-info">
                    <div class="info-item">
                        <div class="info-label">Type</div>
                        <div class="info-value">
                            <span class="ticket-type-badge ticket-type-{{ $ticket['ticket_type'] }}">
                                {{ ucfirst($ticket['ticket_type']) }}
                            </span>
                        </div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Price</div>
                        <div class="info-value price-highlight">${{ number_format($ticket['total_amount'], 2) }}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Status</div>
                        <div class="info-value" style="color: #28a745;">Confirmed</div>
                    </div>
                </div>

                <!-- Ticket Details -->
                <div class="ticket-details">
                    <div class="detail-row">
                        <span class="detail-label">Event Date</span>
                        <span class="detail-value">{{ \Carbon\Carbon::parse($booking->startDate)->format('M d, Y') }}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Event Time</span>
                        <span class="detail-value">{{ \Carbon\Carbon::parse($booking->startTime)->format('g:i A') }}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Location</span>
                        <span class="detail-value">{{ $booking->city ?? 'TBA' }}</span>
                    </div>
                    @if($booking->address)
                    <div class="detail-row">
                        <span class="detail-label">Address</span>
                        <span class="detail-value">{{ $booking->address }}</span>
                    </div>
                    @endif
                    <div class="detail-row">
                        <span class="detail-label">Attendee</span>
                        <span class="detail-value">{{ $booking->userName }}</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Email</span>
                        <span class="detail-value">{{ $booking->userEmail }}</span>
                    </div>
                </div>

                <!-- QR Code Section -->
                <div class="qr-section">
                    <div class="qr-label">Scan for verification</div>
                    <div class="qr-code">
                        QR CODE<br>
                        {{ $ticket['ticket_number'] }}
                    </div>
                    <div style="font-size: 10px; color: #999;">
                        Present this ticket at the event entrance
                    </div>
                </div>
            </div>

            <!-- Ticket Footer -->
            <div class="ticket-footer">
                <div class="footer-text">
                    <strong>EventGo</strong><br>
                    Thank you for your booking!<br>
                    For support, contact us at support@eventgo-live.com
                </div>
            </div>
        </div>
    @endforeach

    <script>
        // Auto-hide instructions after 5 seconds
        setTimeout(() => {
            const instructions = document.getElementById('printInstructions');
            if (instructions) {
                instructions.style.opacity = '0';
                setTimeout(() => instructions.remove(), 300);
            }
        }, 5000);

        // Close instructions function
        function closeInstructions() {
            const instructions = document.getElementById('printInstructions');
            if (instructions) {
                instructions.style.opacity = '0';
                setTimeout(() => instructions.remove(), 300);
            }
        }

        // Auto-trigger print dialog after a short delay
        window.addEventListener('load', () => {
            setTimeout(() => {
                // Only trigger print if this is opened in a new window/tab
                if (window.opener) {
                    window.print();
                }
            }, 1000);
        });

        // Handle print event
        window.addEventListener('beforeprint', () => {
            // Hide instructions before printing
            const instructions = document.getElementById('printInstructions');
            if (instructions) {
                instructions.style.display = 'none';
            }
        });

        // Show instructions again after print
        window.addEventListener('afterprint', () => {
            const instructions = document.getElementById('printInstructions');
            if (instructions) {
                instructions.style.display = 'block';
            }
        });
    </script>
</body>
</html>
