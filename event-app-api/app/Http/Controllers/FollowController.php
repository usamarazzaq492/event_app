<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FollowController extends Controller
{
    public function followUser(Request $request, $id)
    {
        $followerId = $request->user()->userId;

        if ($followerId == $id) {
            return response()->json(['error' => 'You cannot follow yourself.'], 400);
        }

        DB::table('follows')->updateOrInsert(
            ['follower_id' => $followerId, 'followee_id' => $id],
            ['created_at' => now()]
        );

        return response()->json(['message' => 'Followed successfully.']);
    }

    public function unfollowUser(Request $request, $id)
    {
        $followerId = $request->user()->userId;

        DB::table('follows')
            ->where('follower_id', $followerId)
            ->where('followee_id', $id)
            ->delete();

        return response()->json(['message' => 'Unfollowed successfully.']);
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
