import 'dart:ui';
import 'package:event_app/Services/promotion_service.dart';
import 'package:event_app/Services/payment_web_view.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/utils/haptic_utils.dart';
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
              'description':
                  'Boost your event for 10 days to increase visibility',
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
            'description':
                'Boost your event for 10 days to increase visibility',
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
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -15.h,
            left: -15.w,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blueColor.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoadingPackages
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticUtils.navigation();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(1.2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Promote Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 44), // Placeholder for symmetry
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Title Card
          ClipRRect(
            borderRadius: BorderRadius.circular(2.h),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(2.h),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(1.5.w),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(1.h),
                      ),
                      child: Icon(Icons.event_available_rounded,
                          color: AppColors.blueColor, size: 18.sp),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        widget.eventTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),

          // Boost Benefits Section
          Text(
            'Boost Benefits',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2.5.h),
          _buildBenefitItem(
            Icons.trending_up_rounded,
            'Increased Visibility',
            'Your event appears in the Ads section and gets more exposure',
          ),
          _buildBenefitItem(
            Icons.verified_rounded,
            'Promoted Badge',
            'Get a special "Promoted" badge on your event',
          ),
          _buildBenefitItem(
            Icons.home_max_rounded,
            'Homepage Featured',
            'Featured section on the main discovery feed',
          ),
          _buildBenefitItem(
            Icons.people_alt_rounded,
            'Reach More People',
            'Maximize your attendance by reaching active users',
          ),
          SizedBox(height: 4.h),

          // Single Boost Package Card
          if (_boostPackage != null) ...[
            Text(
              'Available Package',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2.h),
            _buildBoostCard(_boostPackage!),
            SizedBox(height: 4.h),
          ],

          // Purchase Button
          Hero(
            tag: 'promote_button',
            child: SizedBox(
              width: double.infinity,
              height: 6.5.h,
              child: GestureDetector(
                onTap: () {
                  HapticUtils.buttonPress();
                  if (!_isLoading) _purchaseBoost();
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.blueColor,
                        AppColors.blueColor.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(4.h),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blueColor.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Promote Now - \$${_boostPackage?['price']?.toStringAsFixed(0) ?? BOOST_PRICE.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Info Text
          ClipRRect(
            borderRadius: BorderRadius.circular(2.h),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(2.h),
                  border: Border.all(
                    color: AppColors.blueColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.blueColor,
                      size: 18.sp,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Your event will be boosted for ${_boostPackage?['durationDays'] ?? BOOST_DURATION_DAYS} days. You can boost again after it expires.',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white60,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_error != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(1.5.h),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red, fontSize: 10.sp),
              ),
            ),
          ],
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1.8.h),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(2.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(1.8.h),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(1.2.h),
                  ),
                  child: Icon(icon, color: AppColors.blueColor, size: 18.sp),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoostCard(Map<String, dynamic> boostData) {
    final price = boostData['price']?.toStringAsFixed(2) ??
        BOOST_PRICE.toStringAsFixed(2);
    final durationDays =
        boostData['durationDays']?.toString() ?? BOOST_DURATION_DAYS.toString();
    final name = boostData['name']?.toString() ?? 'Event Boost';
    final description = boostData['description']?.toString() ??
        'Boost your event visibility for 10 days';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blueColor,
            AppColors.blueColor.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(2.5.h),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DURATION',
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '$durationDays Days',
                    style: TextStyle(
                      fontSize: 18.sp,
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
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '\$$price',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
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
