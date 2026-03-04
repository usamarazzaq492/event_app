import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/Widget/input_text_field.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';
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
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          /// Gradient header (consistent with Auth/Profile screens)
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Text(
                      'Add New Card',
                      style: TextStyles.heading.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer for balance
                  ],
                ),
                SizedBox(height: 3.h),

                /// Visual Card Illustration with a subtle glow
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blueColor.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    AppImages.creditcard,
                    height: 20.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),

          /// Form card (Glassmorphic)
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Card Details',
                        style: TextStyles.heading.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Securely add your payment method',
                        style: TextStyles.regularwhite.copyWith(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      /// Input Fields (consistent with Auth/Profile)
                      _buildLabeledField(
                        label: 'Card Holder Name',
                        child: InputTextField(
                          myController: cardNameController,
                          keyBoardType: TextInputType.name,
                          obscureText: false,
                          hint: 'e.g. John Doe',
                          validator: (v) =>
                              v!.isEmpty ? 'Enter card name' : null,
                        ),
                      ),
                      SizedBox(height: 2.5.h),

                      _buildLabeledField(
                        label: 'Card Number',
                        child: InputTextField(
                          myController: cardNumberController,
                          keyBoardType: TextInputType.number,
                          obscureText: false,
                          hint: '**** **** **** ****',
                          validator: (v) =>
                              v!.length < 16 ? 'Invalid card number' : null,
                        ),
                      ),
                      SizedBox(height: 2.5.h),

                      Row(
                        children: [
                          Expanded(
                            child: _buildLabeledField(
                              label: 'Expiry Date',
                              child: InputTextField(
                                myController: expiryDateController,
                                keyBoardType: TextInputType.datetime,
                                obscureText: false,
                                hint: 'MM/YY',
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: _buildLabeledField(
                              label: 'CVV',
                              child: InputTextField(
                                myController: cvvController,
                                keyBoardType: TextInputType.number,
                                obscureText: true,
                                hint: '***',
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h),

                      /// Continue Button
                      ButtonWidget(
                        text: 'Continue',
                        onPressed: () {
                          HapticUtils.buttonPress();
                          if (cardNumberController.text.length >= 4) {
                            Navigator.pop(
                              context,
                              '**** **** **** ${cardNumberController.text.substring(cardNumberController.text.length - 4)}',
                            );
                          }
                        },
                        backgroundColor: AppColors.blueColor,
                        textColor: AppColors.whiteColor,
                        borderRadius: 14,
                      ),
                    ],
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
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 1.h),
        child,
      ],
    );
  }
}
