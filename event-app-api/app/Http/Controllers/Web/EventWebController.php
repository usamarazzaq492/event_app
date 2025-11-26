<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class EventWebController extends Controller
{
    /**
     * Display a listing of events
     */
    public function index(Request $request)
    {
        // Get 4 upcoming events for top section
        $query = Event::query()
            ->where('startDate', '>=', now())
            ->orderBy('startDate', 'asc');

        // Apply search filter if provided
        if ($request->has('q') && $request->q) {
            $searchTerm = $request->q;
            $query->where(function($q) use ($searchTerm) {
                $q->where('eventTitle', 'like', "%{$searchTerm}%")
                  ->orWhere('description', 'like', "%{$searchTerm}%")
                  ->orWhere('category', 'like', "%{$searchTerm}%")
                  ->orWhere('city', 'like', "%{$searchTerm}%");
            });
        }

        $events = $query->paginate(12);

        return view('events.index', compact('events'));
    }

    /**
     * Display the specified event
     */
    public function show($id)
    {
        $event = Event::with('user')->findOrFail((int)$id);

        return view('events.show', compact('event'));
    }

    /**
     * Show the form for creating a new event
     */
    public function create()
    {
        return view('events.create');
    }

    /**
     * Search events
     */
    public function search(Request $request)
    {
        return $this->index($request);
    }

    /**
     * Store a newly created event
     */
    public function store(Request $request)
    {
        $request->validate([
            'eventTitle' => 'required|string|max:255|min:5',
            'description' => 'required|string|min:50',
            'category' => 'required|string|max:100',
            'city' => 'required|string|max:100',
            'startDate' => 'required|date|after_or_equal:today',
            'endDate' => 'required|date|after_or_equal:startDate',
            'startTime' => 'required',
            'endTime' => 'required',
            'address' => 'required|string|max:500',
            'eventPrice' => 'required|numeric|min:0',
            'eventImage' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
            'live_stream_url' => 'nullable|url|max:500',
        ], [
            'eventTitle.min' => 'Event title must be at least 5 characters long.',
            'description.min' => 'Event description must be at least 50 characters long.',
            'startDate.after_or_equal' => 'Start date must be today or later.',
            'endDate.after_or_equal' => 'End date must be on or after start date.',
            'eventImage.required' => 'Event image is required.',
            'eventImage.image' => 'File must be a valid image.',
            'eventImage.mimes' => 'Image must be in JPEG, PNG, JPG, or GIF format.',
            'eventImage.max' => 'Image size cannot exceed 2MB.',
        ]);

        try {
            $user = Auth::user();

            // Handle image upload
            $image = $request->file('eventImage');
            $imageName = 'event_' . $user->userId . '_' . time() . '.' . $image->getClientOriginalExtension();
            $imagePath = $image->storeAs('public/events', $imageName);
            $imageUrl = '/storage/' . str_replace('public/', '', $imagePath);

            // Create event
            $event = Event::create([
                'userId' => $user->userId,
                'eventTitle' => $request->eventTitle,
                'description' => $request->description,
                'category' => $request->category,
                'city' => $request->city,
                'startDate' => $request->startDate,
                'endDate' => $request->endDate,
                'startTime' => $request->startTime,
                'endTime' => $request->endTime,
                'address' => $request->address,
                'eventPrice' => $request->eventPrice,
                'eventImage' => $imageUrl,
                'live_stream_url' => $request->live_stream_url,
                'isActive' => 1,
                'addDate' => now(),
            ]);

            return redirect()->route('events.show', $event->eventId)
                ->with('success', '🎉 Event created successfully! Your event is now live and ready for bookings.');

        } catch (\Exception $e) {
            // Log the error
            Log::error('Event creation failed: ' . $e->getMessage());

            return back()->withErrors(['error' => 'Failed to create event. Please try again.'])->withInput();
        }
    }

    /**
     * Book an event
     */
    public function book(Request $request, $id)
    {
        $request->validate([
            'quantity' => 'required|integer|min:1|max:10',
            'ticket_type' => 'required|in:gold,silver,general'
        ]);

        $event = Event::findOrFail((int)$id);

        // Check if user is authenticated
        if (!Auth::check()) {
            return redirect()->route('login')->with('error', 'Please login to book this event.');
        }

        // Redirect to Square payment page
        return redirect()->route('square.payment', $id)->with([
            'quantity' => $request->quantity,
            'ticket_type' => $request->ticket_type
        ]);
    }
}

