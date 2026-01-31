import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/MVVM/body_model/event_model.dart';
import 'package:event_app/MVVM/body_model/user_list_model.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_pages.dart';
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
import '../../../Services/location_service.dart';
import '../../../Services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, RefreshOnNavigation {
  final EventController controller = Get.put(EventController());
  final authViewModel = Get.put(AuthViewModel());
  final BottomNavController navController =
      Get.find<BottomNavController>(tag: 'BottomNavController');

  late AnimationController _bannerAnimationController;
  late Animation<double> _bannerAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // General search (events + users)
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<EventModel> _searchEventResults = [];
  List<Data> _searchUserResults = [];
  bool _showSearchResults = false;

  // Device location - city from current GPS (for Discover section)
  String? _deviceCity;

  // Discover (Eventbrite-style) category filter
  String _discoverCategory = 'All';
  static const List<String> _discoverCategories = [
    'All',
    'Dating',
    'Sports',
    'Music',
    'Parties',
    'Food',
    'Business',
    'Education',
    'Travel',
    'Religion',
    'Youth events',
    'Social Circle',
    'Sell Items',
  ];

  String get _greeting {
    return 'Hi';
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _fetchDeviceCity();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && mounted) {
        setState(() => _showSearchResults = false);
      }
    });
  }

  @override
  void refreshData() {
    if (authViewModel.isLoggedIn.value) {
      authViewModel.fetchUsers(); // Load users for search dropdown
      controller.fetchTimelineEvents();
      _fetchDeviceCity();
    } else {
      controller.fetchAllEvents();
      _fetchDeviceCity();
    }
  }

  /// Fetch device's current location and get city for Discover section
  Future<void> _fetchDeviceCity() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null && mounted) {
        final city = await LocationService.getCityFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (mounted) {
          setState(() {
            _deviceCity = (city != 'Unknown City' && city.isNotEmpty)
                ? city.trim()
                : null;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _deviceCity = null);
    }
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

  List<EventModel> _filterUpcomingByCategory(List<EventModel> events) {
    if (_discoverCategory == 'All') return events;
    return events
        .where((e) =>
            (e.category ?? '').toLowerCase() == _discoverCategory.toLowerCase())
        .toList();
  }

  /// User's city from device location (for Discover section). Null for guests or if location unavailable.
  String? get _userCity => _deviceCity;

  /// Featured: only promoted events (up to 5). Section hidden if none promoted.
  List<EventModel> _getFeaturedEvents() {
    final byCategory = _filterUpcomingByCategory(controller.upcomingEvents);
    final promoted = byCategory.where((e) => e.isPromotionActive).toList();
    return promoted.take(5).toList();
  }

  /// Discover: events in device city + events from followed organizers (when logged in)
  List<EventModel> _getDiscoverEvents() {
    final upcoming = _filterUpcomingByCategory(controller.upcomingEvents);
    final userCity = _userCity;

    final Set<int> seenIds = {};
    final List<EventModel> discoverList = [];

    // Logged-in: add events from followed organizers
    if (authViewModel.isLoggedIn.value) {
      for (final e in controller.timelineEvents) {
        if (e.eventId != null && seenIds.add(e.eventId!)) {
          discoverList.add(e);
        }
      }
    }

    // Add events in device city (exact match)
    if (userCity != null) {
      final userCityLower = userCity.trim().toLowerCase();
      for (final e in upcoming) {
        if (e.eventId != null &&
            seenIds.add(e.eventId!) &&
            (e.city ?? '').trim().toLowerCase() == userCityLower) {
          discoverList.add(e);
        }
      }
    }

    discoverList.sort((a, b) => _compareDiscover(a, b));
    return discoverList;
  }

  /// Sort: promoted first, then from-followed (in timeline), then by date.
  int _compareDiscover(EventModel a, EventModel b) {
    final aPromo = a.isPromotionActive ? 1 : 0;
    final bPromo = b.isPromotionActive ? 1 : 0;
    if (bPromo != aPromo) return bPromo.compareTo(aPromo);

    // Events from followed organizers come next
    final aInTimeline =
        controller.timelineEvents.any((e) => e.eventId == a.eventId);
    final bInTimeline =
        controller.timelineEvents.any((e) => e.eventId == b.eventId);
    if (aInTimeline != bInTimeline) return bInTimeline ? 1 : -1;

    // Finally sort by date
    final aDate = DateTime.tryParse(a.startDate ?? '');
    final bDate = DateTime.tryParse(b.startDate ?? '');
    if (aDate == null || bDate == null) return 0;
    return aDate.compareTo(bDate);
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

  Future<void> _onSearchChanged(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() {
        _searchEventResults = [];
        _searchUserResults = [];
        _showSearchResults = false;
      });
      return;
    }

    final lower = trimmed.toLowerCase();

    // Search events (title, category, city, address)
    final eventResults = controller.upcomingEvents
        .where((e) {
          final title = (e.eventTitle ?? '').toLowerCase();
          final category = (e.category ?? '').toLowerCase();
          final city = (e.city ?? '').toLowerCase();
          final address = (e.address ?? '').toLowerCase();
          return title.contains(lower) ||
              category.contains(lower) ||
              city.contains(lower) ||
              address.contains(lower);
        })
        .take(5)
        .toList();

    // Search users - different source for guests vs logged-in
    List<Data> userResults = [];
    if (authViewModel.isLoggedIn.value) {
      // Logged in: use cached list, fetch if empty
      if (authViewModel.users.isEmpty) {
        await authViewModel.fetchUsers();
        if (!mounted) return;
      }
      final currentUserId = authViewModel.currentUser['userId'];
      final currentId = currentUserId is int
          ? currentUserId
          : int.tryParse(currentUserId?.toString() ?? '');
      userResults = authViewModel.users
          .where((user) => user.userId != null && user.userId != currentId)
          .where((user) {
            final name = (user.name ?? '').toString().toLowerCase();
            final email = (user.email ?? '').toString().toLowerCase();
            return name.contains(lower) || email.contains(lower);
          })
          .take(4)
          .toList();
    } else {
      // Guest: use public search API
      final response = await AuthService.searchUsers(trimmed);
      userResults = response.data ?? [];
      if (!mounted) return;
    }

    if (mounted) setState(() {
      _searchEventResults = eventResults;
      _searchUserResults = userResults;
      _showSearchResults = eventResults.isNotEmpty || userResults.isNotEmpty;
    });
  }

  void _dismissSearchResults() {
    setState(() {
      _showSearchResults = false;
      _searchEventResults = [];
      _searchUserResults = [];
      _searchController.clear();
    });
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          onTap: () {
            if (_searchController.text.length >= 2) {
              _onSearchChanged(_searchController.text);
            }
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search events, users, categories...',
            hintStyle: TextStyle(color: Colors.white54, fontSize: 12.sp),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: Colors.white54, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _dismissSearchResults();
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.signinoptioncolor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.h),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.h),
              borderSide: const BorderSide(color: AppColors.blueColor),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
          ),
        ),
        if (_showSearchResults) _buildSearchResultsOverlay(),
      ],
    );
  }

  Widget _buildSearchResultsOverlay() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchEventResults.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              child: Text('Events',
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 10.sp,
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            ...List.generate(_searchEventResults.length, (i) {
              final e = _searchEventResults[i];
              final imageUrl = (e.eventImage ?? '').startsWith('http')
                  ? e.eventImage!
                  : 'https://eventgo-live.com/${e.eventImage ?? ""}';
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(1.h),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.grey.shade800),
                    errorWidget: (_, __, ___) =>
                        Icon(Icons.event, color: Colors.white54),
                  ),
                ),
                title: Text(
                  e.eventTitle ?? 'Event',
                  style: TextStyles.regularwhite.copyWith(fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${e.city ?? ''} • ${e.category ?? ''}',
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 10.sp,
                    color: Colors.white60,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  HapticUtils.navigation();
                  FocusScope.of(context).unfocus();
                  _dismissSearchResults();
                  NavigationUtils.push(
                    context,
                    EventDetailScreen(eventId: '${e.eventId}'),
                    routeName: '/event-detail',
                  );
                },
              );
            }),
            if (_searchUserResults.isNotEmpty)
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          ],
          if (_searchUserResults.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              child: Text('Users',
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 10.sp,
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            ...List.generate(_searchUserResults.length, (i) {
              final user = _searchUserResults[i];
              final imageUrl = (user.profileImageUrl ?? '').toString().trim();
              return ListTile(
                leading: CircleAvatar(
                  radius: 20,
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
                  style: TextStyles.regularwhite.copyWith(fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  user.email ?? '',
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 10.sp,
                    color: Colors.white60,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  HapticUtils.navigation();
                  FocusScope.of(context).unfocus();
                  _dismissSearchResults();
                  NavigationUtils.push(
                    context,
                    PublicProfileScreen(id: user.userId),
                    routeName: '/public-profile',
                  );
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Unfocus inputs when navigating away
    KeyboardUtils.unfocus(context);
    _bannerAnimationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
            if (authViewModel.isLoggedIn.value) {
              await controller.fetchTimelineEvents();
            }
          },
          color: AppColors.blueColor,
          backgroundColor: AppColors.signinoptioncolor,
          strokeWidth: 3.0,
          displacement: 50.0,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(6.w, 6.h, 6.w, 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                    navController.changeTab(
                                        4); // Navigate to Profile tab
                                  },
                                  label:
                                      'Profile picture, tap to go to profile',
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticUtils.navigation();
                                      navController.changeTab(
                                          4); // Navigate to Profile tab
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                          3), // border width
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
                                          authViewModel.isLoggedIn.value
                                              ? (authViewModel
                                                      .currentUser['name'] ??
                                                  '')
                                              : 'Guest';
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
                                      builder: (_) =>
                                          const NotificationScreen(),
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
                                        color: Colors.black
                                            .withValues(alpha: (0.1)),
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
                                          builder: (_) =>
                                              const NotificationScreen(),
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
                  SizedBox(height: 2.h),

                  /// General search bar (events + users)
                  _buildSearchBar(),
                  SizedBox(height: 2.h),

                  /// Eventbrite-style: Category chips
                  SizedBox(
                    height: 4.5.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _discoverCategories.length,
                      itemBuilder: (context, index) {
                        final cat = _discoverCategories[index];
                        final isSelected = _discoverCategory == cat;
                        return Padding(
                          padding: EdgeInsets.only(right: 2.w),
                          child: GestureDetector(
                            onTap: () {
                              HapticUtils.light();
                              setState(() => _discoverCategory = cat);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.blueColor
                                    : AppColors.signinoptioncolor,
                                borderRadius: BorderRadius.circular(2.h),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.blueColor
                                      : Colors.white.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cat,
                                style: TextStyles.regularwhite.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 2.5.h),

                  /// Eventbrite-style: Featured carousel (promoted events only)
                  Obx(() {
                    final featured = _getFeaturedEvents();
                    if (featured.isEmpty && !controller.isLoading.value) {
                      return const SizedBox.shrink();
                    }
                    if (controller.isLoading.value && featured.isEmpty) {
                      return SizedBox(
                        height: 22.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (_, __) => Container(
                            width: 75.w,
                            margin: EdgeInsets.only(right: 4.w),
                            decoration: BoxDecoration(
                              color: AppColors.signinoptioncolor,
                              borderRadius: BorderRadius.circular(2.5.h),
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 1.5.h),
                          child: Text(
                            "Featured",
                            style: TextStyles.homeheadingtext.copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: featured.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: _buildFeaturedCard(featured[index]),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],
                    );
                  }),

                  /// Eventbrite-style: Slim CTA (Create event)
                  GestureDetector(
                    onTap: () {
                      HapticUtils.light();
                      if (authViewModel.isLoggedIn.value) {
                        NavigationUtils.push(
                          context,
                          const CreateEvent(),
                          routeName: '/create-event',
                        );
                      } else {
                        Get.snackbar(
                          'Sign in to create events',
                          'Create an account to host your own events.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.signinoptioncolor,
                          colorText: Colors.white,
                          mainButton: TextButton(
                            onPressed: () => Get.toNamed(RouteName.loginScreen),
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                color: AppColors.blueColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color:
                            AppColors.signinoptioncolor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2.h),
                        border: Border.all(
                          color: AppColors.blueColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: AppColors.blueColor,
                            size: 24.sp,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              "Host an event? Create one and get tickets in a few taps.",
                              style: TextStyles.regularwhite.copyWith(
                                fontSize: 11.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12.sp,
                            color: AppColors.blueColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.5.h),

                  /// Discover: events near you (by distance or city) + from followed organizers (logged-in only)
                  Obx(() {
                    if (controller.isTimelineLoading.value &&
                        controller.timelineEvents.isEmpty &&
                        controller.upcomingEvents.isEmpty) {
                      return SkeletonLoading.listSkeleton(itemCount: 2);
                    }
                    final discoverEvents = _getDiscoverEvents();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Text(
                            "Discover",
                            style: TextStyles.homeheadingtext.copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (discoverEvents.isEmpty)
                          Container(
                            padding: EdgeInsets.all(4.h),
                            decoration: BoxDecoration(
                              color: AppColors.signinoptioncolor
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2.h),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 40.sp,
                                    color: Colors.white54,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    "No events to discover yet",
                                    style: TextStyles.regularwhite.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    "Follow organizers to see their events here, or enable location to see events near you.",
                                    style: TextStyles.regularwhite.copyWith(
                                      fontSize: 11.sp,
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 2.h),
                                  ElevatedButton(
                                    onPressed: () {
                                      HapticUtils.buttonPress();
                                      navController
                                          .changeTab(1); // Go to Search tab
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.blueColor,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 1.2.h,
                                      ),
                                    ),
                                    child: Text(
                                      "Find organizers to follow",
                                      style: TextStyles.regularwhite.copyWith(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          AnimationLimiter(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: discoverEvents.length,
                              itemBuilder: (context, index) {
                                final event = discoverEvents[index];
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 400),
                                  child: SlideAnimation(
                                    verticalOffset: 30.0,
                                    child: FadeInAnimation(
                                      child: _buildDiscoverEventCard(
                                          context, event),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Eventbrite-style: Featured carousel card (large image + overlay)
  Widget _buildFeaturedCard(EventModel event) {
    final imageUrl = event.eventImage?.startsWith('http') == true
        ? event.eventImage!
        : 'https://eventgo-live.com/${event.eventImage}';
    final dateLabel = _shortDate(event.startDate);

    return Material(
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
        child: Container(
          width: 78.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.5.h),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.5.h),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.signinoptioncolor,
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.blueColor),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.signinoptioncolor,
                    child:
                        Icon(Icons.event, size: 48.sp, color: Colors.white30),
                  ),
                ),
                // Gradient overlay
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 12.h,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                ),
                // Date chip
                Positioned(
                  top: 2.h,
                  left: 3.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1.2.h),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      dateLabel ?? 'TBA',
                      style: TextStyles.profiletext.copyWith(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueColor,
                      ),
                    ),
                  ),
                ),
                // Title at bottom
                Positioned(
                  left: 3.w,
                  right: 3.w,
                  bottom: 2.h,
                  child: Text(
                    event.eventTitle ?? 'Event',
                    style: TextStyles.profiletext.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Eventbrite-style: Discover list card (image-forward, date badge, title, location, price)
  Widget _buildDiscoverEventCard(BuildContext context, EventModel event) {
    final imageUrl = event.eventImage?.startsWith('http') == true
        ? event.eventImage!
        : 'https://eventgo-live.com/${event.eventImage}';
    final dateLabel = _shortDate(event.startDate);

    return Container(
      margin: EdgeInsets.only(bottom: 2.5.h),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.5.h),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
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
              // Image with date badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(2.5.h)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 22.h,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 22.h,
                        color: Colors.grey.shade800,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.blueColor),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 22.h,
                        color: Colors.grey.shade800,
                        child: Icon(Icons.event,
                            size: 40.sp, color: Colors.white30),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 1.5.h,
                    left: 3.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1.h),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        dateLabel ?? 'TBA',
                        style: TextStyles.profiletext.copyWith(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueColor,
                        ),
                      ),
                    ),
                  ),
                  if (event.isPromotionActive)
                    Positioned(
                      top: 1.5.h,
                      right: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
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
                    ),
                ],
              ),
              // Title, location, price
              Padding(
                padding: EdgeInsets.all(3.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventTitle ?? '',
                      style: TextStyles.homeheadingtext.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.2.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14.sp, color: Colors.white60),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            event.city ?? 'Location TBA',
                            style: TextStyles.regularwhite.copyWith(
                              fontSize: 11.sp,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (event.eventPrice != null &&
                        event.eventPrice!.isNotEmpty) ...[
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Text(
                            event.eventPrice!,
                            style: TextStyles.homedatetext.copyWith(
                              fontSize: 13.sp,
                              color: Colors.green.shade300,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'per ticket',
                            style: TextStyles.regularwhite.copyWith(
                              fontSize: 10.sp,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _shortDate(String? date) {
    try {
      final parsed = DateTime.parse(date!);
      return DateFormat('EEE, MMM d').format(parsed);
    } catch (e) {
      return date;
    }
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
