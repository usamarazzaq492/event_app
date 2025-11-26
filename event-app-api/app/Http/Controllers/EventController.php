<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use App\Models\Event;
use App\Models\Booking;

class EventController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'eventTitle' => 'required|string|max:500',
            'startDate' => 'required|date',
            'endDate' => 'nullable|date|after_or_equal:startDate',
            'startTime' => 'required|date_format:H:i',
            'endTime' => 'required|date_format:H:i',
            'eventPrice' => 'nullable|numeric',
            'description' => 'required|string|max:1000',
            'category' => 'required|string|max:50',
            'address' => 'required|string|max:500',
            'city' => 'required|string|max:50',
            'eventImage' => 'required|image|max:2048',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'live_stream_url' => 'nullable|url|max:500',
        ]);

        // Validate live stream URL if provided
        if ($request->has('live_stream_url') && $request->live_stream_url) {
            $liveStreamValidation = $this->validateLiveStreamUrl($request->live_stream_url);
            if (!$liveStreamValidation['valid']) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid live stream URL',
                    'errors' => ['live_stream_url' => [$liveStreamValidation['message']]]
                ], 400);
            }
        }

        $path = $request->file('eventImage')->store('events', 'public');

        $eventId = DB::table('events')->insertGetId([
            'userId' => $request->user()->userId,
            'eventTitle' => $validated['eventTitle'],
            'startDate' => $validated['startDate'],
            'endDate' => $validated['endDate'],
            'startTime' => $validated['startTime'],
            'endTime' => $validated['endTime'],
            'eventPrice' => $validated['eventPrice'],
            'description' => $validated['description'],
            'category' => $validated['category'],
            'address' => $validated['address'],
            'city' => $validated['city'],
            'eventImage' => "/storage/public/$path",
            'latitude' => $request->input('latitude'),
            'longitude' => $request->input('longitude'),
            'live_stream_url' => $request->input('live_stream_url'),
            'isActive' => 1,
            'addDate' => now(),
            'editDate' => now(),
        ]);

        return response()->json(['message' => 'Event created successfully.', 'eventId' => $eventId]);
    }

    public function index(Request $request)
{
    try {
        // Validate the search input
        $validated = $request->validate([
            'name' => 'sometimes|string|max:100'
        ]);

        $query = DB::table('events')
            ->where('isActive', 1)
            ->orderByRaw('
                CASE 
                    WHEN isPromoted = 1 AND promotionEndDate >= NOW() THEN 0 
                    ELSE 1 
                END ASC,
                startDate ASC
            ');

        // Name filter (case-insensitive search)
        if ($request->filled('name')) {
            $query->where('eventTitle', 'like', '%'.$validated['name'].'%');
        }

        $events = $query->get([
            'eventId',
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
            'eventImage',
            'latitude',
            'longitude',
            'isPromoted',
            'promotionStartDate',
            'promotionEndDate',
            'promotionPackage'
        ]);

        return response()->json([
            'success' => true,
            'data' => $events,
            'message' => 'Events retrieved successfully'
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Failed to fetch events',
            'error' => $e->getMessage()
        ], 500);
    }
}

    public function myEvents(Request $request)
    {
        $userId = $request->user()->userId;

        $events = DB::table('events')
            ->where('userId', $userId)
            ->where('isActive', 1)
            ->get();

        return response()->json($events);
    }

   public function show(Request $request, $id)
{
    $event = DB::table('events')->where('eventId', $id)->first();

    if (!$event) {
        return response()->json(['error' => 'Event not found.'], 404);
    }

    // Get current user ID
    $userId = $request->user()->userId;

    // Check booking status for this user and event
    $isBooked = DB::table('booking')
        ->where('eventId', $id)
        ->where('userId', $userId)
        ->where('status', 'confirmed')
        ->exists();

    // Check if user is the organizer
    $isOrganizer = $event->userId == $userId;

    // Check if user has access to live stream
    $hasLiveStreamAccess = $isOrganizer || $isBooked;

    // Convert event object to array
    $eventArray = (array) $event;
    $eventArray['isBooked'] = $isBooked;
    $eventArray['isOrganizer'] = $isOrganizer;
    $eventArray['hasLiveStreamAccess'] = $hasLiveStreamAccess;

    // Only include live stream URL if user has access
    if (!$hasLiveStreamAccess) {
        unset($eventArray['live_stream_url']);
    } else if ($event->live_stream_url) {
        // Add embed URL for live stream
        $eventArray['live_stream_embed_url'] = $this->getLiveStreamEmbedUrl($event->live_stream_url);
    }

    return response()->json($eventArray);
}


    public function update(Request $request, $id)
    {
        $userId = $request->user()->userId;
        $event = DB::table('events')->where('eventId', $id)->first();

        if (!$event) {
            return response()->json(['error' => 'Event not found.'], 404);
        }

        if ($event->userId !== $userId) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'eventTitle' => 'sometimes|required|string|max:500',
            'startDate' => 'sometimes|required|date',
            'endDate' => 'nullable|date|after_or_equal:startDate',
            'startTime' => 'sometimes|required|date_format:H:i',
            'endTime' => 'sometimes|required|date_format:H:i',
            'eventPrice' => 'nullable|numeric',
            'description' => 'sometimes|required|string|max:1000',
            'category' => 'sometimes|required|string|max:50',
            'address' => 'sometimes|required|string|max:500',
            'city' => 'sometimes|required|string|max:50',
            'eventImage' => 'nullable|image|max:2048',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'live_stream_url' => 'nullable|url|max:500',
        ]);

        // Validate live stream URL if provided
        if ($request->has('live_stream_url') && $request->live_stream_url) {
            $liveStreamValidation = $this->validateLiveStreamUrl($request->live_stream_url);
            if (!$liveStreamValidation['valid']) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid live stream URL',
                    'errors' => ['live_stream_url' => [$liveStreamValidation['message']]]
                ], 400);
            }
        }

        $dataToUpdate = $validated;

        if ($request->hasFile('eventImage')) {
            if ($event->eventImage) {
                Storage::disk('public')->delete(str_replace('public/', '', $event->eventImage));
            }
            $path = $request->file('eventImage')->store('events', 'public');
            $dataToUpdate['eventImage'] = "/storage/public/$path";
        }

        // Add live stream URL to update data
        if ($request->has('live_stream_url')) {
            $dataToUpdate['live_stream_url'] = $request->input('live_stream_url');
        }

        $dataToUpdate['editDate'] = now();

        DB::table('events')->where('eventId', $id)->update($dataToUpdate);

        return response()->json(['message' => 'Event updated successfully.']);
    }

    public function destroy(Request $request, $id)
    {
        $userId = $request->user()->userId;
        $event = DB::table('events')->where('eventId', $id)->first();

        if (!$event) {
            return response()->json(['error' => 'Event not found.'], 404);
        }

        if ($event->userId !== $userId) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        DB::table('events')->where('eventId', $id)->delete();

        return response()->json(['message' => 'Event deleted successfully.']);
    }

    private function validateLiveStreamUrl($url)
    {
        // Check if URL is valid
        if (!filter_var($url, FILTER_VALIDATE_URL)) {
            return [
                'valid' => false,
                'message' => 'Invalid URL format'
            ];
        }

        // Check if URL is from YouTube or Facebook
        $youtubePattern = '/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/';
        $facebookPattern = '/facebook\.com/';

        if (preg_match($youtubePattern, $url) || preg_match($facebookPattern, $url)) {
            return [
                'valid' => true,
                'message' => 'Valid live stream URL'
            ];
        }

        return [
            'valid' => false,
            'message' => 'Live stream URL must be from YouTube or Facebook'
        ];
    }

    private function getLiveStreamEmbedUrl($url)
    {
        if (!$url) {
            return null;
        }

        // YouTube URL conversion
        if (strpos($url, 'youtube.com') !== false || strpos($url, 'youtu.be') !== false) {
            $videoId = $this->extractYouTubeVideoId($url);
            if ($videoId) {
                return "https://www.youtube.com/embed/{$videoId}";
            }
        }

        // Facebook Live URL conversion
        if (strpos($url, 'facebook.com') !== false) {
            return $url; // Facebook URLs can be used directly
        }

        return null;
    }

    private function extractYouTubeVideoId($url)
    {
        $pattern = '/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/';
        preg_match($pattern, $url, $matches);
        return isset($matches[1]) ? $matches[1] : null;
    }
}
