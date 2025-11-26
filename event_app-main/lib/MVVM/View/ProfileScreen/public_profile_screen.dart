import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/view_model/data_view_model.dart';
import 'package:event_app/MVVM/view_model/public_profile_controller.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:event_app/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';

class PublicProfileScreen extends StatefulWidget {
  final int? id;

  const PublicProfileScreen({super.key, required this.id});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final PublicProfileController controller = Get.put(PublicProfileController());
  final DataViewModel dataViewModel = Get.put(DataViewModel());

  final Map<String, IconData> knownInterestIcons = {
    'music': Icons.music_note,
    'sports': Icons.sports_soccer,
    'travel': Icons.flight_takeoff,
    'coding': Icons.code,
    'reading': Icons.menu_book,
    'default': Icons.star,
  };

  final IconData defaultIcon = Icons.star;

  final List<Color> gradientColors = [
    const Color(0xFF817AFF),
    const Color(0xFFFD5D5D),
    const Color(0xFFFF9B57),
    const Color(0xFF817AFF),
    const Color(0xFF5BD7A1),
    const Color(0xFF52D2FF),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadProfile();
    });
  }

  Future<void> loadProfile() async {
    await controller.loadPublicProfile(widget.id);
    final profile = controller.profile.value;
    if (profile != null) {
      dataViewModel.initializeFollowState(
        profile.isFollowing ?? false,
        profile.followersCount ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        } else if (controller.error.isNotEmpty) {
          return _buildErrorState();
        } else if (controller.profile.value == null) {
          return _buildEmptyState();
        }

        final profile = controller.profile.value!;
        final rawInterests = profile.interests ?? [];
        final splitInterests =
            rawInterests.expand((e) => e.split(',')).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await loadProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 7.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                SizedBox(height: 3.h),

                // Profile Image
                _buildProfileImage(profile),
                SizedBox(height: 3.h),

                // Name
                _buildName(profile),
                SizedBox(height: 2.h),

                // Stats Card
                _buildStatsCard(profile),
                SizedBox(height: 2.h),

                // Action Buttons
                _buildActionButtons(profile),
                SizedBox(height: 3.h),

                // About Section
                _buildAboutSection(profile),
                SizedBox(height: 3.h),

                // Interests Section
                _buildInterestsSection(splitInterests),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Loading State
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueColor),
            strokeWidth: 3,
          ),
          SizedBox(height: 3.h),
          Text(
            'Loading profile...',
            style: TextStyles.regularwhite.copyWith(
              fontSize: 12.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Error State
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Colors.red.shade400,
          ),
          SizedBox(height: 3.h),
          Text(
            'Error Loading Profile',
            style: TextStyles.homeheadingtext.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            controller.error.value,
            style: TextStyles.regularwhite.copyWith(
              fontSize: 11.sp,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: () => loadProfile(),
            icon: Icon(Icons.refresh, size: 14.sp),
            label: Text('Retry', style: TextStyle(fontSize: 12.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 48.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 3.h),
          Text(
            'Profile Not Found',
            style: TextStyles.homeheadingtext.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'This profile doesn\'t exist or has been removed.',
            style: TextStyles.regularwhite.copyWith(
              fontSize: 11.sp,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: () => NavigationUtils.pop(context),
            icon: Icon(Icons.arrow_back, size: 14.sp),
            label: Text('Go Back', style: TextStyle(fontSize: 12.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            HapticUtils.navigation();
            NavigationUtils.pop(context);
          },
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        SizedBox(width: 5.w),
        Text(
          'Profile',
          style: TextStyles.heading,
        ),
        const Spacer(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (String value) {
            HapticUtils.light();
            if (value == 'share') {
              _shareProfile();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Share Profile'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Profile Image
  Widget _buildProfileImage(dynamic profile) {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundImage: CachedNetworkImageProvider(
          'https://eventgo-live.com/${profile.profileImageUrl}',
        ),
      ),
    );
  }

  // Name
  Widget _buildName(dynamic profile) {
    return Center(
      child: Text(
        profile.name ?? '',
        style: TextStyles.heading,
      ),
    );
  }

  // Stats Card
  Widget _buildStatsCard(dynamic profile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor.withAlpha(51), // 20% opacity
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Obx(() => buildCountColumn(
                  '${dataViewModel.followersCount.value}',
                  'Followers',
                )),
          ),
          Container(
            height: 5.h,
            width: 1,
            color: Colors.white.withAlpha(77), // ~30% opacity
          ),
          Expanded(
            child: buildCountColumn('${profile.followingCount}', 'Following'),
          ),
        ],
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons(dynamic profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Obx(() {
          final isFollowing = dataViewModel.isFollowing.value;
          return InkWell(
            onTap: () {
              HapticUtils.buttonPress();
              final userId = profile.userId;
              if (userId != null) {
                dataViewModel.toggleFollow(userId);
              }
            },
            child: buildActionButton(
              icon: Icons.person_add,
              label: isFollowing ? 'Unfollow' : 'Follow',
              filled: true,
            ),
          );
        }),
        buildActionButton(
          icon: Icons.message,
          label: 'Message',
          filled: false,
          onTap: () {
            HapticUtils.light();
            // Navigate to chat screen
          },
        ),
      ],
    );
  }

  // About Section
  Widget _buildAboutSection(dynamic profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('About Me', Icons.person),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.signinoptioncolor, AppColors.backgroundColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            profile.shortBio ?? 'No bio added',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // Interests Section
  Widget _buildInterestsSection(List<String> splitInterests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader('Interests', Icons.star),
        splitInterests.isEmpty
            ? Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Text('No interests added',
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
              )
            : Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: List.generate(splitInterests.length, (index) {
                  final interest = splitInterests[index].trim();
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
                    avatar: Icon(icon, color: Colors.white, size: 14.sp),
                    label: Text(
                      interest,
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
                    ),
                    backgroundColor: color,
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  );
                }),
              ),
      ],
    );
  }

  /// Helper to build count columns
  Widget buildCountColumn(String count, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: TextStyles.regularhometext2,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: TextStyles.regularwhite.copyWith(
            color: Colors.white.withAlpha(204), // ~80% opacity
          ),
        ),
      ],
    );
  }

  /// Helper to build section headers
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

  /// Helper to build action buttons
  Widget buildActionButton({
    required IconData icon,
    required String label,
    bool filled = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 7.h,
        width: 40.w,
        decoration: BoxDecoration(
          color: filled ? AppColors.blueColor : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(2.h),
          border: Border.all(color: AppColors.blueColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: filled ? Colors.white : AppColors.blueColor),
            SizedBox(width: 2.w),
            Text(label,
                style: TextStyle(
                    color: filled ? Colors.white : AppColors.blueColor,
                    fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }

  /// Share profile functionality
  void _shareProfile() {
    final profile = controller.profile.value;
    if (profile != null) {
      final shareText = '''
Check out ${profile.name ?? 'this user'}'s profile on EventGo!

${profile.shortBio != null ? 'Bio: ${profile.shortBio}' : ''}

Download EventGo app to connect with them and discover amazing events!
      ''';

      Share.share(
        shareText,
        subject: '${profile.name ?? 'User'}\'s Profile on EventGo',
      );
    }
  }
}
