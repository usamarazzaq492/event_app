<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    protected $table = 'events';
    protected $primaryKey = 'eventId';
    public $timestamps = false;

    protected $fillable = [
        'userId',
        'eventTitle',
        'startDate',
        'endDate',
        'startTime',
        'endTime',
        'eventPrice',
        'description',
        'category',
        'address',
        'city',
        'latitude',
        'longitude',
        'eventImage',
        'live_stream_url',
        'isActive',
        'addDate',
        'editDate'
    ];

    protected $casts = [
        'startDate' => 'date',
        'endDate' => 'date',
        'startTime' => 'datetime:H:i:s',
        'endTime' => 'datetime:H:i:s',
        'eventPrice' => 'decimal:2',
        'isActive' => 'boolean',
        'addDate' => 'datetime',
        'editDate' => 'datetime'
    ];

    // Relationship with user (organizer)
    public function user()
    {
        return $this->belongsTo(User::class, 'userId', 'userId');
    }

    // Relationship with bookings
    public function bookings()
    {
        return $this->hasMany(Booking::class, 'eventId', 'eventId');
    }

    // Check if user has valid ticket for this event
    public function hasValidTicket($userId)
    {
        return $this->bookings()
            ->where('userId', $userId)
            ->where('status', 'confirmed')
            ->exists();
    }

    // Check if user is the organizer
    public function isOrganizer($userId)
    {
        return $this->userId == $userId;
    }

    // Check if user has access to live stream
    public function hasLiveStreamAccess($userId)
    {
        return $this->isOrganizer($userId) || $this->hasValidTicket($userId);
    }

    // Get embed URL for live stream
    public function getLiveStreamEmbedUrl()
    {
        if (!$this->live_stream_url) {
            return null;
        }

        // YouTube URL conversion
        if (strpos($this->live_stream_url, 'youtube.com') !== false || strpos($this->live_stream_url, 'youtu.be') !== false) {
            $videoId = $this->extractYouTubeVideoId($this->live_stream_url);
            if ($videoId) {
                return "https://www.youtube.com/embed/{$videoId}";
            }
        }

        // Facebook Live URL conversion
        if (strpos($this->live_stream_url, 'facebook.com') !== false) {
            return $this->live_stream_url; // Facebook URLs can be used directly
        }

        return null;
    }

    // Extract YouTube video ID from various YouTube URL formats
    private function extractYouTubeVideoId($url)
    {
        $pattern = '/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/';
        preg_match($pattern, $url, $matches);
        return isset($matches[1]) ? $matches[1] : null;
    }
}

