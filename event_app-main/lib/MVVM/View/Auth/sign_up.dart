import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../Widget/input_text_field.dart';
import '../../../app/config/app_asset.dart';
import '../../../app/config/app_pages.dart';
import '../../../app/config/app_strings.dart';
import '../../../app/config/app_text_style.dart';
import '../../../utils/form_validation_utils.dart';
import '../../../utils/haptic_utils.dart';
import '../../view_model/auth_view_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthViewModel controller = Get.put(AuthViewModel());

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpassController = TextEditingController();

  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPassFocusNode = FocusNode();

  bool _isObscure = true;
  bool _isObscureConfirm = true;
  bool _acceptedTerms = false;
  String? _termsError;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpassController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPassFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_acceptedTerms) {
      setState(() {
        _termsError =
            'You must agree to the terms and conditions to create an account.';
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      controller.signup(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        confirmpassController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
                              context, RouteName.loginScreen);
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
                                'Already have an account? ',
                                style: TextStyles.regularwhite.copyWith(
                                  fontSize: 11.sp,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'Sign in',
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
                    AppStrings.createaccountText,
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
                            'Create Account',
                            style: TextStyles.heading.copyWith(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Fill in your details below',
                            style: TextStyles.regularwhite.copyWith(
                              fontSize: 13.sp,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 4.h),

                          /// Name field
                          _buildLabeledField(
                            label: 'Full Name',
                            child: InputTextField(
                              myController: nameController,
                              focusNode: nameFocusNode,
                              onFieldSubmittedValue: (_) =>
                                  FocusScope.of(context)
                                      .requestFocus(emailFocusNode),
                              keyBoardType: TextInputType.name,
                              obscureText: false,
                              hint: 'Enter your name',
                              prefixIcon: Image.asset(
                                AppImages.profile,
                                height: 2.h,
                                color: Colors.white.withAlpha(179),
                              ),
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              validator: (v) =>
                                  FormValidationUtils.validateName(v),
                              onChanged: (_) => controller.nameError.value = '',
                            ),
                          ),
                          Obx(
                            () => controller.nameError.value.isNotEmpty
                                ? _buildErrorText(controller.nameError.value)
                                : const SizedBox.shrink(),
                          ),
                          SizedBox(height: 2.5.h),

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
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              validator: (v) =>
                                  FormValidationUtils.validateEmail(v),
                              onChanged: (_) =>
                                  controller.emailError.value = '',
                            ),
                          ),
                          Obx(
                            () => controller.emailError.value.isNotEmpty
                                ? _buildErrorText(controller.emailError.value)
                                : const SizedBox.shrink(),
                          ),
                          SizedBox(height: 2.5.h),

                          /// Password field
                          _buildLabeledField(
                            label: 'Password',
                            child: InputTextField(
                              myController: passwordController,
                              focusNode: passwordFocusNode,
                              onFieldSubmittedValue: (_) =>
                                  FocusScope.of(context)
                                      .requestFocus(confirmPassFocusNode),
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
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                              validator: (v) =>
                                  FormValidationUtils.validatePassword(v),
                              onChanged: (_) =>
                                  controller.passwordError.value = '',
                            ),
                          ),
                          Obx(
                            () => controller.passwordError.value.isNotEmpty
                                ? _buildErrorText(
                                    controller.passwordError.value)
                                : const SizedBox.shrink(),
                          ),
                          SizedBox(height: 2.5.h),

                          /// Confirm Password field
                          _buildLabeledField(
                            label: 'Confirm Password',
                            child: InputTextField(
                              myController: confirmpassController,
                              focusNode: confirmPassFocusNode,
                              onFieldSubmittedValue: (_) => _submitForm(),
                              keyBoardType: TextInputType.visiblePassword,
                              obscureText: _isObscureConfirm,
                              hint: 'Confirm your password',
                              prefixIcon: Image.asset(
                                AppImages.passwordIcon,
                                height: 2.h,
                                color: Colors.white.withAlpha(179),
                              ),
                              suffixIcon: Icon(
                                _isObscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white.withAlpha(179),
                                size: 20,
                              ),
                              onSuffixIconPress: () => setState(
                                  () => _isObscureConfirm = !_isObscureConfirm),
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              validator: (v) =>
                                  FormValidationUtils.validateConfirmPassword(
                                      v, passwordController.text),
                              onChanged: (_) => controller
                                  .confirmPasswordError.value = '',
                            ),
                          ),
                          Obx(
                            () => controller.confirmPasswordError.value
                                    .isNotEmpty
                                ? _buildErrorText(controller
                                    .confirmPasswordError.value)
                                : const SizedBox.shrink(),
                          ),
                          SizedBox(height: 2.h),

                          /// Terms & Conditions
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Transform.translate(
                                offset: const Offset(0, -2),
                                child: Checkbox(
                                  value: _acceptedTerms,
                                  activeColor: AppColors.blueColor,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (val) {
                                    setState(() {
                                      _acceptedTerms = val ?? false;
                                      if (_acceptedTerms) _termsError = null;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 1.h),
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyles.regularwhite.copyWith(
                                        fontSize: 11.sp,
                                        color: Colors.white70,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Terms & Conditions',
                                          style: TextStyles.regulartext
                                              .copyWith(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              HapticUtils.navigation();
                                              Navigator.pushNamed(
                                                  context,
                                                  RouteName.termsScreen);
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_termsError != null)
                            Padding(
                              padding: EdgeInsets.only(top: 0.5.h, left: 1.w),
                              child: Text(
                                _termsError!,
                                style: TextStyle(
                                  color: Colors.red.shade400,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          SizedBox(height: 3.h),

                          /// Sign up button
                          Obx(
                            () => ButtonWidget(
                              text: AppStrings.signupText,
                              isLoading: controller.isLoading.value,
                              onPressed: _submitForm,
                              backgroundColor: AppColors.blueColor,
                              borderRadius: 14,
                            ),
                          ),
                          SizedBox(height: 2.h),

                          /// Or sign up with
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                      color: AppColors
                                          .signinoptionbordercolor)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                child: Text(
                                  'Or sign up with',
                                  style: TextStyles.regularwhite.copyWith(
                                    fontSize: 12.sp,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Divider(
                                      color: AppColors
                                          .signinoptionbordercolor)),
                            ],
                          ),
                          SizedBox(height: 3.h),

                          /// Social sign-up buttons
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
                                      'Google sign-up will be available soon',
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
                                      'Facebook sign-up will be available soon',
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
              style: TextStyle(
                  color: Colors.red.shade400, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }
}
