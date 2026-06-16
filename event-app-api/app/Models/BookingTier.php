<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BookingTier extends Model
{
    protected $table = 'booking_tiers';
    public $timestamps = false;

    protected $fillable = [
        'bookingId',
        'tierId',
        'tierName',
        'unitPrice',
        'quantity',
        'lineTotal',
    ];

    protected $casts = [
        'unitPrice' => 'decimal:2',
        'lineTotal' => 'decimal:2',
        'quantity'  => 'integer',
    ];

    // Relationship — belongs to a booking
    public function booking()
    {
        return $this->belongsTo(Booking::class, 'bookingId', 'bookingId');
    }

    // Relationship — belongs to a tier definition
    public function tier()
    {
        return $this->belongsTo(EventTicketTier::class, 'tierId', 'tierId');
    }
}
