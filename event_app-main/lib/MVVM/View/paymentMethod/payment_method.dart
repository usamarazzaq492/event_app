import 'package:event_app/Services/payment_web_view.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String category;
  final int seats;
  final int? id;

  const PaymentMethodScreen({
    super.key,
    required this.category,
    required this.seats,
    required this.id,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int selectedIndex = 0;
  List<String> paymentOptions = ['Square Payment'];
  List<String> addedCards = []; // Integrate saved cards later

  @override
  Widget build(BuildContext context) {
    print('category ${widget.category}');
    print('seats ${widget.seats}');
    print('event id ${widget.id}');

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 15.w),
                Text(
                  'Payment Method',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // 🔷 Description
            Text(
              'Select the payment method you want to use.',
              style: TextStyle(color: Colors.white70, fontSize: 11.sp),
            ),
            SizedBox(height: 3.h),

            // 🔷 Payment options
            ...List.generate(paymentOptions.length, (index) {
              return _paymentOptionTile(index, paymentOptions[index]);
            }),

            // 🔷 Saved cards (future enhancement)
            ...List.generate(addedCards.length, (index) {
              return _paymentOptionTile(
                  paymentOptions.length + index, addedCards[index]);
            }),

            const Spacer(),

            // 🔷 Pay Now button
            ButtonWidget(
              text: 'PAY NOW',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SquarePaymentPage(
                      category: widget.category,
                      seats: widget.seats,
                      id: widget.id,
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.blueColor,
              textColor: AppColors.whiteColor,
              borderRadius: 4.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOptionTile(int index, String title) {
    return Card(
      color: AppColors.signinoptioncolor,
      margin: EdgeInsets.only(bottom: 1.5.h),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Radio(
          activeColor: AppColors.blueColor,
          value: index,
          groupValue: selectedIndex,
          onChanged: (value) {
            setState(() {
              selectedIndex = value!;
            });
          },
        ),
      ),
    );
  }
}
