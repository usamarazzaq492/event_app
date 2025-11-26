import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/CreateAd/payment_donate_screen.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/Widget/input_text_field.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DonationScreen extends StatefulWidget {
  final int? donId;
  final String? imageUrl; // 🔷 pass ad image url

  const DonationScreen({super.key, required this.donId, this.imageUrl});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final TextEditingController amountcontroller = TextEditingController();
  final priceFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 Hero Ad Image
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://eventgo-live.com${widget.imageUrl ?? ''}',
                  height: 25.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 25.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                    ),
                  ),
                ),
                Positioned(
                  top: 2.h,
                  left: 4.w,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(1.h),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2.h,
                  left: 5.w,
                  child: Text(
                    'Donation',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                    ),
                  ),
                ),
              ],
            ),

            // 🔷 Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Amount",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    InputTextField(
                      myController: amountcontroller,
                      focusNode: priceFocusNode,
                      onFieldSubmittedValue: (value) {},
                      keyBoardType: TextInputType.number,
                      obscureText: false,
                      hint: 'Enter amount',
                      validator: (value) => null,
                    ),
                    SizedBox(height: 3.h),

                    Text(
                      "Why Donate?",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "Your contribution will help achieve the ad's target and support the cause effectively.",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.sp,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔷 Donate Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: ButtonWidget(
                text: 'Donate Now',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentDonateScreen(
                        donaid: widget.donId,
                        donate: amountcontroller.text,
                      ),
                    ),
                  );
                },
                borderRadius: 4.h,
                textColor: AppColors.whiteColor,
                backgroundColor: AppColors.blueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
