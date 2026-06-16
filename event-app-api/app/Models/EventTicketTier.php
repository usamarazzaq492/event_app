<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EventTicketTier extends Model
{
    protected $table = 'event_ticket_tiers';
    protected $primaryKey = 'tierId';

    const CREATED_AT = 'createdAt';
    const UPDATED_AT = 'updatedAt';

    protected $fillable = [
        'eventId',
        'tierName',
        'price',
        'quantityCap',
        'quantitySold',
        'description',
        'sortOrder',
        'isActive',
    ];

    protected $casts = [
        'price'        => 'decimal:2',
        'quantityCap'  => 'integer',
        'quantitySold' => 'integer',
        'sortOrder'    => 'integer',
        'isActive'     => 'boolean',
    ];

    // Relationship — belongs to an event
    public function event()
    {
        return $this->belongsTo(Event::class, 'eventId', 'eventId');
    }

    // Relationship — has many booking tier rows
    public function bookingTiers()
    {
        return $this->hasMany(BookingTier::class, 'tierId', 'tierId');
    }

    // Computed: how many tickets remain available
    public function getAvailableAttribute(): ?int
    {
        if ($this->quantityCap === null) {
            return null; // unlimited
        }
        return max(0, $this->quantityCap - $this->quantitySold);
    }

    // Computed: whether this tier is fully sold out
    public function getIsSoldOutAttribute(): bool
    {
        if ($this->quantityCap === null) {
            return false;
        }
        return $this->quantitySold >= $this->quantityCap;
    }
}
