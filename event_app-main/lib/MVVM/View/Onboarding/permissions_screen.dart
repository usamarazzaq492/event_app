import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_pages.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

/// Eventbrite-style permissions screen shown on first app install.
/// Explains benefits before requesting Location and Notification permissions.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isRequesting = false;
  bool _locationGranted = false;
  bool _notificationGranted = false;

  Future<void> _requestPermissions() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    try {
      // Request location (when in use)
      final locationStatus = await Permission.locationWhenInUse.request();
      if (mounted) {
        setState(() {
          _locationGranted = locationStatus.isGranted;
        });
      }

      // Request notifications
      final notificationStatus = await Permission.notification.request();
      if (mounted) {
        setState(() {
          _notificationGranted = notificationStatus.isGranted;
        });
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  void _onContinue() async {
    await _requestPermissions();
    await _markOnboardingComplete();
    if (mounted) {
      Get.offAllNamed(RouteName.bottomNav);
    }
  }

  void _onSkip() async {
    await _markOnboardingComplete();
    Get.offAllNamed(RouteName.bottomNav);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 4.h),

              // Header
              Text(
                'Get the most out of EventGo',
                style: TextStyles.subheading.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.5.h),
              Text(
                'Enable these to discover events near you and never miss an update.',
                style: TextStyles.regularhometext.copyWith(
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5.h),

              // Location permission card
              _PermissionCard(
                icon: Icons.location_on_outlined,
                iconColor: Colors.green.shade400,
                title: 'Location',
                subtitle: 'Find events near you',
                description: 'See events happening in your area on your home feed.',
                isGranted: _locationGranted,
              ),
              SizedBox(height: 3.h),

              // Notification permission card
              _PermissionCard(
                icon: Icons.notifications_outlined,
                iconColor: Colors.orange.shade400,
                title: 'Notifications',
                subtitle: 'Stay in the loop',
                description: 'Get reminders about your tickets and events you might like.',
                isGranted: _notificationGranted,
              ),

              const Spacer(),

              // Turn on button
              ButtonWidget(
                text: _isRequesting ? 'Enabling...' : 'Turn on',
                onPressed: _isRequesting ? null : _onContinue,
                backgroundColor: AppColors.blueColor,
                borderRadius: 4.h,
              ),
              SizedBox(height: 2.h),

              // Skip link
              TextButton(
                onPressed: _onSkip,
                child: Text(
                  'Maybe later',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;
  final bool isGranted;

  const _PermissionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isGranted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.5.h),
        border: Border.all(
          color: isGranted
              ? Colors.green.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2.h),
            ),
            child: Icon(icon, size: 28.sp, color: iconColor),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyles.regularwhite.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isGranted) ...[
                      SizedBox(width: 2.w),
                      Icon(Icons.check_circle, size: 18.sp, color: Colors.green),
                    ],
                  ],
                ),
                SizedBox(height: 0.3.h),
                Text(
                  subtitle,
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 11.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 10.sp,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
