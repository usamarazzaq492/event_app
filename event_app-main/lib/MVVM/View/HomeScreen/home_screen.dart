import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/view_model/event_view_model.dart';
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
import '../../../Widget/error_widget.dart';
import '../../../Widget/skeleton_loading.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/accessibility_utils.dart';
import '../../../utils/haptic_utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final EventController controller = Get.put(EventController());
  final authViewModel = Get.put(AuthViewModel());
  final BottomNavController navController =
      Get.find<BottomNavController>(tag: 'BottomNavController');

  late AnimationController _bannerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _bannerAnimation;
  late Animation<double> _listAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // People search state
  final TextEditingController _userSearchController = TextEditingController();
  List<dynamic> _userSearchResults = [];
  bool _showUserSearchResults = false;

  String get _greeting {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    // Preload users so we can search people from Home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authViewModel.fetchUsers();
    });
  }

  void _initializeAnimations() {
    _bannerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bannerAnimation = CurvedAnimation(
      parent: _bannerAnimationController,
      curve: Curves.easeOutCubic,
    );

    _listAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Start animations
    _bannerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _listAnimationController.forward();
    });
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
    _bannerAnimationController.dispose();
    _listAnimationController.dispose();
    _scrollController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchAllEvents();
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

                /// Featured Promoted Events Section
                Obx(() {
                  final promotedEvents = controller.events.where((event) {
                    if (event.startDate == null) return false;
                    final eventDate = DateTime.tryParse(event.startDate!);
                    if (eventDate == null) return false;
                    return eventDate.isAfter(DateTime.now()) &&
                        event.isPromotionActive;
                  }).toList();

                  // Sort promoted events by date
                  promotedEvents.sort((a, b) {
                    try {
                      return DateTime.parse(a.startDate ?? '')
                          .compareTo(DateTime.parse(b.startDate ?? ''));
                    } catch (_) {
                      return 0;
                    }
                  });

                  if (promotedEvents.isNotEmpty) {
                    return AnimatedBuilder(
                      animation: _listAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - _listAnimation.value)),
                          child: Opacity(
                            opacity: _listAnimation.value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.orange,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          "Featured Events",
                                          style: TextStyles.homeheadingtext
                                              .copyWith(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                SizedBox(
                                  height: 25.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: promotedEvents.length > 4
                                        ? 4
                                        : promotedEvents.length,
                                    itemBuilder: (context, index) {
                                      final event = promotedEvents[index];
                                      return Container(
                                        width: 70.w,
                                        margin: EdgeInsets.only(right: 3.w),
                                        decoration: BoxDecoration(
                                          color: AppColors.signinoptioncolor,
                                          borderRadius:
                                              BorderRadius.circular(2.5.h),
                                          border: Border.all(
                                            color: Colors.orange
                                                .withValues(alpha: 0.5),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.orange
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child:
                                            AccessibilityUtils.accessibleCard(
                                          label:
                                              'Featured Event: ${event.eventTitle}',
                                          hint: 'Tap to view event details',
                                          onTap: () {
                                            HapticUtils.selection();
                                            NavigationUtils.push(
                                              context,
                                              EventDetailScreen(
                                                  eventId: '${event.eventId}'),
                                              routeName: '/event-detail',
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Event Image with Promoted Badge
                                              Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                          2.5.h),
                                                      topRight: Radius.circular(
                                                          2.5.h),
                                                    ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          event.eventImage ??
                                                              '',
                                                      width: double.infinity,
                                                      height: 12.h,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        color: AppColors
                                                            .blueColor
                                                            .withValues(
                                                                alpha: 0.1),
                                                        child: Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: AppColors
                                                                .blueColor,
                                                          ),
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Container(
                                                        color: AppColors
                                                            .blueColor
                                                            .withValues(
                                                                alpha: 0.1),
                                                        child: Icon(
                                                          Icons.event,
                                                          size: 30.sp,
                                                          color: AppColors
                                                              .blueColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Promoted Badge
                                                  Positioned(
                                                    top: 1.h,
                                                    right: 1.w,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 2.w,
                                                        vertical: 0.5.h,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(1.h),
                                                      ),
                                                      child: Text(
                                                        'PROMOTED',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 7.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Event Details
                                              Padding(
                                                padding: EdgeInsets.all(2.h),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      event.eventTitle ?? '',
                                                      style: TextStyles
                                                          .homeheadingtext
                                                          .copyWith(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    Text(
                                                      formatDate(event
                                                              .startDate) ??
                                                          '',
                                                      style: TextStyles
                                                          .homedatetext,
                                                    ),
                                                    SizedBox(height: 0.5.h),
                                                    Text(
                                                      event.city ??
                                                          'Location TBA',
                                                      style: TextStyles
                                                          .homedatetext,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 4.h),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return SizedBox.shrink();
                }),

                /// Upcoming Events Title with enhanced styling
                AnimatedBuilder(
                  animation: _listAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _listAnimation.value)),
                      child: Opacity(
                        opacity: _listAnimation.value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Upcoming Events",
                              style: TextStyles.homeheadingtext.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticUtils.light();
                                navController.changeTab(1);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.blueColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(1.5.h),
                                  border: Border.all(
                                    color: AppColors.blueColor
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "View All",
                                      style: TextStyles.regularwhite.copyWith(
                                        color: AppColors.blueColor,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 1.w),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: AppColors.blueColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 2.h),

                /// Upcoming Events List with staggered animations
                Obx(() {
                  if (controller.isLoading.value) {
                    return SkeletonLoading.listSkeleton(itemCount: 3);
                  } else if (controller.errorMessage.isNotEmpty) {
                    return AppErrorWidget(
                      message: controller.errorMessage.value,
                      onRetry: () => controller.fetchAllEvents(),
                    );
                  } else {
                    // Filter upcoming events only, then sort: promoted first, then by date
                    final upcomingEvents = controller.events.where((event) {
                      if (event.startDate == null) return false;
                      final eventDate = DateTime.tryParse(event.startDate!);
                      if (eventDate == null) return false;
                      return eventDate.isAfter(DateTime.now());
                    }).toList();

                    // Sort: Promoted events FIRST, then by date
                    upcomingEvents.sort((a, b) {
                      final aIsPromoted = a.isPromotionActive;
                      final bIsPromoted = b.isPromotionActive;

                      if (aIsPromoted && !bIsPromoted)
                        return -1; // a comes first
                      if (!aIsPromoted && bIsPromoted)
                        return 1; // b comes first

                      // If both promoted or both not promoted, sort by date
                      try {
                        final aDate = DateTime.parse(a.startDate ?? '');
                        final bDate = DateTime.parse(b.startDate ?? '');
                        return aDate.compareTo(bDate);
                      } catch (_) {
                        return 0;
                      }
                    });

                    if (upcomingEvents.isEmpty) {
                      return AppEmptyStateWidget(
                        title: "No Upcoming Events",
                        message: "Check back later for new events!",
                        icon: Icons.event_available,
                        onAction: () => navController.changeTab(1),
                        actionText: "Explore Events",
                      );
                    }

                    return AnimationLimiter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: upcomingEvents.length,
                        itemBuilder: (context, index) {
                          final event = upcomingEvents[index];

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 600),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: AccessibilityUtils.accessibleCard(
                                  label: 'Event: ${event.eventTitle}',
                                  hint: 'Tap to view event details',
                                  onTap: () {
                                    HapticUtils.selection();
                                    NavigationUtils.push(
                                      context,
                                      EventDetailScreen(
                                          eventId: '${event.eventId}'),
                                      routeName: '/event-detail',
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 2.5.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.signinoptioncolor,
                                      borderRadius:
                                          BorderRadius.circular(2.5.h),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: AppColors.blueColor
                                              .withValues(alpha: 0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.15),
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(2.5.h),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            HapticUtils.selection();
                                            NavigationUtils.push(
                                              context,
                                              EventDetailScreen(
                                                  eventId: '${event.eventId}'),
                                              routeName: '/event-detail',
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              /// Event Image with overlay
                                              Stack(
                                                children: [
                                                  Container(
                                                    height: 20.h,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                2.5.h),
                                                        topRight:
                                                            Radius.circular(
                                                                2.5.h),
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                2.5.h),
                                                        topRight:
                                                            Radius.circular(
                                                                2.5.h),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            'https://eventgo-live.com/${event.eventImage}',
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors.grey
                                                                    .shade700,
                                                                Colors.grey
                                                                    .shade600,
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                          ),
                                                          child: const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      AppColors
                                                                          .blueColor),
                                                            ),
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors.grey
                                                                    .shade800,
                                                                Colors.grey
                                                                    .shade700,
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            color: Colors
                                                                .grey.shade400,
                                                            size: 32,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  /// Category Badge
                                                  Positioned(
                                                    top: 1.5.h,
                                                    left: 1.5.h,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 2.w,
                                                        vertical: 0.8.h,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .blueColor
                                                            .withValues(
                                                                alpha: 0.9),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(1.h),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha: 0.2),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        event.category
                                                                ?.toUpperCase() ??
                                                            'EVENT',
                                                        style: TextStyles
                                                            .regularwhite
                                                            .copyWith(
                                                          fontSize: 8.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  /// Price Badge
                                                  if (event.eventPrice !=
                                                          null &&
                                                      event.eventPrice !=
                                                          '0.00')
                                                    Positioned(
                                                      top: 1.5.h,
                                                      right: 1.5.h,
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 2.w,
                                                          vertical: 0.8.h,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black
                                                              .withValues(
                                                                  alpha: 0.7),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      1.h),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                      alpha:
                                                                          0.3),
                                                              blurRadius: 4,
                                                              offset:
                                                                  const Offset(
                                                                      0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          '\$${event.eventPrice}',
                                                          style: TextStyles
                                                              .regularwhite
                                                              .copyWith(
                                                            fontSize: 9.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                  /// Gradient Overlay
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      height: 6.h,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors.transparent,
                                                            Colors.black
                                                                .withValues(
                                                                    alpha: 0.3),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              /// Event Content
                                              Padding(
                                                padding: EdgeInsets.all(2.h),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    /// Event Title
                                                    Text(
                                                      _capitalizeFirstLetter(
                                                          event.eventTitle ??
                                                              ''),
                                                      style: TextStyles
                                                          .homeheadingtext
                                                          .copyWith(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.3,
                                                        height: 1.3,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 1.5.h),

                                                    /// Date and Time Row
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  1.h),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors
                                                                .blueColor
                                                                .withValues(
                                                                    alpha: 0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1.h),
                                                            border: Border.all(
                                                              color: AppColors
                                                                  .blueColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.3),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 12.sp,
                                                            color: AppColors
                                                                .blueColor,
                                                          ),
                                                        ),
                                                        SizedBox(width: 2.w),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                formatDate(event
                                                                        .startDate) ??
                                                                    '',
                                                                style: TextStyles
                                                                    .homedatetext
                                                                    .copyWith(
                                                                  fontSize:
                                                                      10.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: AppColors
                                                                      .blueColor,
                                                                ),
                                                              ),
                                                              Text(
                                                                formatTime(event
                                                                        .startTime) ??
                                                                    '',
                                                                style: TextStyles
                                                                    .regularwhite
                                                                    .copyWith(
                                                                  fontSize:
                                                                      9.sp,
                                                                  color: Colors
                                                                      .white70,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 1.5.h),

                                                    /// Location Row
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  1.h),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey
                                                                .withValues(
                                                                    alpha: 0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1.h),
                                                            border: Border.all(
                                                              color: Colors.grey
                                                                  .withValues(
                                                                      alpha:
                                                                          0.3),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons.location_on,
                                                            size: 12.sp,
                                                            color: Colors
                                                                .grey.shade400,
                                                          ),
                                                        ),
                                                        SizedBox(width: 2.w),
                                                        Expanded(
                                                          child: Text(
                                                            '${event.city}${event.address != null ? ', ${event.address}' : ''}',
                                                            style: TextStyles
                                                                .regularwhite
                                                                .copyWith(
                                                              fontSize: 10.sp,
                                                              color: Colors
                                                                  .white70,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    /// Description Preview
                                                    if (event.description !=
                                                            null &&
                                                        event.description!
                                                            .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 1.5.h),
                                                        child: Text(
                                                          event.description!,
                                                          style: TextStyles
                                                              .regularwhite
                                                              .copyWith(
                                                            fontSize: 9.sp,
                                                            color:
                                                                Colors.white60,
                                                            height: 1.4,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),

                                                    /// Bottom Action Row
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 2.h),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          /// Event Status
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 2.w,
                                                              vertical: 0.8.h,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: AppColors
                                                                  .blueColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          1.h),
                                                              border:
                                                                  Border.all(
                                                                color: AppColors
                                                                    .blueColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.5),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .event_available,
                                                                  size: 10.sp,
                                                                  color: AppColors
                                                                      .blueColor,
                                                                ),
                                                                SizedBox(
                                                                    width: 1.w),
                                                                Text(
                                                                  'Available',
                                                                  style: TextStyles
                                                                      .regularwhite
                                                                      .copyWith(
                                                                    fontSize:
                                                                        8.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: AppColors
                                                                        .blueColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          /// View Details Arrow
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    1.h),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: AppColors
                                                                  .blueColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          1.h),
                                                              border:
                                                                  Border.all(
                                                                color: AppColors
                                                                    .blueColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.3),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              size: 10.sp,
                                                              color: AppColors
                                                                  .blueColor,
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
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                })
              ],
            ),
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

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
