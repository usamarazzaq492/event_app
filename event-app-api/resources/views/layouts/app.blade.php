<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Event Booking')</title>

    <!-- Favicon -->
    <link rel="icon" type="image/png" href="{{ asset('favicon.ico') }}">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- AOS for scroll animations -->
    <link href="https://unpkg.com/aos@2.3.4/dist/aos.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <!-- Google Font -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&display=swap" rel="stylesheet" />

    <!-- Styles -->
    <link href="{{ asset('assets/vendors/bootstrap/bootstrap.min.css') }}" rel="stylesheet" />
    <link href="{{ asset('assets/vendors/bootstrap-icons/font/bootstrap-icons.min.css') }}" rel="stylesheet" />
    <link href="{{ asset('assets/vendors/glightbox/glightbox.min.css') }}" rel="stylesheet" />
    <link href="{{ asset('assets/vendors/swiper/swiper-bundle.min.css') }}" rel="stylesheet" />
    <link href="{{ asset('assets/vendors/aos/aos.css') }}" rel="stylesheet" />

    <!-- EventLab Style -->
    <style>
        /* Top Bar */
        .top-bar {
            background: #2c2c2c;
            color: white;
            padding: 8px 0;
            font-size: 14px;
        }

        .top-bar a {
            color: white;
            text-decoration: none;
            margin: 0 8px;
        }

        .top-bar .social-icons a {
            margin: 0 5px;
            color: #ccc;
        }

        /* Modern Header */
        .modern-header {
            background: #ffffff;
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.08);
            padding: 0;
            position: sticky;
            top: 0;
            z-index: 1000;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            background: rgba(255, 255, 255, 0.95);
        }

        .modern-header.scrolled {
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.12);
            padding: 0;
        }

        .modern-header .navbar {
            padding: 1rem 0;
        }

        /* Logo Styles */
        .navbar-brand {
            padding: 0;
            margin-right: 2rem;
            text-decoration: none;
        }

        .logo-wrapper {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .logo-img {
            height: 45px;
            width: auto;
            transition: transform 0.3s ease;
        }

        .navbar-brand:hover .logo-img {
            transform: scale(1.05) rotate(5deg);
        }

        .brand-text {
            font-size: 1.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, #584CF4 0%, #7c6ff5 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            letter-spacing: -0.5px;
        }

        /* Navigation Links */
        .navbar-nav {
            gap: 0.5rem;
        }

        .nav-link {
            color: #2c2c2c;
            font-weight: 500;
            font-size: 0.95rem;
            padding: 0.5rem 1rem !important;
            border-radius: 8px;
            transition: all 0.3s ease;
            position: relative;
            display: flex;
            align-items: center;
        }

        .nav-link i {
            font-size: 0.85rem;
            opacity: 0.7;
        }

        .nav-link:hover {
            color: #584CF4;
            background: rgba(88, 76, 244, 0.08);
            transform: translateY(-1px);
        }

        .nav-link:hover i {
            opacity: 1;
        }

        .nav-link.active {
            color: #584CF4;
            background: rgba(88, 76, 244, 0.12);
            font-weight: 600;
        }

        .nav-link.active::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 30px;
            height: 3px;
            background: linear-gradient(90deg, #584CF4, #7c6ff5);
            border-radius: 2px;
        }

        /* Navbar Actions */
        .navbar-actions {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-left: auto;
        }

        /* Buttons */
        .btn-create-event {
            background: linear-gradient(135deg, #ff9500 0%, #ff7a00 100%);
            color: white;
            border: none;
            padding: 0.65rem 1.5rem;
            border-radius: 12px;
            font-weight: 600;
            font-size: 0.9rem;
            text-decoration: none;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            box-shadow: 0 4px 15px rgba(255, 149, 0, 0.3);
        }

        .btn-create-event:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 149, 0, 0.4);
            color: white;
        }

        .btn-create-event i {
            font-size: 1rem;
        }

        .btn-login {
            background: transparent;
            color: #584CF4;
            border: 2px solid #584CF4;
            padding: 0.65rem 1.5rem;
            border-radius: 12px;
            font-weight: 600;
            font-size: 0.9rem;
            text-decoration: none;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
        }

        .btn-login:hover {
            background: #584CF4;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(88, 76, 244, 0.3);
        }

        /* User Menu */
        .user-menu {
            position: relative;
        }

        .user-profile-link {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            text-decoration: none;
            color: #2c2c2c;
            padding: 0.5rem 1rem;
            border-radius: 12px;
            transition: all 0.3s ease;
        }

        .user-profile-link:hover {
            background: rgba(88, 76, 244, 0.08);
            color: #584CF4;
        }

        .user-avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            overflow: hidden;
            border: 2.5px solid #584CF4;
            transition: all 0.3s ease;
            flex-shrink: 0;
        }

        .user-profile-link:hover .user-avatar {
            border-color: #7c6ff5;
            box-shadow: 0 4px 15px rgba(88, 76, 244, 0.3);
            transform: scale(1.05);
        }

        .profile-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .profile-image-placeholder {
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, #584CF4 0%, #7c6ff5 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.1rem;
        }

        .user-name {
            font-weight: 600;
            font-size: 0.9rem;
            max-width: 120px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        /* Dropdown Menu */
        .dropdown-menu {
            border: none;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
            border-radius: 12px;
            padding: 0.5rem;
            margin-top: 0.5rem;
            min-width: 220px;
        }

        .dropdown-item {
            padding: 0.75rem 1rem;
            border-radius: 8px;
            transition: all 0.2s ease;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
        }

        .dropdown-item:hover {
            background: rgba(88, 76, 244, 0.1);
            color: #584CF4;
        }

        .dropdown-item i {
            width: 20px;
            text-align: center;
        }

        /* Mobile Toggle */
        .navbar-toggler {
            border: none;
            padding: 0.5rem;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .navbar-toggler:focus {
            box-shadow: 0 0 0 0.2rem rgba(88, 76, 244, 0.25);
        }

        .navbar-toggler-icon {
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3e%3cpath stroke='rgba%2844, 44, 44, 0.85%29' stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' d='M4 7h22M4 15h22M4 23h22'/%3e%3c/svg%3e");
        }

        /* Responsive */
        @media (max-width: 991px) {
            .navbar-nav {
                margin: 1rem 0;
                gap: 0.25rem;
            }

            .nav-link {
                padding: 0.75rem 1rem !important;
            }

            .navbar-actions {
                flex-direction: column;
                width: 100%;
                gap: 0.75rem;
                margin-top: 1rem;
                padding-top: 1rem;
                border-top: 1px solid rgba(0, 0, 0, 0.1);
            }

            .btn-create-event,
            .btn-login {
                width: 100%;
                justify-content: center;
            }

            .user-profile-link {
                width: 100%;
                justify-content: flex-start;
            }

            .user-name {
                max-width: none;
            }
        }

        @media (max-width: 576px) {
            .logo-img {
                height: 38px;
            }

            .brand-text {
                font-size: 1.25rem;
            }

            .btn-create-event,
            .btn-login {
                padding: 0.6rem 1.25rem;
                font-size: 0.85rem;
            }
        }


        /* Hero Section */
        .hero-section {
            background: linear-gradient(135deg, #f0f0ff 0%, #e8e5ff 50%, #ffffff 100%);
            padding: 100px 0;
            position: relative;
            overflow: hidden;
        }

        .hero-title {
            font-size: 3.5rem;
            font-weight: 800;
            color: #2c2c2c;
            line-height: 1.2;
        }

        .hero-highlight {
            color: #584CF4;
        }

        /* Carousel styling */
        #heroCarousel .carousel-caption {
            background: rgba(0,0,0,0.5);
            padding: 15px;
            border-radius: 10px;
            bottom: 20px;
            left: 20px;
            right: 20px;
        }

        #heroCarousel .carousel-caption h5 {
            font-weight: 700;
            margin-bottom: 5px;
        }

        #heroCarousel .carousel-control-prev-icon,
        #heroCarousel .carousel-control-next-icon {
            background-color: rgba(88, 76, 244, 0.8);
            border-radius: 50%;
            width: 40px;
            height: 40px;
            padding: 8px;
        }

        .hero-buttons .btn {
            padding: 15px 30px;
            margin: 10px;
            border-radius: 30px;
            font-weight: 600;
        }

        .btn-explore {
            background: #584CF4;
            border: none;
            color: white;
        }

        .btn-explore:hover {
            background: #4a3dd6;
            color: white;
        }

        /* Search Filter */
        .search-filter {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            padding: 30px;
            margin-top: -50px;
            position: relative;
            z-index: 10;
        }

        .search-input {
            border: 2px solid #f1f2f6;
            border-radius: 10px;
            padding: 15px;
            width: 100%;
            transition: border-color 0.3s;
        }

        .search-input:focus {
            border-color: #584CF4;
            outline: none;
        }

        .search-btn {
            background: #584CF4;
            border: none;
            color: white;
            padding: 15px 30px;
            border-radius: 10px;
            font-weight: 600;
            transition: background 0.3s;
        }

        .search-btn:hover {
            background: #4a3dd6;
        }

        /* Section Titles */
        .section-title {
            font-size: 2.5rem;
            font-weight: 800;
            color: #2c2c2c;
            text-align: center;
            margin-bottom: 50px;
            position: relative;
        }

        .section-title::before {
            content: "🎯";
            display: block;
            font-size: 2rem;
            margin-bottom: 15px;
        }

        /* Event Cards */
        .event-card-modern {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            transition: all 0.3s;
            margin-bottom: 30px;
            height: 100%;
            display: flex;
            flex-direction: column;
        }

        .event-card-modern:hover {
            transform: translateY(-5px);
        }

        .event-card-modern .card-img {
            height: 220px;
            object-fit: cover;
            border-radius: 15px 15px 0 0;
        }

        .event-tag {
            position: absolute;
            top: 15px;
            left: 15px;
            background: #584CF4;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .event-attendees {
            position: absolute;
            top: 15px;
            right: 15px;
            background: rgba(255,255,255,0.9);
            color: #ff9500;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 600;
        }

        .event-card-modern .card-body {
            padding: 20px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .event-card-modern .card-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: #2c2c2c;
            margin-bottom: 10px;
        }

        .event-meta {
            color: #636e72;
            font-size: 14px;
            margin-bottom: 15px;
            flex: 1;
        }

        .buy-now-btn {
            background: transparent;
            border: 2px solid #584CF4;
            color: #584CF4;
            padding: 8px 20px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s;
            align-self: flex-start;
            margin-top: auto;
        }

        .buy-now-btn:hover {
            background: #584CF4;
            color: white;
        }

        /* Statistics Section */
        .stats-section {
            background: linear-gradient(135deg, #2c2c2c, #3d3d3d);
            color: white;
            padding: 80px 0;
            position: relative;
        }

        .stats-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="20" cy="20" r="2" fill="rgba(255,255,255,0.1)"/><circle cx="80" cy="40" r="1" fill="rgba(255,255,255,0.1)"/><circle cx="40" cy="80" r="1.5" fill="rgba(255,255,255,0.1)"/></svg>');
        }

        .stat-item {
            text-align: center;
            position: relative;
            z-index: 2;
        }

        .stat-number {
            font-size: 3rem;
            font-weight: 800;
            color: #ff4757;
            display: block;
        }

        .stat-label {
            font-size: 1rem;
            color: #ddd;
            margin-top: 10px;
        }

        /* Filter Tabs */
        .filter-tabs {
            text-align: center;
            margin-bottom: 40px;
        }

        .filter-tab {
            background: transparent;
            border: none;
            color: #636e72;
            padding: 10px 20px;
            margin: 0 5px;
            border-radius: 20px;
            transition: all 0.3s;
        }

        .filter-tab.active {
            background: #584CF4;
            color: white;
        }

        .filter-tab:hover {
            color: #584CF4;
        }

        .filter-tab.active:hover {
            color: white;
        }
    </style>

    <!-- Theme Style -->
    <link href="{{ asset('assets/css/style.css') }}" rel="stylesheet" />

    <!-- Apply theme -->
    <script>
    (function() {
        const storedTheme = localStorage.getItem("theme") || "light";
        document.documentElement.setAttribute("data-bs-theme", storedTheme);
    })();
    </script>

    <style>
    :root{
      --primary:#4da6ff;
      --primary-dark:#247fd9;
      --bg:#ffffff;
      --muted:#6b7280;
      --card-shadow: 0 10px 20px rgba(13, 42, 86, 0.06);
    }

    .hero {
      background: linear-gradient(135deg, #4f6ef7 0%, #6b5cff 50%, #4da6ff 100%);
      color: white;
      padding: 4.5rem 0;
      border-bottom-left-radius: 16px;
      border-bottom-right-radius: 16px;
    }
    .hero h1 { font-weight:800; letter-spacing: -0.02em; }
    .hero .lead { opacity:0.95; }

    .feature-card{
      border-radius: 12px;
      box-shadow: var(--card-shadow);
      transition: transform .22s cubic-bezier(.2,.9,.3,1), box-shadow .22s;
      background: var(--bg);
      padding: 1.25rem;
      min-height: 180px;
    }
    .feature-card:hover{
      transform: translateY(-8px);
      box-shadow: 0 18px 40px rgba(13,42,86,0.12);
    }
    .feature-icon{
      width:56px; height:56px; display:flex; align-items:center; justify-content:center;
      border-radius:12px; color:white; margin-bottom:.75rem; font-size:1.2rem;
    }

    .category-pill{
      background: rgba(77,166,255,0.08);
      color: var(--primary-dark);
      border-radius: 999px;
      padding: .5rem .9rem;
      font-weight:600; display:inline-flex; gap:.5rem; align-items:center;
      border: 1px solid rgba(77,166,255,0.12);
    }

    .detail-hero {
      background: linear-gradient(180deg, rgba(77,166,255,0.08), rgba(255,255,255,0));
      padding: 3rem 1rem;
      border-radius: 12px;
    }

    @media (max-width: 767px){
      .hero { padding: 3rem 0; }
      .feature-card { min-height: auto; }
    }

    .btn-ghost {
      background: rgba(255,255,255,0.12);
      border: 1px solid rgba(255,255,255,0.18);
      color: white;
    }
    </style>

    @stack('styles')
</head>

<body>
    <div class="site-wrap">
        @include('layouts.partials.header')

        <main>
            @yield('content')
        </main>

        <style>
            /* Main content background */
            main {
                background-color: #f8f9ff;
                min-height: 50vh;
            }

            /* Footer white background with border */
            .footer {
                background-color: #ffffff !important;
                border-top: 1px solid #e9ecef;
                box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.03);
            }

            /* Enhanced Animations and Hover Effects */
            .event-card-modern {
                transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            }

            .event-card-modern:hover {
                transform: translateY(-10px);
                box-shadow: 0 20px 40px rgba(88, 76, 244, 0.2) !important;
            }

            .btn {
                position: relative;
                overflow: hidden;
                transition: all 0.3s ease;
            }

            .btn::before {
                content: '';
                position: absolute;
                top: 50%;
                left: 50%;
                width: 0;
                height: 0;
                border-radius: 50%;
                background: rgba(255, 255, 255, 0.3);
                transform: translate(-50%, -50%);
                transition: width 0.6s, height 0.6s;
            }

            .btn:hover::before {
                width: 300px;
                height: 300px;
            }

            .hero-title {
                animation: fadeInUp 0.8s ease-out;
            }

            .hero-buttons a {
                animation: fadeInUp 1s ease-out;
                animation-fill-mode: both;
            }

            .hero-buttons a:nth-child(1) {
                animation-delay: 0.2s;
            }

            .hero-buttons a:nth-child(2) {
                animation-delay: 0.4s;
            }

            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(30px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            /* Card image hover effect */
            .event-card-modern .card-img {
                transition: transform 0.5s ease;
            }

            .event-card-modern:hover .card-img {
                transform: scale(1.1);
            }

            /* Button pulse effect */
            @keyframes pulse {
                0% {
                    box-shadow: 0 0 0 0 rgba(88, 76, 244, 0.7);
                }
                70% {
                    box-shadow: 0 0 0 10px rgba(88, 76, 244, 0);
                }
                100% {
                    box-shadow: 0 0 0 0 rgba(88, 76, 244, 0);
                }
            }

            .btn-explore:hover {
                animation: pulse 1.5s infinite;
            }

            /* Search filter animation */
            .search-filter {
                animation: slideInUp 0.8s ease-out;
            }

            @keyframes slideInUp {
                from {
                    opacity: 0;
                    transform: translateY(50px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            /* Icon hover effects */
            .bi {
                transition: all 0.3s ease;
            }

            a:hover .bi {
                transform: scale(1.2);
            }

            /* Navbar smooth transitions */
            .navbar {
                transition: all 0.3s ease;
            }

            .navbar-nav .nav-link {
                position: relative;
                transition: color 0.3s ease;
            }

            .navbar-nav .nav-link::after {
                content: '';
                position: absolute;
                bottom: 0;
                left: 50%;
                width: 0;
                height: 2px;
                background: #584CF4;
                transition: all 0.3s ease;
                transform: translateX(-50%);
            }

            .navbar-nav .nav-link:hover::after {
                width: 80%;
            }
        </style>

        @include('layouts.partials.footer')
    </div>

    <!-- Back to Top -->
    <button id="back-to-top"><i class="bi bi-arrow-up-short"></i></button>

    <!-- JavaScripts -->
    <script src="{{ asset('assets/vendors/bootstrap/bootstrap.bundle.min.js') }}"></script>
    <script src="{{ asset('assets/vendors/gsap/gsap.min.js') }}"></script>
    <script src="{{ asset('assets/vendors/imagesloaded/imagesloaded.pkgd.min.js') }}"></script>
    <script src="{{ asset('assets/vendors/isotope/isotope.pkgd.min.js') }}"></script>
    <script src="{{ asset('assets/vendors/glightbox/glightbox.min.js') }}"></script>
    <script src="{{ asset('assets/vendors/swiper/swiper-bundle.min.js') }}"></script>
    <script src="{{ asset('assets/vendors/aos/aos.js') }}"></script>
    <script src="{{ asset('assets/vendors/purecounter/purecounter.js') }}"></script>
    <script src="{{ asset('assets/js/custom.js') }}"></script>

    <!-- Initialize AOS Animations -->
    <script>
        AOS.init({
            duration: 800,
            easing: 'ease-in-out',
            once: true,
            mirror: false,
            offset: 100
        });

        // Header scroll effect
        window.addEventListener('scroll', function() {
            const header = document.getElementById('mainHeader');
            if (header) {
                if (window.scrollY > 50) {
                    header.classList.add('scrolled');
                } else {
                    header.classList.remove('scrolled');
                }
            }
        });
    </script>

    <!-- Toast Notification System -->
    <style>
        .toast-container {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            max-width: 400px;
        }

        .toast {
            background: white;
            color: #333;
            padding: 20px;
            margin-bottom: 15px;
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
            border-left: 4px solid #ccc;
            position: relative;
            overflow: hidden;
            transform: translateX(100%);
            opacity: 0;
            transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
        }

        .toast.success {
            border-left-color: #22c55e;
            box-shadow: 0 8px 32px rgba(34, 197, 94, 0.2);
        }

        .toast.error {
            border-left-color: #ef4444;
            box-shadow: 0 8px 32px rgba(239, 68, 68, 0.2);
        }

        .toast.warning {
            border-left-color: #f59e0b;
            box-shadow: 0 8px 32px rgba(245, 158, 11, 0.2);
        }

        .toast.info {
            border-left-color: #3b82f6;
            box-shadow: 0 8px 32px rgba(59, 130, 246, 0.2);
        }

        .toast.show {
            transform: translateX(0);
            opacity: 1;
        }

        .toast.hide {
            transform: translateX(100%);
            opacity: 0;
        }


        .toast-content {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .toast-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: rgba(0, 0, 0, 0.05);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }

        .toast-icon.success {
            background: rgba(34, 197, 94, 0.1);
            color: #22c55e;
        }

        .toast-icon.error {
            background: rgba(239, 68, 68, 0.1);
            color: #ef4444;
        }

        .toast-icon.warning {
            background: rgba(245, 158, 11, 0.1);
            color: #f59e0b;
        }

        .toast-icon.info {
            background: rgba(59, 130, 246, 0.1);
            color: #3b82f6;
        }

        .toast-text {
            flex: 1;
        }

        .toast-title {
            font-weight: 600;
            font-size: 16px;
            margin-bottom: 4px;
        }

        .toast.success .toast-title {
            color: #22c55e;
        }

        .toast.error .toast-title {
            color: #ef4444;
        }

        .toast.warning .toast-title {
            color: #f59e0b;
        }

        .toast.info .toast-title {
            color: #3b82f6;
        }

        .toast-message {
            font-size: 14px;
            color: #666;
            line-height: 1.4;
        }

        .toast-close {
            position: absolute;
            top: 10px;
            right: 10px;
            background: none;
            border: none;
            color: #999;
            font-size: 18px;
            cursor: pointer;
            padding: 5px;
            border-radius: 50%;
            transition: all 0.3s ease;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .toast-close:hover {
            background: rgba(0, 0, 0, 0.05);
            color: #333;
        }

        .toast-progress {
            position: absolute;
            bottom: 0;
            left: 0;
            height: 3px;
            background: rgba(255, 255, 255, 0.3);
            width: 100%;
            overflow: hidden;
        }

        .toast-progress-bar {
            height: 100%;
            background: #ddd;
            width: 100%;
            animation: progress 5s linear;
        }

        .toast.success .toast-progress-bar {
            background: #22c55e;
        }

        .toast.error .toast-progress-bar {
            background: #ef4444;
        }

        .toast.warning .toast-progress-bar {
            background: #f59e0b;
        }

        .toast.info .toast-progress-bar {
            background: #3b82f6;
        }

        @keyframes progress {
            from { width: 100%; }
            to { width: 0%; }
        }

        .toast-bounce {
            animation: bounceIn 0.6s ease;
        }

        @keyframes bounceIn {
            0% {
                transform: scale(0.3) translateX(100%);
                opacity: 0;
            }
            50% {
                transform: scale(1.05) translateX(0);
            }
            70% {
                transform: scale(0.9) translateX(0);
            }
            100% {
                transform: scale(1) translateX(0);
                opacity: 1;
            }
        }

        @media (max-width: 768px) {
            .toast-container {
                left: 20px;
                right: 20px;
                max-width: none;
            }

            .toast {
                margin-bottom: 10px;
            }
        }
    </style>

    <script>
        class ToastNotification {
            constructor() {
                this.container = null;
                this.init();
            }

            init() {
                // Create toast container
                this.container = document.createElement('div');
                this.container.className = 'toast-container';
                document.body.appendChild(this.container);
            }

            show(message, type = 'success', duration = 5000) {
                const toast = this.createToast(message, type, duration);
                this.container.appendChild(toast);

                // Trigger animation
                setTimeout(() => {
                    toast.classList.add('show', 'toast-bounce');
                }, 100);

                // Auto remove
                setTimeout(() => {
                    this.remove(toast);
                }, duration);
            }

            createToast(message, type, duration) {
                const toast = document.createElement('div');
                toast.className = 'toast ' + type;

                const iconMap = {
                    success: '✓',
                    error: '✕',
                    warning: '⚠',
                    info: 'ℹ'
                };

                const titleMap = {
                    success: 'Success!',
                    error: 'Error!',
                    warning: 'Warning!',
                    info: 'Info!'
                };

                toast.innerHTML = `
                    <div class="toast-content">
                        <div class="toast-icon ${type}">
                            ${iconMap[type] || iconMap.info}
                        </div>
                        <div class="toast-text">
                            <div class="toast-title">${titleMap[type] || titleMap.info}</div>
                            <div class="toast-message">${message}</div>
                        </div>
                    </div>
                    <button class="toast-close" onclick="window.toastNotification.remove(this.parentElement)">×</button>
                    <div class="toast-progress">
                        <div class="toast-progress-bar"></div>
                    </div>
                `;

                return toast;
            }

            remove(toast) {
                if (!toast) return;

                toast.classList.remove('show');
                toast.classList.add('hide');

                setTimeout(() => {
                    if (toast.parentElement) {
                        toast.parentElement.removeChild(toast);
                    }
                }, 400);
            }

            success(message, duration = 5000) {
                this.show(message, 'success', duration);
            }

            error(message, duration = 5000) {
                this.show(message, 'error', duration);
            }

            warning(message, duration = 5000) {
                this.show(message, 'warning', duration);
            }

            info(message, duration = 5000) {
                this.show(message, 'info', duration);
            }
        }

        // Initialize toast notification system
        window.toastNotification = new ToastNotification();

        // Check for session messages and show toasts
        document.addEventListener('DOMContentLoaded', function() {
            // Check for Laravel session messages
            @if(session('success'))
                window.toastNotification.success('{{ session('success') }}');
            @endif

            @if(session('error'))
                window.toastNotification.error('{{ session('error') }}');
            @endif

            @if(session('warning'))
                window.toastNotification.warning('{{ session('warning') }}');
            @endif

            @if(session('info'))
                window.toastNotification.info('{{ session('info') }}');
            @endif

            // Check for validation errors
            @if($errors->any())
                @foreach($errors->all() as $error)
                    window.toastNotification.error('{{ $error }}');
                @endforeach
            @endif
        });
    </script>

    @stack('scripts')
</body>
</html>
