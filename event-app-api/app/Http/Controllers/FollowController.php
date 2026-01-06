<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FollowController extends Controller
{
    public function followUser(Request $request, $id)
    {
        try {
            $followerId = $request->user()->userId;

            if ($followerId == $id) {
                return response()->json(['error' => 'You cannot follow yourself.'], 400);
            }

            // Check if already following
            $exists = DB::table('follows')
                ->where('follower_id', $followerId)
                ->where('followee_id', $id)
                ->exists();

            if (!$exists) {
                // Insert new follow relationship
                DB::table('follows')->insert([
                    'follower_id' => $followerId,
                    'followee_id' => $id,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            // Return updated follower count
            $followersCount = DB::table('follows')
                ->where('followee_id', $id)
                ->count();

            return response()->json([
                'success' => true,
                'message' => 'Followed successfully.',
                'followersCount' => $followersCount
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Failed to follow user: ' . $e->getMessage()
            ], 500);
        }
    }

    public function unfollowUser(Request $request, $id)
    {
        try {
            $followerId = $request->user()->userId;

            $deleted = DB::table('follows')
                ->where('follower_id', $followerId)
                ->where('followee_id', $id)
                ->delete();

            // Return updated follower count
            $followersCount = DB::table('follows')
                ->where('followee_id', $id)
                ->count();

            return response()->json([
                'success' => true,
                'message' => 'Unfollowed successfully.',
                'followersCount' => $followersCount
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Failed to unfollow user: ' . $e->getMessage()
            ], 500);
        }
    }

    public function getFollowers($id)
    {
        $followers = DB::table('follows')
            ->join('mstuser', 'follows.follower_id', '=', 'mstuser.userId')
            ->where('follows.followee_id', $id)
            ->select('mstuser.userId', 'mstuser.name', 'mstuser.profileImageUrl')
            ->get();

        return response()->json($followers);
    }

    public function getFollowing($id)
    {
        $following = DB::table('follows')
            ->join('mstuser', 'follows.followee_id', '=', 'mstuser.userId')
            ->where('follows.follower_id', $id)
            ->select('mstuser.userId', 'mstuser.name', 'mstuser.profileImageUrl')
            ->get();

        return response()->json($following);
    }
}
