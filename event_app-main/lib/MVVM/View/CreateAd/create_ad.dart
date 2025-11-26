import 'package:event_app/MVVM/view_model/ad_view_model.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class CreateAd extends StatefulWidget {
  const CreateAd({super.key});

  @override
  State<CreateAd> createState() => _CreateAdState();
}

class _CreateAdState extends State<CreateAd> {
  final RxString imageError = ''.obs;
  final adVM = Get.put(AdViewModel());

  final _formKey = GlobalKey<FormState>();

  final TextEditingController desccontroller = TextEditingController();
  final TextEditingController titlecontroller = TextEditingController();
  final TextEditingController pricecontroller = TextEditingController();

  final titleFocusNode = FocusNode();
  final desFocusNode = FocusNode();
  final priceFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(top: 4.h, left: 5.w, right: 5.w, bottom: 5.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderModern(),
                SizedBox(height: 2.h),
                _buildSection(
                  title: 'Ad Details',
                  child: Column(
                    children: [
                      _buildInputField(
                        controller: titlecontroller,
                        focusNode: titleFocusNode,
                        hint: 'Name of Ad',
                        validatorMsg: 'Title is required',
                      ),
                      SizedBox(height: 1.5.h),
                      _buildInputField(
                        controller: pricecontroller,
                        focusNode: priceFocusNode,
                        hint: 'Amount',
                        keyboardType: TextInputType.number,
                        validatorMsg: 'Amount is required',
                      ),
                      SizedBox(height: 1.5.h),
                      _buildDescriptionField(),
                    ],
                  ),
                ),
                _buildSection(
                  title: 'Media',
                  child: _buildImagePicker(),
                ),
                SizedBox(height: 2.h),
                _buildUploadButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderModern() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Text('Create Ad', style: TextStyles.heading),
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

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.blueColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 2.w),
              Text(title, style: TextStyles.homeheadingtext),
            ],
          ),
          SizedBox(height: 1.5.h),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    String? validatorMsg,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.signinoptioncolor,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.blueColor),
          borderRadius: BorderRadius.circular(20),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorMsg;
        }
        if (hint == 'Amount') {
          final v = double.tryParse(value);
          if (v == null || v < 0) return 'Enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: desccontroller,
      maxLines: 6,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Description',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.signinoptioncolor,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.blueColor),
          borderRadius: BorderRadius.circular(20),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Description is required';
        }
        return null;
      },
    );
  }

  Widget _buildImagePicker() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              await adVM.pickImage();
              if (adVM.selectedImage.value != null) {
                imageError.value = '';
              }
            },
            child: Container(
              height: 20.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1.h),
                color: AppColors.signinoptioncolor,
                border: Border.all(
                  color: imageError.value.isNotEmpty
                      ? Colors.red
                      : Colors.transparent,
                  width: 1,
                ),
                image: adVM.selectedImage.value != null
                    ? DecorationImage(
                        image: FileImage(adVM.selectedImage.value!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: adVM.selectedImage.value == null
                  ? Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Choose File',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(Icons.upload_file,
                              color: Colors.white, size: 3.h),
                        ],
                      ),
                    )
                  : Container(),
            ),
          ),
          if (imageError.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 5),
              child: Text(
                imageError.value,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildUploadButton() {
    return Obx(() => adVM.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : ButtonWidget(
            text: adVM.isLoading.value ? 'Creating…' : 'Create Ad',
            borderRadius: 4.h,
            textColor: AppColors.whiteColor,
            backgroundColor: AppColors.blueColor,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (adVM.selectedImage.value == null) {
                  imageError.value = 'Please select an image';
                  return;
                }

                // If image selected, clear error
                imageError.value = '';

                adVM.uploadAd(
                  title: titlecontroller.text.trim(),
                  description: desccontroller.text.trim(),
                  targetAmount: pricecontroller.text.trim(),
                );
              }
            },
          ));
  }
}
