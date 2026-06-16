@extends('layouts.app')

@section('title', 'Account Deletion - EventGo')

@section('content')
<!-- Account Deletion Section -->
<section class="section account-deletion" id="account-deletion">
    <div class="container-xxl flex-grow-1 container-p-y mt-5">
        <div class="container mb-5">
            <h3>Account Deletion Request</h3>
            <p class="text-muted">
                Last updated on: April 18th, 2026
            </p>

            <h5>Introduction</h5>
            <p>
                At <b>EventGo</b>, we value your privacy and give you full control over your data. This page outlines the steps you can take to permanently delete your account and all associated personal information from our platform.
            </p>

            <h5>How to Delete Your Account</h5>
            <p>You can request account deletion through two primary methods:</p>
            
            <div class="card mb-4 border-0 shadow-sm" style="background: rgba(88, 76, 244, 0.03); border-left: 4px solid #584CF4 !important;">
                <div class="card-body">
                    <h6>Option 1: In-App (Recommended)</h6>
                    <p class="mb-0">
                        The fastest way to delete your account is directly through the <b>EventGo Mobile App</b>:
                    </p>
                    <ol class="mt-2">
                        <li>Open the app and ensure you are logged in.</li>
                        <li>Navigate to your <b>Profile</b> tab.</li>
                        <li>Tap on <b>Settings</b>.</li>
                        <li>Select <b>Delete Account</b> and confirm your request.</li>
                    </ol>
                    <p class="small text-muted mb-0">* This process is instantaneous and irreversible.</p>
                </div>
            </div>

            <div class="card mb-4 border-0 shadow-sm" style="background: rgba(88, 76, 244, 0.03); border-left: 4px solid #584CF4 !important;">
                <div class="card-body">
                    <h6>Option 2: Web Request</h6>
                    <p>
                        If you no longer have access to the app, you may request deletion by contacting our support team via your registered email address:
                    </p>
                    <a href="mailto:support@eventgo-live.com" class="btn btn-primary" style="background-color: #584CF4; border-color: #584CF4;">
                        <i class="fas fa-envelope me-2"></i> Email support@eventgo-live.com
                    </a>
                    <p class="small text-muted mt-2 mb-0">* Manual requests are typically processed within 1-3 business days.</p>
                </div>
            </div>

            <h5>Data Handled During Deletion</h5>
            <p>When you delete your account, the following data is permanently erased from our active databases:</p>
            <ul>
                <li><b>Personal Identity</b> – Your name, email address, profile picture, and verified contact details.</li>
                <li><b>Activity Records</b> – Your event booking history, saved events, and ticket history.</li>
                <li><b>Social Data</b> – Your invitations, notifications, and interaction logs.</li>
                <li><b>Promoted Content</b> – Any active advertisements or promotions you created within the platform.</li>
            </ul>

            <h5>Important Considerations</h5>
            <p>
                Please be aware that while your personal profile is deleted, some data may be retained for specific reasons:
            </p>
            <ul>
                <li><b>Legal & Financial Records</b> – Basic transaction data related to payments and taxes must be retained for the minimum period required by law.</li>
                <li><b>Security Logs</b> – Anonymized logs may be kept for a short period to prevent fraud and ensure platform stability.</li>
            </ul>

            <h5>Contact Us</h5>
            <p>
                If you encounter any issues with the account deletion process, please reach out to our privacy team at 
                <a href="mailto:support@eventgo-live.com">support@eventgo-live.com</a>.
            </p>
        </div>
    </div>
</section>
@endsection
