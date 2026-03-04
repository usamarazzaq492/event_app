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
import 'package:shimmer/shimmer.dart';
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
import 'package:event_app/Services/moderation_service.dart';
import 'dart:ui';

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
  bool _isDescriptionExpanded = false;

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

  Future<void> _showReportEventSheet(int eventId) async {
    final reason = await Get.dialog<String>(
      _ReportEventReasonDialog(),
    );
    if (reason == null) return;
    try {
      final res = await ModerationService.reportEvent(eventId,
          reason: reason.isEmpty ? null : reason);
      if (res['statusCode'] == 201 || res['statusCode'] == 200) {
        Get.snackbar('Reported', res['message'] ?? 'Report submitted.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.signinoptioncolor,
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', res['message'] ?? 'Could not submit report.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
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
          physics: const BouncingScrollPhysics(),
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
                    SizedBox(height: 2.h),

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
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 40.h,
            backgroundColor: Colors.grey[900],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: Colors.grey[900]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(1.h),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Container(
                    width: 40.w,
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(1.h),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  ...List.generate(
                      3,
                      (index) => Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Container(
                              width: double.infinity,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(2.h),
                              ),
                            ),
                          )),
                ],
              ),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(1.2.h),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 14.sp),
                onPressed: () {
                  HapticUtils.navigation();
                  NavigationUtils.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
      actions: [
        ClipRRect(
          borderRadius: BorderRadius.circular(1.2.h),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: EdgeInsets.all(1.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(1.2.h),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded,
                    color: Colors.white, size: 16.sp),
                color: AppColors.signinoptioncolor,
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.h)),
                onSelected: (value) async {
                  HapticUtils.light();
                  if (value == 'share') {
                    ShareUtils.shareEvent(
                      eventTitle: event.eventTitle ?? 'Event',
                      eventDescription: event.description ?? '',
                      eventDate: event.startDate ?? '',
                      eventTime: event.startTime ?? '',
                      eventLocation: '${event.address} ${event.city}',
                      eventImageUrl:
                          'https://eventgo-live.com/${event.eventImage}',
                      eventUrl:
                          'https://eventgo-live.com/event/${event.eventId}',
                      organizerName: hostProfile?.name,
                    );
                  } else if (value == 'report') {
                    if (!authViewModel.isLoggedIn.value) {
                      Get.snackbar(
                          'Sign in required', 'Please sign in to report.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.blueColor,
                          colorText: Colors.white,
                          mainButton: TextButton(
                              onPressed: () {
                                Get.closeCurrentSnackbar();
                                Get.toNamed(RouteName.loginScreen);
                              },
                              child: const Text('Sign in',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))));
                      return;
                    }
                    await _showReportEventSheet(event.eventId!);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: 'share',
                      child: Row(children: [
                        Icon(Icons.share_rounded,
                            color: Colors.white, size: 16.sp),
                        const SizedBox(width: 8),
                        Text('Share',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11.sp))
                      ])),
                  PopupMenuItem(
                      value: 'report',
                      child: Row(children: [
                        Icon(Icons.flag_rounded,
                            color: Colors.orange, size: 16.sp),
                        const SizedBox(width: 8),
                        Text('Report',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11.sp))
                      ])),
                ],
              ),
            ),
          ),
        ),
        if (isCreator)
          ClipRRect(
            borderRadius: BorderRadius.circular(1.2.h),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                margin: EdgeInsets.all(1.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1.2.h),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: IconButton(
                  icon: Icon(Icons.person_add_rounded,
                      color: Colors.white, size: 16.sp),
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
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (event.eventPrice != null &&
                          event.eventPrice != '0.00')
                        Container(
                          margin: EdgeInsets.only(bottom: 1.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(2.h),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'REGULAR: ',
                                style: TextStyles.regularwhite.copyWith(
                                  fontSize: 10.sp,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${event.eventPrice}',
                                style: TextStyles.regularwhite.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (event.vipPrice != null && event.vipPrice != '0.00')
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade900.withValues(alpha: 0.9),
                                Colors.black.withValues(alpha: 0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(2.h),
                            border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.3),
                                width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'VIP: ',
                                style: TextStyles.regularwhite.copyWith(
                                  fontSize: 10.sp,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${event.vipPrice}',
                                style: TextStyles.regularwhite.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.5.h),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(2.5.h),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.blueColor, Colors.transparent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://eventgo-live.com/${hostProfile.profileImageUrl}',
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white.withValues(alpha: 0.05),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white24,
                          size: 25.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOSTED BY',
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.white38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        hostProfile.name ?? 'Host Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(1.2.h),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10.sp,
                    color: AppColors.blueColor,
                  ),
                ),
              ],
            ),
          ),
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
                    HapticUtils.light();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Regular Access',
                      style: TextStyles.regularwhite.copyWith(
                        fontSize: 11.sp,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '\$${event.eventPrice}',
                      style: TextStyles.regularhometext1.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              if (event.eventPrice != null &&
                  event.eventPrice != '0.00' &&
                  event.vipPrice != null &&
                  event.vipPrice != '0.00')
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.8.h),
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.05),
                    thickness: 1,
                  ),
                ),
              if (event.vipPrice != null && event.vipPrice != '0.00')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'VIP Access',
                          style: TextStyles.regularwhite.copyWith(
                            fontSize: 11.sp,
                            color: Colors.amber.shade200,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w, vertical: 0.2.h),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(0.5.h),
                            border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.5),
                                width: 0.5),
                          ),
                          child: Text(
                            'BEST VALUE',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${event.vipPrice}',
                      style: TextStyles.regularhometext1.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              if ((event.eventPrice == null || event.eventPrice == '0.00') &&
                  (event.vipPrice == null || event.vipPrice == '0.00'))
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(2.5.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(2.5.h),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppColors.blueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1.2.h),
                ),
                child: Icon(
                  icon,
                  color: AppColors.blueColor,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.white38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    content,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(EventDetailModel event) {
    final description = event.description ?? 'No description available.';
    final isLongDescription = description.length > 200;

    return ClipRRect(
      borderRadius: BorderRadius.circular(2.5.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(2.5.h),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.blueColor,
                    size: 16.sp,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'ABOUT THIS EVENT',
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.white38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                maxLines: _isDescriptionExpanded ? null : 4,
                overflow: _isDescriptionExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.sp,
                  height: 1.6,
                ),
              ),
              if (isLongDescription) ...[
                SizedBox(height: 1.h),
                InkWell(
                  onTap: () {
                    HapticUtils.light();
                    setState(() {
                      _isDescriptionExpanded = !_isDescriptionExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _isDescriptionExpanded ? 'Read Less' : 'Read More',
                        style: TextStyles.regularwhite.copyWith(
                          color: AppColors.blueColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        _isDescriptionExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.blueColor,
                        size: 14.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventStatusSection(EventDetailModel event, bool isCreator,
      bool isBooked, bool hasEventStarted, bool hasEventEnded) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(3.h),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Status Header
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
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
                            color: (hasEventEnded
                                    ? Colors.red
                                    : hasEventStarted
                                        ? Colors.orange
                                        : Colors.green)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(1.h),
                          ),
                          child: Icon(
                            hasEventEnded
                                ? Icons.event_busy_rounded
                                : hasEventStarted
                                    ? Icons.play_circle_rounded
                                    : Icons.schedule_rounded,
                            size: 16.sp,
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
                              'EVENT STATUS',
                              style: TextStyle(
                                fontSize: 8.sp,
                                color: Colors.white38,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 0.2.h),
                            Text(
                              hasEventEnded
                                  ? 'Event Ended'
                                  : hasEventStarted
                                      ? 'Event Started'
                                      : 'Upcoming Event',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                                color: hasEventEnded
                                    ? Colors.red
                                    : hasEventStarted
                                        ? Colors.orange
                                        : Colors.green,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isBooked)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.2.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.h),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 12.sp,
                              color: Colors.green,
                            ),
                            SizedBox(width: 1.5.w),
                            Text(
                              'BOOKED',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.green,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
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
                    // Primary Action Button (Get Tickets)
                    _buildActionButton(
                      title: hasEventEnded
                          ? 'EVENT ENDED'
                          : hasEventStarted
                              ? 'EVENT STARTED'
                              : isBooked
                                  ? 'ALREADY BOOKED'
                                  : isCreator
                                      ? 'YOUR EVENT'
                                      : 'GET TICKETS',
                      icon: hasEventEnded
                          ? Icons.event_busy_rounded
                          : hasEventStarted
                              ? Icons.play_circle_fill_rounded
                              : isBooked
                                  ? Icons.check_circle_rounded
                                  : isCreator
                                      ? Icons.person_rounded
                                      : Icons.shopping_bag_rounded,
                      color: hasEventEnded
                          ? Colors.grey
                          : hasEventStarted
                              ? Colors.orange
                              : isBooked
                                  ? Colors.green
                                  : isCreator
                                      ? Colors.purple
                                      : AppColors.blueColor,
                      isDisabled: hasEventStarted ||
                          isBooked ||
                          hasEventEnded ||
                          isCreator,
                      onTap: () {
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
                              child: const Text(
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
                    ),

                    if (isCreator && !hasEventEnded) ...[
                      SizedBox(height: 2.h),

                      // Boost Event
                      if (event.isPromotionActive)
                        _buildStatusIndicator(
                          title: 'PROMOTION ACTIVE',
                          subtitle: 'Boosting your reach',
                          icon: Icons.verified_rounded,
                          color: Colors.green,
                        )
                      else
                        _buildActionButton(
                          title: 'BOOST EVENT',
                          icon: Icons.bolt_rounded,
                          color: Colors.orange,
                          onTap: () {
                            HapticUtils.buttonPress();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PromoteEventScreen(
                                  eventId: event.eventId!,
                                  eventTitle: event.eventTitle ?? 'Event',
                                ),
                              ),
                            ).then((_) {
                              controller.fetchEventDetailById(widget.eventId);
                            });
                          },
                        ),

                      SizedBox(height: 2.h),

                      // Generate Payment QR
                      _buildActionButton(
                        title: 'GENERATE PAYMENT QR',
                        icon: Icons.qr_code_rounded,
                        color: AppColors.blueColor,
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
                            _loadQrCodes();
                          });
                        },
                      ),

                      SizedBox(height: 2.h),

                      // Check-in Tickets
                      _buildActionButton(
                        title: 'CHECK IN TICKETS',
                        icon: Icons.qr_code_scanner_rounded,
                        color: Colors.green,
                        onTap: () {
                          HapticUtils.buttonPress();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TicketCheckInScanner(),
                            ),
                          );
                        },
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

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return Container(
      width: double.infinity,
      height: 6.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDisabled
              ? [color.withValues(alpha: 0.5), color.withValues(alpha: 0.7)]
              : [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(2.h),
        boxShadow: [
          if (!isDisabled)
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(2.h),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.h),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16.sp, color: Colors.white),
                SizedBox(width: 3.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(2.h),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18.sp),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 0.2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(3.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(3.h),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.blueColor,
                    size: 16.sp,
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORGANIZER TOOLS',
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.white38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Payment QR Codes',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              if (_isLoadingQrCodes)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_qrCodes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No payment QR codes generated yet.',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 3.w,
                    mainAxisSpacing: 2.h,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _qrCodes.length,
                  itemBuilder: (context, index) {
                    final qr = _qrCodes[index];
                    return _buildQrCodeItem(qr);
                  },
                ),
            ],
          ),
        ),
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

    final qrString = qrDataMap['web'] ?? (qrDataMap['app'] ?? qrCodeData);
    final ticketType = qr['ticketType'] ?? 'general';
    final currentUses = qr['currentUses'] ?? 0;
    final maxUses = qr['maxUses'];
    final isLimitReached = maxUses != null && currentUses >= maxUses;

    Color badgeColor = ticketType.toLowerCase() == 'vip'
        ? const Color(0xFFFFD700)
        : AppColors.blueColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(2.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(2.h),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(0.8.h),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  ticketType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 7.sp,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              // QR Card
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.5.h),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrString,
                  version: QrVersions.auto,
                  size: 22.w,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                ),
              ),
              if (isLimitReached) ...[
                SizedBox(height: 1.h),
                Text(
                  'LIMIT REACHED',
                  style: TextStyle(
                    fontSize: 6.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStreamSection(EventDetailModel event) {
    final hasAccess = event.hasLiveStreamAccess ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(3.h),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(3.h),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.video_collection_rounded,
                    color: AppColors.blueColor,
                    size: 16.sp,
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EVENT CONTENT',
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.white38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Live Stream',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              if (hasAccess && event.liveStreamEmbedUrl != null) ...[
                // Show live stream player
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.h),
                  child: LiveStreamWidget(
                    embedUrl: event.liveStreamEmbedUrl!,
                    platform: _getPlatformFromUrl(event.liveStreamUrl!),
                  ),
                ),
              ] else ...[
                // Show access denied message
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(2.h),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_person_rounded,
                          size: 32.sp,
                          color: AppColors.blueColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Exclusive Content',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'This live stream is available for ticket holders only.',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white38,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 3.h),
                      _buildActionButton(
                        title: 'GET TICKETS',
                        icon: Icons.shopping_bag_rounded,
                        color: AppColors.blueColor,
                        onTap: () {
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
                                child: const Text(
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
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
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

class _ReportEventReasonDialog extends StatefulWidget {
  @override
  State<_ReportEventReasonDialog> createState() =>
      _ReportEventReasonDialogState();
}

class _ReportEventReasonDialogState extends State<_ReportEventReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.signinoptioncolor,
      title: const Text('Report Event', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Optionally describe the issue:',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Reason (optional)',
              hintStyle: const TextStyle(color: Colors.white38),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70))),
        TextButton(
            onPressed: () => Navigator.pop(context, _controller.text.trim()),
            child: const Text('Submit',
                style: TextStyle(color: AppColors.blueColor))),
      ],
    );
  }
}
