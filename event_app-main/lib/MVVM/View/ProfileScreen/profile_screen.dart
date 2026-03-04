import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/ProfileScreen/profile_tab/about_tab.dart';
import 'package:event_app/MVVM/View/ProfileScreen/profile_tab/event_tab.dart';
import 'package:event_app/MVVM/View/exploreevent/create_event.dart';
import 'package:event_app/MVVM/view_model/public_profile_controller.dart';
import 'package:event_app/MVVM/view_model/ad_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_pages.dart';
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

  AuthViewModel get authViewModel => Get.put(AuthViewModel());

  @override
  void refreshData() {
    if (mounted && authViewModel.isLoggedIn.value) {
      controller.fetchUserProfile();
      adVM.fetchAds();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildGuestProfilePrompt() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 72.sp,
              color: Colors.white54,
            ),
            SizedBox(height: 3.h),
            Text(
              "Sign in to your account",
              style: TextStyles.heading.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.5.h),
            Text(
              "Manage your profile, events, and tickets.",
              style: TextStyles.regularwhite.copyWith(
                color: Colors.white70,
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.toNamed(RouteName.signupScreen),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.blueColor),
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.h),
                      ),
                    ),
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(RouteName.loginScreen),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.h),
                      ),
                    ),
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!authViewModel.isLoggedIn.value) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(child: _buildGuestProfilePrompt()),
        );
      }
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          } else if (controller.error.isNotEmpty) {
            return _buildErrorState();
          } else if (controller.userProfile.value == null) {
            return _buildEmptyState();
          }

          final profile = controller.userProfile.value!;
          final profileImageUrl = profile.data?.profileImageUrl != null &&
                  profile.data!.profileImageUrl!.isNotEmpty
              ? 'https://eventgo-live.com/${profile.data!.profileImageUrl}'
              : null;

          return Stack(
            children: [
              // Dynamic Blurred Background
              if (profileImageUrl != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.15,
                    child: CachedNetworkImage(
                      imageUrl: profileImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Main Content
              RefreshIndicator(
                onRefresh: _refreshProfile,
                color: AppColors.blueColor,
                backgroundColor: AppColors.signinoptioncolor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                      4.w, MediaQuery.of(context).padding.top + 2.h, 4.w, 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeader(context),
                      SizedBox(height: 3.h),
                      _buildProfileImage(profile),
                      SizedBox(height: 2.5.h),
                      _buildUserName(profile),
                      SizedBox(height: 3.h),
                      _buildFollowCounts(profile),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Expanded(child: _buildEditProfileButton(context)),
                          SizedBox(width: 3.w),
                          Expanded(child: _buildCreateEventButton(context)),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      _buildTabBar(),
                      SizedBox(height: 3.h),
                      SizedBox(
                        height: 80.h,
                        child: _buildTabBarView(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      );
    });
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

  // Error State (scrollable for iPad/overflow safety)
  Widget _buildErrorState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              100,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  controller.error.value,
                  style: TextStyles.regularwhite.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
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
        ),
      ),
    );
  }

  // Empty State (scrollable for iPad/overflow safety)
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              100,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MY PROFILE',
              style: TextStyle(
                fontSize: 8.sp,
                color: Colors.white38,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            Container(
              height: 2,
              width: 20.w,
              margin: EdgeInsets.only(top: 0.5.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.blueColor, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(1.5.h),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(1.5.h),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  HapticUtils.light();
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppColors.signinoptioncolor,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25)),
                    ),
                    builder: (_) => _buildBottomSheetMenu(context),
                  );
                },
                icon: Icon(
                  Icons.settings_suggest_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(profile) {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.blueColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.blueColor.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.all(1.w),
        child: Hero(
          tag: 'profile_image',
          child: CircleAvatar(
            radius: 65,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            backgroundImage: (profile.data?.profileImageUrl != null &&
                    profile.data!.profileImageUrl!.isNotEmpty)
                ? CachedNetworkImageProvider(
                    'https://eventgo-live.com/${profile.data!.profileImageUrl}',
                  )
                : null,
            child: profile.data?.profileImageUrl == null
                ? Icon(
                    Icons.person_rounded,
                    size: 40.sp,
                    color: Colors.white24,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildUserName(profile) {
    return Column(
      children: [
        Text(
          '${profile.data?.name ?? 'User Name'}',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        if (profile.data?.email != null)
          Text(
            profile.data!.email!.toLowerCase(),
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildFollowCounts(profile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2.5.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(2.5.h),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFollowColumn(
                  '${profile.data?.followingCount ?? 0}', 'Following'),
              Container(
                height: 4.h,
                width: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              _buildFollowColumn(
                  '${profile.data?.followersCount ?? 0}', 'Followers'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 0.2.h),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 7.sp,
            color: Colors.white38,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
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
            AppColors.blueColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(2.h),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
            padding: EdgeInsets.symmetric(vertical: 1.8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateEventButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticUtils.buttonPress();
            NavigationUtils.push(
              context,
              const CreateEvent(),
              routeName: '/create-event',
            );
          },
          borderRadius: BorderRadius.circular(2.h),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white70,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Create Event',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(2.h),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.blueColor,
                  AppColors.blueColor.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(1.5.h),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(0.8.h),
            labelPadding: EdgeInsets.symmetric(vertical: 0.5.h),
            dividerColor: Colors.transparent,
            labelStyle: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            tabs: [
              _buildTabItem('About', 0),
              _buildTabItem('Events', 1),
              _buildTabItem('Ads', 2),
            ],
          ),
        ),
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
        const AboutTab(),
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
          child: CircularProgressIndicator(color: AppColors.blueColor),
        );
      }
      if (adVM.error.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: Colors.red.withValues(alpha: 0.5), size: 40.sp),
              SizedBox(height: 2.h),
              Text(adVM.error.value,
                  style: TextStyle(color: Colors.white60, fontSize: 10.sp)),
            ],
          ),
        );
      }
      if (currentUserId == null) {
        return Center(
          child: Text('Not signed in',
              style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
        );
      }

      final myAds = adVM.ads.where((a) => a.userId == currentUserId).toList();
      if (myAds.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ads_click_rounded, color: Colors.white10, size: 50.sp),
              SizedBox(height: 2.h),
              Text('You have not created any ads yet',
                  style: TextStyle(color: Colors.white24, fontSize: 11.sp)),
            ],
          ),
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
          padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
          itemCount: myAds.length,
          separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
          itemBuilder: (context, index) {
            final ad = myAds[index];
            final imagePath = ad.imageUrl ?? '';
            final imageUrl = imagePath.startsWith('http')
                ? imagePath
                : 'https://eventgo-live.com/$imagePath';
            final title = (ad.title ?? '').toString();
            final desc = (ad.description ?? '').toString();

            return Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(2.5.h),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 32.w,
                        height: 15.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 32.w,
                          height: 15.h,
                          color: Colors.white.withValues(alpha: 0.05),
                          child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 32.w,
                          height: 15.h,
                          color: Colors.white.withValues(alpha: 0.1),
                          child: const Icon(Icons.broken_image,
                              color: Colors.white24),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty
                                ? '${title[0].toUpperCase()}${title.substring(1)}'
                                : 'Untitled Ad',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.8.h),
                          Text(
                            desc.isNotEmpty ? desc : 'No description provided.',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.white60,
                              height: 1.4,
                            ),
                            maxLines: 2,
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

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(1.2.h),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(icon, color: iconColor, size: 16.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
          letterSpacing: 0.3,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.white12,
        size: 18.sp,
      ),
      onTap: () {
        HapticUtils.light();
        onTap();
      },
    );
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

          // Terms & Conditions
          _buildMenuTile(
            context: context,
            icon: Icons.description_outlined,
            iconColor: Colors.blue,
            title: 'Terms & Conditions',
            onTap: () {
              HapticUtils.light();
              NavigationUtils.pop(context);
              Navigator.pushNamed(context, RouteName.termsScreen);
            },
          ),
          SizedBox(height: 1.h),

          // Privacy Policy
          _buildMenuTile(
            context: context,
            icon: Icons.privacy_tip_outlined,
            iconColor: Colors.blue,
            title: 'Privacy Policy',
            onTap: () {
              HapticUtils.light();
              NavigationUtils.pop(context);
              Navigator.pushNamed(context, RouteName.privacyScreen);
            },
          ),
          SizedBox(height: 1.h),

          // Contact & Support
          _buildMenuTile(
            context: context,
            icon: Icons.support_agent_outlined,
            iconColor: Colors.blue,
            title: 'Contact & Support',
            onTap: () {
              HapticUtils.light();
              NavigationUtils.pop(context);
              Navigator.pushNamed(context, RouteName.contactScreen);
            },
          ),
          SizedBox(height: 2.h),

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
                    _buildWarningItem(
                        'Your followers and following relationships'),
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
