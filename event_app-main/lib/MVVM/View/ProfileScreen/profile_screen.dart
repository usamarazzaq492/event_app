import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/ProfileScreen/profile_tab/about_tab.dart';
import 'package:event_app/MVVM/View/ProfileScreen/profile_tab/event_tab.dart';
import 'package:event_app/MVVM/View/exploreevent/create_event.dart';
import 'package:event_app/MVVM/view_model/public_profile_controller.dart';
import 'package:event_app/MVVM/view_model/ad_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:event_app/utils/navigation_utils.dart';
import 'package:event_app/utils/refresh_on_navigation_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../view_model/auth_view_model.dart';
import '../../view_model/event_view_model.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin, RefreshOnNavigation {
  int _activeIndex = 0;
  late TabController _tabController;
  final controller = Get.put(PublicProfileController());
  final adVM = Get.put(AdViewModel());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    // Clamp index in case of hot reload or previous state
    if (_tabController.index >= _tabController.length) {
      _tabController.index = 0;
      _activeIndex = 0;
    }
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (!mounted) return;
        setState(() {
          _activeIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void refreshData() {
    if (mounted) {
      controller.fetchUserProfile();
      adVM.fetchAds();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Guard against hot-reload or prior state with different length
    if (_tabController.length != 3) {
      final int safeIndex = 0;
      _tabController.dispose();
      _tabController = TabController(vsync: this, length: 3);
      _tabController.index = safeIndex;
      _activeIndex = safeIndex;
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          } else if (controller.error.isNotEmpty) {
            return _buildErrorState();
          } else if (controller.userProfile.value == null) {
            return _buildEmptyState();
          }

          final profile = controller.userProfile.value!;
          return RefreshIndicator(
            onRefresh: _refreshProfile,
            color: AppColors.blueColor,
            backgroundColor: AppColors.signinoptioncolor,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 3.h),
                  _buildProfileImage(profile),
                  SizedBox(height: 2.h),
                  _buildUserName(profile),
                  SizedBox(height: 2.h),
                  _buildFollowCounts(profile),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(child: _buildEditProfileButton(context)),
                      SizedBox(width: 3.w),
                      Expanded(child: _buildCreateEventButton(context)),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  _buildTabBar(),
                  SizedBox(height: 2.h),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: _buildTabBarView(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // Loading State
  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Column(
        children: [
          // Header skeleton
          Row(
            children: [
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Profile image skeleton
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 2.h),
          // Name skeleton
          Container(
            width: 150,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 2.h),
          // Stats skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSkeletonColumn(),
              Container(height: 5.h, width: 1, color: Colors.grey.shade600),
              _buildSkeletonColumn(),
            ],
          ),
          SizedBox(height: 2.h),
          // Edit button skeleton
          Container(
            width: 50.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(2.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonColumn() {
    return Column(
      children: [
        Container(
          width: 30,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        SizedBox(height: 0.5.h),
        Container(
          width: 50,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
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
            style: TextStyles.heading,
          ),
          SizedBox(height: 1.h),
          Text(
            controller.error.value,
            style: TextStyles.regularwhite.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: () => _refreshProfile(),
            icon: Icon(Icons.refresh, size: 12.sp),
            label: Text('Retry', style: TextStyles.buttontext),
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
            style: TextStyles.heading,
          ),
          SizedBox(height: 1.h),
          Text(
            'This profile doesn\'t exist or has been removed.',
            style: TextStyles.regularwhite.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: () => _refreshProfile(),
            icon: Icon(Icons.refresh, size: 12.sp),
            label: Text('Retry', style: TextStyles.buttontext),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: () {
              HapticUtils.light();
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.signinoptioncolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => _buildBottomSheetMenu(context),
              );
            },
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(profile) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.blueColor,
            AppColors.blueColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(4),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade800,
        backgroundImage: CachedNetworkImageProvider(
          'https://eventgo-live.com/${profile.data?.profileImageUrl}',
        ),
        child: profile.data?.profileImageUrl == null
            ? Icon(
                Icons.person,
                size: 32.sp,
                color: Colors.grey.shade400,
              )
            : null,
      ),
    );
  }

  Widget _buildUserName(profile) {
    return Text(
      '${profile.data?.name ?? 'User Name'}',
      style: TextStyles.heading,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFollowCounts(profile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFollowColumn(
              '${profile.data?.followingCount ?? 0}', 'Following'),
          Container(
            height: 4.h,
            width: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          _buildFollowColumn(
              '${profile.data?.followersCount ?? 0}', 'Followers'),
        ],
      ),
    );
  }

  Widget _buildFollowColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyles.regularhometext2,
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: TextStyles.regularwhite.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blueColor,
            AppColors.blueColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(2.h),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticUtils.buttonPress();
            NavigationUtils.push(
              context,
              const EditProfileScreen(),
              routeName: '/edit-profile',
            );
          },
          borderRadius: BorderRadius.circular(2.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 14.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Edit Profile',
                  style: TextStyles.buttontext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateEventButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add, size: 18, color: Colors.white),
      label: Text(
        'Create Event',
        style: TextStyles.buttontext.copyWith(
          color: Colors.white,
          fontSize: 12.sp,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blueColor.withValues(alpha: 0.85),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 1.4.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.h),
        ),
      ),
      onPressed: () {
        HapticUtils.buttonPress();
        NavigationUtils.push(
          context,
          const CreateEvent(),
          routeName: '/create-event',
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.blueColor,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        dividerColor: Colors.transparent,
        tabs: [
          _buildTabItem('About', 0),
          _buildTabItem('Events', 1),
          _buildTabItem('Ads', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
      child: Text(
        label,
        style: TextStyles.tabtext.copyWith(
          color: _activeIndex == index ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      physics:
          const NeverScrollableScrollPhysics(), // Disable swipe, use tabs only
      children: [
        AboutTab(),
        EventTab(),
        _buildMyAdsTab(),
      ],
    );
  }

  Widget _buildMyAdsTab() {
    final profile = controller.userProfile.value;
    final int? currentUserId = profile?.data?.userId;

    return Obx(() {
      if (adVM.isLoading.value && adVM.ads.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.blueColor));
      }
      if (adVM.error.isNotEmpty) {
        return Center(
          child: Text(adVM.error.value,
              style: TextStyles.regularwhite.copyWith(color: Colors.red)),
        );
      }
      if (currentUserId == null) {
        return Center(
          child: Text('Not signed in', style: TextStyles.regularwhite),
        );
      }

      final myAds = adVM.ads.where((a) => a.userId == currentUserId).toList();
      if (myAds.isEmpty) {
        return Center(
          child: Text('You have not created any ads yet',
              style: TextStyles.regularwhite.copyWith(color: Colors.white70)),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await adVM.fetchAds();
        },
        color: AppColors.blueColor,
        backgroundColor: AppColors.signinoptioncolor,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 1.h),
          itemCount: myAds.length,
          separatorBuilder: (_, __) => SizedBox(height: 1.2.h),
          itemBuilder: (context, index) {
            final ad = myAds[index];
            final imagePath = ad.imageUrl ?? '';
            final imageUrl = imagePath.startsWith('http')
                ? imagePath
                : 'https://eventgo-live.com/$imagePath';
            final title = (ad.title ?? '').toString();
            final desc = (ad.description ?? '').toString();

            return Container(
              decoration: BoxDecoration(
                color: AppColors.signinoptioncolor,
                borderRadius: BorderRadius.circular(2.h),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(2.h),
                      bottomLeft: Radius.circular(2.h),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 28.w,
                      height: 14.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.broken_image,
                            color: Colors.white70),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 1.2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty
                                ? '${title[0].toUpperCase()}${title.substring(1)}'
                                : 'Untitled',
                            style: TextStyles.homeheadingtext,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.6.h),
                          Text(
                            desc.isNotEmpty
                                ? (desc.length > 100
                                    ? '${desc.substring(0, 100)}…'
                                    : desc)
                                : 'No description provided',
                            style: TextStyles.regularwhite
                                .copyWith(color: Colors.white70),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildBottomSheetMenu(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),

          // Logout option
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout,
                color: Colors.orange,
                size: 16.sp,
              ),
            ),
            title: Text(
              'Logout',
              style: TextStyles.regularhometext2.copyWith(
                color: Colors.orange,
              ),
            ),
            onTap: () async {
              HapticUtils.light();
              NavigationUtils.pop(context);
              final authController = Get.find<AuthViewModel>();
              await authController.logoutUser();
            },
          ),

          SizedBox(height: 1.h),

          // Delete Account option
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 16.sp,
              ),
            ),
            title: Text(
              'Delete Account',
              style: TextStyles.regularhometext2.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              HapticUtils.light();
              NavigationUtils.pop(context);
              _showDeleteAccountConfirmation(context);
            },
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.signinoptioncolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 24.sp,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Delete Account',
                  style: TextStyles.heading.copyWith(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                style: TextStyles.regularwhite,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This action cannot be undone. All your data will be permanently deleted, including:',
                      style: TextStyles.regularwhite.copyWith(
                        color: Colors.white70,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    _buildWarningItem('Your profile and personal information'),
                    _buildWarningItem('All your events'),
                    _buildWarningItem('All your bookings and tickets'),
                    _buildWarningItem('Your followers and following relationships'),
                    _buildWarningItem('All your ads and promotions'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticUtils.light();
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyles.buttontext.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                HapticUtils.buttonPress();
                Navigator.of(context).pop();
                await _handleDeleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Delete Account',
                style: TextStyles.buttontext,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        children: [
          Icon(
            Icons.close,
            size: 12.sp,
            color: Colors.red,
          ),
          SizedBox(width: 1.w),
          Expanded(
            child: Text(
              text,
              style: TextStyles.regularwhite.copyWith(
                color: Colors.white70,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    // Show loading dialog
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: AppColors.signinoptioncolor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.blueColor,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Deleting your account...',
                  style: TextStyles.regularwhite,
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final authController = Get.find<AuthViewModel>();
      
      // Close dialog before navigation to avoid Navigator history issues
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog first
      }
      
      // Small delay to ensure dialog is closed
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Delete account (this will handle navigation)
      await authController.deleteAccount();
    } catch (e) {
      // If error occurs, try to close dialog if still mounted
      if (mounted) {
        try {
          Navigator.of(context).pop(); // Close loading dialog
        } catch (_) {
          // Dialog might already be closed, ignore
        }
        Get.snackbar(
          "Error",
          "Failed to delete account: ${e.toString()}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _refreshProfile() async {
    await controller.fetchUserProfile();

    final eventController = Get.find<EventController>();
    await eventController.getMyEvents();
    await adVM.fetchAds();

    if (!mounted) return;
    setState(() {});
  }
}
