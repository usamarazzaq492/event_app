import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/EventDetailScreen/event_detail_screen.dart';
import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/MVVM/view_model/bottom_nav_controller.dart';
import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../body_model/event_model.dart';
import 'create_event.dart';
import '../../../Widget/error_widget.dart';
import '../../../Widget/skeleton_loading.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/haptic_utils.dart';
import '../../../Services/location_service.dart';

class ExploreEventScreen extends StatefulWidget {
  const ExploreEventScreen({super.key});

  @override
  State<ExploreEventScreen> createState() => _ExploreEventScreenState();
}

class _ExploreEventScreenState extends State<ExploreEventScreen>
    with TickerProviderStateMixin {
  final EventController controller = Get.put(EventController());
  final AuthViewModel authViewModel = Get.put(AuthViewModel());
  final BottomNavController navController =
      Get.find<BottomNavController>(tag: 'BottomNavController');

  // Animation controllers
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _useCurrentLocation = false;
  double _radiusKm = 25;
  double? _currentLat;
  double? _currentLon;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSearching = false;
  bool _showAdvancedFilters = false;
  List<EventModel> _filteredEvents = [];
  List<String> _searchSuggestions = [];

  // Available categories
  final List<String> _categories = [
    'All',
    'Dating',
    'Sell Items',
    'Religion',
    'Sports',
    'Parties',
    'Food',
    'Music',
    'Youth events',
    'Social Circle',
    'Business',
    'Education',
    'Travel'
  ];

  // Sorting is fixed to date ascending

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _searchController.addListener(_onSearchChanged);
    // Defer initial actions to after first frame to avoid Obx updates during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadEvents();
      // Do not enable current location by default
    });
  }

  void _initializeAnimations() {
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.length >= 2) {
      _generateSearchSuggestions();
    } else {
      setState(() {
        _searchSuggestions.clear();
      });
    }
    _applyFilters();
  }

  void _generateSearchSuggestions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      final suggestions = <String>[];

      // Add matching event titles
      final matchingTitles = controller.events
          .where((event) =>
              event.eventTitle?.toLowerCase().contains(query) ?? false)
          .map((event) => event.eventTitle ?? '')
          .where((title) => title.isNotEmpty)
          .toSet() // Remove duplicates
          .take(3)
          .toList();
      suggestions.addAll(matchingTitles);

      // Add matching cities
      final matchingCities = controller.events
          .where((event) => event.city?.toLowerCase().contains(query) ?? false)
          .map((event) => event.city ?? '')
          .where((city) => city.isNotEmpty)
          .toSet() // Remove duplicates
          .take(2)
          .toList();
      suggestions.addAll(matchingCities);

      _searchSuggestions = suggestions.take(5).toList();
    });
  }

  Future<void> _loadEvents() async {
    setState(() => _isSearching = true);
    try {
      await controller.fetchAllEvents();
      _applyFilters();
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredEvents = controller.events.where((event) {
        // Search by title, category, and location (city + address)
        bool matchesSearch = _searchController.text.isEmpty ||
            (event.eventTitle
                    ?.toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ??
                false) ||
            (event.category
                    ?.toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ??
                false) ||
            (event.city
                    ?.toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ??
                false) ||
            (event.address
                    ?.toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ??
                false);

        // Filter by category
        bool matchesCategory = _selectedCategory == 'All' ||
            (event.category?.toLowerCase() == _selectedCategory.toLowerCase());

        // Filter out past events - only show events that haven't passed
        bool isNotPast = false; // Default to false (exclude) for safety
        if (event.startDate != null && event.startDate!.isNotEmpty) {
          try {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            // Combine startDate and startTime if both are available
            if (event.startTime != null && event.startTime!.isNotEmpty) {
              DateTime eventDateTime;
              // Try to parse combined date and time
              try {
                final dateTimeString =
                    '${event.startDate!} ${event.startTime!}';
                eventDateTime = DateTime.parse(dateTimeString);
              } catch (_) {
                // If combined parsing fails, parse date and add time manually
                final dateOnly = DateTime.parse(event.startDate!);
                final timeParts = event.startTime!.split(':');
                if (timeParts.length >= 2) {
                  final hour = int.tryParse(timeParts[0]) ?? 0;
                  final minute = int.tryParse(timeParts[1]) ?? 0;
                  eventDateTime = DateTime(
                    dateOnly.year,
                    dateOnly.month,
                    dateOnly.day,
                    hour,
                    minute,
                  );
                } else {
                  // If time parsing fails, use start of day
                  eventDateTime = DateTime(
                    dateOnly.year,
                    dateOnly.month,
                    dateOnly.day,
                  );
                }
              }

              // For events with time: include only if event datetime is in the future
              // (exclude if event has already started)
              isNotPast = eventDateTime.isAfter(now);
            } else {
              // Only date available - compare dates only (ignore time)
              final dateOnly = DateTime.parse(event.startDate!);
              final eventDate =
                  DateTime(dateOnly.year, dateOnly.month, dateOnly.day);

              // Include if event date is today or in the future
              // (exclude if event date is in the past)
              isNotPast =
                  eventDate.isAfter(today) || eventDate.isAtSameMomentAs(today);
            }
          } catch (e) {
            // If date parsing fails, exclude the event to be safe
            isNotPast = false;
            debugPrint(
                'Error parsing event date: ${event.startDate}, error: $e');
          }
        }
        // If no start date, isNotPast remains false (event excluded)

        // Distance filter (if enabled)
        bool matchesDistance = true;
        if (_useCurrentLocation && _currentLat != null && _currentLon != null) {
          final evLat = double.tryParse(event.latitude ?? '');
          final evLon = double.tryParse(event.longitude ?? '');
          // Strict: require valid coordinates and be within radius
          if (evLat == null || evLon == null) {
            matchesDistance = false;
          } else {
            final distanceKm = LocationService.calculateDistance(
              _currentLat!,
              _currentLon!,
              evLat,
              evLon,
            );
            matchesDistance = distanceKm <= _radiusKm;
          }
        }

        // Filter by date range
        bool matchesDate = true;
        if (_startDate != null || _endDate != null) {
          try {
            final eventDate = DateTime.parse(event.startDate ?? '');
            if (_startDate != null && eventDate.isBefore(_startDate!)) {
              matchesDate = false;
            }
            if (_endDate != null && eventDate.isAfter(_endDate!)) {
              matchesDate = false;
            }
          } catch (_) {
            matchesDate = true;
          }
        }

        return matchesSearch &&
            matchesCategory &&
            isNotPast &&
            matchesDistance &&
            matchesDate;
      }).toList();

      // Sort: Promoted events FIRST, then by distance when location active, else by date
      _filteredEvents.sort((a, b) {
        // First priority: Promoted events come first
        final aIsPromoted = a.isPromotionActive;
        final bIsPromoted = b.isPromotionActive;

        if (aIsPromoted && !bIsPromoted) return -1; // a comes first
        if (!aIsPromoted && bIsPromoted) return 1; // b comes first

        // If both promoted or both not promoted, use secondary sorting
        if (_useCurrentLocation && _currentLat != null && _currentLon != null) {
          // Sort by distance
          final aLat = double.tryParse(a.latitude ?? '') ?? 0;
          final aLon = double.tryParse(a.longitude ?? '') ?? 0;
          final bLat = double.tryParse(b.latitude ?? '') ?? 0;
          final bLon = double.tryParse(b.longitude ?? '') ?? 0;
          final aDist = LocationService.calculateDistance(
              _currentLat!, _currentLon!, aLat, aLon);
          final bDist = LocationService.calculateDistance(
              _currentLat!, _currentLon!, bLat, bLon);
          return aDist.compareTo(bDist);
        } else {
          // Sort by date
          try {
            return DateTime.parse(a.startDate ?? '')
                .compareTo(DateTime.parse(b.startDate ?? ''));
          } catch (_) {
            return 0;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          HapticUtils.navigation();
          navController.changeTab(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 11.h),
          child: FloatingActionButton(
            heroTag: "explore_fab",
            backgroundColor: AppColors.blueColor,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
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
                    onPressed: () {
                      Get.toNamed(RouteName.loginScreen);
                    },
                    child: const Text(
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
          ),
        ),
        body: SafeArea(
          child: _buildScrollableContent(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withValues(alpha: 0.8),
            border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticUtils.navigation();
                  navController.changeTab(0);
                },
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.blueColor, size: 18.sp),
              ),
              Expanded(
                child: Text(
                  "Discover Events",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5),
                ),
              ),
              _buildHeaderActionIcon(
                icon: Icons.my_location_rounded,
                isActive: _useCurrentLocation,
                onTap: () async {
                  HapticUtils.light();
                  final activating = !_useCurrentLocation;
                  setState(() => _useCurrentLocation = activating);
                  if (activating) {
                    await _enableCurrentLocation();
                  } else {
                    setState(() {
                      _currentLat = null;
                      _currentLon = null;
                    });
                    _applyFilters();
                  }
                },
              ),
              SizedBox(width: 2.w),
              _buildHeaderActionIcon(
                icon: Icons.tune_rounded,
                isActive: _showAdvancedFilters,
                onTap: () {
                  HapticUtils.light();
                  _toggleAdvancedFilters();
                },
                isRotating: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderActionIcon({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isRotating = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(1.2.h),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.blueColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? AppColors.blueColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: isRotating
            ? AnimatedRotation(
                turns: isActive ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(icon,
                    color: isActive ? AppColors.blueColor : Colors.white,
                    size: 16.sp),
              )
            : Icon(icon,
                color: isActive ? AppColors.blueColor : Colors.white,
                size: 16.sp),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2.h),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(2.h),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search events, categories, locations...',
                        hintStyle:
                            TextStyle(color: Colors.white38, fontSize: 11.sp),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.blueColor,
                          size: 20.sp,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  HapticUtils.light();
                                  _searchController.clear();
                                  _applyFilters();
                                },
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: Colors.white70,
                                  size: 16.sp,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                      ),
                    ),
                  ),
                ),
              ),
              if (_searchSuggestions.isNotEmpty)
                Positioned(
                  top: 7.h,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1.5.h),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.signinoptioncolor
                              .withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(1.5.h),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _searchSuggestions
                              .map(
                                (suggestion) => ListTile(
                                  title: Text(
                                    suggestion,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11.sp),
                                  ),
                                  leading: Icon(
                                    Icons.history_rounded,
                                    color: AppColors.blueColor,
                                    size: 16.sp,
                                  ),
                                  onTap: () {
                                    HapticUtils.selection();
                                    _searchController.text = suggestion;
                                    setState(() {
                                      _searchSuggestions.clear();
                                    });
                                    _applyFilters();
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _filterAnimation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Column(
              children: [
                // Quick filters
                _buildQuickFilters(),
                SizedBox(height: 2.h),

                // Advanced filters
                if (_showAdvancedFilters) ...[
                  _buildAdvancedFilters(),
                  SizedBox(height: 2.h),
                ],

                // Clear filters
                _buildClearRow(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 1.5.h),
        SizedBox(
          height: 4.5.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;

              return Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.light();
                    setState(() {
                      _selectedCategory = category;
                    });
                    _applyFilters();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.blueColor
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(1.2.h),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.blueColor
                            : Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.blueColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 10.sp,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedFilters() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(2.h),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Advanced Filters',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold),
              ),
              if (_useCurrentLocation &&
                  _currentLat != null &&
                  _currentLon != null) ...[
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Search Radius',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 10.sp)),
                    Text('${_radiusKm.round()} km',
                        style: TextStyle(
                            color: AppColors.blueColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: AppColors.blueColor,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                    thumbColor: Colors.white,
                    overlayColor: AppColors.blueColor.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _radiusKm,
                    min: 1,
                    max: 100,
                    onChanged: (val) {
                      HapticUtils.light();
                      setState(() => _radiusKm = val);
                      _applyFilters();
                    },
                  ),
                ),
              ],
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Start Date',
                      date: _startDate,
                      onTap: _selectStartDate,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildDatePicker(
                      label: 'End Date',
                      date: _endDate,
                      onTap: _selectEndDate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 9.sp)),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () {
            HapticUtils.light();
            onTap();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(1.h),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: AppColors.blueColor, size: 14.sp),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('MMM d, yyyy').format(date)
                        : 'Anytime',
                    style: TextStyle(
                        color: date != null ? Colors.white : Colors.white38,
                        fontSize: 10.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClearRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            HapticUtils.light();
            _clearAllFilters();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(1.h),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded,
                    color: Colors.redAccent, size: 12.sp),
                SizedBox(width: 1.5.w),
                Text(
                  'Reset Filters',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Removed _buildEventsList; list is built in _buildScrollableContent

  Widget _buildEventCard(EventModel event, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(2.2.h),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticUtils.selection();
            NavigationUtils.push(
              context,
              EventDetailScreen(eventId: event.eventId?.toString() ?? ''),
              routeName: '/event-detail',
            );
          },
          borderRadius: BorderRadius.circular(2.2.h),
          child: Padding(
            padding: EdgeInsets.all(1.5.h),
            child: Row(
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'event_image_${event.eventId}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1.5.h),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://eventgo-live.com/${event.eventImage}',
                          width: 25.w,
                          height: 12.h,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.white.withValues(alpha: 0.05),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.blueColor),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white.withValues(alpha: 0.05),
                            child: Icon(Icons.image_not_supported_rounded,
                                color: Colors.white24, size: 20.sp),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0.6.h,
                      left: 0.6.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.4.h),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          borderRadius: BorderRadius.circular(0.8.h),
                        ),
                        child: Text(
                          (event.category ?? 'Event').toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 6.sp,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalizeFirstLetter(event.eventTitle ?? '').trim(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 10.sp, color: AppColors.blueColor),
                          SizedBox(width: 1.5.w),
                          Expanded(
                            child: Text(
                              '${_formatDate(event.startDate)} • ${_formatTime(event.startTime)}',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 9.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      if (_useCurrentLocation &&
                          _currentLat != null &&
                          _currentLon != null)
                        Builder(
                          builder: (_) {
                            final evLat = double.tryParse(event.latitude ?? '');
                            final evLon =
                                double.tryParse(event.longitude ?? '');
                            if (evLat != null && evLon != null) {
                              final dKm = LocationService.calculateDistance(
                                  _currentLat!, _currentLon!, evLat, evLon);
                              return Text(
                                LocationService.formatDistance(dKm),
                                style: TextStyle(
                                    color: AppColors.blueColor
                                        .withValues(alpha: 0.7),
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      SizedBox(height: 1.h),
                      if (event.eventPrice != null &&
                          event.eventPrice != '0.00')
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(0.6.h),
                          ),
                          child: Text(
                            '\$${event.eventPrice}',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white24, size: 12.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleAdvancedFilters() {
    HapticUtils.light();
    setState(() {
      _showAdvancedFilters = !_showAdvancedFilters;
    });

    if (_showAdvancedFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'All';
      _useCurrentLocation = false;
      _radiusKm = 25;
      _currentLat = null;
      _currentLon = null;
      _startDate = null;
      _endDate = null;
      _searchSuggestions.clear();
    });
    _applyFilters();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.blueColor,
              onPrimary: Colors.white,
              surface: AppColors.signinoptioncolor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
      _applyFilters();
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.blueColor,
              onPrimary: Colors.white,
              surface: AppColors.signinoptioncolor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
      _applyFilters();
    }
  }

  Future<void> _enableCurrentLocation() async {
    try {
      setState(() {});
      final pos = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _currentLat = pos?.latitude;
        _currentLon = pos?.longitude;
        _useCurrentLocation = pos != null;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _useCurrentLocation = false;
        _currentLat = null;
        _currentLon = null;
      });
      Get.snackbar(
        'Location unavailable',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Utility methods
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  String? _formatDate(String? date) {
    try {
      final parsedDate = DateTime.parse(date!);
      return DateFormat('MMM d, yyyy').format(parsedDate);
    } catch (_) {
      return date;
    }
  }

  String? _formatTime(String? time) {
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time!);
      return DateFormat("h:mm a").format(parsedTime);
    } catch (_) {
      return time;
    }
  }

  Widget _buildScrollableContent() {
    return RefreshIndicator(
      onRefresh: _loadEvents,
      color: AppColors.blueColor,
      backgroundColor: AppColors.signinoptioncolor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildSearchSection()),
          SliverToBoxAdapter(child: _buildFiltersSection()),
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value || _isSearching) {
                return SkeletonLoading.listSkeleton(itemCount: 5);
              } else if (controller.errorMessage.isNotEmpty) {
                return AppErrorWidget(
                  message: controller.errorMessage.value,
                  onRetry: () => _loadEvents(),
                );
              } else if (_filteredEvents.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 60.sp, color: Colors.white10),
                      SizedBox(height: 2.h),
                      Text(
                        "No Events Found",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Try adjusting your filters to find more events.",
                        style:
                            TextStyle(color: Colors.white38, fontSize: 10.sp),
                      ),
                      SizedBox(height: 3.h),
                      OutlinedButton(
                        onPressed: () {
                          HapticUtils.light();
                          _clearAllFilters();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color:
                                  AppColors.blueColor.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1.h)),
                        ),
                        child: Text("Clear All Filters",
                            style: TextStyle(
                                color: AppColors.blueColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  itemCount: _filteredEvents.length,
                  itemBuilder: (context, index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    child: _buildEventCard(_filteredEvents[index], index),
                  ),
                );
              }
            }),
          ),
          // Add bottom spacer for safe scrolling past last card (accounting for bottom nav bar)
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        ],
      ),
    );
  }
}
