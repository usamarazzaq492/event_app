import 'dart:math' as math;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/MVVM/body_model/event_model.dart';
import 'package:event_app/MVVM/body_model/user_list_model.dart';
import 'package:event_app/app/config/app_asset.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_pages.dart';
import '../../view_model/auth_view_model.dart';
import '../../view_model/bottom_nav_controller.dart';
import '../EventDetailScreen/event_detail_screen.dart';
import '../ProfileScreen/public_profile_screen.dart';
import '../exploreevent/create_event.dart';
import '../notification/notification_screen.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/haptic_utils.dart';
import '../../../utils/refresh_on_navigation_mixin.dart';
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

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<EventModel> _searchEventResults = [];
  List<Data> _searchUserResults = [];
  bool _showSearchResults = false;
  String _discoverCategory = 'All';
  List<EventModel> _randomizedUpcomingEvents = [];

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
    'Sell Items'
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && mounted) {
        setState(() => _showSearchResults = false);
      }
    });
    _shuffleEvents();
  }

  void _shuffleEvents() {
    final List<EventModel> shuffled = List.from(controller.upcomingEvents);
    shuffled.shuffle(math.Random());
    if (mounted) {
      setState(() {
        _randomizedUpcomingEvents = shuffled;
      });
    }
  }

  @override
  void refreshData() {
    if (authViewModel.isLoggedIn.value) {
      authViewModel.fetchUsers();
      controller.fetchTimelineEvents().then((_) => _shuffleEvents());
    } else {
      controller.fetchAllEvents().then((_) => _shuffleEvents());
    }
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
    final eventResults = controller.upcomingEvents
        .where((e) {
          final title = (e.eventTitle ?? '').toLowerCase();
          final category = (e.category ?? '').toLowerCase();
          final city = (e.city ?? '').toLowerCase();
          return title.contains(lower) ||
              category.contains(lower) ||
              city.contains(lower);
        })
        .take(5)
        .toList();

    List<Data> userResults = [];
    if (authViewModel.isLoggedIn.value) {
      if (authViewModel.users.isEmpty) await authViewModel.fetchUsers();
      final currentUserId = authViewModel.currentUser['userId'];
      userResults = authViewModel.users
          .where((user) {
            final name = (user.name ?? '').toString().toLowerCase();
            return name.contains(lower) &&
                user.userId.toString() != currentUserId.toString();
          })
          .take(4)
          .toList();
    } else {
      final response = await AuthService.searchUsers(trimmed);
      userResults = response.data ?? [];
    }

    if (mounted) {
      setState(() {
        _searchEventResults = eventResults;
        _searchUserResults = userResults;
        _showSearchResults = eventResults.isNotEmpty || userResults.isNotEmpty;
      });
    }
  }

  void _dismissSearchResults() {
    setState(() {
      _showSearchResults = false;
      _searchEventResults = [];
      _searchUserResults = [];
      _searchController.clear();
      _searchFocusNode.unfocus();
    });
  }

  List<EventModel> _getPromotedEvents() {
    return controller.upcomingEvents
        .where((e) => e.isPromotionActive)
        .take(5)
        .toList();
  }

  List<EventModel> _getDiscoverEvents() {
    final List<EventModel> discoverList = [];
    final Set<int> seenIds = {};

    // 1. If logged in, prioritize followed events (Timeline)
    if (authViewModel.isLoggedIn.value) {
      for (final e in controller.timelineEvents) {
        if (e.eventId != null && seenIds.add(e.eventId!)) {
          discoverList.add(e);
        }
      }
    }

    // 2. Add randomized upcoming events that aren't already added
    if (_randomizedUpcomingEvents.isEmpty &&
        controller.upcomingEvents.isNotEmpty) {
      final List<EventModel> shuffled = List.from(controller.upcomingEvents);
      shuffled.shuffle(math.Random());
      _randomizedUpcomingEvents = shuffled;
    }

    for (final e in _randomizedUpcomingEvents) {
      if (e.eventId != null && seenIds.add(e.eventId!)) {
        discoverList.add(e);
      }
    }

    // 3. Filter by category if selected
    if (_discoverCategory != 'All') {
      return discoverList
          .where((e) =>
              (e.category ?? '').toLowerCase() ==
              _discoverCategory.toLowerCase())
          .toList();
    }

    return discoverList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async => refreshData(),
        color: AppColors.blueColor,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPremiumHeader(),
              SizedBox(height: 1.h),
              _buildPremiumSearchBar(),
              SizedBox(height: 2.h),
              _buildCategoryChips(),
              SizedBox(height: 2.5.h),
              _buildPromotedCarousel(),
              _buildCreateEventCTA(),
              SizedBox(height: 2.5.h),
              _buildDiscoverSection(),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? "Good morning"
        : (hour < 17 ? "Good afternoon" : "Good evening");

    return Container(
      padding: EdgeInsets.fromLTRB(
          6.w, MediaQuery.of(context).padding.top + 2.h, 6.w, 1.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: TextStyle(color: Colors.white60, fontSize: 10.sp)),
                Obx(() {
                  final name = authViewModel.isLoggedIn.value
                      ? (authViewModel.currentUser['name'] ?? 'Friend')
                      : 'Guest';
                  return Text(name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold));
                }),
              ],
            ),
          ),
          _buildNotificationCircle(),
          SizedBox(width: 3.w),
          _buildProfileCircle(),
        ],
      ),
    );
  }

  Widget _buildNotificationCircle() {
    return GestureDetector(
      onTap: () {
        HapticUtils.light();
        NavigationUtils.push(context, const NotificationScreen(),
            routeName: '/notifications');
      },
      child: Container(
        padding: EdgeInsets.all(1.2.h),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle),
        child: Icon(Icons.notifications_none_rounded,
            color: Colors.white, size: 20.sp),
      ),
    );
  }

  Widget _buildProfileCircle() {
    return Obx(() {
      final user = authViewModel.currentUser;
      final imageUrl = (user['profileImageUrl'] != null &&
              user['profileImageUrl'].isNotEmpty)
          ? 'https://eventgo-live.com/${user['profileImageUrl']}'
          : '';
      return GestureDetector(
        onTap: () {
          HapticUtils.navigation();
          navController.changeTab(4);
        },
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.blueColor.withValues(alpha: 0.5), width: 2)),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.signinoptioncolor,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : const AssetImage(AppImages.profileicon) as ImageProvider,
          ),
        ),
      );
    });
  }

  Widget _buildPremiumSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2.h),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(2.h),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1))),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search events, organizers...",
                    hintStyle:
                        TextStyle(color: Colors.white38, fontSize: 11.sp),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.blueColor, size: 20.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                  ),
                ),
              ),
            ),
          ),
          if (_showSearchResults) _buildSearchResultsOverlay(),
        ],
      ),
    );
  }

  Widget _buildSearchResultsOverlay() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      constraints: BoxConstraints(maxHeight: 40.h),
      decoration: BoxDecoration(
          color: AppColors.signinoptioncolor,
          borderRadius: BorderRadius.circular(2.h),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        children: [
          if (_searchEventResults.isNotEmpty) ...[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Text('Events',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold))),
            ..._searchEventResults.map((e) => ListTile(
                  title: Text(e.eventTitle ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                  onTap: () {
                    _dismissSearchResults();
                    NavigationUtils.push(
                        context, EventDetailScreen(eventId: '${e.eventId}'),
                        routeName: '/event-detail');
                  },
                )),
          ],
          if (_searchUserResults.isNotEmpty) ...[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Text('Users',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold))),
            ..._searchUserResults.map((u) => ListTile(
                  title: Text(u.name ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                  onTap: () {
                    _dismissSearchResults();
                    NavigationUtils.push(
                        context, PublicProfileScreen(id: u.userId),
                        routeName: '/public-profile');
                  },
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 4.5.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 6.w),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.blueColor
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(2.h),
                  border: Border.all(
                      color: isSelected
                          ? AppColors.blueColor
                          : Colors.white.withValues(alpha: 0.1)),
                ),
                alignment: Alignment.center,
                child: Text(cat,
                    style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white70)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromotedCarousel() {
    return Obx(() {
      final promoted = _getPromotedEvents();
      if (promoted.isEmpty && !controller.isLoading.value) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Promoted Events",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5)),
                Icon(Icons.stars_rounded,
                    color: AppColors.blueColor, size: 18.sp),
              ],
            ),
          ),
          SizedBox(
            height: 25.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              physics: const BouncingScrollPhysics(),
              itemCount: controller.isLoading.value && promoted.isEmpty
                  ? 3
                  : promoted.length,
              itemBuilder: (context, index) {
                if (controller.isLoading.value && promoted.isEmpty) {
                  return Container(
                      width: 78.w,
                      margin: EdgeInsets.only(right: 4.w),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(2.5.h)));
                }
                return Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: _buildPromotedCard(promoted[index]));
              },
            ),
          ),
          SizedBox(height: 3.h),
        ],
      );
    });
  }

  Widget _buildPromotedCard(EventModel event) {
    final imageUrl = event.eventImage?.startsWith('http') == true
        ? event.eventImage!
        : 'https://eventgo-live.com/${event.eventImage}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticUtils.light();
          NavigationUtils.push(
              context, EventDetailScreen(eventId: '${event.eventId}'),
              routeName: '/event-detail');
        },
        borderRadius: BorderRadius.circular(2.5.h),
        child: Container(
          width: 78.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.5.h),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8))
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.5.h),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                // Promoted Badge
                Positioned(
                  top: 1.5.h,
                  right: 1.5.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1.h),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w, vertical: 0.6.h),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(1.h),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.campaign_rounded,
                                color: Colors.white, size: 10.sp),
                            SizedBox(width: 1.w),
                            Text(
                              "PROMOTED",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(2.h, 4.h, 2.h, 2.h),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8)
                        ])),
                    child: Text(event.eventTitle ?? '',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                            letterSpacing: -0.2),
                        maxLines: 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateEventCTA() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: GestureDetector(
        onTap: () => authViewModel.isLoggedIn.value
            ? NavigationUtils.push(context, const CreateEvent())
            : Get.toNamed(RouteName.loginScreen),
        child: Container(
          padding: EdgeInsets.all(2.h),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(2.h),
              border: Border.all(
                  color: AppColors.blueColor.withValues(alpha: 0.3))),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline,
                  color: AppColors.blueColor, size: 24.sp),
              SizedBox(width: 3.w),
              Expanded(
                  child: Text("Host an event? Create one in a few taps.",
                      style:
                          TextStyle(fontSize: 10.sp, color: Colors.white70))),
              Icon(Icons.arrow_forward_ios,
                  size: 10.sp, color: AppColors.blueColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverSection() {
    return Obx(() {
      final discoverEvents = _getDiscoverEvents();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              child: Text("Discover",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold))),
          ...discoverEvents.map((e) => _buildDiscoverEventCard(context, e)),
        ],
      );
    });
  }

  Widget _buildDiscoverEventCard(BuildContext context, EventModel event) {
    final imageUrl = event.eventImage?.startsWith('http') == true
        ? event.eventImage!
        : 'https://eventgo-live.com/${event.eventImage}';
    return Container(
      margin: EdgeInsets.fromLTRB(6.w, 0, 6.w, 2.h),
      decoration: BoxDecoration(
          color: AppColors.signinoptioncolor,
          borderRadius: BorderRadius.circular(2.h)),
      child: ListTile(
        contentPadding: EdgeInsets.all(1.5.h),
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(1.h),
            child: CachedNetworkImage(
                imageUrl: imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
        title: Text(event.eventTitle ?? '',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11.sp),
            maxLines: 2),
        subtitle: Text(event.city ?? '',
            style: TextStyle(color: Colors.white60, fontSize: 9.sp)),
        onTap: () => NavigationUtils.push(
            context, EventDetailScreen(eventId: '${event.eventId}'),
            routeName: '/event-detail'),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
