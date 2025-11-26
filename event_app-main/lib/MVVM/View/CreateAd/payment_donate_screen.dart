import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'donation_webview_screen.dart';

class PaymentDonateScreen extends StatefulWidget {
  final int? donaid;
  final String donate;

  const PaymentDonateScreen({super.key, required this.donate, required this.donaid});

  @override
  State<PaymentDonateScreen> createState() => _PaymentDonateScreenState();
}

class _PaymentDonateScreenState extends State<PaymentDonateScreen> {
  int selectedIndex = 0;
  List<String> paymentOptions = ['Square Payment'];
  List<String> addedCards = []; // Future integration

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Method',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select the payment method you want to use.',
              style: TextStyle(color: Colors.white70, fontSize: 11.sp),
            ),
            SizedBox(height: 3.h),
            ...List.generate(paymentOptions.length, (index) {
              return _paymentOptionTile(index, paymentOptions[index]);
            }),
            if (addedCards.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text('Saved Cards', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 1.h),
              ...List.generate(addedCards.length, (index) {
                return _paymentOptionTile(paymentOptions.length + index, addedCards[index]);
              }),
            ],
            const Spacer(),
            _addNewCardButton(context),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _paymentOptionTile(int index, String title) {
    return Card(
      color: AppColors.signinoptioncolor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: EdgeInsets.only(bottom: 1.5.h),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
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

  Widget _addNewCardButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueColor,
          padding: EdgeInsets.symmetric(vertical: 1.8.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        label: const Text(
          'PAY NOW',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DonationWebView(donationid: widget.donaid, donation: widget.donate),
            ),
          );
        },
      ),
    );
  }
}
