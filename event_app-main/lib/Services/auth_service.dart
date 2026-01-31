import 'dart:convert';
import 'package:event_app/MVVM/body_model/user_list_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "https://eventgo-live.com/api/v1";

  /// 🔐 Helper to get stored token for authenticated requests
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ✅ Safe JSON decoder with fallback
  static Map<String, dynamic> _safeJsonDecode(String source) {
    try {
      return jsonDecode(source);
    } catch (e) {
      print('❌ JSON Decode Error: $e');
      print('🔴 Raw Response: $source');
      return {'message': 'Invalid response format', 'raw': source};
    }
  }

  /// 🔑 Login User
  static Future<Map<String, dynamic>> loginUser(
      String email, String password, bool rememberMe) async {
    var url = Uri.parse('$baseUrl/login');

    var response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'email': email,
        'password': password,
        'remember_me': rememberMe.toString(),
      },
    );

    print('🔵 Login Status: ${response.statusCode}');
    print('🔵 Login Response: ${response.body}');

    var decodedResponse = _safeJsonDecode(response.body);
    decodedResponse['statusCode'] = response.statusCode;
    return decodedResponse;
  }

  /// 📝 Register User
  static Future<Map<String, dynamic>> registerUser(
      String name, String email, String password, String confirmPassword) async {
    var url = Uri.parse('$baseUrl/register');

    var response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );

    print('🔵 Register Status: ${response.statusCode}');
    print('🔵 Register Response: ${response.body}');

    var decodedResponse = _safeJsonDecode(response.body);
    decodedResponse['statusCode'] = response.statusCode;
    return decodedResponse;
  }

  /// 📧 Verify Email
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    var url = Uri.parse("$baseUrl/verify-email");

    var response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        "email": email,
        "verificationCode": verificationCode,
      },
    );

    print("🔵 Verify Email Status: ${response.statusCode}");
    print("🔵 Verify Email Response: ${response.body}");

    var decodedResponse = _safeJsonDecode(response.body);
    decodedResponse['statusCode'] = response.statusCode;
    return decodedResponse;
  }

  /// 🔑 Forgot Password
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    var url = Uri.parse("$baseUrl/forgot-password");

    var response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'email': email},
    );

    print("🔵 Forgot Password Status: ${response.statusCode}");
    print("🔵 Forgot Password Response: ${response.body}");

    var decodedResponse = _safeJsonDecode(response.body);
    decodedResponse['statusCode'] = response.statusCode;
    return decodedResponse;
  }

  /// 🔐 Verify Password OTP
  static Future<Map<String, dynamic>> verifyPasswordOtp({
    required String email,
    required String otp,
  }) async {
    var url = Uri.parse("$baseUrl/verify-password-otp");

    var response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        "email": email,
        "otp": otp,
      },
    );

    print("🔵 Verify OTP Status: ${response.statusCode}");
    print("🔵 Verify OTP Response: ${response.body}");

    var decodedResponse = _safeJsonDecode(response.body);
    decodedResponse['statusCode'] = response.statusCode;
    return decodedResponse;
  }

  /// 🔒 Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    var url = Uri.parse("$baseUrl/reset-password");

    var response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
      },
    );

    print("🔵 Reset Password Status: ${response.statusCode}");
    print("🔵 Reset Password Response: ${response.body}");

    var decodedResponse = _safeJsonDecode(response.body);
    decodedResponse['statusCode'] = response.statusCode;
    return decodedResponse;
  }

  /// 👥 Search Users (Public - no auth, for guests)
  static Future<UserListModel> searchUsers(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return UserListModel(success: true, data: [], message: 'Query too short', count: 0);
    }
    final uri = Uri.parse('$baseUrl/users/search').replace(queryParameters: {'q': trimmed});
    var response = await http.get(uri, headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) {
      return UserListModel.fromJson(json.decode(response.body));
    }
    return UserListModel(success: false, data: [], message: 'Search failed', count: 0);
  }

  /// 👥 Fetch Users (Authenticated)
  static Future<UserListModel> fetchUsers() async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/fetchusers');

    var response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('🔵 Fetch Users Status: ${response.statusCode}');
    print('🔵 Fetch Users Response: ${response.body}');

    if (response.statusCode == 200) {
      return UserListModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch users: ${response.body}');
    }
  }

  /// 📧 Resend Verification Email
  static Future<Map<String, dynamic>> resendVerificationEmail({
    required String email,
  }) async {
    var url = Uri.parse('$baseUrl/resend-verification');

    var response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'email': email},
    );

    print('🔵 Resend Verification Status: ${response.statusCode}');
    print('🔵 Resend Verification Response: ${response.body}');

    var decodedResponse = _safeJsonDecode(response.body);
    decodedResponse['statusCode'] = response.statusCode;
    return decodedResponse;
  }

  /// 🚪 Logout User
  static Future<Map<String, dynamic>> logoutUser() async {
    final token = await _getToken();
    var url = Uri.parse('$baseUrl/logout');

    var response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('🔵 Logout Status: ${response.statusCode}');
    print('🔵 Logout Response: ${response.body}');

    var decodedResponse = _safeJsonDecode(response.body);
    decodedResponse['statusCode'] = response.statusCode;

    // Clear token from storage on successful logout
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }

    return decodedResponse;
  }

  /// 🗑️ Delete User Account
  static Future<Map<String, dynamic>> deleteAccount() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication required. Please log in again.');
    }

    var url = Uri.parse('$baseUrl/user/delete');

    var response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('🔴 Delete Account Status: ${response.statusCode}');
    print('🔴 Delete Account Response: ${response.body}');

    var decodedResponse = _safeJsonDecode(response.body);
    decodedResponse['statusCode'] = response.statusCode;

    // Clear token and all user data from storage on successful deletion
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all stored data
    }

    return decodedResponse;
  }

}
