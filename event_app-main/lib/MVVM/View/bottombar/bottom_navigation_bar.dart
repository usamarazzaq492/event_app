import 'dart:ui';
import 'package:event_app/MVVM/View/ProfileScreen/profile_screen.dart';
import 'package:event_app/MVVM/view_model/bottom_nav_controller.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../utils/accessibility_utils.dart';
import '../../../utils/haptic_utils.dart';

import '../HomeScreen/home_screen.dart';
import '../CreateAd/all_ads_screen.dart';
import '../exploreevent/explore_event screen.dart';
import '../ticketScreen/ticket_screen.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;

  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late final BottomNavController navController;

  final List<Map<String, String>> _navItems = [
    {
      'label': 'Discover',
      'filled': AppImages.homefilledIcon,
      'outline': AppImages.homeoutlinedIcon
    },
    {
      'label': 'Search',
      'filled': AppImages.explorefilledIcon,
      'outline': AppImages.exploreoutlinedIcon
    },
    {
      'label': 'Ads',
      'filled': AppImages.adsfilledIcon,
      'outline': AppImages.adsoutlinedIcon
    },
    {
      'label': 'My Tickets',
      'filled': AppImages.ticketfilledIcon,
      'outline': AppImages.ticketoutlinedIcon
    },
    {
      'label': 'Profile',
      'filled': AppImages.profilefilledIcon,
      'outline': AppImages.profilefilledIcon
    },
  ];

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreEventScreen(),
    const AllAdsScreen(),
    const TicketScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    navController = Get.put(
        BottomNavController(initialIndex: widget.initialIndex),
        tag: 'BottomNavController');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: true, // Allows the glass bar to float over content
      body: Obx(() => IndexedStack(
            index: navController.selectedIndex.value,
            children: _screens,
          )),
      bottomNavigationBar: Obx(() {
        final double bottomPadding = MediaQuery.of(context).padding.bottom;
        return Container(
          margin: EdgeInsets.fromLTRB(
              4.w, 0, 4.w, bottomPadding > 0 ? bottomPadding : 2.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.h),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                decoration: BoxDecoration(
                  color: AppColors.bottombarcolor.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(3.h),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_navItems.length, (index) {
                    final bool isSelected =
                        navController.selectedIndex.value == index;
                    return Expanded(
                      child: AccessibilityUtils.accessibleBottomNavigation(
                        label: _navItems[index]['label']!,
                        selected: isSelected,
                        onTap: () {
                          HapticUtils.selection();
                          navController.changeTab(index);
                        },
                        child: GestureDetector(
                          onTap: () {
                            HapticUtils.selection();
                            navController.changeTab(index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutQuint,
                            padding: EdgeInsets.symmetric(vertical: 0.8.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.blueColor.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2.h),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  isSelected
                                      ? _navItems[index]['filled']!
                                      : _navItems[index]['outline']!,
                                  width: 2.6.h,
                                  height: 2.6.h,
                                  color: isSelected
                                      ? AppColors.blueColor
                                      : Colors.white54,
                                ),
                                SizedBox(height: 0.4.h),
                                Text(
                                  _navItems[index]['label']!,
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.blueColor
                                        : Colors.white54,
                                    fontFamily: 'Montserrat',
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
