<!-- Modern Header -->
<header class="modern-header" id="mainHeader">
    <div class="container-fluid px-3 px-lg-4">
        <nav class="navbar navbar-expand-lg">
            <!-- Logo -->
            <a href="{{ route('home') }}" class="navbar-brand">
                <div class="logo-wrapper">
                    <img src="{{ asset('assets/images/logo.png') }}" alt="EventGo" class="logo-img" />
                    <span class="brand-text">EventGo</span>
                </div>
            </a>

            <!-- Mobile toggle -->
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <!-- Navigation -->
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav mx-auto">
                    <li class="nav-item">
                        <a class="nav-link {{ request()->routeIs('home') ? 'active' : '' }}" href="{{ route('home') }}">
                            <i class="fas fa-home me-1"></i>Home
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{ request()->routeIs('events.*') ? 'active' : '' }}" href="{{ route('events.index') }}">
                            <i class="fas fa-calendar-alt me-1"></i>Events
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{ request()->routeIs('ads.*') ? 'active' : '' }}" href="{{ route('ads.index') }}">
                            <i class="fas fa-rocket me-1"></i>Promoted Events
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{ request()->routeIs('about') ? 'active' : '' }}" href="{{ route('about') }}">
                            <i class="fas fa-info-circle me-1"></i>About
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{ request()->routeIs('contact') ? 'active' : '' }}" href="{{ route('contact') }}">
                            <i class="fas fa-envelope me-1"></i>Contact
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link {{ request()->routeIs('faq') ? 'active' : '' }}" href="{{ route('faq') }}">
                            <i class="fas fa-question-circle me-1"></i>FAQ
                        </a>
                    </li>
                </ul>

                <!-- Right side actions -->
                <div class="navbar-actions">
                    @auth
                        <a href="{{ route('events.create') }}" class="btn-create-event">
                            <i class="fas fa-plus-circle me-2"></i>
                            <span>Create Event</span>
                        </a>
                        <div class="dropdown user-menu">
                            <a href="#" class="user-profile-link" data-bs-toggle="dropdown" aria-expanded="false">
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
                                <span class="user-name d-none d-lg-inline">{{ Auth::user()->name }}</span>
                                <i class="fas fa-chevron-down ms-2 d-none d-lg-inline"></i>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li>
                                    <a class="dropdown-item" href="{{ route('profile') }}">
                                        <i class="fas fa-user me-2"></i>My Profile
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item" href="{{ route('events.create') }}">
                                        <i class="fas fa-plus-circle me-2"></i>Create Event
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item" href="{{ route('promotion.select-event') }}">
                                        <i class="fas fa-rocket me-2"></i>Promote Event
                                    </a>
                                </li>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <form method="POST" action="{{ route('logout') }}" class="d-inline">
                                        @csrf
                                        <button type="submit" class="dropdown-item text-danger">
                                            <i class="fas fa-sign-out-alt me-2"></i>Logout
                                        </button>
                                    </form>
                                </li>
                            </ul>
                        </div>
                    @else
                        <a href="{{ route('login') }}" class="btn-login">
                            <i class="fas fa-sign-in-alt me-2"></i>Login
                        </a>
                        <a href="{{ route('events.create') }}" class="btn-create-event">
                            <i class="fas fa-plus-circle me-2"></i>
                            <span>Create Event</span>
                        </a>
                    @endauth
                </div>
            </div>
        </nav>
    </div>
</header>
