<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class UserController extends Controller
{
    /**
     * Fetch all users with pagination
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        try {
            // Get all users without pagination
            $users = \App\Models\User::select([
                    'userId',
                    'name',
                    'email',
                    'phoneNumber',
                    'profileImageUrl',
                    'shortBio',
                    'interests',
                    'isActive',
                    'emailVerified',
                    'created_at'
                ])
                ->get();

            // Transform the collection
            $users = $users->map(function ($user) {
                return [
                    'userId' => $user->userId,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phoneNumber' => $user->phoneNumber,
                    'profileImageUrl' => $user->profileImageUrl,
                    'shortBio' => $user->shortBio,
                    'interests' => $user->interests,
                    'isActive' => (bool)$user->isActive,
                    'emailVerified' => (bool)$user->emailVerified,
                    'created_at' => $user->created_at,
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $users,
                'message' => 'Users fetched successfully',
                'count' => $users->count()
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch users',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function showProfile(Request $request)
{
    try {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized - No authenticated user found'
            ], 401);
        }

        // Get counts in a single query for better performance
        $followCounts = DB::table('follows')
            ->selectRaw('COUNT(CASE WHEN followee_id = ? THEN 1 END) as followers_count', [$user->userId])
            ->selectRaw('COUNT(CASE WHEN follower_id = ? THEN 1 END) as following_count', [$user->userId])
            ->first();

        // Prepare the user data
        $userData = [
            'userId' => $user->userId,
            'name' => $user->name,
            'email' => $user->email,
            'phoneNumber' => $user->phoneNumber,
            'profileImageUrl' => $user->profileImageUrl,
            'shortBio' => $user->shortBio,
            'interests' => $user->interests ?? [],
            'created_at' => $user->created_at,
            'followers_count' => $followCounts->followers_count ?? 0,
            'following_count' => $followCounts->following_count ?? 0
        ];

        return response()->json([
            'success' => true,
            'data' => $userData,
            'message' => 'Profile retrieved successfully'
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Failed to fetch profile',
            'error' => $e->getMessage()
        ], 500);
    }
}

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name' => 'nullable|string|max:255',
            'shortBio' => 'nullable|string|max:255',
            'interests' => 'nullable|array',
            'phoneNumber' => 'nullable|string|max:20',
            'profileImage' => 'nullable|image',
        ]);

        if ($request->hasFile('profileImage')) {
            // Delete old image if exists
            if ($user->profileImageUrl) {
                Storage::disk('public')->delete($user->profileImageUrl);
            }

            $image = $request->file('profileImage')->store('profiles', 'public');
            $user->profileImageUrl = "/storage/public/$image";
        }

        if ($request->has('name')) {
            $user->name = $request->input('name');
        }
        if ($request->has('shortBio')) {
            $user->shortBio = $request->input('shortBio');
        }
        if ($request->has('interests')) {
            $user->interests = $request->input('interests');  // Assign array directly
        }
        if ($request->has('phoneNumber')) {
            $user->phoneNumber = $request->input('phoneNumber');
        }
        $user->updated_at = now();  // Update the updated_at timestamp

        $user->save();

        // No need to json_decode, Laravel handles this automatically
        return response()->json([
            'message' => 'Profile updated successfully.',
            'user' => $user,
        ]);
    }

public function viewPublicProfile(Request $request, $id)
{
    try {
        $user = \App\Models\User::findOrFail($id);

        // 🔹 Get logged-in user ID
        $currentUserId = $request->user()->userId;

        // 🔹 Check if current user is following this profile
        $isFollowing = DB::table('follows')
            ->where('follower_id', $currentUserId)
            ->where('followee_id', $user->userId)
            ->exists();

        return response()->json([
            'userId' => $user->userId,
            'name' => $user->name,
            'profileImageUrl' => $user->profileImageUrl,
            'shortBio' => $user->shortBio,
            'interests' => $user->interests ?? '[]',
            'followers_count' => DB::table('follows')->where('followee_id', $user->userId)->count(),
            'following_count' => DB::table('follows')->where('follower_id', $user->userId)->count(),
            'isFollowing' => $isFollowing, // 🔥 added here
        ]);

    } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
        return response()->json([
            'message' => 'No profile found'
        ], 404);
    }
}

}
