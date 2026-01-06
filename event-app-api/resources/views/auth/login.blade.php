@extends('layouts.app')

@section('title', 'Login - EventGo')

@section('content')
<script>
    window.Laravel = {!! json_encode([
        'csrfToken' => csrf_token(),
    ]) !!};
</script>
<style>
:root {
  --primary-color: #584CF4;
  --secondary-color: #ff9500;
  --black: #000000;
  --white: #ffffff;
  --gray: #efefef;
  --gray-2: #757575;
}

@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@200;300;400;500;600&display=swap');

* {
  font-family: 'Poppins', sans-serif;
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body {
  height: 100vh;
  overflow: hidden;
}

.auth-container {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
}

.auth-row {
  display: flex;
  flex-wrap: wrap;
  height: 100vh;
}

.auth-col {
  width: 50%;
}

.align-items-center {
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
}

.form-wrapper {
  width: 100%;
  max-width: 28rem;
}

.auth-form {
  padding: 1rem;
  background-color: var(--white);
  border-radius: 1.5rem;
  width: 100%;
  box-shadow: rgba(0,0,0,0.35) 0px 5px 15px;
  transform: scale(0);
  transition: .5s ease-in-out;
  transition-delay: 1s;
}

.input-group {
  position: relative;
  width: 100%;
  margin: 1rem 0;
}

.input-group i {
  position: absolute;
  top: 50%;
  left: 1rem;
  transform: translateY(-50%);
  font-size: 1.4rem;
  color: var(--gray-2);
}

.input-group input {
  width: 100%;
  padding: 1rem 3rem;
  font-size: 1rem;
  background-color: var(--gray);
  border-radius: .5rem;
  border: 0.125rem solid var(--white);
  outline: none;
}

.input-group input:focus {
  border: 0.125rem solid var(--primary-color);
}

.auth-form button {
  cursor: pointer;
  width: 100%;
  padding: .6rem 0;
  border-radius: .5rem;
  border: none;
  background-color: var(--primary-color);
  color: var(--white);
  font-size: 1.2rem;
  outline: none;
}

.auth-form p {
  margin: 1rem 0;
  font-size: .7rem;
}

.flex-col {
  flex-direction: column;
}

.pointer {
  cursor: pointer;
  color: var(--primary-color);
}

.auth-container.sign-in .auth-form.sign-in,
.auth-container.sign-up .auth-form.sign-up {
  transform: scale(1);
}

.content-row {
  position: absolute;
  top: 0;
  left: 0;
  pointer-events: none;
  z-index: 6;
  width: 100%;
}

.text {
  margin: 4rem;
  color: var(--white);
}

.text h2 {
  color: var(--white);
  font-size: 3.5rem;
  font-weight: 800;
  margin: 2rem 0;
  transition: 1s ease-in-out;
}

    .text.sign-in h2,
    .text.sign-in p {
      transform: translateX(-250%);
    }
    .text.sign-up h2,
    .text.sign-up p {
      transform: translateX(250%);
    }

    .auth-container.sign-in .text.sign-in h2,
    .auth-container.sign-in .text.sign-in p,
    .auth-container.sign-up .text.sign-up h2,
    .auth-container.sign-up .text.sign-up p {
      transform: translateX(0);
    }

/* Background */
.auth-container::before {
  content: "";
  position: absolute;
  top: 0;
  right: 0;
  height: 100vh;
  width: 300vw;
  transform: translate(35%, 0);
  background-color: var(--primary-color);
  transition: 1s ease-in-out;
  z-index: 6;
  box-shadow: rgba(0,0,0,0.35) 0px 5px 15px;
  border-bottom-right-radius: max(50vw, 50vh);
  border-top-left-radius: max(50vw, 50vh);
}

.auth-container.sign-in::before {
  transform: translate(0,0);
  right: 50%;
}

.auth-container.sign-up::before {
  transform: translate(100%,0);
  right: 50%;
}

/* Responsive */
@media only screen and (max-width: 425px) {
  .auth-container::before,
  .auth-container.sign-in::before,
  .auth-container.sign-up::before {
    height: 100vh;
    border-bottom-right-radius: 0;
    border-top-left-radius: 0;
    z-index: 0;
    transform: none;
    right: 0;
  }

  .auth-col {
    width: 100%;
    position: absolute;
    padding: 2rem;
    background-color: var(--white);
    border-top-left-radius: 2rem;
    border-top-right-radius: 2rem;
    transform: translateY(100%);
    transition: 1s ease-in-out;
  }

  .auth-row {
    align-items: flex-end;
    justify-content: flex-end;
  }

  .auth-form {
    box-shadow: none;
  }

  .text {
    margin: 0;
  }

  .text h2 {
    margin: .5rem;
    font-size: 2rem;
  }
}
</style>

<div id="container" class="auth-container">
    <!-- FORM SECTION -->
    <div class="auth-row">
        <!-- SIGN UP -->
        <div class="auth-col align-items-center flex-col sign-up">
            <div class="form-wrapper align-items-center">
                <form class="auth-form sign-up" method="POST" action="{{ route('register') }}" id="registerForm">
                    @csrf
                    <input type="hidden" name="_token" value="{{ csrf_token() }}">
                    <div class="input-group">
                        <i class='bi bi-person'></i>
                        <input type="text" name="name" placeholder="Full Name" value="{{ old('name') }}" required>
                    </div>
                    <div class="input-group">
                        <i class='bi bi-envelope'></i>
                        <input type="email" name="email" placeholder="Email" value="{{ old('email') }}" required>
                    </div>
                    <div class="input-group">
                        <i class='bi bi-phone'></i>
                        <input type="tel" name="phone" placeholder="Phone (Optional)" value="{{ old('phone') }}">
                    </div>
                    <div class="input-group">
                        <i class='bi bi-lock'></i>
                        <input type="password" name="password" placeholder="Password (min 8 chars, uppercase, lowercase, number, special char)" required>
                    </div>
                    <div class="input-group">
                        <i class='bi bi-lock-fill'></i>
                        <input type="password" name="password_confirmation" placeholder="Confirm password" required>
                    </div>

                    <!-- Terms & Conditions checkbox (replace text later) -->
                    <div class="input-group" style="margin-top: 0.5rem; text-align: left;">
                        <label
  style="display:inline-flex; align-items:center; font-size:0.75rem; color:#555; cursor:pointer; white-space:nowrap;"
>
  <input
    type="checkbox"
    name="terms"
    value="1"
    required
    style="margin-right:0.5rem;"
  >
  <span>
    I agree to the
    <a href="{{ route('terms') }}" target="_blank"
       style="color: var(--primary-color); text-decoration: underline;">
      Terms &amp; Conditions
    </a>.
  </span>
</label>
                        @error('terms')
                            <div style="color: red; font-size: 0.7rem; margin-top: 0.25rem;">{{ $message }}</div>
                        @enderror
                    </div>

                    <div style="font-size: 0.75rem; color: #666; margin-bottom: 1rem; padding: 0.5rem; background: #f8f9ff; border-radius: 5px;">
                        <strong>Password Requirements:</strong><br>
                        • At least 8 characters<br>
                        • Uppercase letter (A-Z)<br>
                        • Lowercase letter (a-z)<br>
                        • Number (0-9)<br>
                        • Special character (@$!%*#?&)
                    </div>

                    @if ($errors->any())
                        <div style="color: red; font-size: 0.8rem; margin: 0.5rem 0;">
                            @foreach ($errors->all() as $error)
                                <div>{{ $error }}</div>
                            @endforeach
                        </div>
                    @endif

                    <button type="submit">Sign up</button>
                    <p>
                        <span>Already have an account?</span>
                        <b onclick="toggle()" class="pointer">Sign in here</b>
                    </p>
                </form>
            </div>
        </div>
        <!-- END SIGN UP -->

        <!-- SIGN IN -->
        <div class="auth-col align-items-center flex-col sign-in">
            <div class="form-wrapper align-items-center">
                <form class="auth-form sign-in" method="POST" action="{{ route('login') }}">
                    @csrf
                    <input type="hidden" name="_token" value="{{ csrf_token() }}">
                    @if(request()->has('redirect'))
                        <input type="hidden" name="redirect" value="{{ request()->get('redirect') }}">
                    @endif
                    <div class="input-group">
                        <i class='bi bi-envelope'></i>
                        <input type="email" name="email" placeholder="Email" value="{{ old('email') }}" required>
                    </div>
                    <div class="input-group">
                        <i class='bi bi-lock'></i>
                        <input type="password" name="password" placeholder="Password" required>
                    </div>

                    @if ($errors->any())
                        <div style="color: red; font-size: 0.8rem; margin: 0.5rem 0;">
                            @foreach ($errors->all() as $error)
                                <div>{{ $error }}</div>
                            @endforeach
                        </div>
                    @endif

                    <button type="submit">Sign in</button>
                    <p><a href="{{ route('password.request') }}" style="color: var(--primary-color); text-decoration: none;"><b>Forgot password?</b></a></p>
                    <p>
                        <span>Don't have an account?</span>
                        <b onclick="toggle()" class="pointer">Sign up here</b>
                    </p>
                </form>
            </div>
        </div>
        <!-- END SIGN IN -->
    </div>
    <!-- END FORM SECTION -->

    <!-- CONTENT SECTION -->
    <div class="auth-row content-row">
        <!-- SIGN IN CONTENT -->
        <div class="auth-col align-items-center flex-col">
            <div class="text sign-in">
                <h2>Welcome Back</h2>
                <p style="color: var(--white); font-size: 1.1rem; margin-top: 1rem;">Sign in to continue your journey with EventGo and discover amazing events.</p>
            </div>
        </div>
        <!-- END SIGN IN CONTENT -->

        <!-- SIGN UP CONTENT -->
        <div class="auth-col align-items-center flex-col">
            <div class="text sign-up">
                <h2>Join EventGo</h2>
                <p style="color: var(--white); font-size: 1.1rem; margin-top: 1rem;">Create your account to start exploring and booking events in your area.</p>
            </div>
        </div>
        <!-- END SIGN UP CONTENT -->
    </div>
    <!-- END CONTENT SECTION -->
</div>

<script>
let container = document.getElementById('container');

function toggle() {
  container.classList.toggle('sign-in');
  container.classList.toggle('sign-up');
}

setTimeout(() => {
  // Check if we're on the register route
  const currentPath = window.location.pathname;
  if (currentPath.includes('register')) {
    container.classList.add('sign-up');
  } else {
    container.classList.add('sign-in');
  }
}, 200);

// Handle registration form submission with animation
document.getElementById('registerForm').addEventListener('submit', function(e) {
    const submitBtn = this.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;

    // Show loading state
    submitBtn.innerHTML = '<i class="bi bi-hourglass-split"></i> Creating Account...';
    submitBtn.disabled = true;

    // Add a small delay to show the loading state
    setTimeout(() => {
        // Let the form submit naturally
    }, 100);
});

// Registration success celebration
document.addEventListener('DOMContentLoaded', function() {
    @if(session('success') && str_contains(session('success'), 'Welcome to EventGo'))
        // Show celebration animation for successful registration
        setTimeout(() => {
            // Create confetti effect
            createConfetti();

            // Show success message
            if (window.toastNotification) {
                window.toastNotification.success('🎉 Welcome to EventGo! Your account has been created successfully!');
            }
        }, 500);
    @endif
});

function createConfetti() {
    const colors = ['#584CF4', '#ff9500', '#22c55e', '#ef4444', '#f59e0b', '#8b5cf6'];

    for (let i = 0; i < 50; i++) {
        setTimeout(() => {
            const confetti = document.createElement('div');
            confetti.style.position = 'fixed';
            confetti.style.left = Math.random() * 100 + 'vw';
            confetti.style.top = '-10px';
            confetti.style.width = '10px';
            confetti.style.height = '10px';
            confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
            confetti.style.borderRadius = '50%';
            confetti.style.pointerEvents = 'none';
            confetti.style.zIndex = '10000';
            confetti.style.animation = `fall ${Math.random() * 3 + 2}s linear forwards`;

            document.body.appendChild(confetti);

            setTimeout(() => {
                confetti.remove();
            }, 5000);
        }, i * 50);
    }

    // Add CSS for falling animation
    if (!document.getElementById('confetti-style')) {
        const style = document.createElement('style');
        style.id = 'confetti-style';
        style.textContent = `
            @keyframes fall {
                to {
                    transform: translateY(100vh) rotate(360deg);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);
    }
}
</script>
@endsection
