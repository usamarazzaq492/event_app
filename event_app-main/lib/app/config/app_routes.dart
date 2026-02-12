import 'package:event_app/MVVM/View/Auth/sign_in.dart';
import 'package:event_app/MVVM/View/Auth/sign_up.dart';
import 'package:event_app/MVVM/View/Auth/terms_screen.dart';
import 'package:event_app/MVVM/View/HomeScreen/home_screen.dart';
import 'package:event_app/MVVM/View/Onboarding/onboarding_screen.dart';
import 'package:event_app/MVVM/View/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';

import '../../MVVM/View/AccountSetup/otp_screen.dart';
import '../../MVVM/View/AccountSetup/password_setting.dart';
import '../../MVVM/View/ForgotPAssword/forgot_password.dart';
import '../../MVVM/View/ProfileScreen/profile_screen.dart';
import '../../MVVM/View/splash/splash_screen.dart';
import '../../MVVM/View/bottombar/bottom_navigation_bar.dart';
import 'app_pages.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Uri.parse(settings.name ?? '');

    // if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'post_view_screen') {
    //   final contentId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
    //   if (contentId != null) {
    //     return MaterialPageRoute(
    //       builder: (_) => PostViewScreen(contentsId: contentId),
    //     );
    //   }
    // }

    // if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'user_profile_view') {
    //   final profileId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
    //   if (profileId != null) {
    //     return MaterialPageRoute(
    //       builder: (_) => OtherUserProfileScreen(userId: profileId),
    //     );
    //   }
    // }

    // Handle other routes
    switch (settings.name) {
      case RouteName.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteName.welcomScreen:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case RouteName.onboardScreen:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case RouteName.signupScreen:
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case RouteName.termsScreen:
        return MaterialPageRoute(builder: (_) => const TermsScreen());

      case RouteName.loginScreen:
        return MaterialPageRoute(builder: (_) => SigninScreen());

      case RouteName.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case RouteName.bottomNav:
        return MaterialPageRoute(builder: (_) => BottomNavBar(initialIndex: 0));
      case RouteName.otpScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OTPScreen(
            email: args['email'],
            message: args['message'],
          ),
        );
      case RouteName.password:
        return MaterialPageRoute(builder: (_) => PasswordSetting());
      case RouteName.forgotpassword:
        return MaterialPageRoute(builder: (_) => ForgotPassword());
      case RouteName.profileScreen:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
