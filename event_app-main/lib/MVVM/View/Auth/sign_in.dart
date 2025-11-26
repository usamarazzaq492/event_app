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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),

                  /// Logo
                  Center(
                    child: Hero(
                      tag: 'app-logo',
                      child: Image.asset(
                        AppImages.logo2,
                        height: 12.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  /// Title
                  Center(
                    child: Text(
                      AppStrings.loginText,
                      style: TextStyles.heading.copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),

                  /// Email Field
                  InputTextField(
                    myController: emailController,
                    focusNode: emailFocusNode,
                    onFieldSubmittedValue: (_) =>
                        FocusScope.of(context).requestFocus(passwordFocusNode),
                    keyBoardType: TextInputType.emailAddress,
                    obscureText: false,
                    hint: 'Email',
                    prefixIcon: Image.asset(
                      AppImages.emailIcon,
                      height: 2.h,
                      color: Colors.white.withAlpha(179),
                    ),
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        FormValidationUtils.validateEmail(value),
                    onChanged: (value) {
                      authViewModel.emailError.value = '';
                    },
                  ),
                  Obx(() => authViewModel.emailError.value.isNotEmpty
                      ? _buildErrorText(authViewModel.emailError.value)
                      : const SizedBox.shrink()),
                  SizedBox(height: 2.h),

                  /// Password Field
                  InputTextField(
                    myController: passwordController,
                    focusNode: passwordFocusNode,
                    onFieldSubmittedValue: (_) => _submitForm(),
                    keyBoardType: TextInputType.visiblePassword,
                    obscureText: _isObscure,
                    hint: AppStrings.hintpasswordtText,
                    prefixIcon: Image.asset(
                      AppImages.passwordIcon,
                      height: 2.h,
                      color: Colors.white.withAlpha(179),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white.withAlpha(179),
                      ),
                      onPressed: () {
                        setState(() => _isObscure = !_isObscure);
                      },
                    ),
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    validator: (value) =>
                        FormValidationUtils.validatePassword(value),
                    onChanged: (value) {
                      authViewModel.passwordError.value = '';
                    },
                  ),
                  Obx(() => authViewModel.passwordError.value.isNotEmpty
                      ? _buildErrorText(authViewModel.passwordError.value)
                      : const SizedBox.shrink()),
                  SizedBox(height: 1.h),

                  /// Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Transform.scale(
                            scale: 0.8,
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
                            "Remember Me",
                            style: TextStyles.regularwhite
                                .copyWith(fontSize: 10.sp),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, RouteName.forgotpassword);
                        },
                        child: Text(
                          AppStrings.forgotpassText,
                          style: TextStyles.regulartext.copyWith(
                            fontSize: 10.sp,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  /// Sign In Button
                  ButtonWidget(
                    text: AppStrings.signinText,
                    onPressed: _submitForm,
                    backgroundColor: AppColors.blueColor,
                    borderRadius: 4.h,
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: 4.h),

                  /// Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.accountText,
                        style:
                            TextStyles.regularwhite.copyWith(fontSize: 10.sp),
                      ),
                      SizedBox(width: 1.w),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, RouteName.signupScreen);
                        },
                        child: Text(
                          AppStrings.signupText,
                          style: TextStyles.regulartext.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
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
          Icon(Icons.error_outline, size: 12.sp, color: Colors.red),
          SizedBox(width: 1.w),
          Flexible(
            child: Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 10.sp),
            ),
          ),
        ],
      ),
    );
  }
}
