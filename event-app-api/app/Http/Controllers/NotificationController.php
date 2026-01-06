<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotificationController extends Controller
{
    /**
     * Get all notifications for the current user
     * Includes: Event invites, Follow notifications
     */
    public function getAllNotifications(Request $request)
    {
        try {
            $userId = $request->user()->userId;
            $notifications = [];

            // 1. Get Event Invites
            $invites = DB::table('event_invites')
                ->join('events', 'event_invites.eventId', '=', 'events.eventId')
                ->join('mstuser', 'event_invites.inviterId', '=', 'mstuser.userId')
                ->where('event_invites.inviteeId', $userId)
                ->select([
                    'event_invites.inviteId as id',
                    DB::raw("'invite' as type"),
                    'event_invites.status',
                    'event_invites.created_at as createdAt',
                    'events.eventId',
                    'events.eventTitle',
                    'events.startDate',
                    'events.endDate',
                    'events.city',
                    'events.eventImage',
                    'mstuser.userId as actorId',
                    'mstuser.name as actorName',
                    'mstuser.profileImageUrl as actorImage',
                ])
                ->orderBy('event_invites.created_at', 'desc')
                ->get();

            foreach ($invites as $invite) {
                $notifications[] = [
                    'id' => $invite->id,
                    'type' => 'invite',
                    'status' => $invite->status,
                    'createdAt' => $invite->createdAt,
                    'actor' => [
                        'id' => $invite->actorId,
                        'name' => $invite->actorName,
                        'profileImage' => $invite->actorImage,
                    ],
                    'event' => [
                        'id' => $invite->eventId,
                        'title' => $invite->eventTitle,
                        'startDate' => $invite->startDate,
                        'endDate' => $invite->endDate,
                        'city' => $invite->city,
                        'image' => $invite->eventImage,
                    ],
                ];
            }

            // 2. Get Follow Notifications (people who followed you)
            $followers = DB::table('follows')
                ->join('mstuser', 'follows.follower_id', '=', 'mstuser.userId')
                ->where('follows.followee_id', $userId)
                ->select([
                    'follows.follower_id as id',
                    DB::raw("'follow' as type"),
                    'follows.created_at as createdAt',
                    'mstuser.userId as actorId',
                    'mstuser.name as actorName',
                    'mstuser.profileImageUrl as actorImage',
                ])
                ->orderBy('follows.created_at', 'desc')
                ->get();

            foreach ($followers as $follower) {
                $notifications[] = [
                    'id' => $follower->id,
                    'type' => 'follow',
                    'createdAt' => $follower->createdAt,
                    'actor' => [
                        'id' => $follower->actorId,
                        'name' => $follower->actorName,
                        'profileImage' => $follower->actorImage,
                    ],
                ];
            }

            // Sort all notifications by createdAt (newest first)
            usort($notifications, function ($a, $b) {
                return strtotime($b['createdAt']) - strtotime($a['createdAt']);
            });

            return response()->json([
                'success' => true,
                'data' => $notifications,
                'count' => count($notifications),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Failed to fetch notifications: ' . $e->getMessage()
            ], 500);
        }
    }
}
