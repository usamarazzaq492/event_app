import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

class VerifyEmail extends StatefulWidget {
  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  TextEditingController otpController = TextEditingController();
  final authViewModel = Get.put(AuthViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.only(top: 7.h, left: 5.w, right: 5.w, bottom: 3.h),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 5.w,
                ),
                Text(
                  'Email verification',
                  style: TextStyles.profiletext,
                )
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            Text(
              'Code has been send to your email',
              style: TextStyles.regularwhite,
            ),
            SizedBox(
              height: 5.h,
            ),
            PinCodeTextField(
              keyboardType: TextInputType.number,
              length: 4,
              obscureText: false,
              animationType: AnimationType.fade,
              cursorColor: AppColors.blueColor,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 8.h,
                fieldWidth: 8.h,
                activeFillColor: AppColors.signinoptioncolor,
                activeColor: AppColors.signinoptionbordercolor,
                selectedFillColor: AppColors.signinoptionbordercolor,
                selectedColor: AppColors.blueColor,
                inactiveColor: AppColors.signinoptionbordercolor,
                inactiveFillColor: AppColors.signinoptionbordercolor,
              ),
              textStyle: TextStyles.regularwhite,
              animationDuration: Duration(milliseconds: 300),
              backgroundColor: Colors.transparent,
              enableActiveFill: true,
              controller: otpController,
              onCompleted: (v) {
                print("Completed");
              },
              onChanged: (value) {
                print(value);
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                return true;
              },
              appContext: context,
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              'Resend code in 55s',
              style: TextStyles.regularwhite,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ButtonWidget(
                  text: 'Verify',
                  onPressed: () {
                    // Navigator.pushReplacementNamed(context, RouteName.password);
                    final code = otpController.text.trim();

                    authViewModel.verifyEmail(code);
                  },
                  backgroundColor: AppColors.blueColor,
                  borderRadius: 4.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
