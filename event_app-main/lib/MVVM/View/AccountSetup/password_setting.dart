import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/Widget/input_text_field.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 7.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Back button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                SizedBox(height: 5.h),

                /// Title
                Center(
                  child: Text(
                    'Reset Password',
                    style: TextStyles.heading.copyWith(fontSize: 22.sp),
                  ),
                ),
                SizedBox(height: 6.h),

                /// New Password Field
                InputTextField(
                  myController: passwordController,
                  focusNode: passwordFocusNode,
                  onFieldSubmittedValue: (_) =>
                      FocusScope.of(context).requestFocus(confirmPasswordFocusNode),
                  keyBoardType: TextInputType.visiblePassword,
                  obscureText: _isObscure,
                  hint: 'New Password',
                  prefixIcon: Image.asset(
                    'assets/icons/password_icon.png',
                    height: 2.h,
                    color: Colors.white.withAlpha(179),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.white.withAlpha(179),
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
                  onFieldSubmittedValue: (_) => _submitForm(),
                  keyBoardType: TextInputType.visiblePassword,
                  obscureText: _isObscureConfirm,
                  hint: 'Confirm Password',
                  prefixIcon: Image.asset(
                    'assets/icons/password_icon.png',
                    height: 2.h,
                    color: Colors.white.withAlpha(179),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white.withAlpha(179),
                    ),
                    onPressed: () {
                      setState(() => _isObscureConfirm = !_isObscureConfirm);
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
                  onPressed: _submitForm,
                  backgroundColor: AppColors.blueColor,
                  borderRadius: 4.h,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
