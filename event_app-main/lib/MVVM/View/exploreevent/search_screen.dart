import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/MVVM/View/EventDetailScreen/event_detail_screen.dart';
import 'package:event_app/MVVM/view_model/search_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../body_model/event_model.dart';
import '../../../utils/haptic_utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SearchViewModel controller = Get.put(SearchViewModel());
  bool _showFilters = true; // Control filter visibility

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w)
            .copyWith(top: 7.h, bottom: 5.h),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 3.h),
            if (_showFilters) ...[
              _buildSearchFilters(),
              SizedBox(height: 3.h),
            ],
            _buildTabButtons(),
            SizedBox(height: 3.h),
            _buildEventList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                HapticUtils.navigation();
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Center(
                child: Text(
                  "Search Events",
                  style: TextStyles.tickettext.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  icon: Icon(
                    _showFilters ? Icons.filter_list : Icons.filter_list_off,
                    color: AppColors.blueColor,
                    size: 24.sp,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    controller.clearSearch();
                    setState(() {
                      _showFilters = false;
                    });
                  },
                  icon: Icon(Icons.clear, color: AppColors.blueColor, size: 24.sp),
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
      ],
    );
  }

  Widget _buildSearchFilters() {
    return Column(
      children: [
        // Location Status
        Obx(() => _buildLocationStatus()),
        SizedBox(height: 2.h),

        // City Input
        _buildCityInput(),
        SizedBox(height: 2.h),

        // Category Tabs
        _buildCategoryTabs(),
        SizedBox(height: 2.h),

        // Search Radius Slider
        Obx(() => _buildRadiusSlider()),
      ],
    );
  }

  Widget _buildLocationStatus() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
      ),
      child: Row(
        children: [
          Icon(
            controller.isLocationEnabled.value
                ? Icons.location_on
                : Icons.location_off,
            color: controller.isLocationEnabled.value
                ? AppColors.blueColor
                : Colors.grey,
            size: 20.sp,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              controller.isLocationEnabled.value
                  ? 'Location enabled - Finding nearby events'
                  : 'Location disabled - Search by city only',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
              ),
            ),
          ),
          if (!controller.isLocationEnabled.value)
            TextButton(
              onPressed: () => controller.getCurrentLocation(),
              child: Text(
                'Enable',
                style: TextStyle(color: AppColors.blueColor, fontSize: 10.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCityInput() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
      ),
      child: TextField(
        controller: TextEditingController(
            text: controller.selectedCity.value == 'All Cities'
                ? ''
                : controller.selectedCity.value),
        style: TextStyle(color: Colors.white, fontSize: 12.sp),
        decoration: InputDecoration(
          hintText: 'Enter city name...',
          hintStyle: TextStyle(color: Colors.white70, fontSize: 12.sp),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.location_city,
              color: AppColors.blueColor, size: 20.sp),
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            controller.updateSelectedCity('All Cities');
          } else {
            controller.updateSelectedCity(value);
          }
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 6.h,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.availableCategories.length,
            itemBuilder: (context, index) {
              String category = controller.availableCategories[index];
              bool isSelected = controller.selectedCategory.value == category;

              return GestureDetector(
                onTap: () => controller.updateSelectedCategory(category),
                child: Container(
                  margin: EdgeInsets.only(right: 2.w),
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.blueColor
                        : AppColors.signinoptioncolor,
                    borderRadius: BorderRadius.circular(1.h),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.blueColor
                          : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 9.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget _buildRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Radius: ${controller.searchRadius.value.round()}km',
          style: TextStyle(color: Colors.white, fontSize: 10.sp),
        ),
        SizedBox(height: 1.h),
        Slider(
          value: controller.searchRadius.value,
          min: 5.0,
          max: 100.0,
          divisions: 19,
          activeColor: AppColors.blueColor,
          inactiveColor: Colors.grey,
          onChanged: (value) => controller.updateSearchRadius(value),
        ),
      ],
    );
  }

  Widget _buildTabButtons() {
    return Container(
      height: 6.h,
      width: double.infinity,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.h),
        color: AppColors.signinoptioncolor,
      ),
      child: Row(
        children: [
          _buildTabButton('Nearby Events', 0),
          _buildTabButton('All Events', 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabController.animateTo(index)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blueColor : Colors.transparent,
            borderRadius: BorderRadius.circular(3.h),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildNearbyEventsList(),
          _buildAllEventsList(),
        ],
      ),
    );
  }

  Widget _buildNearbyEventsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.blueColor));
      } else if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.red),
          ),
        );
      } else if (!controller.isLocationEnabled.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 50.sp, color: Colors.grey),
              SizedBox(height: 2.h),
              Text(
                'Enable location to see nearby events',
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => controller.getCurrentLocation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                ),
                child: Text('Enable Location'),
              ),
            ],
          ),
        );
      } else if (controller.nearbyEvents.isEmpty) {
        return Center(
          child: Text(
            'No nearby events found',
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
        );
      } else {
        return RefreshIndicator(
          onRefresh: controller.getNearbyEvents,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.nearbyEvents.length,
            itemBuilder: (context, index) =>
                _buildEventCard(controller.nearbyEvents[index]),
          ),
        );
      }
    });
  }

  Widget _buildAllEventsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.blueColor));
      } else if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.red),
          ),
        );
      } else if (controller.searchResults.isEmpty) {
        return Center(
          child: Text(
            'No events found with current filters',
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
        );
      } else {
        return RefreshIndicator(
          onRefresh: controller.searchEvents,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) =>
                _buildEventCard(controller.searchResults[index]),
          ),
        );
      }
    });
  }

  Widget _buildEventCard(EventModel event) {
    String distance = controller.getEventDistance(event);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EventDetailScreen(eventId: event.eventId?.toString() ?? ''),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          color: AppColors.signinoptioncolor,
          borderRadius: BorderRadius.circular(2.h),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(1.h),
              child: CachedNetworkImage(
                imageUrl: 'https://eventgo-live.com/${event.eventImage}',
                width: 20.w,
                height: 10.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.red),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          capitalize(event.eventTitle ?? ''),
                          style: TextStyles.homeheadingtext.copyWith(fontSize: 12.sp),
                        ),
                      ),
                      if (event.isPromotionActive) ...[
                        SizedBox(width: 1.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor,
                            borderRadius: BorderRadius.circular(1.h),
                          ),
                          child: Text(
                            'PROMOTED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '${formatDate(event.startDate)} | ${formatTime(event.startTime)}',
                    style: TextStyles.homedatetext,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12.sp, color: AppColors.blueColor),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          '${event.address} ${event.city}',
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 9.sp, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  if (distance.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Icon(Icons.my_location,
                            size: 10.sp, color: AppColors.blueColor),
                        SizedBox(width: 1.w),
                        Text(
                          distance,
                          style: TextStyle(
                              fontSize: 8.sp, color: AppColors.blueColor),
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
    );
  }

  /// Utilities
  String? formatDate(String? date) {
    try {
      final parsedDate = DateTime.parse(date!);
      return DateFormat('EEEE, MMM d').format(parsedDate);
    } catch (_) {
      return date;
    }
  }

  String? formatTime(String? time) {
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time!);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (_) {
      return time;
    }
  }

  String capitalize(String text) =>
      text.isNotEmpty ? '${text[0].toUpperCase()}${text.substring(1)}' : text;
}
