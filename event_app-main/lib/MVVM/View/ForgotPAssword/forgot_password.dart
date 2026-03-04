import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/form_validation_utils.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../Widget/button_widget.dart';
import '../../../Widget/input_text_field.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final AuthViewModel authViewModel = Get.put(AuthViewModel());
  final FocusNode emailFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      HapticUtils.medium();
      final email = emailController.text.trim();
      await authViewModel.forgotPassword(email);
      HapticUtils.success();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
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
                  'Forgot Password',
                  style: TextStyles.heading.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          /// Form card
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
                          'Reset Password',
                          style: TextStyles.heading.copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Enter your email to receive a recovery link',
                          style: TextStyles.regularwhite.copyWith(
                            fontSize: 13.sp,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4.h),

                        /// Recovery Image (optional, but keep for visual interest if desired)
                        Center(
                          child: Image.asset(
                            AppImages.passwordimg,
                            height: 15.h,
                          ),
                        ),
                        SizedBox(height: 4.h),

                        /// Email Input Field
                        Text(
                          'Email Address',
                          style: TextStyles.regularwhite.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        InputTextField(
                          myController: emailController,
                          focusNode: emailFocusNode,
                          onFieldSubmittedValue: (_) => _submitForm(),
                          keyBoardType: TextInputType.emailAddress,
                          obscureText: false,
                          hint: 'Enter your email',
                          prefixIcon: Image.asset(
                            AppImages.emailIcon,
                            height: 2.h,
                            color: Colors.white.withAlpha(179),
                          ),
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.done,
                          validator: (v) =>
                              FormValidationUtils.validateEmail(v),
                          onChanged: (value) {
                            authViewModel.emailError.value = '';
                          },
                        ),

                        /// API Error Display
                        Obx(() => authViewModel.emailError.value.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(top: 0.8.h),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        size: 14.sp,
                                        color: Colors.red.shade400),
                                    SizedBox(width: 1.w),
                                    Flexible(
                                      child: Text(
                                        authViewModel.emailError.value,
                                        style: TextStyle(
                                            color: Colors.red.shade400,
                                            fontSize: 11.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink()),
                        SizedBox(height: 4.h),

                        /// Continue Button
                        Obx(() => ButtonWidget(
                              text: 'Send Reset Link',
                              onPressed: _submitForm,
                              backgroundColor: AppColors.blueColor,
                              borderRadius: 14,
                              isLoading: authViewModel.isLoading.value,
                            )),
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
}
