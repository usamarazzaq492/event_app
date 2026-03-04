import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/Widget/input_text_field.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class PasswordSetting extends StatefulWidget {
  const PasswordSetting({super.key});

  @override
  State<PasswordSetting> createState() => _PasswordSettingState();
}

class _PasswordSettingState extends State<PasswordSetting> {
  final _formKey = GlobalKey<FormState>();
  final authViewModel = Get.put(AuthViewModel());

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  bool _isObscure = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final message = args?['message'] ?? '';
    if (message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "Success",
          message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      });
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await authViewModel.resetPassword(
          password: passwordController.text.trim(),
          confirmPassword: confirmPasswordController.text.trim(),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          /// Gradient header (App style)
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
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.whiteColor,
                        size: 20,
                      ),
                      onPressed: () {
                        HapticUtils.navigation();
                        Get.back();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Hero(
                  tag: 'app-logo',
                  child: Image.asset(
                    AppImages.logo2,
                    height: 10.h,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Security',
                  style: TextStyles.heading.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          /// Form content
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
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 4.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Reset Password',
                              style: TextStyles.heading.copyWith(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Text(
                              'Set your new secure password',
                              style: TextStyles.regularwhite.copyWith(
                                fontSize: 12.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),

                          /// New Password Field
                          InputTextField(
                            myController: passwordController,
                            focusNode: passwordFocusNode,
                            onFieldSubmittedValue: (_) => FocusScope.of(context)
                                .requestFocus(confirmPasswordFocusNode),
                            keyBoardType: TextInputType.visiblePassword,
                            obscureText: _isObscure,
                            hint: 'New Password',
                            prefixIcon: Image.asset(
                              'assets/icons/password_icon.png',
                              height: 2.h,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              onPressed: () {
                                setState(() => _isObscure = !_isObscure);
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 2.h),

                          /// Confirm Password Field
                          InputTextField(
                            myController: confirmPasswordController,
                            focusNode: confirmPasswordFocusNode,
                            onFieldSubmittedValue: (_) {
                              HapticUtils.medium();
                              _submitForm();
                            },
                            keyBoardType: TextInputType.visiblePassword,
                            obscureText: _isObscureConfirm,
                            hint: 'Confirm Password',
                            prefixIcon: Image.asset(
                              'assets/icons/password_icon.png',
                              height: 2.h,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              onPressed: () {
                                setState(() =>
                                    _isObscureConfirm = !_isObscureConfirm);
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 4.h),

                          /// Reset Button
                          ButtonWidget(
                            text: 'Reset Password',
                            onPressed: () {
                              HapticUtils.medium();
                              _submitForm();
                            },
                            backgroundColor: AppColors.blueColor,
                            borderRadius: 4.h,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
