import 'dart:io';
import 'package:event_app/MVVM/View/bottombar/bottom_navigation_bar.dart';
import 'package:event_app/MVVM/body_model/ads_model.dart';
import 'package:event_app/MVVM/body_model/ad_detail_model.dart';
import 'package:event_app/Services/ad_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdViewModel extends GetxController {
  final AdService _adService = AdService();

  /// 🔷 Observables
  var ads = <AdsModel>[].obs;
  var adDetail = AdsDetailModel().obs;
  var selectedImage = Rx<File?>(null);
  var error = ''.obs;
  var isLoading = false.obs;

  /// 🔷 Initialize on controller creation
  @override
  void onInit() {
    super.onInit();

    /// If arguments indicate refresh, re-fetch ads
    if (Get.arguments != null && Get.arguments['refresh'] == true) {
      fetchAds();
    }
  }

  /// 🔷 Image Picker function
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedImage.value = File(picked.path);
    }
  }

  /// 🔷 Upload a new ad
  Future<void> uploadAd({
    required String title,
    required String description,
    required String targetAmount,
  }) async {
    // Validate image
    if (selectedImage.value == null) {
      Get.snackbar("Image Missing", "Please select an image.");
      return;
    }

    try {
      isLoading.value = true;

      final result = await _adService.addAd(
        title: title,
        description: description,
        targetAmount: targetAmount,
        imageFile: selectedImage.value!,
      );

      if (result['success']) {
        Get.snackbar("Success", "Ad uploaded successfully");

        // Navigate to bottom nav bar (adjust initial index as needed)
        Get.offAll(() => BottomNavBar(initialIndex: 2));

        // Refresh ads list after uploading
        await fetchAds();

        // Optionally clear inputs and image after upload
        selectedImage.value = null;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔷 Fetch all ads
  Future<void> fetchAds() async {
    try {
      isLoading.value = true;
      ads.value = await _adService.fetchAds();
      error.value = '';
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔷 Fetch details of a specific ad
  Future<void> getAdDetail(int? adId) async {
    if (adId == null) {
      error.value = 'Ad ID is null';
      return;
    }

    try {
      isLoading.value = true;
      adDetail.value = await _adService.fetchAdDetail(adId);
      error.value = '';
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
