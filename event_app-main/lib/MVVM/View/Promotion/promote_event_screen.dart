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
  Map<String, dynamic>? _boostPackage;
  String? _error;

  // Single boost option: $35 for 10 days
  static const double BOOST_PRICE = 35.00;
  static const int BOOST_DURATION_DAYS = 10;

  @override
  void initState() {
    super.initState();
    _loadBoostPackage();
  }

  Future<void> _loadBoostPackage() async {
    try {
      setState(() {
        _isLoadingPackages = true;
        _error = null;
      });

      final response = await _promotionService.getPackages();

      // Handle different response formats
      if (response['success'] == true || response['success'] == 'true') {
        final data = response['data'];
        if (data != null && data is Map && data['boost'] != null) {
          setState(() {
            _boostPackage = Map<String, dynamic>.from(data['boost']);
            _isLoadingPackages = false;
          });
        } else {
          // Fallback to default boost values
          setState(() {
            _boostPackage = {
              'price': BOOST_PRICE,
              'durationDays': BOOST_DURATION_DAYS,
              'name': 'Event Go-Live Boost',
              'description': 'Boost your event for 10 days to increase visibility',
            };
            _isLoadingPackages = false;
          });
        }
      } else {
        // Fallback to default boost values
        setState(() {
          _boostPackage = {
            'price': BOOST_PRICE,
            'durationDays': BOOST_DURATION_DAYS,
            'name': 'Event Go-Live Boost',
            'description': 'Boost your event for 10 days to increase visibility',
          };
          _isLoadingPackages = false;
        });
      }
    } catch (e) {
      print('Error loading boost package: $e');
      // Use fallback values on error
      setState(() {
        _boostPackage = {
          'price': BOOST_PRICE,
          'durationDays': BOOST_DURATION_DAYS,
          'name': 'Event Go-Live Boost',
          'description': 'Boost your event for 10 days to increase visibility',
        };
        _isLoadingPackages = false;
      });
    }
  }

  Future<void> _purchaseBoost() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Navigate to Square payment page with 'boost' package
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SquarePaymentPage(
            category: 'boost', // Always use 'boost' for new system
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
            'Your event is now boosted for 10 days!',
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

                  // Boost Benefits Section
                  Text(
                    'Boost Your Event',
                    style: TextStyles.subheading,
                  ),
                  SizedBox(height: 2.h),
                  _buildBenefitItem(
                    Icons.trending_up,
                    'Increased Visibility',
                    'Your event appears in the Ads section and gets more exposure',
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
                  _buildBenefitItem(
                    Icons.people,
                    'Reach More People',
                    'Your event will be seen by more users browsing the app',
                  ),
                  SizedBox(height: 4.h),

                  // Single Boost Package Card
                  if (_boostPackage != null) ...[
                    Text(
                      'Boost Package',
                      style: TextStyles.subheading,
                    ),
                    SizedBox(height: 2.h),
                    _buildBoostCard(_boostPackage!),
                    SizedBox(height: 4.h),
                  ],

                  // Purchase Button
                  ButtonWidget(
                    text: _isLoading
                        ? 'Processing...'
                        : 'Boost Event for \$${_boostPackage?['price']?.toStringAsFixed(0) ?? BOOST_PRICE.toStringAsFixed(0)}',
                    onPressed: _isLoading ? null : _purchaseBoost,
                    backgroundColor: AppColors.blueColor,
                    textColor: Colors.white,
                    borderRadius: 4.h,
                  ),

                  SizedBox(height: 2.h),

                  // Info Text
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppColors.blueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2.h),
                      border: Border.all(
                        color: AppColors.blueColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.blueColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Your event will be boosted for ${_boostPackage?['durationDays'] ?? BOOST_DURATION_DAYS} days. You can boost again after it expires.',
                            style: TextStyles.regularwhite.copyWith(
                              fontSize: 11.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        style: TextStyles.regularwhite
                            .copyWith(color: Colors.red),
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

  Widget _buildBoostCard(Map<String, dynamic> boostData) {
    final price = boostData['price']?.toStringAsFixed(2) ?? BOOST_PRICE.toStringAsFixed(2);
    final durationDays = boostData['durationDays']?.toString() ?? BOOST_DURATION_DAYS.toString();
    final name = boostData['name']?.toString() ?? 'Event Go-Live Boost';
    final description = boostData['description']?.toString() ?? 'Boost your event for 10 days to increase visibility';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blueColor,
            AppColors.blueColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(2.5.h),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(1.h),
                ),
                child: Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyles.homeheadingtext.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      description,
                      style: TextStyles.regularwhite.copyWith(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration',
                    style: TextStyles.regularwhite.copyWith(
                      fontSize: 10.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '$durationDays Days',
                    style: TextStyles.homeheadingtext.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Price',
                    style: TextStyles.regularwhite.copyWith(
                      fontSize: 10.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '\$$price',
                    style: TextStyles.heading.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
