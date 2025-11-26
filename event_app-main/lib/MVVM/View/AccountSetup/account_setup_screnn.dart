import 'dart:io';
import 'package:event_app/MVVM/view_model/data_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/Widget/input_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class AccountSetupScreen extends StatefulWidget {
  const AccountSetupScreen({super.key});

  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  final DataViewModel dataViewModel = Get.put(DataViewModel());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? nameError;
  String? phoneError;
  File? profileImage;

  /// Picks an image from gallery
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  /// Validates input fields
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

    if (profileImage == null) {
      Get.snackbar(
        "Error",
        "Please select a profile image",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      isValid = false;
    }

    return isValid;
  }

  /// Handles profile update API call
  Future<void> handleUpdateProfile() async {
    if (!validateInputs()) return;

    await dataViewModel.updateProfile(
      name: nameController.text.trim(),
      shortBio: aboutController.text.trim(),
      interests: interestController.text.trim(),
      profileImage: profileImage!,
      phoneNumber: phoneController.text.trim(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    interestController.dispose();
    aboutController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Center(
                child: Text(
                  'Complete Your Profile',
                  style: TextStyles.profiletext.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 3.h),

              /// Profile Image Picker with decoration
              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                        child: profileImage == null
                            ? Icon(Icons.person, size: 40.sp, color: Colors.grey)
                            : null,
                      ),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.blueColor,
                        child: Icon(Icons.edit, size: 15.sp, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              /// Input Fields
              buildInputField(
                controller: nameController,
                hint: 'Full Name',
                keyboardType: TextInputType.name,
                errorText: nameError,
              ),
              SizedBox(height: 2.h),
              buildInputField(
                controller: interestController,
                hint: 'Interest',
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 2.h),
              buildInputField(
                controller: aboutController,
                hint: 'About',
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 2.h),
              buildInputField(
                controller: phoneController,
                hint: 'Phone Number',
                keyboardType: TextInputType.phone,
                errorText: phoneError,
              ),
              SizedBox(height: 4.h),

              /// Continue Button
              Obx(() {
                final bool isUpdating = dataViewModel.isLoading.value;
                return ButtonWidget(
                  text: isUpdating ? "Updating..." : "Continue",
                  onPressed: isUpdating ? null : handleUpdateProfile,
                  backgroundColor: AppColors.blueColor,
                  borderRadius: 4.h,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable input field builder
  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    String? errorText,
  }) {
    return InputTextField(
      myController: controller,
      hint: hint,
      obscureText: false,
      keyBoardType: keyboardType,
      errorText: errorText,
      validator: (val) => null,
      focusNode: FocusNode(),
      onFieldSubmittedValue: (_) {},
    );
  }
}
