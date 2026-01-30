import 'dart:convert';

import 'package:event_app/MVVM/View/AccountSetup/account_setup_screnn.dart';
import 'package:event_app/MVVM/View/AccountSetup/otp_screen.dart';
import 'package:event_app/MVVM/View/AccountSetup/verify_email.dart';
import 'package:event_app/MVVM/View/Auth/sign_in.dart';
import 'package:event_app/MVVM/View/AccountSetup/password_setting.dart';
import 'package:event_app/MVVM/body_model/login_model.dart';
import 'package:event_app/MVVM/body_model/user_list_model.dart';
import 'package:event_app/Services/auth_service.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_pages.dart';
import 'package:event_app/Services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthViewModel extends GetxController {
  // Reactive state variables
  final isLoading = false.obs;
  final user = Rxn<LoginModel>();
  final users = <Data>[].obs;
  final registeredEmail = ''.obs;

  // Form errors
  final nameError = ''.obs;
  final emailError = ''.obs;
  final passwordError = ''.obs;
  final confirmPasswordError = ''.obs;
  final error = ''.obs;

  final RxMap<String, dynamic> currentUser = RxMap<String, dynamic>();

  late final SharedPreferences _prefs;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    loadCurrentUser();
  }

  /// Clears all form errors
  void clearErrors() {
    nameError.value = '';
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
    error.value = '';
  }

  bool _validateEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool _validatePassword(String password) => password.length >= 6;

  void _handleApiError(dynamic e) {
    error.value = e.toString();
    Get.snackbar('Error', error.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP);
  }

  void _showSuccess(String message) {
    Get.snackbar('Success', message,
        backgroundColor: AppColors.blueColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP);
  }

  /// 🔐 Login with email and password
  Future<void> login(String email, String password) async {
    clearErrors();

    // Validation
    if (email.isEmpty) {
      emailError.value = "Email is required";
      return;
    }
    if (!_validateEmail(email)) {
      emailError.value = "Please enter a valid email";
      return;
    }
    if (password.isEmpty) {
      passwordError.value = "Password is required";
      return;
    }

    isLoading.value = true;

    try {
      final response = await AuthService.loginUser(email, password, true);

      if (response['message'] == 'Login successful') {
        final user = response['user'];
        await _prefs.setString('token', response['token']);
        await _prefs.setInt('userid', user['userId']);
        _showSuccess(response['message']);
        await _prefs.setString('user', jsonEncode(user));
        currentUser.value = user; // update observable
        // 🔷 OPTION A: If your login API returns full user data
        bool isProfileComplete = _isProfileComplete(user);

        if (isProfileComplete) {
          await fetchUsers();
          Get.offAllNamed(RouteName.bottomNav);
        } else {
          Get.offAll(() => AccountSetupScreen());
        }

        // 🔷 OPTION B: If login API does NOT return full user data
        // Uncomment below if needed and comment out Option A

        /*
      final profileResponse = await DataService.getUserProfile();
      if (profileResponse['statusCode'] == 200) {
        final userProfile = profileResponse['data'];
        bool isProfileComplete = _isProfileComplete(userProfile);

        if (isProfileComplete) {
          Get.offAllNamed(RouteName.home);
        } else {
          Get.offAll(() => AccountSetupScreen());
        }
      } else {
        _handleApiError('Failed to fetch profile');
      }
      */
      } else {
        _handleApiError(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      _handleApiError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      currentUser.value = jsonDecode(userData);
    } else {
      print("No user data found in prefs");
    }
  }

  bool _isProfileComplete(Map<String, dynamic> user) {
    return user['name'] != null &&
        user['name'].toString().isNotEmpty &&
        user['phoneNumber'] != null &&
        user['phoneNumber'].toString().isNotEmpty &&
        user['interests'] != null &&
        user['interests'].toString().isNotEmpty &&
        user['shortBio'] != null &&
        user['shortBio'].toString().isNotEmpty &&
        user['profileImageUrl'] != null &&
        user['profileImageUrl'].toString().isNotEmpty;
  }

  /// 📝 Register new user
  Future<void> signup(String name, String email, String password,
      String confirmPassword) async {
    clearErrors();

    if (name.isEmpty) nameError.value = "Name is required";
    if (email.isEmpty) {
      emailError.value = "Email is required";
    } else if (!_validateEmail(email)) {
      emailError.value = "Please enter a valid email";
    }
    if (password.isEmpty) {
      passwordError.value = "Password is required";
    } else if (!_validatePassword(password)) {
      passwordError.value = "Password must be at least 6 characters";
    }
    if (confirmPassword != password) {
      confirmPasswordError.value = "Passwords do not match";
    }

    if (nameError.isNotEmpty ||
        emailError.isNotEmpty ||
        passwordError.isNotEmpty ||
        confirmPasswordError.isNotEmpty) {
      return;
    }

    isLoading.value = true;

    try {
      final response = await AuthService.registerUser(
          name, email, password, confirmPassword);

      if (response['statusCode'] == 201) {
        await _prefs.setString('registered_email', email);
        _showSuccess(response['message']);
        Get.off(() => VerifyEmail());
      } else if (response['statusCode'] == 422) {
        final errors = response['errors'];
        nameError.value = errors['name']?.first ?? '';
        emailError.value = errors['email']?.first ?? '';
        passwordError.value = errors['password']?.first ?? '';
        confirmPasswordError.value =
            errors['password_confirmation']?.first ?? '';
        _handleApiError('Validation failed');
      } else {
        _handleApiError(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _handleApiError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Verify email with OTP
  Future<void> verifyEmail(String code) async {
    isLoading.value = true;
    clearErrors();

    try {
      final email = _prefs.getString('registered_email') ?? '';
      if (email.isEmpty) throw Exception('Email not found');

      final result =
          await AuthService.verifyEmail(email: email, verificationCode: code);

      if (result.containsKey('message')) {
        _showSuccess(result['message']);
        Get.offAll(() => SigninScreen());
      } else {
        throw Exception('Unknown response');
      }
    } catch (e) {
      _handleApiError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// 📧 Resend verification code
  Future<void> resendVerificationCode(String email) async {
    try {
      final result = await AuthService.resendVerificationEmail(email: email);
      if (result['statusCode'] == 200) {
        _showSuccess(result['message'] ?? 'Verification code has been resent');
      } else {
        throw Exception(result['message'] ?? 'Failed to resend code');
      }
    } catch (e) {
      _handleApiError(e);
    }
  }

  /// 🔑 Resend password reset code
  Future<void> resendPasswordResetCode(String email) async {
    try {
      final result = await AuthService.forgotPassword(email: email);
      if (result.containsKey('message')) {
        _showSuccess(result['message'] ?? 'OTP has been resent');
      } else {
        throw Exception('Failed to resend OTP');
      }
    } catch (e) {
      _handleApiError(e);
    }
  }

  /// 🔑 Forgot password
  Future<void> forgotPassword(String email) async {
    clearErrors();
    if (!_validateEmail(email)) {
      _handleApiError('Please enter a valid email');
      return;
    }

    isLoading.value = true;

    try {
      final result = await AuthService.forgotPassword(email: email);
      if (result.containsKey('message')) {
        await _prefs.setString('registered_email', email);
        Get.to(() => OTPScreen(email: email, message: result['message']));
      } else {
        throw Exception('Unexpected response');
      }
    } catch (e) {
      _handleApiError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔐 Verify password reset OTP
  Future<void> verifyPasswordOtp(String otp) async {
    isLoading.value = true;
    clearErrors();

    try {
      final email = _prefs.getString('registered_email') ?? '';
      if (email.isEmpty) throw Exception('Email not found');

      final result =
          await AuthService.verifyPasswordOtp(email: email, otp: otp);

      if (result.containsKey('message')) {
        Get.to(() => PasswordSetting());
        Future.delayed(Duration(milliseconds: 300), () {
          _showSuccess(result['message'] ?? "OTP Verified");
        });
      } else {
        throw Exception('Unexpected response');
      }
    } catch (e) {
      _handleApiError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔒 Reset password
  Future<void> resetPassword(
      {required String password, required String confirmPassword}) async {
    clearErrors();

    if (!_validatePassword(password)) {
      _handleApiError("Password must be at least 6 characters");
      return;
    }
    if (password != confirmPassword) {
      _handleApiError("Passwords do not match");
      return;
    }

    isLoading.value = true;

    try {
      final email = _prefs.getString('registered_email') ?? '';
      if (email.isEmpty) throw Exception("Email not found");

      final result = await AuthService.resetPassword(
        email: email,
        password: password,
        passwordConfirmation: confirmPassword,
      );

      if (result.containsKey('message')) {
        _showSuccess(result['message']);
        Get.offAll(() => SigninScreen());
      } else {
        throw Exception("Unexpected response from server");
      }
    } catch (e) {
      _handleApiError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔎 Check login status at app start
  Future<void> checkLoginStatus() async {
    final userService = UserService();

    try {
      final profile = await userService.fetchProfile();
      final user = profile.data;

      if (user == null) {
        Get.offAllNamed(RouteName.loginScreen);
        return;
      }

      bool isProfileComplete = (user.name != null && user.name!.isNotEmpty) &&
          (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) &&
          (user.shortBio != null && user.shortBio!.isNotEmpty) &&
          (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) &&
          (user.interests != null && user.interests!.isNotEmpty);

      if (isProfileComplete) {
        Get.offAllNamed(RouteName.bottomNav); // home tab by default
      } else {
        Get.offAll(() =>
            AccountSetupScreen()); // ✅ Navigate to Account Setup if profile incomplete
      }
    } catch (e) {
      print('Error in checkLoginStatus: $e');
      Get.offAllNamed(RouteName.loginScreen);
    }
  }

  /// 👥 Fetch users list
  Future<void> fetchUsers() async {
    isLoading.value = true;

    try {
      final response = await AuthService.fetchUsers();
      users.assignAll(response.data ?? []);
    } catch (e) {
      _handleApiError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout User
  Future<void> logoutUser() async {
    try {
      isLoading.value = true;
      final response = await AuthService.logoutUser();
      if (response['statusCode'] == 200) {
        Get.offAll(() => SigninScreen()); // Navigate to login screen
        Get.snackbar(
          "Success",
          "Logged out successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.blueColor, // ✅ Purple for success
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Logout failed",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red, // ✅ Red for error
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red, // ✅ Red for exception errors
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🗑️ Delete User Account
  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      final response = await AuthService.deleteAccount();
      if (response['statusCode'] == 200) {
        // Show success message first
        Get.snackbar(
          "Account Deleted",
          response['message'] ?? "Your account has been permanently deleted",
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.blueColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Wait a moment for snackbar to show, then navigate
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Navigate to login screen after successful deletion
        // Use Get.offAllNamed to avoid Navigator history issues
        Get.offAllNamed(RouteName.loginScreen);
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Failed to delete account",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred while deleting your account: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
    // Dispose resources if needed
  }
}
