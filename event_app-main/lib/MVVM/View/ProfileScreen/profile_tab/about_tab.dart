import 'package:event_app/MVVM/view_model/public_profile_controller.dart';
import 'package:event_app/MVVM/View/SquareConnect/square_oauth_webview.dart';
import 'package:event_app/Services/square_connect_service.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutTab extends StatefulWidget {
  const AboutTab({super.key});

  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  final controller = Get.put(PublicProfileController());

  final IconData defaultIcon = FontAwesomeIcons.bolt;
  bool _isCheckingSquare = false;
  Map<String, dynamic>? _squareStatus;

  @override
  void initState() {
    super.initState();
    _checkSquareStatus();
  }

  Future<void> _checkSquareStatus() async {
    setState(() {
      _isCheckingSquare = true;
    });

    final status = await SquareConnectService.checkConnectionStatus();

    if (mounted) {
      setState(() {
        _squareStatus = status;
        _isCheckingSquare = false;
      });
    }
  }

  Future<void> _connectSquare() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SquareOAuthWebView(),
      ),
    );

    if (result == true) {
      // Refresh status after successful connection
      await _checkSquareStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Square account connected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
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
    Color(0xFF817AFF),
    Color(0xFFFD5D5D),
    Color(0xFFFF9B57),
    Color(0xFF5BD7A1),
    Color(0xFF52D2FF),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      } else if (controller.error.isNotEmpty) {
        return Center(
            child: Text(controller.error.value,
                style: TextStyle(color: Colors.white)));
      } else if (controller.userProfile.value == null) {
        return Center(
            child: Text('Profile not found',
                style: TextStyle(color: Colors.white)));
      }

      final profile = controller.userProfile.value!;
      final bio = profile.data?.shortBio ?? 'No bio available';
      final rawInterests = profile.data?.interests ?? [];
      final splitInterests = rawInterests
          .expand((e) => e.split(','))
          .map((e) => e.trim())
          .toList();

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 About Me header
            buildSectionHeader('About Me', Icons.person),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.signinoptioncolor,
                    AppColors.backgroundColor
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                bio,
                style: TextStyles.regularwhite.copyWith(
                  height: 1.4,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
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
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppColors.signinoptioncolor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isConnected = _squareStatus?['connected'] == true;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isConnected ? Colors.green : AppColors.blueColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConnected ? Icons.check_circle : Icons.link,
                color: isConnected ? Colors.green : AppColors.blueColor,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  isConnected
                      ? 'Square Account Connected'
                      : 'Connect Square Account',
                  style: TextStyles.subheading.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            isConnected
                ? 'You receive payments directly to your Square account. App owner commission (10%) is automatically deducted.'
                : 'Connect your Square account to receive payments directly when customers book your events.',
            style: TextStyles.regularwhite.copyWith(
              fontSize: 10.sp,
              color: Colors.white70,
            ),
          ),
          if (isConnected && _squareStatus?['merchant_name'] != null) ...[
            SizedBox(height: 1.h),
            Text(
              'Merchant: ${_squareStatus!['merchant_name']}',
              style: TextStyles.regularwhite.copyWith(
                fontSize: 9.sp,
                color: Colors.white60,
              ),
            ),
          ],
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isConnected ? _disconnectSquare : _connectSquare,
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected ? Colors.red : AppColors.blueColor,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isConnected ? 'Disconnect' : 'Connect Square Account',
                style: TextStyles.regularwhite.copyWith(
                  fontSize: 11.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
