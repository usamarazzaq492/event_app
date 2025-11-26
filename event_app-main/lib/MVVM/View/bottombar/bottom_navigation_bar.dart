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

  const BottomNavBar({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late final BottomNavController navController;

  final List<Map<String, String>> _navItems = [
    {
      'label': 'Home',
      'filled': AppImages.homefilledIcon,
      'outline': AppImages.homeoutlinedIcon
    },
    {
      'label': 'Explore',
      'filled': AppImages.explorefilledIcon,
      'outline': AppImages.exploreoutlinedIcon
    },
    {
      'label': 'Ads',
      'filled': AppImages.adsfilledIcon,
      'outline': AppImages.adsoutlinedIcon
    },
    {
      'label': 'Tickets',
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
    HomeScreen(),
    ExploreEventScreen(),
    AllAdsScreen(),
    TicketScreen(),
    ProfileScreen(),
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
      body: Obx(() => IndexedStack(
            index: navController.selectedIndex.value,
            children: _screens,
          )),
      bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
              color: AppColors.bottombarcolor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(1.6.h)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 2.w),
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
                    HapticUtils.navigation();
                    navController.changeTab(index);
                  },
                  child: GestureDetector(
                    onTap: () {
                      HapticUtils.navigation();
                      navController.changeTab(index);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 0.4.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Selected indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            height: isSelected ? 3 : 0,
                            width: 14,
                            margin: EdgeInsets.only(bottom: 0.4.h),
                            decoration: BoxDecoration(
                              color: AppColors.blueColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(0.8.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.blueColor.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              isSelected
                                  ? _navItems[index]['filled']!
                                  : _navItems[index]['outline']!,
                              width: 2.8.h,
                              height: 2.8.h,
                              color: isSelected
                                  ? AppColors.blueColor
                                  : Colors.white54,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            _navItems[index]['label']!,
                            style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.blueColor
                                  : Colors.white54,
                              fontFamily: 'Montserrat',
                              fontFamilyFallback: ['Inter', 'Roboto', 'Arial'],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                  ),
                ));
              }),
            ),
          )),
    );
  }
}
