<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    /**
     * Display the home page
     */
    public function index()
    {
        // Get 4 upcoming events for home page
        $upcomingEvents = \App\Models\Event::query()
            ->where('startDate', '>=', now())
            ->orderBy('startDate', 'asc')
            ->limit(4)
            ->get();

        return view('index', compact('upcomingEvents'));
    }

    /**
     * Display the about page
     */
    public function about()
    {
        return view('about');
    }

    /**
     * Display the contact page
     */
    public function contact()
    {
        return view('contact');
    }

    /**
     * Handle contact form submission
     */
    public function contactSubmit(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'subject' => 'nullable|string|max:255',
            'message' => 'required|string',
        ]);

        // TODO: Send email or store in database

        return back()->with('success', 'Thank you for contacting us! We will get back to you soon.');
    }


    /**
     * Display the FAQ page
     */
    public function faq()
    {
        return view('faq');
    }

    /**
     * Display the terms page
     */
    public function terms()
    {
        return view('terms');
    }

    /**
     * Display the privacy page
     */
    public function privacy()
    {
        return view('privacy');
    }
}

