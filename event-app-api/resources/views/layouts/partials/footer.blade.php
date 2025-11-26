<!-- Footer -->
<footer class="footer pt-5">
    <div class="container">
        <div class="row">
            <div class="col-md-7">
                <h2 class="fs-5">Join our newsletter</h2>
                <p>Stay updated with our latest events and offers—join our newsletter today!</p>
            </div>
            <div class="col-md-5">
                <form action="#" method="POST" class="d-flex gap-2">
                    @csrf
                    <input class="form-control" type="email" name="email" placeholder="Enter your email" required>
                    <button class="btn btn-primary fs-6 w-50" type="submit">Subscribe</button>
                </form>
            </div>
        </div>
        <div class="row justify-content-between mb-5 g-xl-5">
            <div class="col-md-4 mb-5 mb-lg-0">
                <h3 class="mb-3">About</h3>
                <p class="mb-4">Utilize our tools to develop your concepts and bring your vision to life. Once complete, effortlessly share your creations.</p>
            </div>
            <div class="col-md-7">
                <div class="row g-2">
                    <div class="col-md-6 col-lg-4 mb-4 mb-lg-0">
                        <h3 class="mb-3">Company</h3>
                        <ul class="list-unstyled">
                            <li><a href="{{ route('about') }}">About Us</a></li>
                            <li><a href="{{ route('faq') }}">FAQ's</a></li>
                            <li><a href="{{ route('terms') }}">Terms & Conditions</a></li>
                            <li><a href="{{ route('privacy') }}">Privacy Policy</a></li>
                        </ul>
                    </div>
                    <div class="col-md-6 col-lg-4 mb-4 mb-lg-0">
                        <h3 class="mb-3">Accounts</h3>
                        <ul class="list-unstyled">
                            <li><a href="{{ route('register') }}">Register</a></li>
                            <li><a href="{{ route('login') }}">Sign in</a></li>
                        </ul>
                    </div>
                    <div class="col-md-6 col-lg-4 mb-lg-0 quick-contact">
                        <h3 class="">Contact</h3>
                        <p class="d-flex">
                            <i class="bi bi-geo-alt-fill me-3"></i>
                            <span>665 S. Pear Orchard Rd <br> STE 106-815 <br> Ridgeland, MS 39157-4859</span>
                        </p>
                        <a class="d-flex mb-3" href="mailto:info@eventgo-live.com">
                            <i class="bi bi-envelope-fill me-3"></i>
                            <span>info@eventgo-live.com</span>
                        </a>
                        <a class="d-flex mb-3" href="tel://+123456789900">
                            <i class="bi bi-telephone-fill me-3"></i>
                            <span>+1 (234) 5678 9900</span>
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <div class="row credits pt-3">
            <div class="col-xl-8 text-center text-xl-start mb-3 mb-xl-0">
                &copy; {{ date('Y') }} EventGo. All rights reserved.
                Designed with <i class="bi bi-heart-fill text-danger"></i> by 2@lphadev.
            </div>
        </div>
    </div>
</footer>
<!-- End Footer -->
