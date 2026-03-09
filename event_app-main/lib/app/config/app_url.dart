class AppUrl {
  static const String baseUrl = "https://eventgo-live.com/api/v1";

  // Auth Endpoints
  static const String login = "$baseUrl/login";
  static const String register = "$baseUrl/register";
  static const String verifyEmail = "$baseUrl/verify-email";
  static const String forgotPassword = "$baseUrl/forgot-password";
  static const String verifyPasswordOtp = "$baseUrl/verify-password-otp";
  static const String resetPassword = "$baseUrl/reset-password";
  static const String resendVerification = "$baseUrl/resend-verification";
  static const String appleAuth = "$baseUrl/auth/apple";
  static const String logout = "$baseUrl/logout";
  static const String deleteAccount = "$baseUrl/user/delete";
  static const String fetchUsers = "$baseUrl/fetchusers";
  static const String searchUsers = "$baseUrl/users/search";

  // Event Endpoints
  static const String events = "$baseUrl/events";
  static const String addEvent = "$events/add";
  static const String myEvents = "$events/my";
  static const String timelineEvents = "$events/timeline";

  // Profile Endpoints
  static const String userProfile = "$baseUrl/user";
  static const String updateUserProfile = "$userProfile/update";

  // Ad Endpoints
  static const String ads = "$baseUrl/ads";
  static const String addAd = "$ads/add";

  // Helper to get image URL
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return "https://eventgo-live.com/$path";
  }
}
