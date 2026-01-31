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
    /**
     * Public user search - for guests and logged-in users.
     * Search by name (no auth required).
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function searchUsers(Request $request)
    {
        try {
            $query = $request->get('q', '');
            $query = trim($query);

            if (strlen($query) < 2) {
                return response()->json([
                    'success' => true,
                    'data' => [],
                    'message' => 'Query too short',
                    'count' => 0
                ]);
            }

            $users = \App\Models\User::select([
                    'userId',
                    'name',
                    'email',
                    'profileImageUrl',
                ])
                ->where('isActive', 1)
                ->where(function ($q) use ($query) {
                    $q->where('name', 'like', '%' . $query . '%')
                      ->orWhere('email', 'like', '%' . $query . '%');
                })
                ->limit(10)
                ->get()
                ->map(function ($user) {
                    return [
                        'userId' => $user->userId,
                        'name' => $user->name,
                        'email' => $user->email,
                        'profileImageUrl' => $user->profileImageUrl,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $users,
                'message' => 'Users found',
                'count' => $users->count()
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Search failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

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

        // 🔹 Get logged-in user ID (null for guests)
        $currentUser = $request->user();
        $currentUserId = $currentUser?->userId;

        // 🔹 Check if current user is following this profile (guests are never following)
        $isFollowing = false;
        if ($currentUserId) {
            $isFollowing = DB::table('follows')
                ->where('follower_id', $currentUserId)
                ->where('followee_id', $user->userId)
                ->exists();
        }

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

    /**
     * Delete user account and all associated data
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteAccount(Request $request)
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized - No authenticated user found'
                ], 401);
            }

            $userId = $user->userId;

            // Use database transaction to ensure data consistency
            DB::beginTransaction();

            try {
                // 1. Delete user's profile image
                if ($user->profileImageUrl) {
                    Storage::disk('public')->delete($user->profileImageUrl);
                }

                // 2. Delete user's events (and their associated data)
                $userEvents = DB::table('events')->where('userId', $userId)->get();
                foreach ($userEvents as $event) {
                    // Delete event images if they exist
                    if ($event->eventImage) {
                        Storage::disk('public')->delete($event->eventImage);
                    }
                }
                DB::table('events')->where('userId', $userId)->delete();

                // 3. Delete user's bookings
                DB::table('booking')->where('userId', $userId)->delete();

                // 4. Delete user's follows (both as follower and followee)
                DB::table('follows')->where('follower_id', $userId)->delete();
                DB::table('follows')->where('followee_id', $userId)->delete();

                // 5. Delete user's event invites (both sent and received)
                // Notifications are generated from follows and event_invites, so deleting those will handle notifications
                DB::table('event_invites')->where('inviterId', $userId)->delete();
                DB::table('event_invites')->where('inviteeId', $userId)->delete();

                // 6. Delete user's ads/donations
                $userAds = DB::table('donation')->where('userId', $userId)->get();
                foreach ($userAds as $ad) {
                    // Delete ad images if they exist
                    if ($ad->imageUrl) {
                        Storage::disk('public')->delete($ad->imageUrl);
                    }
                }
                DB::table('donation')->where('userId', $userId)->delete();

                // Delete donation transactions
                DB::table('donation_transactions')->where('userId', $userId)->delete();

                // 7. Delete user's payment QR codes
                DB::table('payment_qr_codes')->where('userId', $userId)->delete();

                // 8. Delete user's promotion transactions
                // Note: Promotion data is also stored in events table (isPromoted, promotionStartDate, etc.)
                // but those will be deleted when events are deleted above
                DB::table('promotion_transactions')->where('userId', $userId)->delete();

                // 9. Delete user's Square account connections (if any)
                $organizerIds = DB::table('organizers')->where('userId', $userId)->pluck('organizerId');
                if ($organizerIds->isNotEmpty()) {
                    DB::table('organizer_square_accounts')
                        ->whereIn('organizerId', $organizerIds)
                        ->delete();
                    DB::table('organizers')->where('userId', $userId)->delete();
                }

                // 10. Delete user's Sanctum tokens
                $user->tokens()->delete();

                // 11. Finally, delete the user
                $user->delete();

                DB::commit();

                return response()->json([
                    'success' => true,
                    'message' => 'Account deleted successfully. All your data has been permanently removed.'
                ], 200);

            } catch (\Exception $e) {
                DB::rollBack();
                throw $e;
            }

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete account',
                'error' => $e->getMessage()
            ], 500);
        }
    }

}

