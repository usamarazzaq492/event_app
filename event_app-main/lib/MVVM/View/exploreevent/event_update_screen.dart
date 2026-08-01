import 'dart:io';
import 'dart:ui';

import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

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
  late TextEditingController stateccontroller;
  late TextEditingController addessccontroller;
  late TextEditingController categoryccontroller;
  late TextEditingController sdateController;
  late TextEditingController edateController;
  TextEditingController liveStreamController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  String _startTime = 'Start Time';
  String _endTime = 'End Time';
  File? imageFile;

  String? _startTimeError;
  String? _endTimeError;
  String? _imageError;

  @override
  void initState() {
    super.initState();

    titlecontroller = TextEditingController();
    desccontroller = TextEditingController();
    cityccontroller = TextEditingController();
    stateccontroller = TextEditingController();
    addessccontroller = TextEditingController();
    categoryccontroller = TextEditingController();
    sdateController = TextEditingController();
    edateController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventController.fetchEventDetailById(widget.eventId, onLoaded: (event) {
        setState(() {
          titlecontroller.text = event.eventTitle ?? '';
          desccontroller.text = event.description ?? '';
          cityccontroller.text = event.city ?? '';
          stateccontroller.text = event.state ?? '';
          addessccontroller.text = event.address ?? '';
          categoryccontroller.text = event.category ?? '';
          sdateController.text = event.startDate ?? '';
          edateController.text = event.endDate ?? '';
          liveStreamController.text = event.liveStreamUrl ?? '';
          priceController.text = event.eventPrice ?? '';
          _startTime = event.startTime ?? 'Start Time';
          _endTime = event.endTime ?? 'End Time';
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() {
          if (eventController.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.blueColor));
          }

          return Stack(
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
                          SizedBox(height: 2.h),

                          // Details Section
                          _buildSection(
                            title: 'EVENT DETAILS',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputField('Title', titlecontroller, 'Name of Event'),
                                _buildInputField('Description', desccontroller, 'Event Description', maxLines: 4),
                                _buildInputField('Base Price (Optional)', priceController, 'e.g. 50.00', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                                _buildInputField('Category', categoryccontroller, 'Category'),
                                _buildInputField('Live Stream URL (Optional)', liveStreamController, 'https://youtube.com/... or https://facebook.com/...'),
                                Padding(
                                  padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
                                  child: Text(
                                      'Only YouTube and Facebook URLs are supported',
                                      style: TextStyle(
                                          color: AppColors.textColorPrimary.withValues(alpha: 0.24),
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
                                _buildInputField('City', cityccontroller, 'e.g. Memphis'),
                                _buildInputField('State', stateccontroller, 'e.g. Tennessee'),
                                _buildInputField('Address', addessccontroller, 'Street address or venue'),
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
                                    Expanded(child: _buildDateField('Start Date', sdateController, () => _selectDate(sdateController))),
                                    SizedBox(width: 3.w),
                                    Expanded(child: _buildDateField('End Date', edateController, () => _selectDate(edateController))),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    Expanded(child: _buildTimeField('Start Time', _startTime, () => _selectTime(isStart: true), _startTimeError)),
                                    SizedBox(width: 3.w),
                                    Expanded(child: _buildTimeField('End Time', _endTime, () => _selectTime(isStart: false), _endTimeError)),
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
                          _buildUpdateButton(),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(2.5.h),
      decoration: BoxDecoration(
        color: AppColors.textColorPrimary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(2.5.h),
        border: Border.all(
          color: AppColors.textColorPrimary.withValues(alpha: 0.08),
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
                  color: AppColors.textColorPrimary.withValues(alpha: 0.38),
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
                  color: AppColors.textColorPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(1.5.h),
                  border: Border.all(
                    color: AppColors.textColorPrimary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textColorPrimary, size: 16.sp),
                  onPressed: () => Get.back(),
                  style: IconButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.all(2.w),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'EDIT EVENT',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.textColorPrimary,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10.w), // Spacer to balance back button
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
              color: AppColors.textColorPrimary.withValues(alpha: 0.38),
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
            color: AppColors.textColorPrimary,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.textColorPrimary.withValues(alpha: 0.03),
            hintStyle: TextStyle(color: AppColors.textColorPrimary.withValues(alpha: 0.12), fontSize: 10.sp),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.h),
              borderSide:
                  BorderSide(color: AppColors.textColorPrimary.withValues(alpha: 0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.h),
              borderSide:
                  BorderSide(color: AppColors.textColorPrimary.withValues(alpha: 0.05)),
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
            if (label.contains('Live Stream URL') && value.isNotEmpty) {
              if (!_isValidLiveStreamUrl(value)) return 'Use YT or FB URLs';
            }
            if (label.contains('Price') && value.isNotEmpty) {
               final v = double.tryParse(value);
               if (v == null || v < 0) return 'Invalid price';
            }
            return null;
          },
        ),
        SizedBox(height: 2.5.h),
      ],
    );
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
              color: AppColors.textColorPrimary.withValues(alpha: 0.38),
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
            color: AppColors.textColorPrimary,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Select Date',
            filled: true,
            fillColor: AppColors.textColorPrimary.withValues(alpha: 0.03),
            suffixIcon: Icon(Icons.calendar_month_rounded,
                color: AppColors.textColorPrimary.withValues(alpha: 0.24), size: 16.sp),
            hintStyle: TextStyle(color: AppColors.textColorPrimary.withValues(alpha: 0.12), fontSize: 10.sp),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.h),
              borderSide:
                  BorderSide(color: AppColors.textColorPrimary.withValues(alpha: 0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.5.h),
              borderSide:
                  BorderSide(color: AppColors.textColorPrimary.withValues(alpha: 0.05)),
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
              color: AppColors.textColorPrimary.withValues(alpha: 0.38),
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
              color: AppColors.textColorPrimary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(1.5.h),
              border: Border.all(
                color: errorText != null
                    ? Colors.redAccent
                    : AppColors.textColorPrimary.withValues(alpha: 0.05),
                width: errorText != null ? 1 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value == label ? 'Select $label' : value,
                    style: TextStyle(
                      color: value == label ? AppColors.textColorPrimary.withValues(alpha: 0.12) : AppColors.textColorPrimary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(Icons.access_time_rounded,
                    color: AppColors.textColorPrimary.withValues(alpha: 0.24), size: 16.sp),
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
    final imageUrl = eventController.eventDetail.value?.eventImage;
    String fullImageUrl = '';
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        fullImageUrl = imageUrl;
      } else {
        fullImageUrl = 'https://eventgo-live.com$imageUrl';
      }
    }

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
              color: AppColors.textColorPrimary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(2.h),
              border: Border.all(
                color: _imageError != null ? Colors.redAccent : AppColors.textColorPrimary.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: imageFile == null && fullImageUrl.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textColorPrimary.withValues(alpha: 0.03),
                        ),
                        child: Icon(Icons.add_photo_alternate_rounded,
                            color: AppColors.textColorPrimary.withValues(alpha: 0.24), size: 30.sp),
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        'Tap to upload cover image',
                        style: TextStyle(
                          color: AppColors.textColorPrimary.withValues(alpha: 0.12),
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
                        child: imageFile != null
                            ? Image.file(
                                imageFile!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                fullImageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 1.5.h,
                        right: 1.5.h,
                        child: GestureDetector(
                          onTap: _selectFile,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.textColorSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded,
                                color: AppColors.textColorPrimary, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_imageError != null)
          Padding(
            padding: EdgeInsets.only(top: 0.8.h, left: 1.w),
            child: Text(_imageError!,
                style: TextStyle(color: Colors.redAccent, fontSize: 8.sp)),
          ),
      ],
    );
  }

  void _selectFile() async {
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

  bool _isValidLiveStreamUrl(String url) {
    final youtubePattern = RegExp(
        r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})');
    final facebookPattern = RegExp(r'facebook\.com');

    return youtubePattern.hasMatch(url) || facebookPattern.hasMatch(url);
  }

  Widget _buildUpdateButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.h),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Obx(() {
        final isBusy = eventController.isLoading.value;
        return ButtonWidget(
          text: isBusy ? 'UPDATING...' : 'UPDATE EVENT',
          onPressed: isBusy
              ? null
              : () async {
                  HapticFeedback.lightImpact();
                  bool isValid = _formKey.currentState!.validate();

                  setState(() {
                    _startTimeError = (_startTime == 'Start Time') ? 'Select start time' : null;
                    _endTimeError = (_endTime == 'End Time') ? 'Select end time' : null;
                    _imageError = null; // optional on update
                  });

                  if (isValid && _startTimeError == null && _endTimeError == null) {
                    await eventController.updateEvent(
                      id: widget.eventId,
                      eventTitle: titlecontroller.text,
                      startDate: sdateController.text,
                      endDate: edateController.text,
                      startTime: _startTime,
                      endTime: _endTime,
                      description: desccontroller.text,
                      category: categoryccontroller.text,
                      address: addessccontroller.text,
                      city: cityccontroller.text.trim(),
                      state: stateccontroller.text.trim(),
                      latitude: null,
                      longitude: null,
                      image: imageFile,
                      liveStreamUrl: liveStreamController.text.isNotEmpty ? liveStreamController.text : null,
                      eventPrice: priceController.text.isNotEmpty ? priceController.text : null,
                    );
                  } else {
                    Get.snackbar('Validation', 'Please fill all required fields',
                        backgroundColor: AppColors.textColorPrimary,
                        colorText: Colors.white);
                  }
                },
          borderRadius: 2.h,
          textColor: Colors.white,
          backgroundColor: AppColors.blueColor,
        );
      }),
    );
  }
}
