import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../Widget/button_widget.dart';
import '../../../Widget/input_text_field.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_asset.dart';
import '../../../app/config/app_pages.dart';
import '../../../app/config/app_strings.dart';
import '../../../app/config/app_text_style.dart';
import '../../view_model/auth_view_model.dart';
import '../../../utils/form_validation_utils.dart';
import '../../../utils/haptic_utils.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final authViewModel = Get.put(AuthViewModel());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  bool _isObscure = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await authViewModel.login(
          emailController.text.trim(),
          passwordController.text.trim(),
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
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          /// Gradient header (app colors)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 2.h,
              left: 4.w,
              right: 4.w,
              bottom: 6.h,
            ),
            decoration: BoxDecoration(
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
                    if (canPop)
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
                      )
                    else
                      const SizedBox.shrink(),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticUtils.light();
                        Navigator.pushReplacementNamed(
                            context, RouteName.signupScreen);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.blueColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyles.regularwhite.copyWith(
                                fontSize: 11.sp,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              'Get Started',
                              style: TextStyles.regulartext.copyWith(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.lightColor,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  AppStrings.loginText,
                  style: TextStyles.heading.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          /// Form card (theme colors)
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome Back',
                          style: TextStyles.heading.copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Enter your details below',
                          style: TextStyles.regularwhite.copyWith(
                            fontSize: 13.sp,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4.h),

                        /// Email field
                        _buildLabeledField(
                          label: 'Email Address',
                          child: InputTextField(
                            myController: emailController,
                            focusNode: emailFocusNode,
                            onFieldSubmittedValue: (_) =>
                                FocusScope.of(context)
                                    .requestFocus(passwordFocusNode),
                            keyBoardType: TextInputType.emailAddress,
                            obscureText: false,
                            hint: 'Enter your email',
                            prefixIcon: Image.asset(
                              AppImages.emailIcon,
                              height: 2.h,
                              color: Colors.white.withAlpha(179),
                            ),
                            validator: (v) =>
                                FormValidationUtils.validateEmail(v),
                            onChanged: (_) =>
                                authViewModel.emailError.value = '',
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        Obx(
                          () => authViewModel.emailError.value.isNotEmpty
                              ? _buildErrorText(authViewModel.emailError.value)
                              : const SizedBox.shrink(),
                        ),
                        SizedBox(height: 2.5.h),

                        /// Password field
                        _buildLabeledField(
                          label: 'Password',
                          child: InputTextField(
                            myController: passwordController,
                            focusNode: passwordFocusNode,
                            onFieldSubmittedValue: (_) => _submitForm(),
                            keyBoardType: TextInputType.visiblePassword,
                            obscureText: _isObscure,
                            hint: 'Enter your password',
                            prefixIcon: Image.asset(
                              AppImages.passwordIcon,
                              height: 2.h,
                              color: Colors.white.withAlpha(179),
                            ),
                            suffixIcon: Icon(
                              _isObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white.withAlpha(179),
                              size: 20,
                            ),
                            onSuffixIconPress: () =>
                                setState(() => _isObscure = !_isObscure),
                            validator: (v) =>
                                FormValidationUtils.validatePassword(v),
                            onChanged: (_) =>
                                authViewModel.passwordError.value = '',
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        Obx(
                          () => authViewModel.passwordError.value.isNotEmpty
                              ? _buildErrorText(
                                  authViewModel.passwordError.value)
                              : const SizedBox.shrink(),
                        ),
                        SizedBox(height: 2.h),

                        /// Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.scale(
                                    scale: 0.85,
                                    child: CupertinoSwitch(
                                      value: _rememberMe,
                                      thumbColor: AppColors.blueColor,
                                      activeTrackColor: AppColors.lightColor,
                                      onChanged: (value) {
                                        setState(() => _rememberMe = value);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Remember me',
                                    style: TextStyles.regularwhite
                                        .copyWith(fontSize: 11.sp),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: TextButton(
                                onPressed: () {
                                  HapticUtils.light();
                                  Navigator.pushNamed(
                                      context, RouteName.forgotpassword);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 0.5.h),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyles.regulartext.copyWith(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        /// Sign in button
                        ButtonWidget(
                          text: 'Sign in',
                          onPressed: _submitForm,
                          backgroundColor: AppColors.blueColor,
                          borderRadius: 14,
                          isLoading: _isLoading,
                        ),
                        SizedBox(height: 2.h),

                        /// Or sign in with
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: AppColors.signinoptionbordercolor)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: Text(
                                'Or sign in with',
                                style: TextStyles.regularwhite.copyWith(
                                  fontSize: 12.sp,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: AppColors.signinoptionbordercolor)),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        /// Social sign-in buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildSocialButton(
                                icon: 'G',
                                label: 'Google',
                                onTap: () {
                                  HapticUtils.light();
                                  Get.snackbar(
                                    'Coming soon',
                                    'Google sign-in will be available soon',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppColors.blueColor,
                                    colorText: AppColors.whiteColor,
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: _buildSocialButton(
                                icon: 'f',
                                label: 'Facebook',
                                onTap: () {
                                  HapticUtils.light();
                                  Get.snackbar(
                                    'Coming soon',
                                    'Facebook sign-in will be available soon',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppColors.blueColor,
                                    colorText: AppColors.whiteColor,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
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
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 1.h),
        child,
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.signinoptionbordercolor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: TextStyle(
                  color: label == 'Google'
                      ? AppColors.lightColor
                      : AppColors.blueColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                label,
                style: TextStyles.regularwhite.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: EdgeInsets.only(top: 0.5.h),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 14.sp, color: Colors.red.shade400),
          SizedBox(width: 1.w),
          Flexible(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade400, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }
}
