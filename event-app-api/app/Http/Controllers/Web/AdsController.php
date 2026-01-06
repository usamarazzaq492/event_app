<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;

class AdsController extends Controller
{
    public function index()
    {
        // Ads section now shows only boosted events (paid/promoted events)
        $ads = DB::table('events')
            ->join('mstuser', 'events.userId', '=', 'mstuser.userId')
            ->select(
                'events.*',
                'mstuser.name as userName',
                'mstuser.email as userEmail'
            )
            ->where('events.isActive', 1)
            ->where('events.isPromoted', 1)
            ->where('events.promotionEndDate', '>', now())
            ->orderBy('events.promotionEndDate', 'asc') // Show events expiring soon first
            ->orderBy('events.startDate', 'asc')
            ->paginate(12);

        // Calculate stats for boosted events
        $stats = [
            'active_boosted_events' => DB::table('events')
                ->where('isActive', 1)
                ->where('isPromoted', 1)
                ->where('promotionEndDate', '>', now())
                ->count(),
            'total_boost_revenue' => DB::table('promotion_transactions')
                ->where('status', 'completed')
                ->sum('amount'),
            'total_boosts' => DB::table('promotion_transactions')
                ->where('status', 'completed')
                ->count(),
        ];

        return view('ads.index', compact('ads', 'stats'));
    }

    public function create()
    {
        return view('ads.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255|min:5',
            'description' => 'required|string|max:3000|min:50',
            'amount' => 'required|numeric|min:1|max:1000000',
            'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ], [
            'title.min' => 'Campaign title must be at least 5 characters long.',
            'title.max' => 'Campaign title cannot exceed 255 characters.',
            'description.min' => 'Campaign description must be at least 50 characters long.',
            'description.max' => 'Campaign description cannot exceed 3000 characters.',
            'amount.min' => 'Fundraising goal must be at least $1.',
            'amount.max' => 'Fundraising goal cannot exceed $1,000,000.',
            'image.required' => 'Campaign image is required.',
            'image.image' => 'File must be a valid image.',
            'image.mimes' => 'Image must be in JPEG, PNG, JPG, or GIF format.',
            'image.max' => 'Image size cannot exceed 2MB.',
        ]);

        try {
            $user = Auth::user();

            // Handle image upload
            $image = $request->file('image');
            $imageName = 'ad_' . $user->userId . '_' . time() . '.' . $image->getClientOriginalExtension();
            $imagePath = $image->storeAs('public/ads', $imageName);
            $imageUrl = '/storage/' . str_replace('public/', '', $imagePath);

            // Create ad
            $adId = DB::table('donation')->insertGetId([
                'userId' => $user->userId,
                'title' => $request->title,
                'imageUrl' => $imageUrl,
                'description' => $request->description,
                'amount' => $request->amount,
                'isActive' => 1,
                'addDate' => now(),
                'updated_at' => now(),
            ]);

            return redirect()->route('ads.index')->with('success', '🎉 Campaign created successfully! Your campaign is now live and ready to receive donations.');

        } catch (\Exception $e) {
            // Log the error
            Log::error('Ad creation failed: ' . $e->getMessage());

            return back()->withErrors(['error' => 'Failed to create campaign. Please try again.'])->withInput();
        }
    }

    public function show($id)
    {
        $ad = DB::table('donation')
            ->join('mstuser', 'donation.userId', '=', 'mstuser.userId')
            ->select('donation.*', 'mstuser.name as userName', 'mstuser.email as userEmail')
            ->where('donation.donationId', $id)
            ->where('donation.isActive', 1)
            ->first();

        if (!$ad) {
            abort(404, 'Ad not found');
        }

        // Get donation statistics
        $totalDonations = DB::table('donation_transactions')
            ->where('donationId', $id)
            ->sum('amount');

        $donationCount = DB::table('donation_transactions')
            ->where('donationId', $id)
            ->count();

        $recentDonations = DB::table('donation_transactions')
            ->join('mstuser', 'donation_transactions.userId', '=', 'mstuser.userId')
            ->select('donation_transactions.*', 'mstuser.name as donorName')
            ->where('donation_transactions.donationId', $id)
            ->orderBy('donation_transactions.created_at', 'desc')
            ->limit(10)
            ->get();

        return view('ads.show', compact('ad', 'totalDonations', 'donationCount', 'recentDonations'));
    }

    public function edit($id)
    {
        $ad = DB::table('donation')
            ->where('donationId', $id)
            ->where('userId', Auth::id())
            ->first();

        if (!$ad) {
            abort(404, 'Ad not found or you do not have permission to edit it');
        }

        return view('ads.edit', compact('ad'));
    }

    public function update(Request $request, $id)
    {
        $ad = DB::table('donation')
            ->where('donationId', $id)
            ->where('userId', Auth::id())
            ->first();

        if (!$ad) {
            abort(404, 'Campaign not found or you do not have permission to edit it');
        }

        $request->validate([
            'title' => 'required|string|max:255|min:5',
            'description' => 'required|string|max:3000|min:50',
            'amount' => 'required|numeric|min:1|max:1000000',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ], [
            'title.min' => 'Campaign title must be at least 5 characters long.',
            'title.max' => 'Campaign title cannot exceed 255 characters.',
            'description.min' => 'Campaign description must be at least 50 characters long.',
            'description.max' => 'Campaign description cannot exceed 3000 characters.',
            'amount.min' => 'Fundraising goal must be at least $1.',
            'amount.max' => 'Fundraising goal cannot exceed $1,000,000.',
            'image.image' => 'File must be a valid image.',
            'image.mimes' => 'Image must be in JPEG, PNG, JPG, or GIF format.',
            'image.max' => 'Image size cannot exceed 2MB.',
        ]);

        try {
            $updateData = [
                'title' => $request->title,
                'description' => $request->description,
                'amount' => $request->amount,
                'updated_at' => now(),
            ];

            // Handle image upload if provided
            if ($request->hasFile('image')) {
                // Delete old image
                if ($ad->imageUrl) {
                    $oldImagePath = str_replace('/storage/', 'public/', $ad->imageUrl);
                    Storage::delete($oldImagePath);
                }

                $image = $request->file('image');
                $imageName = 'ad_' . Auth::id() . '_' . time() . '.' . $image->getClientOriginalExtension();
                $imagePath = $image->storeAs('public/ads', $imageName);
                $updateData['imageUrl'] = '/storage/' . str_replace('public/', '', $imagePath);
            }

            DB::table('donation')
                ->where('donationId', $id)
                ->update($updateData);

            return redirect()->route('ads.show', $id)->with('success', '🎉 Campaign updated successfully!');

        } catch (\Exception $e) {
            // Log the error
            Log::error('Ad update failed: ' . $e->getMessage());

            return back()->withErrors(['error' => 'Failed to update campaign. Please try again.'])->withInput();
        }
    }

    public function destroy($id)
    {
        $ad = DB::table('donation')
            ->where('donationId', $id)
            ->where('userId', Auth::id())
            ->first();

        if (!$ad) {
            abort(404, 'Ad not found or you do not have permission to delete it');
        }

        // Delete image
        if ($ad->imageUrl) {
            $imagePath = str_replace('/storage/', 'public/', $ad->imageUrl);
            Storage::delete($imagePath);
        }

        // Soft delete by setting isActive to 0
        DB::table('donation')
            ->where('donationId', $id)
            ->update(['isActive' => 0, 'updated_at' => now()]);

        return redirect()->route('ads.index')->with('success', '🗑️ Ad deleted successfully!');
    }


    public function donate(Request $request, $id)
    {
        $ad = DB::table('donation')
            ->where('donationId', $id)
            ->where('isActive', 1)
            ->first();

        if (!$ad) {
            abort(404, 'Campaign not found or is no longer active');
        }

        $request->validate([
            'amount' => 'required|numeric|min:1|max:10000',
        ], [
            'amount.min' => 'Donation amount must be at least $1.',
            'amount.max' => 'Donation amount cannot exceed $10,000.',
        ]);

        try {
            // Calculate processing fee (2.9% + $0.30) - matching API structure
            $processingFee = ($request->amount * 0.029) + 0.30;
            $totalAmount = $request->amount + $processingFee;

            // Create donation transaction
            $transactionId = DB::table('donation_transactions')->insertGetId([
                'donationId' => $id,
                'userId' => Auth::id(),
                'amount' => $request->amount,
                'processingFee' => $processingFee,
                'totalAmount' => $totalAmount,
                'squarePaymentId' => 'pending_' . Str::random(20),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Redirect to payment page
            return redirect()->route('square.donate', $transactionId);

        } catch (\Exception $e) {
            // Log the error
            Log::error('Donation creation failed: ' . $e->getMessage());

            return back()->withErrors(['error' => 'Failed to process donation. Please try again.'])->withInput();
        }
    }
}
