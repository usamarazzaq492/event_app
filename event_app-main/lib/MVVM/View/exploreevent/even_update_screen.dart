import 'dart:io';

import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../Services/location_service.dart';

import '../bottombar/bottom_navigation_bar.dart';

class EventUpdateScreen extends StatefulWidget {
  final String eventId;

  const EventUpdateScreen({super.key, required this.eventId});

  @override
  State<EventUpdateScreen> createState() => _EventUpdateScreenState();
}

class _EventUpdateScreenState extends State<EventUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final eventController = Get.put(EventController());

  late TextEditingController titlecontroller;
  late TextEditingController desccontroller;
  late TextEditingController cityccontroller;
  late TextEditingController addessccontroller;
  late TextEditingController categoryccontroller;
  late TextEditingController priceccontroller;
  late TextEditingController sdateController;
  late TextEditingController edateController;
  TextEditingController liveStreamController = TextEditingController();

  String _startTime = 'Start Time';
  String _endTime = 'End Time';
  File? imageFile;

  String? _startTimeError;
  String? _endTimeError;
  String? _imageError;
  // Location state
  double? _pickedLat;
  double? _pickedLon;
  bool _isGettingLocation = false;
  // Inline banner
  String? _bannerText;
  Color _bannerColor = Colors.transparent;

  void _showBanner(String message, {Color color = Colors.blue}) {
    setState(() {
      _bannerText = message;
      _bannerColor = color;
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    titlecontroller = TextEditingController();
    desccontroller = TextEditingController();
    cityccontroller = TextEditingController();
    addessccontroller = TextEditingController();
    categoryccontroller = TextEditingController();
    priceccontroller = TextEditingController();
    sdateController = TextEditingController();
    edateController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventController.fetchEventDetailById(widget.eventId, onLoaded: (event) {
        setState(() {
          titlecontroller.text = event.eventTitle ?? '';
          desccontroller.text = event.description ?? '';
          cityccontroller.text = event.city ?? '';
          addessccontroller.text = event.address ?? '';
          categoryccontroller.text = event.category ?? '';
          priceccontroller.text = event.eventPrice ?? '';
          sdateController.text = event.startDate ?? '';
          edateController.text = event.endDate ?? '';
          liveStreamController.text = event.liveStreamUrl ?? '';
          _startTime = event.startTime ?? 'Start Time';
          _endTime = event.endTime ?? 'End Time';
        });
      });
    });

    // Invalidate picked coords on manual edits
    addessccontroller.addListener(_invalidatePickedCoordinatesOnManualEdit);
    cityccontroller.addListener(_invalidatePickedCoordinatesOnManualEdit);
  }

  void _invalidatePickedCoordinatesOnManualEdit() {
    if (_pickedLat != null || _pickedLon != null) {
      setState(() {
        _pickedLat = null;
        _pickedLon = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        if (eventController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.only(top: 4.h, left: 5.w, right: 5.w, bottom: 3.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderModern(),
                  if (_bannerText != null) _buildBanner(),
                  SizedBox(height: 2.5.h),

                  // Details Section
                  _buildSection(
                    title: 'Event Details',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildValidatedInput(titlecontroller, 'Name of Event'),
                        buildValidatedMultiLineField(
                            desccontroller, 'Description'),
                        buildValidatedInput(categoryccontroller, 'Category'),
                        buildValidatedInput(priceccontroller, 'Price of Event'),
                        buildValidatedInput(
                            liveStreamController, 'Live Stream URL (Optional)'),
                      ],
                    ),
                  ),

                  // Location Section
                  _buildSection(
                    title: 'Location',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildValidatedInput(cityccontroller, 'Name of City'),
                        buildValidatedInput(addessccontroller, 'Enter Address'),
                        _buildUseCurrentLocationRow(),
                      ],
                    ),
                  ),

                  // Schedule Section
                  _buildSection(
                    title: 'Schedule',
                    child: Column(
                      children: [
                        buildDateRow(),
                        SizedBox(height: 1.5.h),
                        buildTimeRow(),
                      ],
                    ),
                  ),

                  // Media Section
                  _buildSection(
                    title: 'Media',
                    child: buildImagePicker(),
                  ),

                  SizedBox(height: 3.h),
                  buildUpdateButton(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h, top: 2.h),
      child: Text(label, style: TextStyles.regularwhite),
    );
  }

  Widget buildValidatedInput(TextEditingController controller, String hint) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration(hint),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            if (hint.contains('Live Stream URL')) {
              return null; // Optional field, no error for empty value
            }
            return 'This field is required';
          }
          if (hint == 'Price of Event') {
            final v = double.tryParse(value);
            if (v == null || v < 0) return 'Enter a valid price';
          }
          if (hint.contains('Live Stream URL') && value.isNotEmpty) {
            if (!_isValidLiveStreamUrl(value)) {
              return 'Please enter a valid YouTube or Facebook URL';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget buildValidatedMultiLineField(
      TextEditingController controller, String hint) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: TextFormField(
        controller: controller,
        maxLines: 6,
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration(hint),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: AppColors.signinoptioncolor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.blueColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      errorStyle: TextStyle(
        color: Colors.redAccent,
        fontSize: 11.sp,
      ),
    );
  }

  Widget buildDateRow() {
    return Row(
      children: [
        Expanded(
            child: _buildDateField('Start Date', sdateController,
                () => _selectDate(sdateController))),
        SizedBox(width: 3.w),
        Expanded(
            child: _buildDateField('End Date', edateController,
                () => _selectDate(edateController))),
      ],
    );
  }

  Widget _buildDateField(
      String hint, TextEditingController controller, VoidCallback onTap) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enableInteractiveSelection: false,
      contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
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

  Widget buildTimeRow() {
    return Row(
      children: [
        Expanded(
            child: _buildTimeField('Start Time', _startTime,
                () => _selectTime(isStart: true), _startTimeError)),
        SizedBox(width: 3.w),
        Expanded(
            child: _buildTimeField('End Time', _endTime,
                () => _selectTime(isStart: false), _endTimeError)),
      ],
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

  Widget buildImagePicker() {
    final imageUrl = eventController.eventDetail.value?.eventImage;

    // 🔧 Adjust your domain here
    String fullImageUrl = '';
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        fullImageUrl = imageUrl;
      } else {
        fullImageUrl = 'https://eventgo-live.com$imageUrl'; // 👈 prepend domain
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: selectFile,
          child: Container(
            height: 20.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.signinoptioncolor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _imageError != null ? Colors.red : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: imageFile != null
                ? Image.file(imageFile!, fit: BoxFit.cover)
                : (fullImageUrl.isNotEmpty
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Text('Choose File',
                            style: TextStyle(color: Colors.white)),
                      )),
          ),
        ),
        if (_imageError != null)
          Padding(
            padding: EdgeInsets.only(top: 0.5.h, left: 1.w),
            child: Text(_imageError!,
                style: TextStyle(color: Colors.redAccent, fontSize: 11.sp)),
          ),
      ],
    );
  }

  Widget buildUpdateButton() {
    return Obx(() {
      final isBusy = eventController.isLoading.value;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: ButtonWidget(
          key: ValueKey<bool>(isBusy),
          text: isBusy ? 'Updating…' : 'Update Event',
          onPressed: isBusy
              ? null
              : () async {
                  HapticFeedback.lightImpact();
                  bool isValid = _formKey.currentState!.validate();

                  setState(() {
                    _startTimeError = (_startTime == 'Start Time')
                        ? 'Select start time'
                        : null;
                    _endTimeError =
                        (_endTime == 'End Time') ? 'Select end time' : null;

                    // For updates, image is optional if existing image exists
                    final existingImageUrl =
                        eventController.eventDetail.value?.eventImage;
                    _imageError = null; // Image is optional when updating (can keep existing)
                  });

                  if (isValid &&
                      _startTimeError == null &&
                      _endTimeError == null &&
                      _imageError == null) {
                    // Determine coordinates: prefer picked; else geocode from Address+City
                    double? lat = _pickedLat;
                    double? lon = _pickedLon;
                    if (lat == null || lon == null) {
                      final fullAddress =
                          '${addessccontroller.text}, ${cityccontroller.text}';
                      try {
                        final locations =
                            await locationFromAddress(fullAddress);
                        if (locations.isNotEmpty) {
                          lat = locations.first.latitude;
                          lon = locations.first.longitude;
                        }
                      } catch (_) {}
                    }

                    await eventController.updateEvent(
                      id: widget.eventId,
                      eventTitle: titlecontroller.text,
                      startDate: sdateController.text,
                      endDate: edateController.text,
                      startTime: _startTime,
                      endTime: _endTime,
                      eventPrice: priceccontroller.text,
                      description: desccontroller.text,
                      category: categoryccontroller.text,
                      address: addessccontroller.text,
                      city: cityccontroller.text,
                      latitude: lat?.toStringAsFixed(6),
                      longitude: lon?.toStringAsFixed(6),
                      image: imageFile,
                      liveStreamUrl: liveStreamController.text.isNotEmpty
                          ? liveStreamController.text
                          : null,
                    );
                  } else {
                    Get.snackbar(
                        'Validation', 'Please fill all required fields',
                        backgroundColor: Colors.red, colorText: Colors.white);
                  }
                },
          borderRadius: 4.h,
          textColor: AppColors.whiteColor,
          backgroundColor: AppColors.blueColor,
        ),
      );
    });
  }

  void selectFile() async {
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        imageFile = File(file.path);
      });
    }
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
          color: AppColors.blueColor);

      // Reverse-geocode to fill fields best-effort
      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          cityccontroller.text = p.locality ?? cityccontroller.text;
          final lineParts = [
            p.street,
            p.subLocality,
            p.administrativeArea,
            p.country
          ].whereType<String>().where((e) => e.isNotEmpty).toList();
          if (lineParts.isNotEmpty) {
            addessccontroller.text = lineParts.join(', ');
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

  bool _isValidLiveStreamUrl(String url) {
    final youtubePattern = RegExp(
        r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})');
    final facebookPattern = RegExp(r'facebook\.com');

    return youtubePattern.hasMatch(url) || facebookPattern.hasMatch(url);
  }

  Widget _buildBanner() {
    return Container(
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

  Widget _buildHeaderModern() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BottomNavBar())),
            ),
            Expanded(
              child: Center(
                child: Text('Edit Event', style: TextStyles.heading),
              ),
            ),
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
}
