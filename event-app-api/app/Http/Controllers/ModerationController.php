<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ModerationController extends Controller
{
    /**
     * Report an event (Guideline 1.2)
     */
    public function reportEvent(Request $request, $eventId)
    {
        $request->validate([
            'reason' => 'nullable|string|max:500',
        ]);

        $userId = $request->user()->userId;

        $exists = DB::table('events')->where('eventId', $eventId)->exists();
        if (!$exists) {
            return response()->json(['message' => 'Event not found.'], 404);
        }

        $alreadyReported = DB::table('reports')
            ->where('reporter_id', $userId)
            ->where('reportable_type', 'event')
            ->where('reportable_id', $eventId)
            ->exists();

        if ($alreadyReported) {
            return response()->json(['message' => 'You have already reported this event.'], 400);
        }

        DB::table('reports')->insert([
            'reporter_id' => $userId,
            'reportable_type' => 'event',
            'reportable_id' => $eventId,
            'reason' => $request->input('reason'),
            'status' => 'pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Report submitted. We will review it within 24 hours.',
        ], 201);
    }

    /**
     * Report a user (Guideline 1.2)
     */
    public function reportUser(Request $request, $userId)
    {
        $request->validate([
            'reason' => 'nullable|string|max:500',
        ]);

        $reporterId = $request->user()->userId;

        if ($reporterId == $userId) {
            return response()->json(['message' => 'You cannot report yourself.'], 400);
        }

        $exists = DB::table('mstuser')->where('userId', $userId)->exists();
        if (!$exists) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        $alreadyReported = DB::table('reports')
            ->where('reporter_id', $reporterId)
            ->where('reportable_type', 'user')
            ->where('reportable_id', $userId)
            ->exists();

        if ($alreadyReported) {
            return response()->json(['message' => 'You have already reported this user.'], 400);
        }

        DB::table('reports')->insert([
            'reporter_id' => $reporterId,
            'reportable_type' => 'user',
            'reportable_id' => $userId,
            'reason' => $request->input('reason'),
            'status' => 'pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Report submitted. We will review it within 24 hours.',
        ], 201);
    }

    /**
     * Block a user (Guideline 1.2 - removes from feed instantly)
     */
    public function blockUser(Request $request, $userId)
    {
        $blockerId = $request->user()->userId;

        if ($blockerId == $userId) {
            return response()->json(['message' => 'You cannot block yourself.'], 400);
        }

        $exists = DB::table('mstuser')->where('userId', $userId)->exists();
        if (!$exists) {
            return response()->json(['message' => 'User not found.'], 404);
        }

        DB::table('blocked_users')->insertOrIgnore([
            'blocker_id' => $blockerId,
            'blocked_id' => $userId,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Unfollow if following
        DB::table('follows')
            ->where('follower_id', $blockerId)
            ->where('followee_id', $userId)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'User blocked. They will no longer appear in your feed.',
        ], 200);
    }

    /**
     * Unblock a user
     */
    public function unblockUser(Request $request, $userId)
    {
        $blockerId = $request->user()->userId;

        DB::table('blocked_users')
            ->where('blocker_id', $blockerId)
            ->where('blocked_id', $userId)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'User unblocked.',
        ], 200);
    }

    /**
     * Get list of blocked user IDs (for frontend filtering)
     */
    public function getBlockedUserIds(Request $request)
    {
        $blockerId = $request->user()->userId;

        $ids = DB::table('blocked_users')
            ->where('blocker_id', $blockerId)
            ->pluck('blocked_id');

        return response()->json(['blocked_ids' => $ids]);
    }
}
