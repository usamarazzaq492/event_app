import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../Widget/button_widget.dart';
import '../../../Widget/input_text_field.dart';
import '../../../app/config/app_pages.dart';

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
      final email = emailController.text.trim();
      await authViewModel.forgotPassword(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 7.h, left: 5.w, right: 5.w, bottom: 3.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Back Icon and Title
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteName.loginScreen,
                            (route) => false,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    SizedBox(width: 5.w),
                    Text('Forgot Password', style: TextStyles.profiletext),
                  ],
                ),
                SizedBox(height: 7.h),

                /// Image
                Center(child: Image.asset(AppImages.passwordimg)),
                SizedBox(height: 5.h),

                /// Enter Email Text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Enter Your Email', style: TextStyles.regularwhite),
                ),
                SizedBox(height: 3.h),

                /// Email Input Field
                InputTextField(
                  myController: emailController,
                  focusNode: emailFocusNode,
                  onFieldSubmittedValue: (_) => _submitForm(),
                  keyBoardType: TextInputType.emailAddress,
                  obscureText: false,
                  hint: 'Email',
                  prefixIcon: Image.asset(AppImages.emailIcon, height: 2.h, color: Colors.white.withAlpha(179)),
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    authViewModel.emailError.value = '';
                  },
                ),

                /// API Error Display
                Obx(() => authViewModel.emailError.value.isNotEmpty
                    ? Padding(
                  padding: EdgeInsets.only(top: 0.8.h),
                  child: Text(
                    authViewModel.emailError.value,
                    style: TextStyle(color: Colors.red, fontSize: 10.sp),
                  ),
                )
                    : SizedBox.shrink()),
                SizedBox(height: 4.h),

                /// Continue Button
                Obx(() => ButtonWidget(
                  text: 'Continue',
                  onPressed: _submitForm,
                  backgroundColor: AppColors.blueColor,
                  borderRadius: 4.h,
                  isLoading: authViewModel.isLoading.value,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
