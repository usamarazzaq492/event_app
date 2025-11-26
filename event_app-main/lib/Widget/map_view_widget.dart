import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../app/config/app_colors.dart';
import '../app/config/app_text_style.dart';
import '../utils/haptic_utils.dart';

class MapViewWidget extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final Function(Map<String, dynamic>) onEventSelected;
  final double? initialLatitude;
  final double? initialLongitude;
  final double? initialZoom;

  const MapViewWidget({
    Key? key,
    required this.events,
    required this.onEventSelected,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom,
  }) : super(key: key);

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  bool _isMapView = true;
  late double _zoom;

  @override
  void initState() {
    super.initState();
// Default to NYC
    _zoom = widget.initialZoom ?? 10.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
      ),
      child: Column(
        children: [
          // Map Header
          Container(
            padding: EdgeInsets.all(2.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(2.h)),
            ),
            child: Row(
              children: [
                Icon(Icons.map, color: AppColors.blueColor),
                SizedBox(width: 2.w),
                Text(
                  'Map View',
                  style: TextStyles.homeheadingtext.copyWith(fontSize: 16.sp),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    HapticUtils.light();
                    setState(() {
                      _isMapView = !_isMapView;
                    });
                  },
                  icon: Icon(
                    _isMapView ? Icons.list : Icons.map,
                    color: AppColors.blueColor,
                  ),
                ),
              ],
            ),
          ),

          // Map Content
          Expanded(
            child: _isMapView ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(2.h)),
      ),
      child: Stack(
        children: [
          // Placeholder for actual map implementation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 15.w,
                  color: Colors.grey,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Map View',
                  style: TextStyles.homeheadingtext.copyWith(
                    fontSize: 18.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Interactive map will be implemented here',
                  style: TextStyles.regulartext.copyWith(
                    color: Colors.grey.shade400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                ElevatedButton.icon(
                  onPressed: () {
                    HapticUtils.buttonPress();
                    // TODO: Implement actual map functionality
                  },
                  icon: Icon(Icons.location_on),
                  label: Text('Enable Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Map Controls
          Positioned(
            top: 2.h,
            right: 2.w,
            child: Column(
              children: [
                _buildMapControl(
                  icon: Icons.add,
                  onPressed: () {
                    HapticUtils.light();
                    setState(() {
                      _zoom = (_zoom + 1).clamp(1.0, 20.0);
                    });
                  },
                ),
                SizedBox(height: 1.h),
                _buildMapControl(
                  icon: Icons.remove,
                  onPressed: () {
                    HapticUtils.light();
                    setState(() {
                      _zoom = (_zoom - 1).clamp(1.0, 20.0);
                    });
                  },
                ),
                SizedBox(height: 1.h),
                _buildMapControl(
                  icon: Icons.my_location,
                  onPressed: () {
                    HapticUtils.light();
                    // TODO: Center map on user location
                  },
                ),
              ],
            ),
          ),

          // Event Markers (simulated)
          ...widget.events.take(3).map((event) {
            final index = widget.events.indexOf(event);
            return Positioned(
              left: 20.w + (index * 15.w),
              top: 15.h + (index * 5.h),
              child: GestureDetector(
                onTap: () {
                  HapticUtils.selection();
                  widget.onEventSelected(event);
                },
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 4.w,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(2.h)),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(2.h),
        itemCount: widget.events.length,
        itemBuilder: (context, index) {
          final event = widget.events[index];
          return Container(
            margin: EdgeInsets.only(bottom: 2.h),
            padding: EdgeInsets.all(2.h),
            decoration: BoxDecoration(
              color: AppColors.signinoptioncolor,
              borderRadius: BorderRadius.circular(2.h),
            ),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppColors.blueColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] ?? 'Event',
                        style: TextStyles.homeheadingtext
                            .copyWith(fontSize: 14.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        event['location'] ?? 'Location',
                        style: TextStyles.regulartext.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 4.w,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(2.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.blueColor, size: 4.w),
      ),
    );
  }
}
