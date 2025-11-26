import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/Widget/input_text_field.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AddNewCardScreen extends StatefulWidget {
  const AddNewCardScreen({super.key});

  @override
  State<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {
  final TextEditingController cardNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),

      body: Padding(
        padding: EdgeInsets.only(top: 7.h, left: 4.w, right: 4.w),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 15.w,
                ),
                Text('Add New Card',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',

                        fontSize: 15.sp)),
              ],
            ),
            SizedBox(height: 3.h,),
            Image.asset(AppImages.creditcard), // your card image placeholder
            SizedBox(height: 3.h),
            InputTextField(
              myController: cardNameController,
              onFieldSubmittedValue: (value) {
                // You can trigger validation or API calls here if necessary
              },
              keyBoardType: TextInputType.emailAddress,
              obscureText: false,
              hint: 'Card Name',

              validator: (value) {
                return null;
              },
            ),
            SizedBox(height: 1.5.h),
            InputTextField(
              myController: cardNumberController,
              onFieldSubmittedValue: (value) {
                // You can trigger validation or API calls here if necessary
              },
              keyBoardType: TextInputType.emailAddress,
              obscureText: false,
              hint: 'Card Number',

              validator: (value) {
                return null;
              },
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Expanded(
                  child:
                  InputTextField(
                    myController: expiryDateController,
                    onFieldSubmittedValue: (value) {
                      // You can trigger validation or API calls here if necessary
                    },
                    keyBoardType: TextInputType.emailAddress,
                    obscureText: false,
                    hint: 'Expiry Date',

                    validator: (value) {
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child:   InputTextField(
                    myController: cvvController,
                    onFieldSubmittedValue: (value) {
                      // You can trigger validation or API calls here if necessary
                    },
                    keyBoardType: TextInputType.emailAddress,
                    obscureText: false,
                    hint: 'CVV',

                    validator: (value) {
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const Spacer(),
            ButtonWidget(text: 'Continue', onPressed: (){
              if (cardNumberController.text.isNotEmpty) {
                Navigator.pop(
                    context, '**** **** **** ${cardNumberController.text.substring(cardNumberController.text.length - 4)}');
              }
            },backgroundColor: AppColors.blueColor,
              textColor: AppColors.whiteColor,
              borderRadius: 4.h,)
          ],
        ),
      ),
    );
  }


}
