import 'dart:io';
import 'package:event_app/MVVM/view_model/public_profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      body: Column(
        children: [
          /// Gradient header (consistent with Auth/Detail screens)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 2.h,
              left: 4.w,
              right: 4.w,
              bottom: 6.h,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor,
                  AppColors.backgroundColor,
                  AppColors.signinoptioncolor,
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.whiteColor,
                        size: 20,
                      ),
                      onPressed: () {
                        HapticUtils.navigation();
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'Edit Profile',
                      style: TextStyles.heading.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer for balance
                  ],
                ),
                SizedBox(height: 3.h),

                /// Profile Image Picker with glow/glass effect
                GestureDetector(
                  onTap: () {
                    HapticUtils.light();
                    pickImage();
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blueColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                          gradient: const LinearGradient(
                            colors: [AppColors.blueColor, Colors.transparent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.signinoptioncolor,
                          backgroundImage: (profileImage != null
                              ? FileImage(profileImage!)
                              : (existingImageUrl != null
                                  ? CachedNetworkImageProvider(
                                      existingImageUrl!)
                                  : null)) as ImageProvider?,
                          child:
                              profileImage == null && existingImageUrl == null
                                  ? Icon(Icons.person,
                                      size: 35.sp, color: Colors.white24)
                                  : null,
                        ),
                      ),
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(Icons.camera_alt_rounded,
                            size: 14.sp, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Form card (Glassmorphic)
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.signinoptioncolor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: AppColors.signinoptionbordercolor,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 6.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Profile Information',
                        style: TextStyles.heading.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Update your personal details below',
                        style: TextStyles.regularwhite.copyWith(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      /// Input Fields (consistent with Auth)
                      _buildLabeledField(
                        label: 'Full Name',
                        child: buildInputField(
                          controller: nameController,
                          hint: 'Enter your name',
                          keyboardType: TextInputType.name,
                          errorText: nameError,
                          focusNode: nameFocusNode,
                          nextFocusNode: interestFocusNode,
                          validator: FormValidationUtils.validateName,
                          enableRealTimeValidation: true,
                        ),
                      ),
                      SizedBox(height: 2.5.h),

                      _buildLabeledField(
                        label: 'Interests',
                        child: buildInputField(
                          controller: interestController,
                          hint: 'e.g. Music, Sports, Art',
                          keyboardType: TextInputType.text,
                          focusNode: interestFocusNode,
                          nextFocusNode: aboutFocusNode,
                        ),
                      ),
                      SizedBox(height: 2.5.h),

                      _buildLabeledField(
                        label: 'About Me',
                        child: buildInputField(
                          controller: aboutController,
                          hint: 'Write a short bio...',
                          keyboardType: TextInputType.text,
                          focusNode: aboutFocusNode,
                          nextFocusNode: phoneFocusNode,
                        ),
                      ),
                      SizedBox(height: 2.5.h),

                      _buildLabeledField(
                        label: 'Phone Number',
                        child: buildInputField(
                          controller: phoneController,
                          hint: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                          errorText: phoneError,
                          focusNode: phoneFocusNode,
                          validator: FormValidationUtils.validatePhone,
                          enableRealTimeValidation: true,
                        ),
                      ),
                      SizedBox(height: 5.h),

                      /// Update Button
                      Obx(() {
                        final bool isUpdating =
                            profileController.isLoading.value;
                        return ButtonWidget(
                          text: isUpdating ? "Updating..." : "Update Profile",
                          onPressed: isUpdating
                              ? null
                              : () {
                                  HapticUtils.buttonPress();
                                  handleUpdateProfile();
                                },
                          backgroundColor: AppColors.blueColor,
                          borderRadius: 14,
                          isLoading: isUpdating,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.regularwhite.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 1.h),
        child,
      ],
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
}
