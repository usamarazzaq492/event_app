<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class EventWebController extends Controller
{
    /**
     * Display a listing of events
     */
    public function index(Request $request)
    {
        // Get 4 upcoming events for top section
        // Sort promoted events first, then by date
        $query = Event::query()
            ->where('startDate', '>=', now())
            ->orderByRaw('CASE WHEN isPromoted = 1 AND promotionEndDate > NOW() THEN 0 ELSE 1 END')
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

        // Check if user is authenticated and owns the event
        $isOwner = false;
        $promotionStatus = null;
        $qrCodes = collect([]);

        if (Auth::check()) {
            $user = Auth::user();
            // Ensure we're comparing the same types (integers)
            $isOwner = (int)$event->userId === (int)$user->userId;

            // Get promotion status if user owns the event
            if ($isOwner) {
                $isPromoted = $event->isPromoted == 1;
                $isActive = false;
                $daysRemaining = 0;

                if ($isPromoted && $event->promotionEndDate) {
                    $endDate = \Carbon\Carbon::parse($event->promotionEndDate);
                    $isActive = $endDate->isFuture();

                    if ($isActive) {
                        $daysRemaining = max(0, (int)ceil(now()->diffInDays($endDate, false)));
                    }
                }

                $promotionStatus = [
                    'isPromoted' => $isPromoted,
                    'isActive' => $isActive,
                    'package' => $event->promotionPackage,
                    'startDate' => $event->promotionStartDate,
                    'endDate' => $event->promotionEndDate,
                    'daysRemaining' => $daysRemaining,
                ];

                // Get active QR codes for this event
                $qrCodes = DB::table('payment_qr_codes')
                    ->where('eventId', $event->eventId)
                    ->where('isActive', true)
                    ->orderBy('created_at', 'desc')
                    ->get();
            }
        }

        return view('events.show', compact('event', 'isOwner', 'promotionStatus', 'qrCodes'));
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
     * Show the form for editing an event
     */
    public function edit($id)
    {
        $event = Event::findOrFail((int)$id);

        // Check if user is authenticated and owns the event
        if (!Auth::check()) {
            return redirect()->guest(route('login'))->with('error', 'Please login to edit events.');
        }

        if ((int)$event->userId !== (int)Auth::user()->userId) {
            return redirect()->route('events.show', $id)
                ->with('error', 'You are not authorized to edit this event.');
        }

        return view('events.edit', compact('event'));
    }

    /**
     * Update an event
     */
    public function update(Request $request, $id)
    {
        $event = Event::findOrFail((int)$id);

        // Verify user is organizer
        if (!Auth::check() || (int)$event->userId !== (int)Auth::user()->userId) {
            return redirect()->route('events.show', $id)
                ->with('error', 'You are not authorized to update this event.');
        }

        $request->validate([
            'eventTitle' => 'required|string|max:255|min:5',
            'description' => 'required|string|min:50',
            'category' => 'required|string|max:100',
            'city' => 'required|string|max:100',
            'startDate' => 'required|date',
            'endDate' => 'required|date|after_or_equal:startDate',
            'startTime' => 'required',
            'endTime' => 'required',
            'address' => 'required|string|max:500',
            'eventPrice' => 'required|numeric|min:0',
            'eventImage' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'live_stream_url' => 'nullable|url|max:500',
        ], [
            'eventTitle.min' => 'Event title must be at least 5 characters long.',
            'description.min' => 'Event description must be at least 50 characters long.',
            'endDate.after_or_equal' => 'End date must be on or after start date.',
            'eventImage.image' => 'File must be a valid image.',
            'eventImage.mimes' => 'Image must be in JPEG, PNG, JPG, or GIF format.',
            'eventImage.max' => 'Image size cannot exceed 2MB.',
        ]);

        try {
            $dataToUpdate = [
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
                'live_stream_url' => $request->live_stream_url,
                'editDate' => now(),
            ];

            // Handle image upload if new image provided
            if ($request->hasFile('eventImage')) {
                // Delete old image if exists
                if ($event->eventImage) {
                    $oldImagePath = str_replace('/storage/', 'public/', $event->eventImage);
                    if (Storage::exists($oldImagePath)) {
                        Storage::delete($oldImagePath);
                    }
                }

                $image = $request->file('eventImage');
                $imageName = 'event_' . Auth::user()->userId . '_' . time() . '.' . $image->getClientOriginalExtension();
                $imagePath = $image->storeAs('public/events', $imageName);
                $dataToUpdate['eventImage'] = '/storage/' . str_replace('public/', '', $imagePath);
            }

            $event->update($dataToUpdate);

            return redirect()->route('events.show', $event->eventId)
                ->with('success', '🎉 Event updated successfully!');

        } catch (\Exception $e) {
            Log::error('Event update failed: ' . $e->getMessage());

            return back()->withErrors(['error' => 'Failed to update event. Please try again.'])->withInput();
        }
    }

    /**
     * Book an event
     */
    public function book(Request $request, $id)
    {
        $request->validate([
            'quantity' => 'required|integer|min:1|max:10',
            'ticket_type' => 'required|in:vip,general'
        ]);

        $event = Event::findOrFail((int)$id);

        // Check if user is authenticated
        if (!Auth::check()) {
            return redirect()->guest(route('login'))->with('error', 'Please login to book this event.');
        }

        // Prevent event owners from booking their own events
        if (Auth::check() && (int)$event->userId === (int)Auth::user()->userId) {
            return redirect()->route('events.show', $id)
                ->with('error', 'You cannot book your own event.');
        }

        // Redirect to Square payment page
        return redirect()->route('square.payment', $id)->with([
            'quantity' => $request->quantity,
            'ticket_type' => $request->ticket_type
        ]);
    }
}

