import 'dart:ui';
import 'package:event_app/MVVM/view_model/public_profile_controller.dart';
import 'package:event_app/Services/square_connect_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:event_app/Widget/button_widget.dart';

class AboutTab extends StatefulWidget {
  const AboutTab({super.key});

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> with WidgetsBindingObserver {
  final controller = Get.put(PublicProfileController());

  final IconData defaultIcon = FontAwesomeIcons.bolt;
  bool _isCheckingSquare = false;
  Map<String, dynamic>? _squareStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSquareStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh status when returning to app from browser
      _checkSquareStatus();
    }
  }

  Future<void> _checkSquareStatus() async {
    debugPrint(
        'AboutTab: _checkSquareStatus called. _isCheckingSquare: $_isCheckingSquare');
    if (_isCheckingSquare) return;

    setState(() {
      _isCheckingSquare = true;
    });

    try {
      final status = await SquareConnectService.checkConnectionStatus();
      debugPrint('AboutTab: _checkSquareStatus result: $status');

      if (mounted) {
        setState(() {
          _squareStatus = status;
          _isCheckingSquare = false;
        });
      }
    } catch (e) {
      debugPrint('AboutTab: _checkSquareStatus error: $e');
      if (mounted) {
        setState(() => _isCheckingSquare = false);
      }
    }
  }

  Future<void> _connectSquare() async {
    setState(() => _isCheckingSquare = true);

    try {
      final result = await SquareConnectService.getOAuthUrl();

      if (result['success'] == true && result['oauth_url'] != null) {
        final url = result['oauth_url'] as String;
        final uri = Uri.parse(url);

        // Square Sandbox significantly prefers external browsers on mobile to avoid rendering issues
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched && mounted) {
          // Fallback if external launch fails (unlikely)
          await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to get connection link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingSquare = false);
      }
    }
  }

  Future<void> _disconnectSquare() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Square Account'),
        content: const Text(
            'Are you sure you want to disconnect your Square account? You will need to reconnect to receive payments directly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await SquareConnectService.disconnect();
      if (mounted) {
        if (success) {
          await _checkSquareStatus();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Square account disconnected'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to disconnect Square account'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

// Known mappings
  final Map<String, IconData> knownInterestIcons = {
    'Games Online': FontAwesomeIcons.gamepad,
    'Concert': FontAwesomeIcons.music,
    'Music': FontAwesomeIcons.headphones,
    'Art': FontAwesomeIcons.paintbrush,
    'Movie': FontAwesomeIcons.film,
  };

  final List<Color> gradientColors = [
    const Color(0xFF817AFF),
    const Color(0xFFFD5D5D),
    const Color(0xFFFF9B57),
    const Color(0xFF5BD7A1),
    const Color(0xFF52D2FF),
  ];

  @override
  Widget build(BuildContext context) {
    debugPrint('AboutTab: Building UI...');
    return Obx(() {
      debugPrint(
          'AboutTab: Obx Triggered. Loading: ${controller.isLoading.value}, Error: ${controller.error.value}');
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else if (controller.error.isNotEmpty) {
        return Center(
            child: Text(controller.error.value,
                style: const TextStyle(color: Colors.white)));
      } else if (controller.userProfile.value == null) {
        return const Center(
            child: Text('Profile not found',
                style: TextStyle(color: Colors.white)));
      }

      final profile = controller.userProfile.value!;
      final bio = profile.data?.shortBio ?? 'No bio available';
      final rawInterests = profile.data?.interests ?? [];
      final splitInterests = rawInterests
          .map((e) => e.toString())
          .expand((e) => e.split(','))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 About Me header
            buildSectionHeader('About Me', Icons.person),

            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    bio,
                    style: TextStyles.regularwhite.copyWith(
                      height: 1.5,
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),

            /// 🔹 Square Payment Connection (for Organizers)
            buildSectionHeader('Payment Account', Icons.payment),
            _buildSquareConnectionCard(),

            SizedBox(height: 3.h),

            /// 🔹 Interests header
            buildSectionHeader('Interests', Icons.star),

            splitInterests.isEmpty
                ? Text('No interests added',
                    style: TextStyles.regularwhite.copyWith(color: Colors.grey))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(splitInterests.length, (index) {
                      final interest = splitInterests[index];
                      final icon = knownInterestIcons.entries
                          .firstWhere(
                            (entry) => interest
                                .toLowerCase()
                                .contains(entry.key.toLowerCase()),
                            orElse: () => MapEntry('default', defaultIcon),
                          )
                          .value;

                      final color =
                          gradientColors[index % gradientColors.length];

                      return Chip(
                        avatar: Icon(icon, color: Colors.white, size: 12.sp),
                        label: Text(
                          interest,
                          style: TextStyles.regularwhite,
                        ),
                        backgroundColor: color,
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 0.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      );
                    }),
                  ),
          ],
        ),
      );
    });
  }

  /// 🔹 Reusable section header
  Widget buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blueColor, size: 14.sp),
          SizedBox(width: 2.w),
          Text(
            title,
            style: TextStyles.subheading,
          ),
        ],
      ),
    );
  }

  /// 🔹 Square Connection Card
  Widget _buildSquareConnectionCard() {
    if (_isCheckingSquare) {
      return Container(
        height: 15.h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.blueColor),
        ),
      );
    }

    final isConnected = _squareStatus?['connected'] == true;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: isConnected
                ? Colors.green.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isConnected
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: (isConnected ? Colors.green : AppColors.blueColor)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isConnected
                          ? Icons.check_circle_rounded
                          : Icons.link_rounded,
                      color: isConnected ? Colors.green : AppColors.blueColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isConnected ? 'Square Connected' : 'Connect Square',
                          style: TextStyles.subheading.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isConnected &&
                            _squareStatus?['merchant_name'] != null)
                          Text(
                            _squareStatus!['merchant_name'],
                            style: TextStyles.regularwhite.copyWith(
                              fontSize: 9.sp,
                              color: Colors.white60,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                isConnected
                    ? 'Your Square account is linked. Payments will be deposited directly, with a 10% commission automatically handled.'
                    : 'Link your Square account to start receiving payments directly from your event bookings.',
                style: TextStyles.regularwhite.copyWith(
                  fontSize: 10.sp,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 3.h),
              ButtonWidget(
                text: isConnected ? 'Disconnect Account' : 'Connect Account',
                onPressed: isConnected ? _disconnectSquare : _connectSquare,
                backgroundColor: isConnected
                    ? Colors.red.withValues(alpha: 0.8)
                    : AppColors.blueColor,
                borderRadius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
