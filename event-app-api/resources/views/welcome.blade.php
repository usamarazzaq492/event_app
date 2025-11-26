<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EventGo - Connect, Create, Experience</title>
    <link rel="icon" type="image/png" href="{{asset('fav.png')}}">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        /* Header */
        header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }

        nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 0;
        }

        .logo {
            display: flex;
            align-items: center;
            font-size: 1.8rem;
            font-weight: bold;
            color: #667eea;
        }

        .logo-icon {
            width: 70px;
            height: 70px;
            margin-right: 12px;
            /* Replace 'your-logo.png' with the actual path to your logo file */
            background: url({{ asset('fav.png') }}) center/contain no-repeat;
            /* Fallback if logo doesn't load */
        }

        .nav-links {
            display: flex;
            list-style: none;
            gap: 2rem;
        }

        .nav-links a {
            text-decoration: none;
            color: #333;
            font-weight: 500;
            transition: color 0.3s ease;
        }

        .nav-links a:hover {
            color: #667eea;
        }

        .cta-button {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 25px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .cta-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        }

        /* Hero Section */
        .hero {
        padding: 120px 0 80px;
        text-align: center;
        color: white;
        min-height: 100vh;
        display: flex;
        align-items: center;
        /* Replace with your image path */
        background: url('{{ asset("event-hero-image.jpg") }}') center/cover no-repeat;
        position: relative;
    }

    /* Add overlay for better text readability */
    .hero::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.5);
        z-index: 0;
    }

    .hero .container {
        position: relative;
        z-index: 1;
    }

        .hero h1 {
            font-size: 3.5rem;
            margin-bottom: 1rem;
            font-weight: 700;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }

        .hero p {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            opacity: 0.9;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }

        .hero-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }

        .secondary-button {
            background: rgba(255, 255, 255, 0.2);
            border: 2px solid rgba(255, 255, 255, 0.3);
            color: white;
            padding: 12px 24px;
            border-radius: 25px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            backdrop-filter: blur(10px);
        }

        .secondary-button:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }

        /* Features Section */
        .features {
            padding: 80px 0;
            background: white;
        }

        .section-title {
            text-align: center;
            font-size: 2.5rem;
            margin-bottom: 3rem;
            color: #333;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 3rem;
        }

        .feature-card {
            background: white;
            padding: 2rem;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            text-align: center;
            transition: transform 0.3s ease;
            border: 1px solid rgba(102, 126, 234, 0.1);
        }

        .feature-card:hover {
            transform: translateY(-5px);
        }

        .feature-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 2rem;
            color: white;
        }

        .feature-card h3 {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            color: #333;
        }

        .feature-card p {
            color: #666;
            line-height: 1.6;
        }

        /* How It Works */
        .how-it-works {
            padding: 80px 0;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        }

        .steps {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            margin-top: 3rem;
        }

        .step {
            text-align: center;
            position: relative;
        }

        .step-number {
            width: 60px;
            height: 60px;
            background: #ffd700;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 1.5rem;
            font-weight: bold;
            color: #333;
        }

        .step h3 {
            font-size: 1.3rem;
            margin-bottom: 1rem;
            color: #333;
        }

        .step p {
            color: #666;
        }

        /* CTA Section */
        .cta-section {
            padding: 80px 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            text-align: center;
            color: white;
        }

        .cta-section h2 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }

        .cta-section p {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }

        /* Footer */
        footer {
            background: #333;
            color: white;
            padding: 40px 0;
            text-align: center;
        }

        .footer-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .footer-section h4 {
            margin-bottom: 1rem;
            color: #ffd700;
        }

        .footer-section a {
            color: #ccc;
            text-decoration: none;
            display: block;
            margin-bottom: 0.5rem;
            transition: color 0.3s ease;
        }

        .footer-section a:hover {
            color: #667eea;
        }

        .footer-bottom {
            border-top: 1px solid #555;
            padding-top: 2rem;
            color: #ccc;
        }

        /* Mobile Menu */
        .mobile-menu {
            display: none;
            flex-direction: column;
            gap: 10px;
            cursor: pointer;
        }

        .mobile-menu span {
            width: 25px;
            height: 3px;
            background: #333;
            transition: 0.3s;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .nav-links {
                display: none;
            }

            .mobile-menu {
                display: flex;
            }

            .hero h1 {
                font-size: 2.5rem;
            }

            .hero p {
                font-size: 1rem;
            }

            .hero-buttons {
                flex-direction: column;
                align-items: center;
            }

            .section-title {
                font-size: 2rem;
            }

            .features-grid {
                grid-template-columns: 1fr;
            }

            .steps {
                grid-template-columns: 1fr;
            }
        }

        /* Animations */
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

        .feature-card, .step {
            animation: fadeInUp 0.6s ease forwards;
        }

        .feature-card:nth-child(2) { animation-delay: 0.2s; }
        .feature-card:nth-child(3) { animation-delay: 0.4s; }
        .step:nth-child(2) { animation-delay: 0.2s; }
        .step:nth-child(3) { animation-delay: 0.4s; }
        .step:nth-child(4) { animation-delay: 0.6s; }

        /* About Section */
        .about-section {
            padding: 80px 0;
            background: white;
        }

        .about-content {
            display: flex;
            align-items: center;
            gap: 3rem;
            margin-top: 2rem;
        }

        .about-text {
            flex: 1;
        }

        .about-image {
            flex: 1;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .about-image img {
            width: 100%;
            height: auto;
            display: block;
        }

        /* Contact Section */
        .contact-section {
            padding: 80px 0;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        }

        .contact-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 3rem;
            margin-top: 2rem;
        }

        .contact-info {
            background: white;
            padding: 2rem;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .contact-info h3 {
            color: #667eea;
            margin-bottom: 1.5rem;
        }

        .contact-details {
            margin-bottom: 2rem;
        }

        .contact-details p {
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
        }

        .contact-details i {
            margin-right: 10px;
            color: #667eea;
        }

        .contact-form {
            background: white;
            padding: 2rem;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-family: inherit;
        }

        .form-group textarea {
            min-height: 150px;
            resize: vertical;
        }

        .submit-button {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 25px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .submit-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .about-content {
                flex-direction: column;
            }

            .contact-container {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <header>
        <nav class="container">
            <div class="logo">
                <div class="logo-icon"></div>
            </div>
            <ul class="nav-links">
                <li><a href="#features">Features</a></li>
                <li><a href="#how-it-works">How It Works</a></li>
                <li><a href="#about">About</a></li>
                <!--<li><a href="#contact">Contact</a></li>-->
            </ul>
            <div class="mobile-menu">
                <span></span>
                <span></span>
                <span></span>
            </div>
            <a href="#signup" class="cta-button">Get Started</a>
        </nav>
    </header>

    <main>
        <section class="hero">
            <div class="container">
                <h1>Connect, Create, Experience</h1>
                <p>Discover amazing events near you, create memorable experiences, and connect with like-minded people. Your next adventure is just a tap away!</p>
                <div class="hero-buttons">
                    <a href="#signup" class="cta-button">Join EventGo</a>
                    <a href="#features" class="secondary-button">Learn More</a>
                </div>
            </div>
        </section>

        <section id="features" class="features">
            <div class="container">
                <h2 class="section-title">Why Choose EventGo?</h2>
                <div class="features-grid">
                    <div class="feature-card">
                        <div class="feature-icon">🎯</div>
                        <h3>Discover Events</h3>
                        <p>Find exciting events happening near you. From concerts to workshops, never miss out on what's happening in your area.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">🎪</div>
                        <h3>Create & Host</h3>
                        <p>Organize your own events with ease. Set up locations, manage tickets, and bring people together for unforgettable experiences.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">👥</div>
                        <h3>Connect & Follow</h3>
                        <p>Build your network by following other users, viewing their profiles, and staying updated on their latest events and activities.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">🎫</div>
                        <h3>Easy Booking</h3>
                        <p>Seamlessly book tickets for events with multiple payment options. Download your tickets instantly and keep track of your purchases.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">💬</div>
                        <h3>Real-time Messaging</h3>
                        <p>Stay connected with direct messaging, real-time notifications, and instant updates about events you're interested in.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">📢</div>
                        <h3>Create Ads</h3>
                        <p>Promote your events or causes with custom ads. Accept donations and increase visibility for your important messages.</p>
                    </div>
                </div>
            </div>
        </section>

        <section id="how-it-works" class="how-it-works">
            <div class="container">
                <h2 class="section-title">How It Works</h2>
                <div class="steps">
                    <div class="step">
                        <div class="step-number">1</div>
                        <h3>Sign Up</h3>
                        <p>Create your account with email verification and set up your profile with interests and preferences.</p>
                    </div>
                    <div class="step">
                        <div class="step-number">2</div>
                        <h3>Explore</h3>
                        <p>Browse events near you, filter by location and interests, and discover what's happening in your community.</p>
                    </div>
                    <div class="step">
                        <div class="step-number">3</div>
                        <h3>Connect</h3>
                        <p>Follow other users, view their profiles, send messages, and build your social network within the app.</p>
                    </div>
                    <div class="step">
                        <div class="step-number">4</div>
                        <h3>Participate</h3>
                        <p>Book tickets, host events, invite friends, and create lasting memories through shared experiences.</p>
                    </div>
                </div>
            </div>
        </section>

<section id="about" class="about-section">
        <div class="container">
            <h2 class="section-title">About EventGo</h2>
            <div class="about-content">
                <div class="about-text">
                    <h3>Our Story</h3>
                    <p>Founded in 2025, EventGo was born from a simple idea: to make event discovery and creation effortless. Our team of passionate event enthusiasts noticed how difficult it was to find authentic local experiences while event organizers struggled to reach their audiences.</p>
                    <p>Today, we've grown into a platform that connects millions of event-goers with thousands of unique experiences every month. From small community gatherings to large-scale festivals, we're proud to be the bridge that brings people together.</p>
                    <h3>Our Mission</h3>
                    <p>To create meaningful connections through shared experiences by providing the most intuitive platform for event discovery, creation, and participation.</p>
                </div>
                <div class="about-image">
                    <img src="{{ asset('about.jpg') }}" alt="EventGo team working together">
                </div>
            </div>
        </div>
    </section>

    <!--<section id="contact" class="contact-section">-->
    <!--    <div class="container">-->
    <!--        <h2 class="section-title">Get In Touch</h2>-->
    <!--        <div class="contact-container">-->
    <!--            <div class="contact-info">-->
    <!--                <h3>Contact Information</h3>-->
    <!--                <div class="contact-details">-->
    <!--                    <p><i>📧</i> dbailey@eventgo-live.com</p>-->
    <!--                    <p><i>📱</i> +1 (555) 123-4567</p>-->
    <!--                    <p><i>🏢</i> 665 S. Pear Orchard Rd, STE 106-815, Ridgeland, MS 39157-4859</p>-->
    <!--                </div>-->
    <!--                <h3>Business Hours</h3>-->
    <!--                <p>Monday - Friday: 9:00 AM - 6:00 PM</p>-->
    <!--                <p>Saturday: 10:00 AM - 4:00 PM</p>-->
    <!--                <p>Sunday: Closed</p>-->
    <!--            </div>-->
    <!--            <div class="contact-form">-->
    <!--                <h3>Send Us a Message</h3>-->
    <!--                <form>-->
    <!--                    <div class="form-group">-->
    <!--                        <label for="name">Your Name</label>-->
    <!--                        <input type="text" id="name" required>-->
    <!--                    </div>-->
    <!--                    <div class="form-group">-->
    <!--                        <label for="email">Email Address</label>-->
    <!--                        <input type="email" id="email" required>-->
    <!--                    </div>-->
    <!--                    <div class="form-group">-->
    <!--                        <label for="subject">Subject</label>-->
    <!--                        <input type="text" id="subject" required>-->
    <!--                    </div>-->
    <!--                    <div class="form-group">-->
    <!--                        <label for="message">Your Message</label>-->
    <!--                        <textarea id="message" required></textarea>-->
    <!--                    </div>-->
    <!--                    <button type="submit" class="submit-button">Send Message</button>-->
    <!--                </form>-->
    <!--            </div>-->
    <!--        </div>-->
    <!--    </div>-->
    <!--</section>-->

        <section class="cta-section">
            <div class="container">
                <h2>Ready to Get Started?</h2>
                <p>Join thousands of users who are already connecting and creating amazing experiences together.</p>
                <a href="#signup" class="cta-button">Download EventGo</a>
            </div>
        </section>
    </main>

    <footer>
        <div class="container">
            <div class="footer-content">
                <div class="footer-section">
                    <h4>Product</h4>
                    <a href="#features">Features</a>
                    <!--<a href="#pricing">Pricing</a>-->
                    <!--<a href="#updates">Updates</a>-->
                </div>
                <div class="footer-section">
                    <h4>Company</h4>
                    <a href="#about">About Us</a>
                    <!--<a href="#careers">Careers</a>-->
                    <a href="#how-it-works">How it works</a>
                </div>
                <!--<div class="footer-section">-->
                <!--    <h4>Support</h4>-->
                <!--    <a href="#help">Help Center</a>-->
                    <!--<a href="#contact">Contact</a>-->
                <!--    <a href="#privacy">Privacy Policy</a>-->
                <!--</div>-->
                <div class="footer-section">
                    <h4>Connect</h4>
                    <a href="#twitter">Twitter</a>
                    <a href="#facebook">Facebook</a>
                    <a href="#instagram">Instagram</a>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2025 EventGo. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <script>
        // Smooth scrolling for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Mobile menu toggle
        const mobileMenu = document.querySelector('.mobile-menu');
        const navLinks = document.querySelector('.nav-links');

        mobileMenu.addEventListener('click', () => {
            navLinks.style.display = navLinks.style.display === 'flex' ? 'none' : 'flex';
        });

        // Add scroll effect to header
        window.addEventListener('scroll', () => {
            const header = document.querySelector('header');
            if (window.scrollY > 100) {
                header.style.background = 'rgba(255, 255, 255, 0.98)';
            } else {
                header.style.background = 'rgba(255, 255, 255, 0.95)';
            }
        });

        document.querySelector('.contact-form form').addEventListener('submit', function(e) {
            e.preventDefault();
            // Here you would typically send the form data to your server
            alert('Thank you for your message! We will get back to you soon.');
            this.reset();
        });
    </script>
</body>
</html>
