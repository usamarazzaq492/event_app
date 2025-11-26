import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../Widget/input_text_field.dart';
import '../../../app/config/app_asset.dart';
import '../../../app/config/app_pages.dart';
import '../../../app/config/app_strings.dart';
import '../../../app/config/app_text_style.dart';
import '../../../utils/form_validation_utils.dart';
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
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      RouteName.loginScreen,
                      (route) => false,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(height: 5.h),
                  Center(
                    child: Image.asset(AppImages.logo2, height: 12.h),
                  ),
                  SizedBox(height: 3.h),
                  Center(
                    child: Text(AppStrings.createaccountText,
                        style: TextStyles.heading.copyWith(
                            fontSize: 22.sp, fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(height: 6.h),

                  /// Name
                  InputTextField(
                    myController: nameController,
                    focusNode: nameFocusNode,
                    onFieldSubmittedValue: (_) =>
                        FocusScope.of(context).requestFocus(emailFocusNode),
                    keyBoardType: TextInputType.name,
                    obscureText: false,
                    hint: 'Name',
                    prefixIcon: Image.asset(AppImages.profile,
                        height: 2.h, color: Colors.white.withAlpha(179)),
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: (value) =>
                        FormValidationUtils.validateName(value),
                    onChanged: (value) {
                      controller.nameError.value = '';
                    },
                  ),
                  Obx(() => controller.nameError.value.isNotEmpty
                      ? _buildErrorText(controller.nameError.value)
                      : const SizedBox.shrink()),
                  SizedBox(height: 2.h),

                  /// Email
                  InputTextField(
                    myController: emailController,
                    focusNode: emailFocusNode,
                    onFieldSubmittedValue: (_) =>
                        FocusScope.of(context).requestFocus(passwordFocusNode),
                    keyBoardType: TextInputType.emailAddress,
                    obscureText: false,
                    hint: 'Email',
                    prefixIcon: Image.asset(AppImages.emailIcon,
                        height: 2.h, color: Colors.white.withAlpha(179)),
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) =>
                        FormValidationUtils.validateEmail(value),
                    onChanged: (value) {
                      controller.emailError.value = '';
                    },
                  ),
                  Obx(() => controller.emailError.value.isNotEmpty
                      ? _buildErrorText(controller.emailError.value)
                      : const SizedBox.shrink()),
                  SizedBox(height: 2.h),

                  /// Password
                  InputTextField(
                    myController: passwordController,
                    focusNode: passwordFocusNode,
                    onFieldSubmittedValue: (_) => FocusScope.of(context)
                        .requestFocus(confirmPassFocusNode),
                    keyBoardType: TextInputType.visiblePassword,
                    obscureText: _isObscure,
                    hint: AppStrings.hintpasswordtText,
                    prefixIcon: Image.asset(AppImages.passwordIcon,
                        height: 2.h, color: Colors.white.withAlpha(179)),
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
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) =>
                        FormValidationUtils.validatePassword(value),
                    onChanged: (value) {
                      controller.passwordError.value = '';
                    },
                  ),
                  Obx(() => controller.passwordError.value.isNotEmpty
                      ? _buildErrorText(controller.passwordError.value)
                      : const SizedBox.shrink()),
                  SizedBox(height: 2.h),

                  /// Confirm Password
                  InputTextField(
                    myController: confirmpassController,
                    focusNode: confirmPassFocusNode,
                    onFieldSubmittedValue: (_) => _submitForm(),
                    keyBoardType: TextInputType.visiblePassword,
                    obscureText: _isObscureConfirm,
                    hint: 'Confirm Password',
                    prefixIcon: Image.asset(AppImages.passwordIcon,
                        height: 2.h, color: Colors.white.withAlpha(179)),
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
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) =>
                        FormValidationUtils.validateConfirmPassword(
                            value, passwordController.text),
                    onChanged: (value) {
                      controller.confirmPasswordError.value = '';
                    },
                  ),
                  Obx(() => controller.confirmPasswordError.value.isNotEmpty
                      ? _buildErrorText(controller.confirmPasswordError.value)
                      : const SizedBox.shrink()),
                  SizedBox(height: 4.h),

                  /// Signup Button
                  Obx(() => ButtonWidget(
                        text: AppStrings.signupText,
                        isLoading: controller.isLoading.value,
                        onPressed: _submitForm,
                        backgroundColor: AppColors.blueColor,
                        borderRadius: 4.h,
                      )),
                  SizedBox(height: 4.h),

                  /// Signin Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.alreadyText,
                          style: TextStyles.regularwhite
                              .copyWith(fontSize: 10.sp)),
                      SizedBox(width: 1.w),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, RouteName.loginScreen),
                        child: Text(AppStrings.signinText,
                            style: TextStyles.regulartext.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline)),
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
