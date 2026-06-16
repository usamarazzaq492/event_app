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

  String _startTime = 'Start Time';
  String _endTime = 'End Time';
  File? imageFile;

  String? _startTimeError;
  String? _endTimeError;
  String? _imageError;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
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
          _startTime = event.startTime ?? 'Start Time';
          _endTime = event.endTime ?? 'End Time';
        });
      });
    });
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
                        buildValidatedInput(
                            liveStreamController, 'Live Stream URL (Optional)'),
                      ],
                    ),
                  ),

                  // Location Section (City + State disambiguate same-named cities)
                  _buildSection(
                    title: 'Location',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildValidatedInput(cityccontroller, 'City (e.g. Memphis)'),
                        buildValidatedInput(stateccontroller, 'State (e.g. Tennessee)'),
                        buildValidatedInput(addessccontroller, 'Address'),
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
        keyboardType: TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration(hint),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            if (hint.contains('Live Stream URL')) {
              return null; // Optional field, no error for empty value
            }
            return 'This field is required';
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
      contextMenuBuilder: (context, editableTextState) =>
          const SizedBox.shrink(),
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
                    // final existingImageUrl =
                    //     eventController.eventDetail.value?.eventImage;
                    _imageError =
                        null; // Image is optional when updating (can keep existing)
                  });

                  if (isValid &&
                      _startTimeError == null &&
                      _endTimeError == null &&
                      _imageError == null) {
                    // Backend will geocode address + city + state to get latitude/longitude
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

  bool _isValidLiveStreamUrl(String url) {
    final youtubePattern = RegExp(
        r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})');
    final facebookPattern = RegExp(r'facebook\.com');

    return youtubePattern.hasMatch(url) || facebookPattern.hasMatch(url);
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
              onPressed: () => Navigator.of(context).pop(),
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
