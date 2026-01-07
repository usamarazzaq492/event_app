import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/MVVM/body_model/event_model.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_style.dart';
import '../../view_model/auth_view_model.dart';
import '../../view_model/bottom_nav_controller.dart';
import '../EventDetailScreen/event_detail_screen.dart';
import '../ProfileScreen/public_profile_screen.dart';
import '../exploreevent/create_event.dart';
import '../notification/notification_screen.dart';
import '../../../Widget/skeleton_loading.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/accessibility_utils.dart';
import '../../../utils/haptic_utils.dart';
import '../../../utils/keyboard_utils.dart';
import '../../../utils/refresh_on_navigation_mixin.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, RefreshOnNavigation {
  final EventController controller = Get.put(EventController());
  final authViewModel = Get.put(AuthViewModel());
  final BottomNavController navController =
      Get.find<BottomNavController>(tag: 'BottomNavController');

  late AnimationController _bannerAnimationController;
  late Animation<double> _bannerAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // People search state
  final TextEditingController _userSearchController = TextEditingController();
  List<dynamic> _userSearchResults = [];
  bool _showUserSearchResults = false;

  String get _greeting {
    return 'Hi';
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
  }

  @override
  void refreshData() {
    // Preload users so we can search people from Home
    authViewModel.fetchUsers();
    // Fetch timeline events on home screen load
    controller.fetchTimelineEvents();
  }

  void _initializeAnimations() {
    _bannerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bannerAnimation = CurvedAnimation(
      parent: _bannerAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Start animations
    _bannerAnimationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  void _onUserSearchChanged(String query) {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() {
        _userSearchResults = [];
        _showUserSearchResults = false;
      });
      return;
    }

    final lower = trimmed.toLowerCase();
    final currentUserId = authViewModel.currentUser['userId'];

    final results = authViewModel.users
        .where((user) => user.userId != currentUserId)
        .where((user) {
          final name = (user.name ?? '').toString().toLowerCase();
          final email = (user.email ?? '').toString().toLowerCase();
          return name.contains(lower) || email.contains(lower);
        })
        .take(6)
        .toList();

    setState(() {
      _userSearchResults = results;
      _showUserSearchResults = results.isNotEmpty;
    });
  }

  Widget _buildPeopleSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search people',
          style: TextStyles.regularwhite.copyWith(
            fontSize: 11.sp,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _userSearchController,
          onChanged: _onUserSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search by name or email',
            hintStyle: TextStyle(
              color: Colors.white54,
              fontSize: 11.sp,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            filled: true,
            fillColor: AppColors.signinoptioncolor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.blueColor),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.3.h,
            ),
          ),
        ),
        if (_showUserSearchResults) ...[
          SizedBox(height: 1.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.signinoptioncolor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userSearchResults.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.white.withValues(alpha: 0.08),
                height: 0,
              ),
              itemBuilder: (context, index) {
                final user = _userSearchResults[index];
                final imageUrl = (user.profileImageUrl ?? '').toString().trim();

                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade700,
                    backgroundImage: imageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(
                            imageUrl.startsWith('http')
                                ? imageUrl
                                : 'https://eventgo-live.com$imageUrl',
                          )
                        : const AssetImage(AppImages.profileicon)
                            as ImageProvider,
                  ),
                  title: Text(
                    user.name ?? '',
                    style: TextStyles.regularwhite.copyWith(fontSize: 11.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    user.email ?? '',
                    style: TextStyles.regularwhite.copyWith(
                      fontSize: 9.sp,
                      color: Colors.white60,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    HapticUtils.navigation();
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _showUserSearchResults = false;
                      _userSearchResults = [];
                      _userSearchController.clear();
                    });
                    NavigationUtils.push(
                      context,
                      PublicProfileScreen(id: user.userId),
                      routeName: '/public-profile',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    // Unfocus inputs when navigating away
    KeyboardUtils.unfocus(context);
    _bannerAnimationController.dispose();
    _scrollController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: UnfocusOnTap(
        child: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchAllEvents();
          await controller.fetchTimelineEvents();
        },
        color: AppColors.blueColor,
        backgroundColor: AppColors.signinoptioncolor,
        strokeWidth: 3.0,
        displacement: 50.0,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header with enhanced animations
                SizedBox(height: 3.h),
                AnimatedBuilder(
                  animation: _bannerAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _bannerAnimation.value)),
                      child: Opacity(
                        opacity: _bannerAnimation.value,
                        child: Row(
                          children: [
                            /// Profile Avatar with enhanced border effect
                            Obx(() {
                              final user = authViewModel.currentUser;
                              final imageUrl = user['profileImageUrl'] !=
                                          null &&
                                      user['profileImageUrl'].isNotEmpty
                                  ? 'https://eventgo-live.com/${user['profileImageUrl']}'
                                  : '';

                              return AccessibilityUtils.accessibleButton(
                                onPressed: () {
                                  HapticUtils.navigation();
                                  navController
                                      .changeTab(4); // Navigate to Profile tab
                                },
                                label: 'Profile picture, tap to go to profile',
                                child: GestureDetector(
                                  onTap: () {
                                    HapticUtils.navigation();
                                    navController.changeTab(
                                        4); // Navigate to Profile tab
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(3), // border width
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.blueColor,
                                          Colors.blueAccent,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.blueColor
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.grey.shade300,
                                      backgroundImage: imageUrl.isNotEmpty
                                          ? NetworkImage(imageUrl)
                                          : const AssetImage(
                                                  AppImages.profileicon)
                                              as ImageProvider,
                                    ),
                                  ),
                                ),
                              );
                            }),

                            SizedBox(width: 3.w),

                            /// Greeting and Name Column with enhanced styling
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AccessibilityUtils.addSemantics(
                                    label: 'Greeting: $_greeting',
                                    child: Text(
                                      _greeting,
                                      style: TextStyles.regularwhite.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.sp,
                                        color: Colors.grey.shade300,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Obx(() {
                                    final name =
                                        authViewModel.currentUser['name'] ?? '';
                                    return AccessibilityUtils.addSemantics(
                                      label: 'User name: $name',
                                      child: Text(
                                        name,
                                        style: TextStyles.regularhometext1
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp,
                                          letterSpacing: 0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),

                            SizedBox(width: 2.w),

                            /// Notification icon with enhanced design
                            AccessibilityUtils.accessibleIcon(
                              label: 'Notifications',
                              hint: 'Tap to view notifications',
                              onTap: () {
                                HapticUtils.light();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: (0.15)),
                                      Colors.white.withValues(alpha: (0.05)),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: (0.2)),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: (0.1)),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.notifications_none,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    HapticUtils.light();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const NotificationScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 3.h),

                // People search on Home
                _buildPeopleSearchSection(),

                SizedBox(height: 3.h),

                /// Enhanced Motivational Banner
                AnimatedBuilder(
                  animation: _bannerAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * _bannerAnimation.value),
                      child: Opacity(
                        opacity: _bannerAnimation.value,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(4.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.blueColor,
                                Colors.blueAccent,
                                Colors.blue.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(2.5.h),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blueColor
                                    .withValues(alpha: (0.3)),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow.shade300,
                                    size: 20,
                                  ),
                                  SizedBox(width: 1.w),
                                  Expanded(
                                    child: Text(
                                      "Discover Amazing Events",
                                      style: TextStyles.profiletext.copyWith(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.5.h),
                              Text(
                                "Book your tickets now and explore something new today!",
                                style: TextStyles.regularwhite.copyWith(
                                  fontSize: 11.sp,
                                  height: 1.4,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 2.5.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        HapticUtils.buttonPress();
                                        navController.changeTab(1);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.blueColor,
                                        elevation: 8,
                                        shadowColor:
                                            Colors.black.withValues(alpha: 0.2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2.5.h),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 1.5.h,
                                          horizontal: 3.w,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Explore Now",
                                            style:
                                                TextStyles.profiletext.copyWith(
                                              color: AppColors.blueColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        HapticUtils.buttonPress();
                                        NavigationUtils.push(
                                          context,
                                          const CreateEvent(),
                                          routeName: '/create-event',
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black
                                            .withValues(alpha: 0.15),
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor: Colors.black
                                            .withValues(alpha: 0.15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(2.5.h),
                                          side: const BorderSide(
                                            color: Colors.white24,
                                            width: 1,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 1.5.h,
                                          horizontal: 3.w,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Create Event",
                                            style:
                                                TextStyles.profiletext.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 3.h),

                /// Timeline Feed - Main Social Media Style Feed
                Obx(() {
                  if (controller.isTimelineLoading.value) {
                    return SkeletonLoading.listSkeleton(itemCount: 2);
                  } else if (controller.timelineEvents.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(6.h),
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.signinoptioncolor,
                        borderRadius: BorderRadius.circular(2.5.h),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 50.sp,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            "Your Timeline is Empty",
                            style: TextStyles.homeheadingtext.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.5.h),
                          Text(
                            "Follow users to see their events here",
                            style: TextStyles.regularwhite.copyWith(
                              fontSize: 12.sp,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 2.h),
                          ElevatedButton(
                            onPressed: () {
                              HapticUtils.buttonPress();
                              navController.changeTab(1);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blueColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.5.h,
                              ),
                            ),
                            child: Text(
                              "Explore Events",
                              style: TextStyles.regularwhite.copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return AnimationLimiter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.timelineEvents.length,
                        itemBuilder: (context, index) {
                          final event = controller.timelineEvents[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 400),
                            child: SlideAnimation(
                              verticalOffset: 30.0,
                              child: FadeInAnimation(
                                child: _buildSocialMediaEventCard(context, event),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  /// Build Social Media Style Event Card (Timeline Feed)
  Widget _buildSocialMediaEventCard(BuildContext context, EventModel event) {
    // Get user info if available (from API response)
    final userName = event.userName ?? 'Event Organizer';
    final userProfileImage = event.userProfileImage;
    
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.5.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticUtils.selection();
            NavigationUtils.push(
              context,
              EventDetailScreen(eventId: '${event.eventId}'),
              routeName: '/event-detail',
            );
          },
          borderRadius: BorderRadius.circular(2.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header (like social media post)
              Padding(
                padding: EdgeInsets.all(3.h),
                child: Row(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 20.sp,
                      backgroundColor: AppColors.blueColor.withValues(alpha: 0.3),
                      backgroundImage: userProfileImage != null && userProfileImage.toString().isNotEmpty
                          ? CachedNetworkImageProvider(
                              userProfileImage.toString().startsWith('http')
                                  ? userProfileImage.toString()
                                  : 'https://eventgo-live.com/$userProfileImage',
                            )
                          : null,
                      child: userProfileImage == null || userProfileImage.toString().isEmpty
                          ? Icon(Icons.person, color: Colors.white70, size: 20.sp)
                          : null,
                    ),
                    SizedBox(width: 3.w),
                    // User Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: TextStyles.homeheadingtext.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            formatDate(event.startDate) ?? '',
                            style: TextStyles.regularwhite.copyWith(
                              fontSize: 11.sp,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Promoted Badge (if applicable)
                    if (event.isPromoted == true)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(1.h),
                        ),
                        child: Text(
                          'PROMOTED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Event Image
              GestureDetector(
                onTap: () {
                  HapticUtils.selection();
                  NavigationUtils.push(
                    context,
                    EventDetailScreen(eventId: '${event.eventId}'),
                    routeName: '/event-detail',
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: event.eventImage?.startsWith('http') == true
                      ? event.eventImage!
                      : 'https://eventgo-live.com/${event.eventImage}',
                  width: double.infinity,
                  height: 30.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 30.h,
                    color: Colors.grey.shade800,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.blueColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 30.h,
                    color: Colors.grey.shade800,
                    child: Icon(
                      Icons.event,
                      size: 50.sp,
                      color: Colors.white30,
                    ),
                  ),
                ),
              ),
              // Event Details
              Padding(
                padding: EdgeInsets.all(3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Text(
                      event.eventTitle ?? '',
                      style: TextStyles.homeheadingtext.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.5.h),
                    // Description
                    if (event.description != null && event.description!.isNotEmpty)
                      Text(
                        event.description!,
                        style: TextStyles.regularwhite.copyWith(
                          fontSize: 12.sp,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (event.description != null && event.description!.isNotEmpty)
                      SizedBox(height: 1.5.h),
                    // Event Info Row
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14.sp, color: Colors.white70),
                        SizedBox(width: 1.w),
                        Text(
                          formatDate(event.startDate) ?? '',
                          style: TextStyles.homedatetext.copyWith(fontSize: 11.sp),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.location_on, size: 14.sp, color: Colors.white70),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            event.city ?? 'Location TBA',
                            style: TextStyles.homedatetext.copyWith(fontSize: 11.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (event.eventPrice != null && event.eventPrice!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: Row(
                          children: [
                            Icon(Icons.attach_money, size: 14.sp, color: Colors.green),
                            SizedBox(width: 1.w),
                            Text(
                              event.eventPrice!,
                              style: TextStyles.homedatetext.copyWith(
                                fontSize: 12.sp,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? formatDate(String? date) {
    try {
      final parsedDate = DateTime.parse(date!);
      return DateFormat('EEEE, MMM d').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  String? formatTime(String? time) {
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time!);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return time;
    }
  }

}
