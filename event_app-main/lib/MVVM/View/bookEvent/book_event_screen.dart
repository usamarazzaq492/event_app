import 'dart:ui';
import 'package:event_app/MVVM/View/paymentMethod/payment_method.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BookEventScreen extends StatefulWidget {
  final int? id;
  final String? preFilledTicketType;
  final double? preFilledPrice;

  const BookEventScreen({
    super.key,
    required this.id,
    this.preFilledTicketType,
    this.preFilledPrice,
  });

  @override
  State<BookEventScreen> createState() => _BookEventScreenState();
}

class _BookEventScreenState extends State<BookEventScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int seatCount = 1;
  final TextEditingController _seatCountController =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set initial tab based on pre-filled ticket type
    if (widget.preFilledTicketType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        int initialIndex = 0;
        switch (widget.preFilledTicketType!.toLowerCase()) {
          case 'vip':
            initialIndex = 1;
            break;
          default:
            initialIndex = 0;
        }
        _tabController.animateTo(initialIndex);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _seatCountController.dispose();
    super.dispose();
  }

  void _updateSeatCount(int newCount) {
    if (newCount < 1) {
      newCount = 1;
    }
    // Removed upper limit to allow users to type larger numbers like 25
    setState(() {
      seatCount = newCount;
      _seatCountController.text = newCount.toString();
    });
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔷 TabBar Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2.h),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(2.h),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.white38,
                                  indicator: BoxDecoration(
                                    color: AppColors.blueColor,
                                    borderRadius: BorderRadius.circular(1.8.h),
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  labelStyle: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.2,
                                  ),
                                  tabs: const [
                                    Tab(text: 'General'),
                                    Tab(text: 'VIP'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),

                          // 🔷 Pre-filled price display
                          if (widget.preFilledPrice != null &&
                              widget.preFilledPrice! > 0)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2.h),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  margin: EdgeInsets.only(top: 3.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.blueColor
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(2.h),
                                    border: Border.all(
                                      color: AppColors.blueColor
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner_rounded,
                                        color: AppColors.blueColor,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        'Price: \$${widget.preFilledPrice!.toStringAsFixed(2)} per ticket',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 4.h),

                          // 🔷 Seat selection label
                          Text(
                            'How many tickets?',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // 🔷 Counter with Text Input
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2.5.h),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(2.5.h),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildCounterButton(Icons.remove_rounded,
                                        () {
                                      HapticUtils.light();
                                      _updateSeatCount(seatCount - 1);
                                    }),
                                    const SizedBox(width: 30),
                                    // TextField for direct input
                                    Expanded(
                                      child: TextField(
                                        controller: _seatCountController,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: '0',
                                          hintStyle:
                                              TextStyle(color: Colors.white24),
                                        ),
                                        onChanged: (value) {
                                          final intValue = int.tryParse(value);
                                          if (intValue != null &&
                                              intValue >= 1) {
                                            setState(() {
                                              seatCount = intValue;
                                            });
                                          }
                                        },
                                        onEditingComplete: () {
                                          final intValue = int.tryParse(
                                              _seatCountController.text);
                                          if (intValue == null ||
                                              intValue < 1) {
                                            _updateSeatCount(1);
                                          } else {
                                            _updateSeatCount(intValue);
                                          }
                                          FocusScope.of(context).unfocus();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    _buildCounterButton(Icons.add_rounded, () {
                                      HapticUtils.light();
                                      _updateSeatCount(seatCount + 1);
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),

                          // 🔷 Continue Button
                          SizedBox(
                            width: double.infinity,
                            height: 6.5.h,
                            child: GestureDetector(
                              onTap: () {
                                HapticUtils.buttonPress();
                                String ticketType;
                                switch (_tabController.index) {
                                  case 0:
                                    ticketType = 'general';
                                    break;
                                  case 1:
                                    ticketType = 'vip';
                                    break;
                                  default:
                                    ticketType = 'general';
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentMethodScreen(
                                      category: ticketType,
                                      seats: seatCount,
                                      id: widget.id,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.blueColor,
                                      AppColors.blueColor
                                          .withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(4.h),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.blueColor
                                          .withValues(alpha: 0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Continue to Payment',
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
                        ],
                      ),
                    ),
                  ),
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
                    'Book Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }

  // Counter Button Widget
  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(1.2.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(1.2.h),
          border: Border.all(
            color: AppColors.blueColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, color: AppColors.blueColor, size: 20.sp),
      ),
    );
  }
}
