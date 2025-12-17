import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/EventDetailScreen/event_detail_screen.dart';
import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/MVVM/view_model/bottom_nav_controller.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
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
      final now = DateTime.now();
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
            print('Error parsing event date: ${event.startDate}, error: $e');
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
      onPopInvoked: (didPop) {
        if (!didPop) {
          HapticUtils.navigation();
          navController.changeTab(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        floatingActionButton: FloatingActionButton(
          heroTag: "explore_fab",
          backgroundColor: AppColors.blueColor,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => NavigationUtils.push(
            context,
            const CreateEvent(),
            routeName: '/create-event',
          ),
        ),
        body: SafeArea(
          child: _buildScrollableContent(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticUtils.navigation();
              navController.changeTab(0);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.blueColor,
              size: 20.sp,
            ),
          ),
          Text(
            "Explore Events",
            style: TextStyles.heading,
          ),
          const Spacer(),
          IconButton(
            onPressed: () async {
              HapticUtils.light();
              // Tap toggles current location activation on demand
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
            icon: Icon(
              Icons.my_location,
              color: _useCurrentLocation ? AppColors.blueColor : Colors.white70,
              size: 20.sp,
            ),
            tooltip: 'Use current location',
          ),
          SizedBox(width: 1.w),
          IconButton(
            onPressed: () {
              HapticUtils.light();
              _toggleAdvancedFilters();
            },
            icon: AnimatedRotation(
              turns: _showAdvancedFilters ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.tune,
                color: AppColors.blueColor,
                size: 20.sp,
              ),
            ),
            tooltip: 'Filters',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          // Search Bar with suggestions
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.signinoptioncolor,
                  borderRadius: BorderRadius.circular(2.h),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyles.regularwhite,
                  decoration: InputDecoration(
                    hintText: 'Search events, categories, locations...',
                    hintStyle:
                        TextStyles.regularwhite.copyWith(color: Colors.white70),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.blueColor,
                      size: 20.sp,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white70,
                              size: 16.sp,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  ),
                ),
              ),
              // Search suggestions
              if (_searchSuggestions.isNotEmpty)
                Positioned(
                  top: 6.h,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.signinoptioncolor,
                      borderRadius: BorderRadius.circular(1.h),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
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
                    child: Column(
                      children: _searchSuggestions
                          .map(
                            (suggestion) => ListTile(
                              title: Text(
                                suggestion,
                                style: TextStyles.regularwhite,
                              ),
                              leading: Icon(
                                Icons.history,
                                color: AppColors.blueColor,
                                size: 16.sp,
                              ),
                              onTap: () {
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
          style: TextStyles.subheading,
        ),
        SizedBox(height: 1.h),

        // Category chips
        SizedBox(
          height: 5.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 2.w),
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.light();
                    setState(() {
                      _selectedCategory = category;
                    });
                    _applyFilters();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.blueColor
                          : AppColors.signinoptioncolor,
                      borderRadius: BorderRadius.circular(1.h),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.blueColor
                            : Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.blueColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyles.regularwhite.copyWith(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 2.h),

        // City dropdown removed
      ],
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor.withValues(alpha: 0.3),
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
            style: TextStyles.subheading,
          ),
          SizedBox(height: 2.h),

          // Location toggle removed; radius is shown only when active via header icon
          if (_useCurrentLocation &&
              _currentLat != null &&
              _currentLon != null) ...[
            SizedBox(height: 1.h),
            Slider(
              value: _radiusKm,
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: AppColors.blueColor,
              label: '${_radiusKm.round()} km',
              onChanged: (val) {
                HapticUtils.light();
                setState(() {
                  _radiusKm = val;
                });
                _applyFilters();
              },
            ),
          ],

          SizedBox(height: 2.h),

          // Date range
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date',
                      style: TextStyles.regularwhite,
                    ),
                    SizedBox(height: 1.h),
                    GestureDetector(
                      onTap: () => _selectStartDate(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: AppColors.signinoptioncolor,
                          borderRadius: BorderRadius.circular(1.h),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.blueColor,
                              size: 16.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _startDate != null
                                  ? DateFormat('MMM d, yyyy')
                                      .format(_startDate!)
                                  : 'Select date',
                              style: TextStyles.regularwhite.copyWith(
                                color: _startDate != null
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Date',
                      style: TextStyles.regularwhite,
                    ),
                    SizedBox(height: 1.h),
                    GestureDetector(
                      onTap: () => _selectEndDate(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: AppColors.signinoptioncolor,
                          borderRadius: BorderRadius.circular(1.h),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.blueColor,
                              size: 16.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _endDate != null
                                  ? DateFormat('MMM d, yyyy').format(_endDate!)
                                  : 'Select date',
                              style: TextStyles.regularwhite.copyWith(
                                color: _endDate != null
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.h),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.clear_all,
                  color: Colors.red,
                  size: 16.sp,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Clear All',
                  style: TextStyles.regularwhite.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
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
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
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
              EventDetailScreen(eventId: event.eventId?.toString() ?? ''),
              routeName: '/event-detail',
            );
          },
          borderRadius: BorderRadius.circular(2.h),
          child: Padding(
            padding: EdgeInsets.all(2.h),
            child: Row(
              children: [
                // Event Image with gradient overlay
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(1.h),
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://eventgo-live.com/${event.eventImage}',
                        width: 20.w,
                        height: 12.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 20.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade800,
                                Colors.grey.shade700,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.blueColor),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 20.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade800,
                                Colors.grey.shade700,
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 0.5.h,
                      left: 0.5.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 1.5.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          borderRadius: BorderRadius.circular(0.5.h),
                        ),
                        child: Text(
                          event.category ?? 'Event',
                          style: TextStyles.regularwhite.copyWith(
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 3.w),

                // Event Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        _capitalizeFirstLetter(event.eventTitle ?? ''),
                        style: TextStyles.homeheadingtext,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),

                      // Date & Time
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12.sp,
                            color: AppColors.blueColor,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              '${_formatDate(event.startDate)} | ${_formatTime(event.startTime)}',
                              style: TextStyles.homedatetext,
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
                                style: TextStyles.regularwhite.copyWith(
                                  color: Colors.white70,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                      // Price
                      if (event.eventPrice != null &&
                          event.eventPrice != '0.00')
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 12.sp,
                              color: Colors.green,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '\$${event.eventPrice}',
                              style: TextStyles.regularwhite.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.blueColor,
                  size: 14.sp,
                ),
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
                return AppEmptyStateWidget(
                  title: "No Events Found",
                  message: "Try adjusting your search filters to find events.",
                  icon: Icons.event_available,
                  onAction: () {
                    HapticUtils.light();
                    _clearAllFilters();
                  },
                  actionText: "Clear Filters",
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
          // Add bottom spacer for safe scrolling past last card
          SliverToBoxAdapter(child: SizedBox(height: 2.h)),
        ],
      ),
    );
  }
}
