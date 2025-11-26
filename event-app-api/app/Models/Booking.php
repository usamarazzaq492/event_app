<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    protected $table = 'booking';
    protected $primaryKey = 'bookingId';
    public $timestamps = false;

    protected $fillable = [
        'userId',
        'eventId',
        'bookingDate',
        'ticketType',
        'quantity',
        'totalAmount',
        'squarePaymentId',
        'status',
        'basePrice',
        'subtotal',
        'serviceFee',
        'processingFee',
        'feeBreakdown'
    ];

    protected $casts = [
        'bookingDate' => 'datetime',
        'totalAmount' => 'decimal:2',
        'basePrice' => 'decimal:2',
        'subtotal' => 'decimal:2',
        'serviceFee' => 'decimal:2',
        'processingFee' => 'decimal:2',
        'feeBreakdown' => 'array'
    ];

    // Relationship with user
    public function user()
    {
        return $this->belongsTo(User::class, 'userId', 'userId');
    }

    // Relationship with event
    public function event()
    {
        return $this->belongsTo(Event::class, 'eventId', 'eventId');
    }
}

