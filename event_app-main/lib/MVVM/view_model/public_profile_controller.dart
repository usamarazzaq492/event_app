import 'dart:io';
import 'package:event_app/MVVM/body_model/profile_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Services/profile_service.dart';
import '../body_model/ViewProfileModel.dart';

class PublicProfileController extends GetxController {
  final Rxn<ViewPublicProfileModel> profile = Rxn<ViewPublicProfileModel>();
  final Rxn<ProfileModel> userProfile = Rxn<ProfileModel>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile(); // Loads current logged-in user's profile at initialization
  }

  @override
  void onReady() {
    super.onReady();
    fetchUserProfile(); // ✅ Refresh profile every time this controller's view comes into focus
  }

  /// ✅ Fetch public profile by userId
  Future<void> loadPublicProfile(int? id) async {
    if (id == null) {
      error.value = 'Invalid user ID';
      return;
    }

    try {
      isLoading.value = true;
      error.value = ''; // Clear previous errors
      
      // Force fresh fetch by clearing cached profile if ID changed
      if (profile.value?.userId != id) {
        profile.value = null;
      }
      
      final result = await _userService.fetchPublicProfile(id);
      if (result != null) {
        profile.value = result;
        error.value = '';
        print('🔷 Profile loaded successfully - isFollowing: ${result.isFollowing}, followersCount: ${result.followersCount}');
      } else {
        error.value = 'Failed to load profile';
        print('❌ Profile result is null');
      }
    } catch (e) {
      error.value = e.toString();
      print('❌ Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Fetch current logged-in user's profile
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      error.value = ''; // Clear any previous errors
      final result = await _userService.fetchProfile();
      
      // Validate that we got valid data
      if (result.data == null) {
        error.value = 'Failed to load profile';
        userProfile.value = null;
      } else {
        userProfile.value = result;
        error.value = ''; // Clear error on success
        print("Fetched user profile: ${userProfile.value?.data?.name}");
      }
    } catch (e) {
      // Extract user-friendly error message
      String errorMessage = 'Failed to load profile';
      if (e.toString().contains('Exception: ')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      error.value = errorMessage;
      userProfile.value = null;
      print("Error fetching user profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Edit current logged-in user's profile
  Future<void> editProfile({
    String? name,
    String? shortBio,
    List<String>? interests,
    File? profileImage,
    String? phoneNumber,
  }) async {
    try {
      isLoading.value = true;

      final response = await _userService.updateUserProfile(
        name: name,
        shortBio: shortBio,
        interests: interests,
        profileImage: profileImage,
        phoneNumber: phoneNumber,
      );

      if (response["user"] != null) {
        userProfile.value = ProfileModel.fromJson(response["user"]);
        Get.snackbar(
          "Success",
          response["message"] ?? "Profile updated successfully.",
          backgroundColor: AppColors.blueColor,
          colorText: Colors.white,
        );
        // Refresh after update
        await fetchUserProfile();
      } else {
        Get.snackbar(
          "Error",
          "Failed to update profile",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
