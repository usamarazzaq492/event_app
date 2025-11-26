<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\EventInvite;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class InviteController extends Controller
{
    // Invite multiple followers to an event
    public function inviteUsers(Request $request, $eventId)
{
    $inviter = $request->user();
    $inviterId = $inviter->userId;

    $request->validate([
        'userIds' => 'required|array',
        'userIds.*' => 'integer',
    ]);

    // Check event
    $event = DB::table('events')->where('eventId', $eventId)->first();
    if (!$event) {
        return response()->json(['message' => 'Event not found.'], 404);
    }

    if ($event->userId != $inviterId) {
        return response()->json(['message' => 'Only the event creator can invite others.'], 403);
    }

    $results = [];

    foreach ($request->userIds as $inviteeId) {
        if ($inviteeId == $inviterId) {
            $results[] = [
                'userId' => $inviteeId,
                'status' => 'skipped',
                'message' => 'You cannot invite yourself.',
            ];
            continue;
        }

        // Check if user exists
        $invitee = DB::table('mstuser')->where('userId', $inviteeId)->first();
        if (!$invitee) {
            $results[] = [
                'userId' => $inviteeId,
                'status' => 'invalid',
                'message' => 'User does not exist.',
            ];
            continue;
        }

        // Already invited?
        $alreadyInvited = DB::table('event_invites')
            ->where('eventId', $eventId)
            ->where('inviteeId', $inviteeId)
            ->exists();

        if ($alreadyInvited) {
            $results[] = [
                'userId' => $inviteeId,
                'status' => 'duplicate',
                'message' => 'User has already been invited.',
            ];
            continue;
        }

        // Insert invite
        DB::table('event_invites')->insert([
            'eventId' => $eventId,
            'inviterId' => $inviterId,
            'inviteeId' => $inviteeId,
            'status' => 'pending',
            'created_at' => now(),
        ]);

        // Prepare email
        $emailSubject = "You're Invited to an Event!";
        $emailMessage = "
            Hi {$invitee->name},<br><br>
            {$inviter->name} has invited you to join the event <strong>{$event->eventTitle}</strong> in {$event->city}.<br>
            <br>
            📅 <strong>Date:</strong> {$event->startDate} to {$event->endDate}<br>
            <br>
            Please log in to your account to accept or decline this invitation.
            <br><br>
            — EventGo Team
        ";

        // Send the email
        sendMail($invitee->email, $emailSubject, $emailMessage);

        $results[] = [
            'userId' => $inviteeId,
            'status' => 'invited',
            'message' => 'Invitation sent.',
        ];
    }

    return response()->json([
        'results' => $results
    ]);
}

public function getReceivedInvites(Request $request)
{
    $userId = $request->user()->userId;

    $invites = DB::table('event_invites')
        ->join('events', 'event_invites.eventId', '=', 'events.eventId')
        ->join('mstuser', 'event_invites.inviterId', '=', 'mstuser.userId')
        ->where('event_invites.inviteeId', $userId)
        ->select([
            'event_invites.inviteId',
            'event_invites.status',
            'event_invites.created_at as invitedAt',
            'events.eventId',
            'events.eventTitle',
            'events.startDate',
            'events.endDate',
            'events.city',
            'events.eventImage',
            'mstuser.name as inviterName',
        ])
        ->orderBy('event_invites.created_at', 'desc')
        ->get();

    return response()->json([
        'message' => 'Invites fetched successfully.',
        'data' => $invites,
    ]);
}

    public function respond(Request $request, $inviteId)
{
    $request->validate([
        'response' => 'required|in:accepted,declined',
    ]);

    $userId = $request->user()->userId;

    // Find invite for this user
    $invite = DB::table('event_invites')
        ->where('inviteId', $inviteId)
        ->where('inviteeId', $userId)
        ->first();

    if (!$invite) {
        return response()->json(['message' => 'Invite not found or unauthorized'], 404);
    }

    if ($invite->status !== 'pending') {
        return response()->json(['message' => 'You have already responded to this invite.'], 409);
    }

    // Update invite status
    DB::table('event_invites')
        ->where('inviteId', $inviteId)
        ->update([
            'status' => $request->response
        ]);

    // Auto-book event on acceptance if not already booked
    if ($request->response === 'accepted') {
        $alreadyBooked = DB::table('booking')
            ->where('eventId', $invite->eventId)
            ->where('userId', $userId)
            ->exists();

        if (!$alreadyBooked) {
            DB::table('booking')->insert([
                'eventId' => $invite->eventId,
                'userId' => $userId,
                'bookingDate' => now(),
            ]);
        }
    }

    return response()->json(['message' => "Invite {$request->response} successfully."]);
}

}
