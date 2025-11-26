@extends('layouts.app')

@section('title', 'FAQ - EventGo')

@section('content')
<!-- FAQ Section -->
<section class="section faq__v2" id="faq">
    <div class="container">
        <div class="row mb-4">
            <div class="col-md-6 col-lg-7 mx-auto text-center">
                <span class="subtitle text-uppercase mt-5" data-aos="fade-up" data-aos-delay="0">FAQ</span>
                <h2 class="h2 fw-bold mb-3" data-aos="fade-up" data-aos-delay="0">Frequently Asked Questions</h2>
                <p data-aos="fade-up" data-aos-delay="100">
                    Find answers to common questions about our platform and services.
                </p>
            </div>
        </div>
        <div class="row">
            <div class="col-md-8 mx-auto" data-aos="fade-up" data-aos-delay="200">
                <div class="faq-content">
                    <div class="accordion custom-accordion" id="accordionPanelsStayOpenExample">
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse"
                                    data-bs-target="#panelsStayOpen-collapseOne" aria-expanded="true"
                                    aria-controls="panelsStayOpen-collapseOne">
                                    What services does EventGo offer?
                                </button>
                            </h2>
                            <div class="accordion-collapse collapse show" id="panelsStayOpen-collapseOne">
                                <div class="accordion-body">
                                    EventGo offers a comprehensive platform for discovering, creating, and managing events.
                                    We provide tools for event ticketing, attendee management, real-time messaging, promotional ads,
                                    and secure payment processing.
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                                    data-bs-target="#panelsStayOpen-collapseTwo" aria-expanded="false"
                                    aria-controls="panelsStayOpen-collapseTwo">
                                    How much does it cost to create an event?
                                </button>
                            </h2>
                            <div class="accordion-collapse collapse" id="panelsStayOpen-collapseTwo">
                                <div class="accordion-body">
                                    The cost varies depending on your plan. We offer personal and business plans starting at $7/month.
                                    Each plan includes different features and capabilities to suit your event needs.
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                                    data-bs-target="#panelsStayOpen-collapseThree" aria-expanded="false"
                                    aria-controls="panelsStayOpen-collapseThree">
                                    How long does it take to set up an event?
                                </button>
                            </h2>
                            <div class="accordion-collapse collapse" id="panelsStayOpen-collapseThree">
                                <div class="accordion-body">
                                    You can create and publish an event in just minutes! Our intuitive event builder makes it easy to
                                    add details, set up ticketing, upload media, and customize your event page quickly.
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                                    data-bs-target="#panelsStayOpen-collapseFour" aria-expanded="false"
                                    aria-controls="panelsStayOpen-collapseFour">
                                    Is the platform mobile-friendly?
                                </button>
                            </h2>
                            <div class="accordion-collapse collapse" id="panelsStayOpen-collapseFour">
                                <div class="accordion-body">
                                    Absolutely! EventGo is fully responsive and optimized for all devices. We also offer native mobile
                                    apps for iOS and Android for the best experience on the go.
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                                    data-bs-target="#panelsStayOpen-collapseFive" aria-expanded="false"
                                    aria-controls="panelsStayOpen-collapseFive">
                                    Do you provide customer support?
                                </button>
                            </h2>
                            <div class="accordion-collapse collapse" id="panelsStayOpen-collapseFive">
                                <div class="accordion-body">
                                    Yes! We offer 24/7 customer support via chat, email, and phone. Our help center also provides
                                    detailed guides and tutorials to help you make the most of our platform.
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
