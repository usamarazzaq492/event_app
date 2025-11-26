<!-- Top Bar -->

<!-- Modern Header -->
<header class="modern-header">
    <div class="container">
        <nav class="navbar navbar-expand-lg">
            <div class="container-fluid">
                <!-- Logo -->
                <a href="{{ route('home') }}" class="navbar-brand d-flex align-items-center">
                    <img src="{{ asset('assets/images/logo.png') }}" alt="EventGo" style="height: 50px;" class="me-2" />
                    <span class="brand-text" style="font-size: 24px; font-weight: bold; color: #584CF4;">EventGo</span>
                </a>

                <!-- Mobile toggle -->
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>

                <!-- Navigation -->
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav mx-auto modern-nav">
                        <li class="nav-item">
                            <a class="nav-link" href="{{ route('home') }}">Home</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="{{ route('events.index') }}">Events</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="{{ route('ads.index') }}">Ads</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="{{ route('about') }}">About</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="{{ route('contact') }}">Contact</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="{{ route('faq') }}">FAQ</a>
                        </li>
                    </ul>

                    <!-- Right side -->
                    <div class="d-flex align-items-center gap-3">
                        @auth
                            <a href="{{ route('events.create') }}" class="create-event-btn">Create Event</a>
                            <a href="{{ route('profile') }}" class="user-profile-link">
                                <div class="user-avatar">
                                    @if(Auth::user()->profileImageUrl)
                                        <img src="{{ asset(Auth::user()->profileImageUrl) }}"
                                             alt="{{ Auth::user()->name }}"
                                             class="profile-image">
                                    @else
                                        <div class="profile-image-placeholder">
                                            <i class="fas fa-user"></i>
                                        </div>
                                    @endif
                                </div>
                            </a>
                        @else
                            <a href="{{ route('login') }}" class="btn btn-outline-primary rounded-pill">Login</a>
                            <a href="{{ route('events.create') }}" class="create-event-btn">Create Event</a>
                        @endauth
                    </div>
                </div>
            </div>
        </nav>
    </div>
</header>
