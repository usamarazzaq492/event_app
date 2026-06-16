<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Models\EventTicketTier;

class TicketTierController extends Controller
{
    // ─── Public: List active tiers for an event ─────────────────────────────

    /**
     * GET /api/v1/events/{id}/tiers
     * Returns all active tiers with available ticket counts.
     * Public endpoint — no authentication required.
     */
    public function index($eventId)
    {
        $event = DB::table('events')->where('eventId', $eventId)->first();

        if (!$event) {
            return response()->json(['error' => 'Event not found.'], 404);
        }

        $tiers = EventTicketTier::where('eventId', $eventId)
            ->where('isActive', 1)
            ->orderBy('sortOrder')
            ->get()
            ->map(function ($tier) {
                $available = $tier->quantityCap !== null
                    ? max(0, $tier->quantityCap - $tier->quantitySold)
                    : null;

                return [
                    'tierId'      => $tier->tierId,
                    'tierName'    => $tier->tierName,
                    'price'       => (float) $tier->price,
                    'description' => $tier->description,
                    'quantityCap' => $tier->quantityCap,
                    'quantitySold'=> $tier->quantitySold,
                    'available'   => $available,
                    'isSoldOut'   => $tier->quantityCap !== null && $tier->quantitySold >= $tier->quantityCap,
                ];
            });

        return response()->json([
            'success' => true,
            'tiers'   => $tiers,
        ]);
    }

    // ─── Organizer: Create a new tier ───────────────────────────────────────

    /**
     * POST /api/v1/events/{id}/tiers
     * Creates a new ticket tier for an event. Only the event organizer can do this.
     */
    public function store(Request $request, $eventId)
    {
        $user  = $request->user();
        $event = DB::table('events')->where('eventId', $eventId)->first();

        if (!$event) {
            return response()->json(['error' => 'Event not found.'], 404);
        }

        if ($event->userId !== $user->userId) {
            return response()->json(['error' => 'Unauthorized. Only the event organizer can manage tiers.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'tierName'    => 'required|string|max:100',
            'price'       => 'required|numeric|min:0',
            'quantityCap' => 'nullable|integer|min:1',
            'description' => 'nullable|string|max:255',
            'sortOrder'   => 'nullable|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error'   => 'Validation failed',
                'details' => $validator->errors(),
            ], 422);
        }

        // Auto-assign sort order to end of list if not provided
        $maxOrder = EventTicketTier::where('eventId', $eventId)->max('sortOrder') ?? -1;

        $tier = EventTicketTier::create([
            'eventId'     => $eventId,
            'tierName'    => $request->tierName,
            'price'       => $request->price,
            'quantityCap' => $request->quantityCap,
            'description' => $request->description,
            'sortOrder'   => $request->sortOrder ?? ($maxOrder + 1),
            'isActive'    => 1,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Tier created successfully.',
            'tier'    => $tier,
        ], 201);
    }

    // ─── Organizer: Update a tier ────────────────────────────────────────────

    /**
     * PUT /api/v1/events/{id}/tiers/{tierId}
     * Updates an existing tier. Only the event organizer can do this.
     */
    public function update(Request $request, $eventId, $tierId)
    {
        $user  = $request->user();
        $event = DB::table('events')->where('eventId', $eventId)->first();

        if (!$event) {
            return response()->json(['error' => 'Event not found.'], 404);
        }

        if ($event->userId !== $user->userId) {
            return response()->json(['error' => 'Unauthorized. Only the event organizer can manage tiers.'], 403);
        }

        $tier = EventTicketTier::where('tierId', $tierId)
            ->where('eventId', $eventId)
            ->first();

        if (!$tier) {
            return response()->json(['error' => 'Tier not found for this event.'], 404);
        }

        $validator = Validator::make($request->all(), [
            'tierName'    => 'sometimes|required|string|max:100',
            'price'       => 'sometimes|required|numeric|min:0',
            'quantityCap' => 'nullable|integer|min:1',
            'description' => 'nullable|string|max:255',
            'sortOrder'   => 'nullable|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error'   => 'Validation failed',
                'details' => $validator->errors(),
            ], 422);
        }

        $tier->update(array_filter([
            'tierName'    => $request->tierName,
            'price'       => $request->price,
            'quantityCap' => $request->has('quantityCap') ? $request->quantityCap : $tier->quantityCap,
            'description' => $request->has('description') ? $request->description : $tier->description,
            'sortOrder'   => $request->sortOrder,
        ], fn($v) => $v !== null));

        return response()->json([
            'success' => true,
            'message' => 'Tier updated successfully.',
            'tier'    => $tier->fresh(),
        ]);
    }

    // ─── Organizer: Soft-delete a tier ───────────────────────────────────────

    /**
     * DELETE /api/v1/events/{id}/tiers/{tierId}
     * Soft-deletes a tier (sets isActive = 0). Does not delete booking history.
     */
    public function destroy(Request $request, $eventId, $tierId)
    {
        $user  = $request->user();
        $event = DB::table('events')->where('eventId', $eventId)->first();

        if (!$event) {
            return response()->json(['error' => 'Event not found.'], 404);
        }

        if ($event->userId !== $user->userId) {
            return response()->json(['error' => 'Unauthorized. Only the event organizer can manage tiers.'], 403);
        }

        $tier = EventTicketTier::where('tierId', $tierId)
            ->where('eventId', $eventId)
            ->first();

        if (!$tier) {
            return response()->json(['error' => 'Tier not found for this event.'], 404);
        }

        $tier->update(['isActive' => 0]);

        return response()->json([
            'success' => true,
            'message' => 'Tier deactivated successfully.',
        ]);
    }
}
