import 'package:event_app/Services/promotion_service.dart';
import 'package:event_app/Services/payment_web_view.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class PromoteEventScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const PromoteEventScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<PromoteEventScreen> createState() => _PromoteEventScreenState();
}

class _PromoteEventScreenState extends State<PromoteEventScreen> {
  final PromotionService _promotionService = PromotionService();
  bool _isLoading = false;
  bool _isLoadingPackages = true;
  Map<String, dynamic>? _packages;
  String? _selectedPackage;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      setState(() {
        _isLoadingPackages = true;
        _error = null;
      });

      final response = await _promotionService.getPackages();
      if (response['success'] == true) {
        setState(() {
          _packages = response['data'];
          _isLoadingPackages = false;
        });
      } else {
        throw Exception('Failed to load packages');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingPackages = false;
      });
    }
  }

  Future<void> _purchasePromotion() async {
    if (_selectedPackage == null) {
      Get.snackbar('Selection Required', 'Please select a promotion package',
          backgroundColor: Colors.orange);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Navigate to Square payment page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SquarePaymentPage(
            category: _selectedPackage == 'basic' ? 'basic' : 'premium',
            seats: 1,
            id: widget.eventId,
            isPromotion: true,
          ),
        ),
      ).then((success) {
        if (success == true) {
          Get.back(); // Close promotion screen
          Get.snackbar(
            'Success! 🎉',
            'Your event is now promoted!',
            backgroundColor: AppColors.blueColor,
            colorText: Colors.white,
          );
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        title: Text(
          'Promote Event',
          style: TextStyles.heading,
        ),
      ),
      body: _isLoadingPackages
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _packages == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading packages',
                        style: TextStyles.regularwhite.copyWith(
                            color: Colors.red),
                      ),
                      SizedBox(height: 2.h),
                      ButtonWidget(
                        text: 'Retry',
                        onPressed: _loadPackages,
                        backgroundColor: AppColors.blueColor,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Title
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppColors.signinoptioncolor,
                          borderRadius: BorderRadius.circular(2.h),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event, color: AppColors.blueColor),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                widget.eventTitle,
                                style: TextStyles.homeheadingtext,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Benefits Section
                      Text(
                        'Promotion Benefits',
                        style: TextStyles.subheading,
                      ),
                      SizedBox(height: 2.h),
                      _buildBenefitItem(
                        Icons.trending_up,
                        'Top of Search Results',
                        'Your event appears first in all search results',
                      ),
                      _buildBenefitItem(
                        Icons.verified,
                        'Promoted Badge',
                        'Get a special "Promoted" badge on your event',
                      ),
                      _buildBenefitItem(
                        Icons.home,
                        'Homepage Featured',
                        'Featured section on the homepage',
                      ),
                      SizedBox(height: 4.h),

                      // Packages Section
                      Text(
                        'Choose a Package',
                        style: TextStyles.subheading,
                      ),
                      SizedBox(height: 2.h),

                      if (_packages != null) ...[
                        // Basic Package
                        _buildPackageCard(
                          'Basic',
                          _packages!['basic'],
                          'basic',
                          Colors.blue,
                        ),
                        SizedBox(height: 2.h),

                        // Premium Package
                        _buildPackageCard(
                          'Premium',
                          _packages!['premium'],
                          'premium',
                          Colors.orange,
                        ),
                      ],

                      SizedBox(height: 4.h),

                      // Purchase Button
                      ButtonWidget(
                        text: _isLoading
                            ? 'Processing...'
                            : 'Purchase Promotion',
                        onPressed: _isLoading ? null : _purchasePromotion,
                        backgroundColor: _selectedPackage != null
                            ? AppColors.blueColor
                            : Colors.grey,
                        textColor: Colors.white,
                        borderRadius: 4.h,
                      ),

                      if (_error != null) ...[
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(1.h),
                          ),
                          child: Text(
                            _error!,
                            style: TextStyles.regularwhite.copyWith(
                                color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(1.h),
            ),
            child: Icon(icon, color: AppColors.blueColor, size: 20.sp),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.homeheadingtext.copyWith(fontSize: 13.sp),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: TextStyles.regularwhite.copyWith(
                    color: Colors.white70,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    String packageName,
    Map<String, dynamic> packageData,
    String packageKey,
    Color accentColor,
  ) {
    final isSelected = _selectedPackage == packageKey;
    final price = packageData['price']?.toString() ?? '0';
    final durationDays = packageData['durationDays']?.toString() ?? '0';

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPackage = packageKey;
        });
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppColors.signinoptioncolor,
          borderRadius: BorderRadius.circular(2.h),
          border: Border.all(
            color: isSelected
                ? AppColors.blueColor
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(1.h),
              ),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? accentColor : Colors.white70,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    packageName,
                    style: TextStyles.homeheadingtext.copyWith(
                      fontSize: 15.sp,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '\$$price for $durationDays days',
                    style: TextStyles.regularwhite.copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Text(
              '\$$price',
              style: TextStyles.heading.copyWith(
                fontSize: 18.sp,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




