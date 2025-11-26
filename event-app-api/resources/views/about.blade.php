@extends('layouts.app')

@section('title', 'About Us - EventGo')

@section('content')
<!-- Hero Carousel -->
<section class="hero__v6 section" id="home">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-12 mt-5 mt-lg-0 aos-init aos-animate" data-aos="zoom-in">
                <div id="heroCarousel" class="carousel slide rounded-4 shadow-lg" data-bs-ride="carousel">
                    <div class="carousel-inner">
                        <div class="carousel-item active">
                            <img src="https://images.unsplash.com/photo-1507874457470-272b3c8d8ee2?auto=format&fit=crop&w=1200&q=80"
                                class="d-block w-100 rounded-4" alt="Concert" />
                            <div class="carousel-caption d-none d-md-block text-start">
                                <h5>Summer Music Festival</h5>
                                <p>Live bands • Outdoor stage • Open-air</p>
                            </div>
                        </div>
                        <div class="carousel-item">
                            <img src="https://images.unsplash.com/photo-1531058020387-3be344556be6?auto=format&fit=crop&w=1200&q=80"
                                class="d-block w-100 rounded-4" alt="Conference" />
                            <div class="carousel-caption d-none d-md-block text-start">
                                <h5>Global Tech Conference</h5>
                                <p>Keynotes • Workshops • Networking</p>
                            </div>
                        </div>
                        <div class="carousel-item">
                            <img src="https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=1200&q=80"
                                class="d-block w-100 rounded-4" alt="Meetup" />
                            <div class="carousel-caption d-none d-md-block text-start">
                                <h5>Startups & Meetups</h5>
                                <p>Pitch nights • Demo tables • Meet founders</p>
                            </div>
                        </div>
                    </div>
                    <button class="carousel-control-prev" type="button" data-bs-target="#heroCarousel" data-bs-slide="prev">
                        <span class="carousel-control-prev-icon"></span>
                    </button>
                    <button class="carousel-control-next" type="button" data-bs-target="#heroCarousel" data-bs-slide="next">
                        <span class="carousel-control-next-icon"></span>
                    </button>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- About Section -->
<section class="about__v4 section" id="about">
    <div class="container">
        <div class="row">
            <div class="col-md-6 order-md-2">
                <div class="row justify-content-end">
                    <div class="col-md-11 mb-4 mb-md-0">
                        <span class="subtitle text-uppercase mb-3" data-aos="fade-up" data-aos-delay="0">About us</span>
                        <h2 class="mb-4" data-aos="fade-up" data-aos-delay="100">
                            Experience the future of events with our secure, efficient, and user-friendly platform
                        </h2>
                        <div data-aos="fade-up" data-aos-delay="200">
                            <p>
                                Founded with the vision of revolutionizing the event industry, we are a leading platform dedicated to
                                providing innovative and secure event solutions.
                            </p>
                            <p>
                                Our cutting-edge platform ensures your events are safe, streamlined, and easy to manage, empowering you to
                                take control of your event journey with confidence and convenience.
                            </p>
                        </div>
                        <h4 class="small fw-bold mt-4 mb-3" data-aos="fade-up" data-aos-delay="300">
                            Key Values and Vision
                        </h4>
                        <ul class="d-flex flex-row flex-wrap list-unstyled gap-3 features" data-aos="fade-up" data-aos-delay="400">
                            <li class="d-flex align-items-center gap-2">
                                <span class="icon rounded-circle text-center"><i class="bi bi-check"></i></span>
                                <span class="text">Innovation</span>
                            </li>
                            <li class="d-flex align-items-center gap-2">
                                <span class="icon rounded-circle text-center"><i class="bi bi-check"></i></span>
                                <span class="text">Security</span>
                            </li>
                            <li class="d-flex align-items-center gap-2">
                                <span class="icon rounded-circle text-center"><i class="bi bi-check"></i></span>
                                <span class="text">User-Centric Design</span>
                            </li>
                            <li class="d-flex align-items-center gap-2">
                                <span class="icon rounded-circle text-center"><i class="bi bi-check"></i></span>
                                <span class="text">Transparency</span>
                            </li>
                            <li class="d-flex align-items-center gap-2">
                                <span class="icon rounded-circle text-center"><i class="bi bi-check"></i></span>
                                <span class="text">Empowerment</span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="img-wrap position-relative">
                    <img class="img-fluid rounded-4" src="{{ asset('assets/images/about_2-min.jpg') }}"
                        alt="About EventGo" data-aos="fade-up" data-aos-delay="0" />
                    <div class="mission-statement p-4 rounded-4 d-flex gap-4" data-aos="fade-up" data-aos-delay="100">
                        <div class="mission-icon text-center rounded-circle">
                            <i class="bi bi-lightbulb fs-4"></i>
                        </div>
                        <div>
                            <h3 class="text-uppercase fw-bold">Mission Statement</h3>
                            <p class="fs-5 mb-0">
                                Our mission is to empower individuals and organizers by delivering secure, efficient, and user-friendly event services.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- How it works -->
<section class="section howitworks__v1" id="how-it-works">
    <div class="container">
        <div class="row mb-5">
            <div class="col-md-6 text-center mx-auto">
                <span class="subtitle text-uppercase mb-3" data-aos="fade-up" data-aos-delay="0">How it works</span>
                <h2 data-aos="fade-up" data-aos-delay="100">How It Works</h2>
                <p data-aos="fade-up" data-aos-delay="200">
                    Our platform is designed to make managing your events simple and efficient. Follow these easy steps to get started:
                </p>
            </div>
        </div>
        <div class="row g-md-5">
            <div class="col-md-6 col-lg-3">
                <div class="step-card text-center h-100 d-flex flex-column justify-content-start position-relative" data-aos="fade-up" data-aos-delay="0">
                    <div data-aos="fade-right" data-aos-delay="500">
                        <img class="arch-line" src="{{ asset('assets/images/arch-line.svg') }}" alt="Step 1" />
                    </div>
                    <span class="step-number rounded-circle text-center fw-bold mb-5 mx-auto">1</span>
                    <div>
                        <h3 class="fs-5 mb-4">Sign Up</h3>
                        <p>Visit our website or download our app to sign up. Provide basic information to set up your secure account.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-lg-3" data-aos="fade-up" data-aos-delay="600">
                <div class="step-card reverse text-center h-100 d-flex flex-column justify-content-start position-relative">
                    <div data-aos="fade-right" data-aos-delay="1100">
                        <img class="arch-line reverse" src="{{ asset('assets/images/arch-line-reverse.svg') }}" alt="Step 2" />
                    </div>
                    <span class="step-number rounded-circle text-center fw-bold mb-5 mx-auto">2</span>
                    <h3 class="fs-5 mb-4">Set Up Your Profile</h3>
                    <p>Add your personal or organizer details to tailor the platform to your specific needs.</p>
                </div>
            </div>
            <div class="col-md-6 col-lg-3" data-aos="fade-up" data-aos-delay="1200">
                <div class="step-card text-center h-100 d-flex flex-column justify-content-start position-relative">
                    <div data-aos="fade-right" data-aos-delay="1700">
                        <img class="arch-line" src="{{ asset('assets/images/arch-line.svg') }}" alt="Step 3" />
                    </div>
                    <span class="step-number rounded-circle text-center fw-bold mb-5 mx-auto">3</span>
                    <h3 class="fs-5 mb-4">Explore Events</h3>
                    <p>Access your dashboard for a summary of your events: upcoming, bookings, and insights.</p>
                </div>
            </div>
            <div class="col-md-6 col-lg-3" data-aos="fade-up" data-aos-delay="1800">
                <div class="step-card last text-center h-100 d-flex flex-column justify-content-start position-relative">
                    <span class="step-number rounded-circle text-center fw-bold mb-5 mx-auto">4</span>
                    <div>
                        <h3 class="fs-5 mb-4">Create & Host</h3>
                        <p>Discover opportunities to create and host amazing events tailored to your goals.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Stats -->
<section class="stats__v3 section">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="d-flex flex-wrap content rounded-4 aos-init aos-animate" data-aos="fade-up" data-aos-delay="0">
                    <div class="rounded-borders">
                        <div class="rounded-border-1"></div>
                        <div class="rounded-border-2"></div>
                        <div class="rounded-border-3"></div>
                    </div>
                    <div class="col-12 col-sm-6 col-md-4 mb-4 mb-md-0 text-center aos-init aos-animate" data-aos="fade-up" data-aos-delay="100">
                        <div class="stat-item">
                            <h3 class="fs-1 fw-bold"><span class="purecounter" data-purecounter-start="0" data-purecounter-end="10" data-purecounter-duration="0">10</span><span>K+</span></h3>
                            <p class="mb-0">Happy Users</p>
                        </div>
                    </div>
                    <div class="col-12 col-sm-6 col-md-4 mb-4 mb-md-0 text-center aos-init aos-animate" data-aos="fade-up" data-aos-delay="200">
                        <div class="stat-item">
                            <h3 class="fs-1 fw-bold"><span class="purecounter" data-purecounter-start="0" data-purecounter-end="5000" data-purecounter-duration="0">5000</span><span>+</span></h3>
                            <p class="mb-0">Events Hosted</p>
                        </div>
                    </div>
                    <div class="col-12 col-sm-6 col-md-4 mb-4 mb-md-0 text-center aos-init aos-animate" data-aos="fade-up" data-aos-delay="300">
                        <div class="stat-item">
                            <h3 class="fs-1 fw-bold"><span class="purecounter" data-purecounter-start="0" data-purecounter-end="98" data-purecounter-duration="0">98</span><span>%</span></h3>
                            <p class="mb-0">Satisfaction Rate</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Features -->
<section class="section features__v2" id="features">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <div class="d-lg-flex p-5 rounded-4 content" data-aos="fade-in" data-aos-delay="0">
                    <div class="row">
                        <div class="col-lg-5 mb-5 mb-lg-0" data-aos="fade-up" data-aos-delay="0">
                            <div class="row">
                                <div class="col-lg-11">
                                    <div class="h-100 flex-column justify-content-between d-flex">
                                        <div>
                                            <h2 class="mb-4">Why Choose Us</h2>
                                            <p class="mb-5">
                                                Experience the future of events with our secure, efficient, and user-friendly services.
                                                Our cutting-edge platform ensures your events are safe, streamlined, and easy to manage.
                                            </p>
                                        </div>
                                        <div class="align-self-start">
                                            <a class="glightbox btn btn-play d-inline-flex align-items-center gap-2"
                                                href="https://www.youtube.com/watch?v=DQx96G4yHd8" data-gallery="video">
                                                <i class="bi bi-play-fill"></i> Watch the Video
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-7">
                            <div class="row justify-content-end">
                                <div class="col-lg-11">
                                    <div class="row">
                                        <div class="col-sm-6" data-aos="fade-up" data-aos-delay="0">
                                            <div class="icon text-center mb-4">
                                                <i class="bi bi-person-check fs-4"></i>
                                            </div>
                                            <h3 class="fs-6 fw-bold mb-3">User-Friendly Interface</h3>
                                            <p>Easy navigation with responsive design for various devices.</p>
                                        </div>
                                        <div class="col-sm-6" data-aos="fade-up" data-aos-delay="100">
                                            <div class="icon text-center mb-4">
                                                <i class="bi bi-graph-up fs-4"></i>
                                            </div>
                                            <h3 class="fs-6 fw-bold mb-3">Event Analytics</h3>
                                            <p>Attendee tracking, revenue analysis, and personalized insights.</p>
                                        </div>
                                        <div class="col-sm-6" data-aos="fade-up" data-aos-delay="200">
                                            <div class="icon text-center mb-4">
                                                <i class="bi bi-headset fs-4"></i>
                                            </div>
                                            <h3 class="fs-6 fw-bold mb-3">Customer Support</h3>
                                            <p>24/7 service via chat, email, phone, and a detailed help center.</p>
                                        </div>
                                        <div class="col-sm-6" data-aos="fade-up" data-aos-delay="300">
                                            <div class="icon text-center mb-4">
                                                <i class="bi bi-shield-lock fs-4"></i>
                                            </div>
                                            <h3 class="fs-6 fw-bold mb-3">Security Features</h3>
                                            <p>Data encryption, fraud detection, and prevention mechanisms.</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection

@push('scripts')
<script>
    AOS.init({
        duration: 800,
        easing: 'ease-in-out',
        once: true
    });
</script>
@endpush
