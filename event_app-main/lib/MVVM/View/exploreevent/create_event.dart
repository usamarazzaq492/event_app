import 'dart:io';
import 'dart:ui';

import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../Services/location_service.dart';
import 'package:flutter/services.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final _formKey = GlobalKey<FormState>();
  final eventController = Get.put(EventController());

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final vipPriceController = TextEditingController();
  final sdateController = TextEditingController();
  final edateController = TextEditingController();
  final liveStreamController = TextEditingController();

  String _startTime = 'Start Time';
  String _endTime = 'End Time';
  String? _startTimeError;
  String? _endTimeError;

  File? imageFile;
  double? _pickedLat;
  double? _pickedLon;
  bool _isGettingLocation = false;
  String? _bannerText;
  Color _bannerColor = Colors.transparent;

  String _normalizePrice(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return '0.00';
    final value = double.tryParse(text);
    if (value == null) return text;
    return value.toStringAsFixed(2);
  }

  void _showBanner(String message, {Color color = Colors.blue}) {
    setState(() {
      _bannerText = message;
      _bannerColor = color;
    });
  }

  Widget _buildBanner() {
    return Container(
      key: const ValueKey('banner'),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      margin: EdgeInsets.only(top: 1.h),
      decoration: BoxDecoration(
        color: _bannerColor.withValues(alpha: 0.15),
        border: Border.all(color: _bannerColor.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            _bannerColor == Colors.red
                ? Icons.error_outline
                : Icons.check_circle_outline,
            color: _bannerColor,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _bannerText ?? '',
              style: TextStyles.regularwhite,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 18),
            onPressed: () => setState(() => _bannerText = null),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            // Background Glow
            Positioned(
              top: -15.h,
              left: -20.w,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blueColor.withValues(alpha: 0.08),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _bannerText != null
                              ? _buildBanner()
                              : const SizedBox.shrink(),
                        ),
                        SizedBox(height: 2.h),

                        // Details Section
                        _buildSection(
                          title: 'EVENT DETAILS',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputField(
                                  'Title', titleController, 'Name of Event'),
                              _buildInputField('Description', descController,
                                  'Event Description',
                                  maxLines: 4),
                              _buildInputField(
                                  'Category', categoryController, 'Category'),
                              _buildInputField(
                                  'General Admission Price',
                                  priceController,
                                  'Price for General Admission',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true)),
                              _buildInputField('VIP Price', vipPriceController,
                                  'Price for VIP tickets',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true)),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 1.w, bottom: 2.h),
                                child: Text('Enter 0 for free events',
                                    style: TextStyle(
                                        color: Colors.white24,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600)),
                              ),
                              _buildInputField(
                                  'Live Stream URL (Optional)',
                                  liveStreamController,
                                  'https://youtube.com/... or https://facebook.com/...'),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 1.w, bottom: 1.h),
                                child: Text(
                                    'Only YouTube and Facebook URLs are supported',
                                    style: TextStyle(
                                        color: Colors.white24,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),

                        // Location Section
                        _buildSection(
                          title: 'LOCATION',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputField(
                                  'City', cityController, 'Name of City'),
                              _buildInputField('Address', addressController,
                                  'Event Address'),
                              _buildUseCurrentLocationRow(),
                            ],
                          ),
                        ),

                        // Schedule Section
                        _buildSection(
                          title: 'SCHEDULE',
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: _buildDateField(
                                          'Start Date',
                                          sdateController,
                                          () => _selectDate(sdateController))),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                      child: _buildDateField(
                                          'End Date',
                                          edateController,
                                          () => _selectDate(edateController))),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Expanded(
                                      child: _buildTimeField(
                                          'Start Time',
                                          _startTime,
                                          () => _selectTime(isStart: true),
                                          _startTimeError)),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                      child: _buildTimeField(
                                          'End Time',
                                          _endTime,
                                          () => _selectTime(isStart: false),
                                          _endTimeError)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Media Section
                        _buildSection(
                          title: 'COVER IMAGE',
                          child: _buildImagePicker(),
                        ),

                        SizedBox(height: 3.h),
                        Obx(() {
                          final isBusy = eventController.isLoading.value;
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2.h),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blueColor
                                      .withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ButtonWidget(
                              text: isBusy ? 'CREATING...' : 'CREATE EVENT',
                              onPressed: isBusy
                                  ? null
                                  : () {
                                      HapticFeedback.lightImpact();
                                      _createEvent();
                                    },
                              borderRadius: 2.h,
                              textColor: AppColors.whiteColor,
                              backgroundColor: AppColors.blueColor,
                            ),
                          );
                        }),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Clear picked coordinates when user edits address/city manually
    addressController.addListener(_invalidatePickedCoordinatesOnManualEdit);
    cityController.addListener(_invalidatePickedCoordinatesOnManualEdit);
  }

  void _invalidatePickedCoordinatesOnManualEdit() {
    if (_pickedLat != null || _pickedLon != null) {
      setState(() {
        _pickedLat = null;
        _pickedLon = null;
      });
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(2.5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(2.5.h),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blueColor,
                      AppColors.blueColor.withValues(alpha: 0.5)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white38,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          child,
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(1.5.h),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(1.5.h),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16.sp),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),
          Text(
            'CREATE EVENT',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 48), // Spacer to center title
        ],
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, String hint,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 7.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white38,
              letterSpacing: 1.0,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          cursorColor: AppColors.blueColor,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            hintStyle: TextStyle(color: Colors.white12, fontSize: 10.sp),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.h),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.h),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.h),
              borderSide:
                  const BorderSide(color: AppColors.blueColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.h),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            errorStyle: TextStyle(fontSize: 8.sp, color: Colors.redAccent),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              if (label.contains('Optional')) return null;
              return '$label is required';
            }
            if (label.contains('Price')) {
              final v = double.tryParse(value);
              if (v == null || v < 0) return 'Invalid price';
            }
            if (label.contains('Live Stream URL') && value.isNotEmpty) {
              if (!_isValidLiveStreamUrl(value)) return 'Use YT or FB URLs';
            }
            return null;
          },
        ),
        SizedBox(height: 2.5.h),
      ],
    );
  }

  Widget _buildUseCurrentLocationRow() {
    return InkWell(
      onTap: _isGettingLocation ? null : _useCurrentLocation,
      borderRadius: BorderRadius.circular(1.5.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: AppColors.blueColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(1.5.h),
          border: Border.all(
            color: AppColors.blueColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isGettingLocation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.blueColor)),
                  )
                : Icon(Icons.my_location_rounded,
                    color: AppColors.blueColor, size: 16.sp),
            SizedBox(width: 3.w),
            Text(
              _isGettingLocation
                  ? 'GETTING POSITION...'
                  : 'USE CURRENT LOCATION',
              style: TextStyle(
                color: AppColors.blueColor,
                fontWeight: FontWeight.w900,
                fontSize: 9.sp,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    try {
      setState(() => _isGettingLocation = true);
      final Position? pos = await LocationService.getCurrentLocation();
      if (pos == null) {
        setState(() => _isGettingLocation = false);
        Get.snackbar('Location error', 'Could not get your current location',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      _pickedLat = pos.latitude;
      _pickedLon = pos.longitude;
      _showBanner(
        'Location set: Lat ${_pickedLat!.toStringAsFixed(6)}, Lon ${_pickedLon!.toStringAsFixed(6)}',
        color: AppColors.blueColor,
      );

      // Reverse-geocode to fill city and address best-effort
      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          cityController.text = p.locality ?? cityController.text;
          final lineParts = [
            p.street,
            p.subLocality,
            p.administrativeArea,
            p.country
          ].whereType<String>().where((e) => e.isNotEmpty).toList();
          if (lineParts.isNotEmpty) {
            addressController.text = lineParts.join(', ');
          }
        }
      } catch (_) {}

      setState(() => _isGettingLocation = false);
    } catch (e) {
      setState(() => _isGettingLocation = false);
      Get.snackbar('Location error', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Widget _buildDateField(
      String hint, TextEditingController controller, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
          child: Text(
            hint.toUpperCase(),
            style: TextStyle(
              fontSize: 7.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white38,
              letterSpacing: 1.0,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          enableInteractiveSelection: false,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Select Date',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            suffixIcon: Icon(Icons.calendar_month_rounded,
                color: Colors.white24, size: 16.sp),
            hintStyle: TextStyle(color: Colors.white12, fontSize: 10.sp),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.h),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.h),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.h),
              borderSide:
                  const BorderSide(color: AppColors.blueColor, width: 1.5),
            ),
          ),
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildTimeField(
      String label, String value, VoidCallback onTap, String? errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 7.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white38,
              letterSpacing: 1.0,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(1.5.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(1.5.h),
              border: Border.all(
                color: errorText != null
                    ? Colors.redAccent
                    : Colors.white.withValues(alpha: 0.05),
                width: errorText != null ? 1 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value == label ? 'Select $label' : value,
                  style: TextStyle(
                    color: value == label ? Colors.white12 : Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.access_time_rounded,
                    color: Colors.white24, size: 16.sp),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 0.8.h, left: 1.w),
            child: Text(errorText,
                style: TextStyle(color: Colors.redAccent, fontSize: 8.sp)),
          ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _selectFile,
          borderRadius: BorderRadius.circular(2.h),
          child: Container(
            height: 22.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(2.h),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.03),
                        ),
                        child: Icon(Icons.add_photo_alternate_rounded,
                            color: Colors.white24, size: 30.sp),
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        'Tap to upload cover image',
                        style: TextStyle(
                          color: Colors.white12,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2.h),
                        child: Image.file(
                          imageFile!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 1.5.h,
                        right: 1.5.h,
                        child: GestureDetector(
                          onTap: () => setState(() => imageFile = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> _selectTime({required bool isStart}) async {
    final pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null) {
      final formattedTime = DateFormat('HH:mm')
          .format(DateTime(0, 0, 0, pickedTime.hour, pickedTime.minute));
      setState(() {
        if (isStart) {
          _startTime = formattedTime;
          _startTimeError = null;
        } else {
          _endTime = formattedTime;
          _endTimeError = null;
        }
      });
    }
  }

  Future<void> _selectFile() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        imageFile = File(file.path);
      });
    }
  }

  void _createEvent() async {
    setState(() {
      _startTimeError =
          _startTime == 'Start Time' ? 'Start time is required' : null;
      _endTimeError = _endTime == 'End Time' ? 'End time is required' : null;
    });

    if (_formKey.currentState!.validate() &&
        _startTimeError == null &&
        _endTimeError == null &&
        imageFile != null) {
      // Normalize prices so backend always receives 2 decimal places
      final normalizedPrice = _normalizePrice(priceController.text);
      priceController.text = normalizedPrice;
      final normalizedVipPrice = _normalizePrice(vipPriceController.text);
      vipPriceController.text = normalizedVipPrice;
      _showBanner('Submitting your event…', color: AppColors.blueColor);
      // Prefer picked coords; else geocode Address+City
      double lat;
      double lon;
      if (_pickedLat != null && _pickedLon != null) {
        lat = _pickedLat!;
        lon = _pickedLon!;
      } else {
        final fullAddress = '${addressController.text}, ${cityController.text}';
        try {
          final locations = await locationFromAddress(fullAddress);
          if (locations.isEmpty) {
            _showBanner('Could not resolve address to coordinates',
                color: Colors.red);
            Get.snackbar('Location not found',
                'Could not resolve address to coordinates',
                backgroundColor: Colors.red, colorText: Colors.white);
            return;
          }
          lat = locations.first.latitude;
          lon = locations.first.longitude;
        } catch (e) {
          _showBanner('Failed to geocode address', color: Colors.red);
          Get.snackbar('Location error', 'Failed to geocode address',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
      }

      await eventController.createEvent(
        eventTitle: titleController.text,
        startDate: sdateController.text,
        endDate: edateController.text,
        startTime: _startTime,
        endTime: _endTime,
        eventPrice: normalizedPrice,
        vipPrice: normalizedVipPrice,
        eventDescription: descController.text,
        eventCategory: categoryController.text,
        eventAddress: addressController.text,
        eventCity: cityController.text,
        eventLatitude: lat.toStringAsFixed(6),
        eventLongitude: lon.toStringAsFixed(6),
        eventImage: imageFile!,
        liveStreamUrl: liveStreamController.text.isNotEmpty
            ? liveStreamController.text
            : null,
      );
      _showBanner('Event created successfully', color: AppColors.blueColor);
    } else if (imageFile == null) {
      _showBanner('Please select an image', color: Colors.red);
      Get.snackbar('Error', 'Please select an image',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  bool _isValidLiveStreamUrl(String url) {
    final youtubePattern = RegExp(
        r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})');
    final facebookPattern = RegExp(r'facebook\.com');

    return youtubePattern.hasMatch(url) || facebookPattern.hasMatch(url);
  }
}
