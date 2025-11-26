import 'package:event_app/MVVM/view_model/public_profile_controller.dart';
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

      return Column(
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

                    final color = gradientColors[index % gradientColors.length];

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
}
