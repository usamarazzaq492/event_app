import 'dart:io';

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
      onTap: () =>
          FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.only(top: 4.h, left: 5.w, right: 5.w, bottom: 3.h),
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
                  SizedBox(height: 2.5.h),

                  // Details Section
                  _buildSection(
                    title: 'Event Details',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                            'Title', titleController, 'Name of Event'),
                        _buildInputField(
                            'Description', descController, 'Event Description',
                            maxLines: 5),
                        _buildInputField(
                            'Category', categoryController, 'Category'),
                        _buildInputField(
                            'Price', priceController, 'Price of Event',
                            keyboardType: TextInputType.number),
                        Padding(
                          padding: EdgeInsets.only(left: 1.w, bottom: 0.5.h),
                          child: Text('Enter 0 for free events',
                              style: TextStyles.regularwhite
                                  .copyWith(color: Colors.white70)),
                        ),
                        _buildInputField(
                            'Live Stream URL (Optional)',
                            liveStreamController,
                            'https://youtube.com/watch?v=... or https://facebook.com/...'),
                        Padding(
                          padding: EdgeInsets.only(left: 1.w, bottom: 0.5.h),
                          child: Text(
                              'Only YouTube and Facebook URLs are supported',
                              style: TextStyles.regularwhite
                                  .copyWith(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),

                  // Location Section
                  _buildSection(
                    title: 'Location',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                            'City', cityController, 'Name of City'),
                        _buildInputField(
                            'Address', addressController, 'Event Address'),
                        _buildUseCurrentLocationRow(),
                        // Removed lat/lon preview under the button
                      ],
                    ),
                  ),

                  // Schedule Section
                  _buildSection(
                    title: 'Schedule',
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
                        SizedBox(height: 1.5.h),
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
                    title: 'Media',
                    child: _buildImagePicker(),
                  ),

                  SizedBox(height: 3.h),
                  Obx(() {
                    final isBusy = eventController.isLoading.value;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: ButtonWidget(
                        text: isBusy ? 'Creating…' : 'Create Event',
                        onPressed: isBusy
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                _createEvent();
                              },
                        borderRadius: 4.h,
                        textColor: AppColors.whiteColor,
                        backgroundColor: AppColors.blueColor,
                      ),
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
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.blueColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 2.w),
              Text(title, style: TextStyles.homeheadingtext),
            ],
          ),
          SizedBox(height: 1.5.h),
          child,
        ],
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
              onPressed: () => Get.back(),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Create Event',
                  style: TextStyles.heading,
                ),
              ),
            ),
            // Trailing spacer to balance the back button width
            const SizedBox(width: 48),
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

  Widget _buildInputField(
      String label, TextEditingController controller, String hint,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.regularwhite),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            // General validation - skip for optional fields
            if (value == null || value.trim().isEmpty) {
              if (label.contains('Live Stream URL')) {
                return null; // Optional field, no error for empty value
              }
              return '$label is required';
            }
            if (label == 'Price') {
              final v = double.tryParse(value);
              if (v == null || v < 0) return 'Enter a valid price';
            }
            // Live stream URL validation
            if (label.contains('Live Stream URL') && value.isNotEmpty) {
              if (!_isValidLiveStreamUrl(value)) {
                return 'Please enter a valid YouTube or Facebook URL';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.signinoptioncolor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.blueColor)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.red)),
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildUseCurrentLocationRow() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _isGettingLocation ? null : _useCurrentLocation,
          icon: _isGettingLocation
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location),
          label:
              Text(_isGettingLocation ? 'Locating…' : 'Use current location'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueColor,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        SizedBox(width: 3.w),
      ],
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
    return TextFormField(
      controller: controller,
      readOnly: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.signinoptioncolor,
        suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.grey),
            onPressed: onTap),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.blueColor)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.red)),
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) =>
          (value == null || value.isEmpty) ? '$hint is required' : null,
    );
  }

  Widget _buildTimeField(
      String label, String value, VoidCallback onTap, String? errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: AppColors.signinoptioncolor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: errorText != null ? Colors.red : Colors.transparent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(color: Colors.white)),
                const Icon(Icons.access_time, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 0.5.h, left: 1.w),
            child: Text(errorText,
                style: TextStyle(color: Colors.red, fontSize: 10.sp)),
          ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose File', style: TextStyles.regularwhite),
        SizedBox(height: 1.h),
        InkWell(
          onTap: _selectFile,
          child: Container(
            height: 20.h,
            decoration: BoxDecoration(
              color: AppColors.signinoptioncolor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: imageFile == null
                ? Center(
                    child: Text('Choose File',
                        style: TextStyle(color: Colors.white, fontSize: 14.sp)))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(imageFile!,
                        width: double.infinity, fit: BoxFit.cover),
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
        eventPrice: priceController.text,
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
