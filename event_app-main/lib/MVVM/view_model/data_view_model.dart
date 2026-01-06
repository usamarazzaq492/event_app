import 'dart:io';
import 'package:event_app/MVVM/View/bottombar/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Services/data_service.dart';
import '../../Services/profile_service.dart';
import '../../app/config/app_colors.dart';
import '../body_model/profile_model.dart';

class DataViewModel extends GetxController {
  var isFollowing = false.obs;
  var followersCount = 0.obs;
  var isLoading = false.obs;

  // Use your ProfileModel instead of a Map
  var user = ProfileModel().obs;

  /// Initialize from profile data
  void initializeFollowState(bool following, int count) {
    isFollowing.value = following;
    followersCount.value = count;
  }

  /// Toggle follow status
  Future<void> toggleFollow(int userId) async {
    final prevState = isFollowing.value;
    final prevCount = followersCount.value;

    // 🔷 Optimistic update
    isFollowing.value = !prevState;
    followersCount.value = prevState ? (prevCount - 1) : (prevCount + 1);

    try {
      // 🔷 Call API to actually follow/unfollow
      final response = await DataService.toggleFollow(
        userId: userId,
        isFollowing: prevState,
      );
      
      print('Follow API Response: $response');
      
      // Update follower count from API response if available
      if (response['followersCount'] != null) {
        followersCount.value = response['followersCount'] as int;
      }
      
      // Show success message
      Get.snackbar(
        prevState ? 'Unfollowed' : 'Followed',
        prevState ? 'You unfollowed this user' : 'You are now following this user',
        backgroundColor: AppColors.blueColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // 🔴 Revert changes on failure
      isFollowing.value = prevState;
      followersCount.value = prevCount;
      print('Follow toggle failed: $e');
      Get.snackbar(
        'Error',
        'Failed to ${prevState ? 'unfollow' : 'follow'} user: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Update profile
  Future<void> updateProfile({
    required String name,
    required String shortBio,
    required String interests,
    required File profileImage,
    required String phoneNumber,
  }) async {
    try {
      isLoading.value = true;

      final response = await DataService.updateUserProfile(
        name: name,
        shortBio: shortBio,
        interests: interests,
        profileImage: profileImage,
        phoneNumber: phoneNumber,
      );

      if (response["data"] != null) {
        // Convert the response data to ProfileModel
        user.value = ProfileModel.fromJson(response["data"]);
      }

      Get.snackbar(
        "Success",
        response["message"] ?? "Profile updated successfully.",
        backgroundColor: AppColors.blueColor,
        colorText: AppColors.whiteColor,
      );
      Get.to(() => BottomNavBar());
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: AppColors.whiteColor,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch user profile from API
  Future<void> fetchUserProfile() async {
    final userService = UserService();
    try {
      isLoading.value = true;
      final profile = await userService.fetchProfile();
      user.value = profile; // Directly assign the ProfileModel object
    } catch (e) {
      print("Error fetching user profile: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch profile",
        backgroundColor: Colors.red,
        colorText: AppColors.whiteColor,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
