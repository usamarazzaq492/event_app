import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/MVVM/view_model/data_view_model.dart';
import 'package:event_app/MVVM/view_model/public_profile_controller.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_pages.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:event_app/utils/navigation_utils.dart';
import 'package:event_app/utils/refresh_on_navigation_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:event_app/Services/moderation_service.dart';

class PublicProfileScreen extends StatefulWidget {
  final int? id;

  const PublicProfileScreen({super.key, required this.id});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen>
    with RefreshOnNavigation {
  final PublicProfileController controller = Get.put(PublicProfileController());
  final DataViewModel dataViewModel = Get.put(DataViewModel());
  final AuthViewModel authViewModel = Get.put(AuthViewModel());

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
  void refreshData() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    print('🔷 Loading profile for user ID: ${widget.id}');
    await controller.loadPublicProfile(widget.id);
    final profile = controller.profile.value;
    if (profile != null) {
      print(
          '🔷 Profile loaded - isFollowing: ${profile.isFollowing}, followersCount: ${profile.followersCount}');
      dataViewModel.initializeFollowState(
        profile.isFollowing ?? false,
        profile.followersCount ?? 0,
      );
      print(
          '🔷 Follow state initialized - isFollowing: ${dataViewModel.isFollowing.value}, followersCount: ${dataViewModel.followersCount.value}');
    } else {
      print('❌ Profile is null after loading');
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
            print('🔷 Refreshing profile...');
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
    return Column(
      children: [
        _buildBackOnlyHeader(),
        Expanded(
          child: Center(
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
          ),
        ),
      ],
    );
  }

  // Error State
  Widget _buildErrorState() {
    return Column(
      children: [
        _buildBackOnlyHeader(),
        Expanded(
          child: Center(
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
          ),
        ),
      ],
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Column(
      children: [
        _buildBackOnlyHeader(),
        Expanded(
          child: Center(
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
        ),
        ),
      ],
    );
  }

  Widget _buildBackOnlyHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 2.h, left: 2.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            HapticUtils.navigation();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Column(children: [
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              HapticUtils.navigation();
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Center(
              child: Text('Profile', style: TextStyles.heading),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) async {
              HapticUtils.light();
              if (!authViewModel.isLoggedIn.value && (value == 'report' || value == 'block')) {
                Get.snackbar(
                  'Sign in required',
                  'Please sign in to report or block users.',
                  backgroundColor: AppColors.blueColor,
                  colorText: Colors.white,
                  mainButton: TextButton(
                    onPressed: () {
                      Get.closeCurrentSnackbar();
                      Get.toNamed(RouteName.loginScreen);
                    },
                    child: Text('Sign in', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                );
                return;
              }
              final profile = controller.profile.value;
              if (profile == null) return;
              final userId = profile.userId;
              if (userId == null) return;
              if (value == 'share') {
                _shareProfile();
              } else if (value == 'report') {
                await _showReportUserSheet(userId);
              } else if (value == 'block') {
                await _showBlockUserSheet(userId);
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
              const PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Report'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Block'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 1.h),
      Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.06),
              Colors.white.withValues(alpha: 0.02),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    ]);
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() {
          final isFollowing = dataViewModel.isFollowing.value;
          return InkWell(
            onTap: () {
              HapticUtils.buttonPress();
              if (!authViewModel.isLoggedIn.value) {
                Get.snackbar(
                  'Sign in required',
                  'Please sign in or sign up first to follow users',
                  backgroundColor: AppColors.blueColor,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                  mainButton: TextButton(
                    onPressed: () {
                      Get.closeCurrentSnackbar();
                      Get.toNamed(RouteName.loginScreen);
                    },
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
                return;
              }
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

  Future<void> _showReportUserSheet(int userId) async {
    final reason = await Get.dialog<String>(
      _ReportReasonDialog(),
    );
    if (reason == null) return;
    try {
      final res = await ModerationService.reportUser(userId, reason: reason.isEmpty ? null : reason);
      if (res['statusCode'] == 201 || res['statusCode'] == 200) {
        Get.snackbar('Reported', res['message'] ?? 'Report submitted.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.signinoptioncolor, colorText: Colors.white);
      } else {
        Get.snackbar('Error', res['message'] ?? 'Could not submit report.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _showBlockUserSheet(int userId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.signinoptioncolor,
        title: Text('Block User?', style: TextStyle(color: Colors.white)),
        content: Text('This user will be removed from your feed. You can unblock them later from settings.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Block', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final res = await ModerationService.blockUser(userId);
      if (res['statusCode'] == 200) {
        Get.snackbar('Blocked', res['message'] ?? 'User blocked.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.signinoptioncolor, colorText: Colors.white);
        if (mounted) Navigator.of(context).pop();
      } else {
        Get.snackbar('Error', res['message'] ?? 'Could not block.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}

class _ReportReasonDialog extends StatefulWidget {
  @override
  State<_ReportReasonDialog> createState() => _ReportReasonDialogState();
}

class _ReportReasonDialogState extends State<_ReportReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.signinoptioncolor,
      title: Text('Report User', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Optionally describe the issue:', style: TextStyle(color: Colors.white70, fontSize: 12)),
          SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Reason (optional)',
              hintStyle: TextStyle(color: Colors.white38),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.white70))),
        TextButton(onPressed: () => Navigator.pop(context, _controller.text.trim()), child: Text('Submit', style: TextStyle(color: AppColors.blueColor))),
      ],
    );
  }
}
