@extends('layouts.app')

@section('title', 'Contact Us - EventGo')

@section('content')
<!-- Contact Section -->
<section class="section contact__v2" id="contact">
    <div class="container">
        <div class="row mb-5">
            <div class="col-md-6 col-lg-7 mx-auto text-center">
                <span class="subtitle text-uppercase mt-5" data-aos="fade-up" data-aos-delay="0">Contact</span>
                <h2 class="h2 fw-bold mb-3" data-aos="fade-up" data-aos-delay="0">Contact Us</h2>
                <p data-aos="fade-up" data-aos-delay="100">
                    Have questions or need support? Get in touch with us and we'll be happy to help you.
                </p>
            </div>
        </div>
        <div class="row">
            <div class="col-md-6">
                <div class="d-flex gap-5 flex-column">
                    <div class="d-flex align-items-start gap-3" data-aos="fade-up" data-aos-delay="0">
                        <div class="icon d-block">
                            <i class="bi bi-telephone"></i>
                        </div>
                        <span>
                            <span class="d-block">Phone</span>
                            <strong>+(01 234 567 890)</strong>
                        </span>
                    </div>
                    <div class="d-flex align-items-start gap-3" data-aos="fade-up" data-aos-delay="100">
                        <div class="icon d-block"><i class="bi bi-send"></i></div>
                        <span>
                            <span class="d-block">Email</span>
                            <strong>info@mydomain.com</strong>
                        </span>
                    </div>
                    <div class="d-flex align-items-start gap-3" data-aos="fade-up" data-aos-delay="200">
                        <div class="icon d-block">
                            <i class="bi bi-geo-alt"></i>
                        </div>
                        <span>
                            <span class="d-block">Address</span>
                            <address class="fw-bold">
                                665 S. Pear Orchard Rd <br />
                                STE 106-815 <br />
                                Ridgeland, MS 39157-4859
                            </address>
                        </span>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-wrapper" data-aos="fade-up" data-aos-delay="300">
                    <form id="contactForm" action="{{ route('contact.submit') }}" method="POST">
                        @csrf
                        <div class="row gap-3 mb-3">
                            <div class="col-md-12">
                                <label class="mb-2" for="name">Name</label>
                                <input class="form-control" id="name" type="text" name="name" required />
                            </div>
                            <div class="col-md-12">
                                <label class="mb-2" for="email">Email</label>
                                <input class="form-control" id="email" type="email" name="email" required />
                            </div>
                        </div>
                        <div class="row gap-3 mb-3">
                            <div class="col-md-12">
                                <label class="mb-2" for="subject">Subject</label>
                                <input class="form-control" id="subject" type="text" name="subject" />
                            </div>
                        </div>
                        <div class="row gap-3 gap-md-0 mb-3">
                            <div class="col-md-12">
                                <label class="mb-2" for="message">Message</label>
                                <textarea class="form-control" id="message" name="message" rows="5" required></textarea>
                            </div>
                        </div>
                        <button class="btn btn-primary fw-semibold" type="submit">
                            Send Message
                        </button>
                    </form>
                    @if(session('success'))
                        <div class="mt-3 alert alert-success">{{ session('success') }}</div>
                    @endif
                    @if(session('error'))
                        <div class="mt-3 alert alert-danger">{{ session('error') }}</div>
                    @endif
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Map Section -->
<section id="google-map-area">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <iframe
                    src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3067.8935047617024!2d-104.99371968416142!3d39.74204297944934!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zMznCsDQ0JzMxLjQiTiAxMDTCsDU5JzI5LjUiVw!5e0!3m2!1sen!2sbd!4v1545421237228"
                    width="100%"
                    height="450"
                    frameborder="0"
                    style="border: 0"
                    allowfullscreen="">
                </iframe>
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
