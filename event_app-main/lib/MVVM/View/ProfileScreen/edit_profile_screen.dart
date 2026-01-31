import 'dart:io';
import 'package:event_app/MVVM/view_model/public_profile_controller.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/Widget/input_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import '../../../app/config/app_text_style.dart';
import '../../../utils/form_validation_utils.dart';
import '../../../utils/haptic_utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final PublicProfileController profileController =
      Get.put(PublicProfileController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode interestFocusNode = FocusNode();
  final FocusNode aboutFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();

  String? nameError;
  String? phoneError;
  File? profileImage;
  String? existingImageUrl;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  /// Prefill user data from controller
  void fetchProfileData() {
    final profile = profileController.userProfile.value?.data;
    if (profile != null) {
      nameController.text = profile.name ?? '';
      interestController.text = (profile.interests ?? []).join(', ');
      aboutController.text = profile.shortBio ?? '';
      phoneController.text = profile.phoneNumber ?? '';
      existingImageUrl = profile.profileImageUrl != null
          ? 'https://eventgo-live.com/${profile.profileImageUrl}'
          : null;
    }
  }

  /// Pick profile image
  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  /// Validate input fields
  bool validateInputs() {
    bool isValid = true;
    setState(() {
      nameError = null;
      phoneError = null;
    });

    if (nameController.text.trim().isEmpty) {
      nameError = "Full name is required";
      isValid = false;
    }

    if (phoneController.text.trim().isEmpty) {
      phoneError = "Phone number is required";
      isValid = false;
    }

    return isValid;
  }

  /// Handle profile update API call
  Future<void> handleUpdateProfile() async {
    if (!validateInputs()) return;

    await profileController.editProfile(
      name: nameController.text.trim(),
      shortBio: aboutController.text.trim(),
      interests: interestController.text
          .trim()
          .split(',')
          .map((e) => e.trim())
          .toList(),
      phoneNumber: phoneController.text.trim(),
      profileImage:
          profileImage, // pass selected image or null to keep existing
    );

    Get.back(); // Navigate back after update
  }

  @override
  void dispose() {
    nameController.dispose();
    interestController.dispose();
    aboutController.dispose();
    phoneController.dispose();
    nameFocusNode.dispose();
    interestFocusNode.dispose();
    aboutFocusNode.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                SizedBox(height: 3.h),
                /// Profile Image Picker
                GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey.shade800,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : (existingImageUrl != null
                                ? NetworkImage(existingImageUrl!)
                                    as ImageProvider
                                : null),
                        child: profileImage == null && existingImageUrl == null
                            ? Icon(Icons.person,
                                size: 40.sp, color: Colors.grey.shade400)
                            : null,
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child:
                            Icon(Icons.edit, size: 15.sp, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),

                /// Input Fields
                buildInputField(
                  controller: nameController,
                  hint: 'Full Name',
                  keyboardType: TextInputType.name,
                  errorText: nameError,
                  focusNode: nameFocusNode,
                  nextFocusNode: interestFocusNode,
                  validator: FormValidationUtils.validateName,
                  enableRealTimeValidation: true,
                ),
                SizedBox(height: 2.h),
                buildInputField(
                  controller: interestController,
                  hint: 'Interests (comma separated)',
                  keyboardType: TextInputType.text,
                  focusNode: interestFocusNode,
                  nextFocusNode: aboutFocusNode,
                ),
                SizedBox(height: 2.h),
                buildInputField(
                  controller: aboutController,
                  hint: 'About',
                  keyboardType: TextInputType.text,
                  focusNode: aboutFocusNode,
                  nextFocusNode: phoneFocusNode,
                ),
                SizedBox(height: 2.h),
                buildInputField(
                  controller: phoneController,
                  hint: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  errorText: phoneError,
                  focusNode: phoneFocusNode,
                  validator: FormValidationUtils.validatePhone,
                  enableRealTimeValidation: true,
                ),
                SizedBox(height: 4.h),

                /// Update Button
                Obx(() {
                  final bool isUpdating = profileController.isLoading.value;
                  return ButtonWidget(
                    text: isUpdating ? "Updating..." : "Update Profile",
                    onPressed: isUpdating ? null : handleUpdateProfile,
                    backgroundColor: AppColors.blueColor,
                    borderRadius: 4.h,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reusable Input Field
  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    String? errorText,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    String? Function(String?)? validator,
    bool enableRealTimeValidation = false,
  }) {
    return InputTextField(
      myController: controller,
      hint: hint,
      obscureText: false,
      keyBoardType: keyboardType,
      errorText: errorText,
      validator: validator,
      enableRealTimeValidation: enableRealTimeValidation,
      realTimeValidator: enableRealTimeValidation ? validator : null,
      focusNode: focusNode,
      onFieldSubmittedValue: (_) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      textInputAction:
          nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                HapticUtils.navigation();
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Center(
                child: Text('Edit Profile', style: TextStyles.heading),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.06),
                Colors.white.withValues(alpha: 0.02),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }
}
