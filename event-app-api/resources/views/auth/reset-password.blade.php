@extends('layouts.app')

@section('title', 'Reset Password - EventGo')

@section('content')
<div class="auth-page">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-5 col-md-7">
                <div class="auth-card">
                    <div class="auth-header">
                        <div class="auth-icon">
                            <i class="bi bi-shield-lock-fill"></i>
                        </div>
                        <h2>Reset Password</h2>
                        <p>Enter a new password for your account to complete the reset process.</p>
                    </div>

                    <div class="auth-body">
                        @if (session('status'))
                            <div class="alert alert-success">
                                <i class="bi bi-check-circle me-2"></i>{{ session('status') }}
                            </div>
                        @endif

                        @if ($errors->any())
                            <div class="alert alert-danger">
                                <i class="bi bi-exclamation-triangle me-2"></i>
                                @foreach ($errors->all() as $error)
                                    <div>{{ $error }}</div>
                                @endforeach
                            </div>
                        @endif

                        <form method="POST" action="{{ route('password.update') }}" class="auth-form">
                            @csrf

                            <input type="hidden" name="token" value="{{ $token }}">

                            <div class="form-group">
                                <label for="email" class="form-label">Email Address</label>
                                <div class="input-wrapper">
                                    <i class="bi bi-envelope"></i>
                                    <input type="email"
                                           id="email"
                                           name="email"
                                           class="form-control"
                                           placeholder="Enter your email address"
                                           value="{{ session('password_reset_email') }}"
                                           required
                                           readonly>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="password" class="form-label">New Password</label>
                                <div class="input-wrapper">
                                    <i class="bi bi-lock"></i>
                                    <input type="password"
                                           id="password"
                                           name="password"
                                           class="form-control"
                                           placeholder="Enter new password (min 8 chars, uppercase, lowercase, number, special char)"
                                           required>
                                </div>
                                <div class="password-strength" id="password-strength"></div>
                            </div>

                            <div class="form-group">
                                <label for="password_confirmation" class="form-label">Confirm New Password</label>
                                <div class="input-wrapper">
                                    <i class="bi bi-lock-fill"></i>
                                    <input type="password"
                                           id="password_confirmation"
                                           name="password_confirmation"
                                           class="form-control"
                                           placeholder="Confirm new password"
                                           required>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary w-100">
                                <i class="bi bi-check-circle me-2"></i>Reset Password
                            </button>
                        </form>

                        <div class="auth-footer">
                            <p class="text-center">
                                Remember your password?
                                <a href="{{ route('login') }}" class="auth-link">Sign In</a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
body {
    background-color: #f8f9ff !important;
}

.auth-page {
    min-height: 80vh;
    padding: 4rem 0;
    background-color: #f8f9ff !important;
    background: #f8f9ff !important;
}

.auth-card {
    background: white;
    border-radius: 20px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
    overflow: hidden;
    border: 1px solid #e9ecef;
}

.auth-header {
    background: #584CF4;
    padding: 3rem 2rem 2rem;
    text-align: center;
    color: white;
}

.auth-icon {
    width: 80px;
    height: 80px;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 1.5rem;
    backdrop-filter: blur(10px);
}

.auth-icon i {
    font-size: 2rem;
}

.auth-header h2 {
    font-size: 1.8rem;
    font-weight: 700;
    margin-bottom: 0.5rem;
}

.auth-header p {
    opacity: 0.9;
    font-size: 1rem;
    font-weight: 400;
    margin-bottom: 0;
}

.auth-body {
    padding: 2.5rem 2rem;
}

.form-group {
    margin-bottom: 1.5rem;
}

.form-label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 600;
    color: #2c2c2c;
}

.input-wrapper {
    position: relative;
}

.input-wrapper i {
    position: absolute;
    left: 1rem;
    top: 50%;
    transform: translateY(-50%);
    color: #6c757d;
    font-size: 1.1rem;
}

.form-control {
    width: 100%;
    padding: 1rem 1rem 1rem 3rem;
    border: 2px solid #e9ecef;
    border-radius: 12px;
    font-size: 1rem;
    background: #f8f9fa;
    transition: all 0.3s ease;
}

.form-control:focus {
    outline: none;
    border-color: #584CF4;
    background: white;
    box-shadow: 0 0 0 3px rgba(88, 76, 244, 0.1);
}

.form-control[readonly] {
    background-color: #f8f9fa;
    opacity: 0.7;
}

.btn-primary {
    background: #584CF4;
    border: none;
    border-radius: 12px;
    padding: 1rem;
    font-size: 1rem;
    font-weight: 600;
    color: white;
    transition: all 0.3s ease;
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(88, 76, 244, 0.3);
    background: #4a3bc7;
}

.alert {
    padding: 1rem;
    border-radius: 12px;
    margin-bottom: 1.5rem;
    font-size: 0.9rem;
    border: none;
}

.alert-success {
    background: #d4edda;
    color: #155724;
}

.alert-danger {
    background: #f8d7da;
    color: #721c24;
}

.auth-footer {
    margin-top: 2rem;
    padding-top: 1.5rem;
    border-top: 1px solid #e9ecef;
}

.auth-footer p {
    margin: 0;
    color: #6c757d;
}

.auth-link {
    color: #584CF4;
    text-decoration: none;
    font-weight: 600;
    transition: color 0.3s ease;
}

.auth-link:hover {
    color: #4a3bc7;
    text-decoration: none;
}

.password-strength {
    margin-top: 0.5rem;
    font-size: 0.8rem;
    font-weight: 500;
    text-align: left;
}

.password-strength.weak {
    color: #dc3545;
}

.password-strength.medium {
    color: #ffc107;
}

.password-strength.strong {
    color: #28a745;
}

@media (max-width: 768px) {
    .auth-page {
        padding: 2rem 0;
    }

    .auth-header {
        padding: 2rem 1.5rem 1.5rem;
    }

    .auth-body {
        padding: 2rem 1.5rem;
    }

    .auth-icon {
        width: 60px;
        height: 60px;
    }

    .auth-icon i {
        font-size: 1.5rem;
    }

    .auth-header h2 {
        font-size: 1.5rem;
    }
}
</style>

<script>
document.getElementById('password').addEventListener('input', function() {
    const password = this.value;
    const strengthIndicator = document.getElementById('password-strength');

    if (password.length === 0) {
        strengthIndicator.textContent = '';
        strengthIndicator.className = 'password-strength';
        return;
    }

    let strength = 0;
    if (password.length >= 8) strength++;
    if (/[a-z]/.test(password)) strength++;
    if (/[A-Z]/.test(password)) strength++;
    if (/[0-9]/.test(password)) strength++;
    if (/[^A-Za-z0-9]/.test(password)) strength++;

    if (strength < 2) {
        strengthIndicator.textContent = 'Weak password';
        strengthIndicator.className = 'password-strength weak';
    } else if (strength < 4) {
        strengthIndicator.textContent = 'Medium password';
        strengthIndicator.className = 'password-strength medium';
    } else {
        strengthIndicator.textContent = 'Strong password';
        strengthIndicator.className = 'password-strength strong';
    }
});
</script>
@endsection
