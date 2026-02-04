import 'package:event_app/MVVM/view_model/auth_view_model.dart';
import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/MVVM/body_model/event_detail_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_pages.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // Commented out - map functionality disabled
import '../../view_model/public_profile_controller.dart';
import '../ProfileScreen/public_profile_screen.dart';
import '../UsersData/invite_user_list.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/share_utils.dart';
import '../../../utils/haptic_utils.dart';
import '../bottombar/bottom_navigation_bar.dart';
import '../../../Widget/live_stream_widget.dart';
import '../Promotion/promote_event_screen.dart';
import 'package:event_app/MVVM/View/bookEvent/book_event_screen.dart';
import 'package:event_app/MVVM/View/PaymentQr/generate_payment_qr_screen.dart';
import 'package:event_app/MVVM/View/TicketCheckIn/ticket_checkin_scanner.dart';
import 'package:event_app/Services/payment_qr_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

/// Safe Google Map Widget with error handling - COMMENTED OUT
/*
class _SafeMapStatefulWidget extends StatefulWidget {
  final LatLng location;
  final EventDetailModel event;

  const _SafeMapStatefulWidget({
    required this.location,
    required this.event,
  });

  @override
  State<_SafeMapStatefulWidget> createState() => _SafeMapStatefulWidgetState();
}
*/

/*
class _SafeMapStatefulWidgetState extends State<_SafeMapStatefulWidget> {
  bool _mapInitialized = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    // Temporarily show fallback until API key is configured
    // Uncomment the GoogleMap widget below once API key is added to Info.plist
    return _buildMapFallback(widget.location, widget.event);
    
    // Uncomment this once Google Maps API key is configured in Info.plist
    /*
    if (_hasError) {
      return _buildMapFallback(widget.location, widget.event);
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.location,
        zoom: 15.0,
      ),
      markers: {
        Marker(
          markerId: MarkerId('event_location'),
          position: widget.location,
          infoWindow: InfoWindow(
            title: widget.event.eventTitle ?? 'Event Location',
            snippet: '${widget.event.address ?? ''}, ${widget.event.city ?? ''}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      },
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        if (mounted) {
          setState(() {
            _mapInitialized = true;
          });
        }
      },
    );
    */
  }
*/

// COMMENTED OUT - Map functionality disabled
/*
  Widget _buildMapFallback(LatLng location, EventDetailModel event) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Icon(
                Icons.map,
                size: 50.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          // Content - made scrollable to prevent overflow
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(1.5.w),
                    decoration: BoxDecoration(
                      color: AppColors.blueColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 24.sp,
                      color: AppColors.blueColor,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Event Location',
                    style: TextStyles.regularwhite.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: AppColors.signinoptioncolor,
                      borderRadius: BorderRadius.circular(1.h),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.navigation,
                              size: 10.sp,
                              color: AppColors.blueColor,
                            ),
                            SizedBox(width: 1.w),
                            Flexible(
                              child: Text(
                                'Lat: ${location.latitude.toStringAsFixed(6)}',
                                style: TextStyles.regularwhite.copyWith(
                                  fontSize: 9.sp,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.3.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.navigation,
                              size: 10.sp,
                              color: AppColors.blueColor,
                            ),
                            SizedBox(width: 1.w),
                            Flexible(
                              child: Text(
                                'Lng: ${location.longitude.toStringAsFixed(6)}',
                                style: TextStyles.regularwhite.copyWith(
                                  fontSize: 9.sp,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Text(
                      'Configure Google Maps API key\nto view interactive map',
                      textAlign: TextAlign.center,
                      style: TextStyles.regularwhite.copyWith(
                        fontSize: 8.sp,
                        color: Colors.white60,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  */

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final controller = Get.put(EventController());
  final PublicProfileController hostProfileController =
      Get.put(PublicProfileController());
  final authViewModel = Get.put(AuthViewModel());
  final PaymentQrService _qrService = PaymentQrService();
  List<dynamic> _qrCodes = [];
  bool _isLoadingQrCodes = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEventDetailById(widget.eventId, onLoaded: (detail) {
        hostProfileController.loadPublicProfile(detail.userId);
        // Load QR codes only if user is logged in and is the creator
        if (authViewModel.isLoggedIn.value) {
          final currentUserId = authViewModel.currentUser['userId'];
          if (currentUserId == detail.userId) {
            _loadQrCodes();
          }
        }
      });
    });
  }

  Future<void> _loadQrCodes() async {
    setState(() {
      _isLoadingQrCodes = true;
    });

    try {
      final response = await _qrService
          .getEventQrCodes(int.parse(widget.eventId.toString()));
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          _qrCodes = responseData['data'] ?? [];
          _isLoadingQrCodes = false;
        });
      } else {
        setState(() {
          _isLoadingQrCodes = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingQrCodes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        final event = controller.eventDetail.value;
        if (event == null) {
          return _buildErrorState();
        }

        // Load host profile after event loads (defer to avoid build-time state changes)
        if ((hostProfileController.profile.value == null ||
                hostProfileController.profile.value!.userId != event.userId) &&
            !hostProfileController.isLoading.value) {
          Future.microtask(() {
            hostProfileController.loadPublicProfile(event.userId);
          });
        }

        final hostProfile = hostProfileController.profile.value;
        final eventStartDate = DateTime.tryParse(event.startDate ?? '');
        final eventEndDate = DateTime.tryParse(event.endDate ?? '');
        final hasEventStarted =
            eventStartDate != null && DateTime.now().isAfter(eventStartDate);
        final hasEventEnded =
            eventEndDate != null && DateTime.now().isAfter(eventEndDate);
        final currentUserId = authViewModel.isLoggedIn.value
            ? authViewModel.currentUser['userId']
            : null;
        final isCreator =
            currentUserId != null && currentUserId == event.userId;
        final isBooked = event.isBooked ?? false;

        return CustomScrollView(
          slivers: [
            // Hero Image with App Bar
            _buildHeroImage(event, hostProfile, isCreator),

            // Event Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title and Category
                    _buildEventHeader(event),
                    SizedBox(height: 3.h),

                    // Host Information
                    if (hostProfile != null) _buildHostSection(hostProfile),
                    SizedBox(height: 3.h),

                    // Event Details Cards
                    _buildEventDetailsCards(
                        event, hasEventStarted, hasEventEnded),
                    SizedBox(height: 3.h),

                    // About Section
                    _buildAboutSection(event),
                    SizedBox(height: 3.h),

                    // QR Codes Section (for organizers)
                    if (isCreator && _qrCodes.isNotEmpty)
                      _buildQrCodesSection(),
                    if (isCreator && _qrCodes.isNotEmpty) SizedBox(height: 3.h),

                    // Live Stream Section
                    if (event.liveStreamUrl != null)
                      _buildLiveStreamSection(event),
                    if (event.liveStreamUrl != null) SizedBox(height: 3.h),

                    // Location Map (if coordinates available) - COMMENTED OUT
                    // if (event.latitude != null && event.longitude != null)
                    //   _buildLocationSection(event),
                    // if (event.latitude != null && event.longitude != null)
                    //   SizedBox(height: 3.h),

                    // Event Status and Actions
                    _buildEventStatusSection(event, isCreator, isBooked,
                        hasEventStarted, hasEventEnded),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueColor),
            strokeWidth: 3,
          ),
          SizedBox(height: 3.h),
          Text(
            'Loading event details...',
            style: TextStyles.regularwhite.copyWith(
              fontSize: 12.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

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
            'Event Not Found',
            style: TextStyles.homeheadingtext.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'The event you\'re looking for doesn\'t exist or has been removed.',
            style: TextStyles.regularwhite.copyWith(
              fontSize: 11.sp,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: () => NavigationUtils.pop(context),
            icon: Icon(Icons.arrow_back, size: 14.sp),
            label: Text('Go Back', style: TextStyle(fontSize: 12.sp)),
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

  Widget _buildHeroImage(
      EventDetailModel event, dynamic hostProfile, bool isCreator) {
    return SliverAppBar(
      expandedHeight: 40.h,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(1.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(1.h),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 16.sp),
          onPressed: () {
            HapticUtils.navigation();
            NavigationUtils.pop(context);
          },
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(1.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1.h),
          ),
          child: IconButton(
            icon: Icon(Icons.share, color: Colors.white, size: 16.sp),
            onPressed: () {
              HapticUtils.light();
              ShareUtils.shareEvent(
                eventTitle: event.eventTitle ?? 'Event',
                eventDescription: event.description ?? '',
                eventDate: event.startDate ?? '',
                eventTime: event.startTime ?? '',
                eventLocation: '${event.address} ${event.city}',
                eventImageUrl: 'https://eventgo-live.com/${event.eventImage}',
                eventUrl: 'https://eventgo-live.com/event/${event.eventId}',
                organizerName: hostProfile?.name,
              );
            },
          ),
        ),
        if (isCreator)
          Container(
            margin: EdgeInsets.all(1.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1.h),
            ),
            child: IconButton(
              icon: Icon(Icons.person_add, color: Colors.white, size: 16.sp),
              onPressed: () {
                HapticUtils.light();
                NavigationUtils.push(
                  context,
                  InviteUserList(eventId: event.eventId!),
                  routeName: '/invite-users',
                );
              },
            ),
          ),
        SizedBox(width: 2.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: 'https://eventgo-live.com/${event.eventImage}',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade800, Colors.grey.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.blueColor),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade800, Colors.grey.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey.shade400,
                  size: 32.sp,
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Category and Price badges
            Positioned(
              bottom: 2.h,
              left: 4.w,
              right: 4.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppColors.blueColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(2.h),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      event.category?.toUpperCase() ?? 'EVENT',
                      style: TextStyles.regularwhite.copyWith(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (event.eventPrice != null && event.eventPrice != '0.00')
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2.h),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '\$${event.eventPrice}',
                        style: TextStyles.regularwhite.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader(EventDetailModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          capitalize(event.eventTitle ?? ''),
          style: TextStyles.homeheadingtext.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 12.sp,
              color: AppColors.blueColor,
            ),
            SizedBox(width: 2.w),
            Text(
              '${formatDate(event.startDate)} • ${formatTime(event.startTime)}',
              style: TextStyles.regularwhite.copyWith(
                fontSize: 11.sp,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHostSection(dynamic hostProfile) {
    return GestureDetector(
      onTap: () {
        HapticUtils.light();
        final currentUserId = authViewModel.currentUser['userId'];
        if (hostProfile.userId == currentUserId) {
          Get.offAll(() => const BottomNavBar(initialIndex: 4));
        } else {
          NavigationUtils.push(
            context,
            PublicProfileScreen(id: hostProfile.userId),
            routeName: '/public-profile',
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppColors.signinoptioncolor,
          borderRadius: BorderRadius.circular(2.h),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.blueColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blueColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  'https://eventgo-live.com/${hostProfile.profileImageUrl}',
                ),
                backgroundColor: Colors.grey,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hosted by',
                    style: TextStyles.regularwhite.copyWith(
                      fontSize: 9.sp,
                      color: Colors.white60,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    hostProfile.name ?? 'Host Name',
                    style: TextStyles.regularhometext1.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Tap to view profile',
                    style: TextStyles.regularwhite.copyWith(
                      color: AppColors.blueColor,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
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
    );
  }

  Widget _buildEventDetailsCards(
      EventDetailModel event, bool hasEventStarted, bool hasEventEnded) {
    return Column(
      children: [
        // Date & Time Card
        _buildDetailCard(
          icon: Icons.calendar_today,
          title: 'Date & Time',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDate(event.startDate),
                style: TextStyles.regularhometext1.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                '${formatTime(event.startTime)} - ${formatTime(event.endTime)}',
                style: TextStyles.regularwhite.copyWith(
                  fontSize: 11.sp,
                  color: Colors.white70,
                ),
              ),
              if (event.endDate != null &&
                  event.endDate != event.startDate) ...[
                SizedBox(height: 0.5.h),
                Text(
                  'Ends: ${formatDate(event.endDate)}',
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 10.sp,
                    color: Colors.white60,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 2.h),

        // Location Card
        _buildDetailCard(
          icon: Icons.location_on,
          title: 'Location',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.address ?? 'Address not provided',
                style: TextStyles.regularhometext1.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                event.city ?? 'City not provided',
                style: TextStyles.regularwhite.copyWith(
                  fontSize: 11.sp,
                  color: Colors.white70,
                ),
              ),
              if (event.latitude != null && event.longitude != null) ...[
                SizedBox(height: 1.h),
                InkWell(
                  borderRadius: BorderRadius.circular(1.h),
                  onTap: () async {
                    final latStr = event.latitude;
                    final lonStr = event.longitude;
                    if (latStr == null || lonStr == null) return;

                    final lat = double.tryParse(latStr);
                    final lon = double.tryParse(lonStr);
                    if (lat == null || lon == null) {
                      Get.snackbar(
                        'Location not available',
                        'This event does not have a valid location.',
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    final url = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving',
                    );

                    try {
                      if (!await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      )) {
                        Get.snackbar(
                          'Maps not available',
                          'Could not open Google Maps on this device.',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      }
                    } catch (_) {
                      Get.snackbar(
                        'Maps not available',
                        'Could not open Google Maps on this device.',
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppColors.blueColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(1.h),
                      border: Border.all(
                        color: AppColors.blueColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map,
                          size: 10.sp,
                          color: AppColors.blueColor,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'View on Map',
                          style: TextStyles.regularwhite.copyWith(
                            fontSize: 9.sp,
                            color: AppColors.blueColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 2.h),

        // Price Card
        _buildDetailCard(
          icon: Icons.local_activity,
          title: 'Pricing',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.eventPrice != null && event.eventPrice != '0.00')
                Text(
                  '\$${event.eventPrice}',
                  style: TextStyles.regularhometext1.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                )
              else
                Text(
                  'Free Event',
                  style: TextStyles.regularhometext1.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              SizedBox(height: 0.5.h),
              Text(
                'Per person',
                style: TextStyles.regularwhite.copyWith(
                  fontSize: 11.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(1.h),
            ),
            child: Icon(
              icon,
              color: AppColors.blueColor,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 9.sp,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 1.h),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(EventDetailModel event) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.blueColor,
                size: 16.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'About This Event',
                style: TextStyles.regularhometext1.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            event.description ?? 'No description available.',
            style: TextStyles.regularwhite.copyWith(
              fontSize: 11.sp,
              height: 1.6,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  /// Safe Google Map widget with error handling - COMMENTED OUT
  /*
  Widget _SafeGoogleMapWidget({
    required LatLng location,
    required EventDetailModel event,
  }) {
    return _SafeMapStatefulWidget(location: location, event: event);
  }
  */

  // COMMENTED OUT - Map functionality disabled
  /*
  Widget _buildLocationSection(EventDetailModel event) {
    final lat = double.tryParse(event.latitude ?? '');
    final lng = double.tryParse(event.longitude ?? '');

    if (lat == null || lng == null) {
      return const SizedBox.shrink();
    }

    final eventLocation = LatLng(lat, lng);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.map_outlined,
                color: AppColors.blueColor,
                size: 16.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Location Details',
                style: TextStyles.regularhometext1.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            height: 20.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.h),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1.h),
              child: _SafeGoogleMapWidget(
                location: eventLocation,
                event: event,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          if (event.address != null || event.city != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12.sp,
                    color: AppColors.blueColor,
                  ),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      '${event.address ?? ''}${event.address != null && event.city != null ? ', ' : ''}${event.city ?? ''}',
                      style: TextStyles.regularwhite.copyWith(
                        fontSize: 10.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  */

  /// Fallback UI when Google Maps fails to load - COMMENTED OUT
  /*
  Widget _buildMapFallback(LatLng location, EventDetailModel event) {
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 24.sp,
              color: AppColors.blueColor,
            ),
            SizedBox(height: 1.h),
            Text(
              'Map unavailable',
              style: TextStyles.regularwhite.copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Coordinates: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
              style: TextStyles.regularwhite.copyWith(
                fontSize: 9.sp,
                color: Colors.white60,
              ),
            ),
            SizedBox(height: 1.h),
            GestureDetector(
              onTap: () {
                // Open in external maps app
                final url = 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
                // You can use url_launcher here if available
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(1.h),
                  border: Border.all(
                    color: AppColors.blueColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Open in Maps',
                  style: TextStyles.regularwhite.copyWith(
                    fontSize: 9.sp,
                    color: AppColors.blueColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  */

  Widget _buildEventStatusSection(EventDetailModel event, bool isCreator,
      bool isBooked, bool hasEventStarted, bool hasEventEnded) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.signinoptioncolor,
            AppColors.signinoptioncolor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(3.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.blueColor.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Status Header with Gradient
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.blueColor.withValues(alpha: 0.1),
                  AppColors.blueColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3.h),
                topRight: Radius.circular(3.h),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(1.5.w),
                      decoration: BoxDecoration(
                        color: hasEventEnded
                            ? Colors.red.withValues(alpha: 0.2)
                            : hasEventStarted
                                ? Colors.orange.withValues(alpha: 0.2)
                                : Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(1.h),
                        border: Border.all(
                          color: hasEventEnded
                              ? Colors.red.withValues(alpha: 0.4)
                              : hasEventStarted
                                  ? Colors.orange.withValues(alpha: 0.4)
                                  : Colors.green.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        hasEventEnded
                            ? Icons.event_busy
                            : hasEventStarted
                                ? Icons.play_arrow
                                : Icons.schedule,
                        size: 14.sp,
                        color: hasEventEnded
                            ? Colors.red
                            : hasEventStarted
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Status',
                          style: TextStyles.regularwhite.copyWith(
                            fontSize: 9.sp,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          hasEventEnded
                              ? 'Event Ended'
                              : hasEventStarted
                                  ? 'Event Started'
                                  : 'Upcoming Event',
                          style: TextStyles.regularhometext1.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: hasEventEnded
                                ? Colors.red
                                : hasEventStarted
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isBooked)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withValues(alpha: 0.2),
                          Colors.green.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2.h),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12.sp,
                          color: Colors.green,
                        ),
                        SizedBox(width: 1.5.w),
                        Text(
                          'Booked',
                          style: TextStyles.regularwhite.copyWith(
                            fontSize: 10.sp,
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

          // Action Button Section
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Primary Action Button
                Container(
                  width: double.infinity,
                  height: 5.h,
                  decoration: BoxDecoration(
                    gradient: hasEventEnded
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade600,
                              Colors.grey.shade700
                            ],
                          )
                        : hasEventStarted
                            ? LinearGradient(
                                colors: [
                                  Colors.orange.shade600,
                                  Colors.orange.shade700
                                ],
                              )
                            : isBooked
                                ? LinearGradient(
                                    colors: [
                                      Colors.green.shade600,
                                      Colors.green.shade700
                                    ],
                                  )
                                : isCreator
                                    ? LinearGradient(
                                        colors: [
                                          Colors.purple.shade600,
                                          Colors.purple.shade700
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          AppColors.blueColor,
                                          AppColors.blueColor
                                              .withValues(alpha: 0.8)
                                        ],
                                      ),
                    borderRadius: BorderRadius.circular(2.h),
                    boxShadow: [
                      BoxShadow(
                        color: (hasEventEnded
                                ? Colors.grey
                                : hasEventStarted
                                    ? Colors.orange
                                    : isBooked
                                        ? Colors.green
                                        : isCreator
                                            ? Colors.purple
                                            : AppColors.blueColor)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: (hasEventStarted ||
                              isBooked ||
                              hasEventEnded ||
                              isCreator)
                          ? null
                          : () {
                              HapticUtils.buttonPress();
                              if (!authViewModel.isLoggedIn.value) {
                                Get.snackbar(
                                  'Sign in to get tickets',
                                  'Create an account to purchase tickets.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: AppColors.signinoptioncolor,
                                  colorText: Colors.white,
                                  mainButton: TextButton(
                                    onPressed: () =>
                                        Get.toNamed(RouteName.loginScreen),
                                    child: Text(
                                      'Sign in',
                                      style: TextStyle(
                                        color: AppColors.blueColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                                return;
                              }
                              NavigationUtils.push(
                                context,
                                BookEventScreen(id: event.eventId),
                                routeName: '/book-event',
                              );
                            },
                      borderRadius: BorderRadius.circular(2.h),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.h),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(1.h),
                              ),
                              child: Icon(
                                hasEventEnded
                                    ? Icons.event_busy
                                    : hasEventStarted
                                        ? Icons.play_arrow
                                        : isBooked
                                            ? Icons.check_circle
                                            : isCreator
                                                ? Icons.person
                                                : Icons.shopping_cart,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              hasEventEnded
                                  ? 'Event Ended'
                                  : hasEventStarted
                                      ? 'Event Started'
                                      : isBooked
                                          ? 'Already Booked'
                                          : isCreator
                                              ? 'Your Event'
                                              : 'Get Tickets',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Promotion Status or Promote Button (for organizers)
                if (isCreator && !hasEventEnded) ...[
                  SizedBox(height: 2.h),
                  // Check if promotion is active
                  Builder(
                    builder: (context) {
                      if (event.isPromotionActive) {
                        // Show promotion active message
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2.h),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 20.sp,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Event is Currently Promoted',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      'You can promote again after this promotion expires.',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Show promote button
                        return Container(
                          width: double.infinity,
                          height: 5.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade600,
                                Colors.orange.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2.h),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticUtils.buttonPress();
                                // Open boost screen (now uses single boost option: $35 for 10 days)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PromoteEventScreen(
                                      eventId: event.eventId!,
                                      eventTitle: event.eventTitle ?? 'Event',
                                    ),
                                  ),
                                ).then((_) {
                                  // Refresh event details after boost
                                  controller
                                      .fetchEventDetailById(widget.eventId);
                                });
                              },
                              borderRadius: BorderRadius.circular(2.h),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2.h),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(1.w),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        borderRadius:
                                            BorderRadius.circular(1.h),
                                      ),
                                      child: Icon(
                                        Icons.trending_up,
                                        size: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      'Boost Event',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  // Generate Payment QR Button (for organizers)
                  SizedBox(height: 2.h),
                  Container(
                    width: double.infinity,
                    height: 5.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.blueColor,
                          AppColors.lightColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2.h),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blueColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticUtils.buttonPress();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GeneratePaymentQrScreen(
                                eventId: event.eventId!,
                              ),
                            ),
                          ).then((_) {
                            // Reload QR codes after generating
                            _loadQrCodes();
                          });
                        },
                        borderRadius: BorderRadius.circular(2.h),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.h),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(1.h),
                                ),
                                child: Icon(
                                  Icons.qr_code_scanner,
                                  size: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Generate Payment QR',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Check In Tickets Button (for organizers)
                  SizedBox(height: 2.h),
                  Container(
                    width: double.infinity,
                    height: 5.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade600,
                          Colors.green.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2.h),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticUtils.buttonPress();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TicketCheckInScanner(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(2.h),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.h),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(1.h),
                                ),
                                child: Icon(
                                  Icons.qr_code_scanner,
                                  size: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Check In Tickets',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String? date) {
    try {
      final parsedDate = DateTime.parse(date!);
      return DateFormat('EEEE, MMMM d, y').format(parsedDate);
    } catch (e) {
      return date ?? '';
    }
  }

  String formatTime(String? time) {
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time!);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return time ?? '';
    }
  }

  Widget _buildQrCodesSection() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: AppColors.blueColor,
                size: 18.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Payment QR Codes',
                style: TextStyles.homeheadingtext.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (_isLoadingQrCodes)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.h,
                childAspectRatio: 0.8,
              ),
              itemCount: _qrCodes.length,
              itemBuilder: (context, index) {
                final qr = _qrCodes[index];
                return _buildQrCodeItem(qr);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQrCodeItem(Map<String, dynamic> qr) {
    final qrCodeData = qr['qrCodeData'];
    Map<String, dynamic> qrDataMap;

    try {
      qrDataMap = json.decode(qrCodeData);
    } catch (e) {
      qrDataMap = {'web': qrCodeData, 'app': qrCodeData};
    }

    // Use web URL for QR code (works with all scanners, including iPhone)
    final qrString = qrDataMap['web'] ?? (qrDataMap['app'] ?? qrCodeData);
    final ticketType = qr['ticketType'] ?? 'general';
    final currentUses = qr['currentUses'] ?? 0;
    final maxUses = qr['maxUses'];
    final isLimitReached = maxUses != null && currentUses >= maxUses;

    Color badgeColor;
    Color textColor;

    switch (ticketType.toLowerCase()) {
      case 'vip':
        badgeColor = const Color(0xFFFFD700);
        textColor = Colors.black87;
        break;
      default:
        badgeColor = const Color(0xFF6C757D);
        textColor = Colors.white;
    }

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1.5.h),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(1.h),
                ),
                child: Text(
                  ticketType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              if (isLimitReached) ...[
                SizedBox(width: 1.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(1.h),
                  ),
                  child: Text(
                    'LIMIT',
                    style: TextStyle(
                      fontSize: 6.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 1.h),
          QrImageView(
            data: qrString,
            version: QrVersions.auto,
            size: 20.w,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStreamSection(EventDetailModel event) {
    final hasAccess = event.hasLiveStreamAccess ?? false;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.video_library,
                color: AppColors.blueColor,
                size: 16.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Live Stream',
                style: TextStyles.regularhometext1.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (hasAccess && event.liveStreamEmbedUrl != null) ...[
            // Show live stream player
            LiveStreamWidget(
              embedUrl: event.liveStreamEmbedUrl!,
              platform: _getPlatformFromUrl(event.liveStreamUrl!),
            ),
          ] else ...[
            // Show access denied message
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Live Stream is available for ticket holders only.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        HapticUtils.buttonPress();
                        if (!authViewModel.isLoggedIn.value) {
                          Get.snackbar(
                            'Sign in to get tickets',
                            'Create an account to purchase tickets.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.signinoptioncolor,
                            colorText: Colors.white,
                            mainButton: TextButton(
                              onPressed: () =>
                                  Get.toNamed(RouteName.loginScreen),
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  color: AppColors.blueColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                          return;
                        }
                        NavigationUtils.push(
                          context,
                          BookEventScreen(id: event.eventId),
                          routeName: '/book-event',
                        );
                      },
                      child: Text('Get Tickets'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getPlatformFromUrl(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return 'youtube';
    } else if (url.contains('facebook.com')) {
      return 'facebook';
    }
    return 'unknown';
  }

  String capitalize(String text) =>
      text.isNotEmpty ? '${text[0].toUpperCase()}${text.substring(1)}' : text;
}
