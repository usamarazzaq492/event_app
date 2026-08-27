import 'dart:io';
import 'dart:ui';

import 'package:event_app/MVVM/view_model/event_view_model.dart';
import 'package:event_app/Widget/button_widget.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

// ─── Quick-pick presets ───────────────────────────────────────────────────────
const _kPresets = [
  {'label': 'Adult', 'emoji': '🎫', 'desc': ''},
  {'label': 'Child', 'emoji': '👶', 'desc': 'Ages 12 and under'},
  {'label': 'VIP', 'emoji': '⭐', 'desc': 'Premium experience'},
  {'label': 'Senior 55+', 'emoji': '🏅', 'desc': 'Ages 55 and above'},
  {'label': 'Student', 'emoji': '🎓', 'desc': 'Valid student ID required'},
  {'label': 'Early Bird', 'emoji': '🐦', 'desc': 'Limited availability'},
  {'label': 'General', 'emoji': '🎟️', 'desc': ''},
];

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
  final stateController = TextEditingController();
  final addressController = TextEditingController();
  final categoryController = TextEditingController();
  final sdateController = TextEditingController();
  final edateController = TextEditingController();
  final liveStreamController = TextEditingController();

  String _startTime = 'Start Time';
  String _endTime = 'End Time';
  String? _startTimeError;
  String? _endTimeError;

  File? imageFile;
  String? _bannerText;
  Color _bannerColor = Colors.transparent;

  // ── Local tier list (stored until event is created) ───────────────────────
  final List<Map<String, dynamic>> _localTiers = [];

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
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _bannerText ?? '',
              style: TextStyles.regulartext,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textColorSecondary, size: 18),
            onPressed: () => setState(() => _bannerText = null),
            style: IconButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.all(1.w),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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
                              : SizedBox.shrink(),
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
                                  'Live Stream URL (Optional)',
                                  liveStreamController,
                                  'https://youtube.com/... or https://facebook.com/...'),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 1.w, bottom: 1.h),
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

                        // Location Section (City + State disambiguate same-named cities)
                        _buildSection(
                          title: 'LOCATION',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputField(
                                  'City', cityController, 'e.g. Memphis'),
                              _buildInputField(
                                  'State', stateController, 'e.g. Tennessee'),
                              _buildInputField('Address', addressController,
                                  'Street address or venue'),
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

                        // ── Ticket Tiers Section ──────────────────────────
                        _buildSection(
                          title: 'TICKET TIERS',
                          child: _buildTiersSection(),
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
                              textColor: Colors.white,
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

  // ── Tiers Section ─────────────────────────────────────────────────────────
  Widget _buildTiersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Helper text
        Padding(
          padding: EdgeInsets.only(bottom: 1.5.h),
          child: Text(
            'Add ticket tiers to offer different pricing (optional)',
            style: TextStyle(
              color: AppColors.textColorPrimary.withValues(alpha: 0.38),
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Quick-pick preset chips
        Text('QUICK PICK',
            style: TextStyle(
                color: AppColors.textColorPrimary.withValues(alpha: 0.38),
                fontSize: 8.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _kPresets
              .map((p) => _buildPresetChip(
                    '${p['emoji']} ${p['label']}',
                    () => _openTierSheet(preset: p),
                  ))
              .toList(),
        ),

        SizedBox(height: 2.h),

        // Added tiers list
        if (_localTiers.isNotEmpty) ...[
          ...List.generate(_localTiers.length, (index) {
            final tier = _localTiers[index];
            return _buildLocalTierCard(tier, index);
          }),
          SizedBox(height: 1.h),
        ],

        // Add custom tier button
        GestureDetector(
          onTap: () => _openTierSheet(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 1.8.h),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(1.8.h),
              border: Border.all(
                color: AppColors.blueColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded,
                    color: AppColors.blueColor, size: 16.sp),
                SizedBox(width: 2.w),
                Text(
                  _localTiers.isEmpty ? 'Add a Ticket Tier' : 'Add Another Tier',
                  style: TextStyle(
                    color: AppColors.blueColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.9.h),
        decoration: BoxDecoration(
          color: AppColors.blueColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3.h),
          border:
              Border.all(color: AppColors.blueColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textColorPrimary,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLocalTierCard(Map<String, dynamic> tier, int index) {
    final name = tier['name'] as String;
    final price = tier['price'] as double;
    final cap = tier['quantityCap'] as int?;
    final desc = tier['description'] as String?;
    final isFree = price == 0;

    // Derive emoji
    final nameLower = name.toLowerCase();
    String emoji = '🎫';
    if (nameLower.contains('vip')) emoji = '⭐';
    if (nameLower.contains('child')) emoji = '👶';
    if (nameLower.contains('senior')) emoji = '🏅';
    if (nameLower.contains('student')) emoji = '🎓';
    if (nameLower.contains('early')) emoji = '🐦';
    if (nameLower.contains('general')) emoji = '🎟️';

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: AppColors.textColorPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(
          color: AppColors.textColorPrimary.withValues(alpha: 0.09),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.h),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.h),
            child: Row(
              children: [
                // Emoji icon
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(1.2.h),
                  ),
                  child: Center(
                    child: Text(emoji, style: TextStyle(fontSize: 15.sp)),
                  ),
                ),

                SizedBox(width: 3.w),

                // Name + description + capacity
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: AppColors.textColorPrimary,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (desc != null && desc.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 0.3.h),
                          child: Text(
                            desc,
                            style: TextStyle(
                                color: AppColors.textColorPrimary.withValues(alpha: 0.38), fontSize: 8.5.sp),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.5.h),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.8.w, vertical: 0.25.h),
                          decoration: BoxDecoration(
                            color: AppColors.textColorPrimary.withValues(alpha: 0.24).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(1.h),
                            border: Border.all(
                                color: AppColors.textColorPrimary.withValues(alpha: 0.24).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            cap != null ? 'Cap: $cap' : 'Unlimited',
                            style: TextStyle(
                                color: AppColors.textColorPrimary.withValues(alpha: 0.24), fontSize: 8.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Text(
                  isFree ? 'FREE' : '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isFree ? Colors.greenAccent : AppColors.textColorPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),

                SizedBox(width: 2.w),

                // Edit + Delete buttons
                GestureDetector(
                  onTap: () => _openTierSheet(editIndex: index),
                  child: Container(
                    padding: EdgeInsets.all(1.5.w),
                    decoration: BoxDecoration(
                      color: AppColors.blueColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit_rounded,
                        color: AppColors.blueColor, size: 12.sp),
                  ),
                ),
                SizedBox(width: 1.5.w),
                GestureDetector(
                  onTap: () {
                    HapticUtils.light();
                    setState(() => _localTiers.removeAt(index));
                  },
                  child: Container(
                    padding: EdgeInsets.all(1.5.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        color: Colors.redAccent, size: 12.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Tier Bottom Sheet ─────────────────────────────────────────────────────
  void _openTierSheet({Map<String, dynamic>? preset, int? editIndex}) {
    HapticUtils.buttonPress();

    // Pre-fill data
    String? initialName;
    String? initialPrice;
    String? initialCap;
    String? initialDesc;
    bool initialHasCap = false;

    if (editIndex != null) {
      // Editing an existing local tier
      final tier = _localTiers[editIndex];
      initialName = tier['name'] as String;
      initialPrice = (tier['price'] as double).toStringAsFixed(2);
      initialCap =
          tier['quantityCap'] != null ? '${tier['quantityCap']}' : null;
      initialDesc = tier['description'] as String?;
      initialHasCap = tier['quantityCap'] != null;
    } else if (preset != null) {
      // Using a preset
      initialName = preset['label'] as String;
      initialDesc = (preset['desc'] as String).isNotEmpty
          ? preset['desc'] as String
          : null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TierFormSheet(
        isEditing: editIndex != null,
        initialName: initialName,
        initialPrice: initialPrice,
        initialCap: initialCap,
        initialDesc: initialDesc,
        initialHasCap: initialHasCap,
        onSave: (name, price, cap, desc) {
          Navigator.pop(context);
          setState(() {
            final tierData = {
              'name': name,
              'price': price,
              'quantityCap': cap,
              'description': desc,
            };
            if (editIndex != null) {
              _localTiers[editIndex] = tierData;
            } else {
              _localTiers.add(tierData);
            }
          });
          HapticUtils.success();
        },
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
              'CREATE EVENT',
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
                color: AppColors.textColorPrimary.withValues(alpha: 0.05),
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
                              color: AppColors.textColorSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.textColorPrimary, size: 16),
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
      _showBanner('Submitting your event…', color: AppColors.blueColor);
      // Backend will geocode address + city + state to get latitude/longitude
      await eventController.createEventWithTiers(
        eventTitle: titleController.text,
        startDate: sdateController.text,
        endDate: edateController.text,
        startTime: _startTime,
        endTime: _endTime,
        eventDescription: descController.text,
        eventCategory: categoryController.text,
        eventAddress: addressController.text,
        eventCity: cityController.text.trim(),
        eventState: stateController.text.trim(),
        eventLatitude: null,
        eventLongitude: null,
        eventImage: imageFile!,
        liveStreamUrl: liveStreamController.text.isNotEmpty
            ? liveStreamController.text
            : null,
        eventPrice: null,
        tiersList: _localTiers,
      );
    } else if (imageFile == null) {
      _showBanner('Please select an image', color: Colors.red);
      Get.snackbar('Error', 'Please select an image',
backgroundColor: AppColors.textColorPrimary,
colorText: Colors.white,);
    }
  }

  bool _isValidLiveStreamUrl(String url) {
    final youtubePattern = RegExp(
        r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})');
    final facebookPattern = RegExp(r'facebook\.com');

    return youtubePattern.hasMatch(url) || facebookPattern.hasMatch(url);
  }
}

// ─── Add / Edit Tier Bottom Sheet (self-contained, no external deps) ─────────
class _TierFormSheet extends StatefulWidget {
  final bool isEditing;
  final String? initialName;
  final String? initialPrice;
  final String? initialCap;
  final String? initialDesc;
  final bool initialHasCap;
  final void Function(String name, double price, int? cap, String? desc) onSave;

  const _TierFormSheet({
    required this.isEditing,
    this.initialName,
    this.initialPrice,
    this.initialCap,
    this.initialDesc,
    this.initialHasCap = false,
    required this.onSave,
  });

  @override
  State<_TierFormSheet> createState() => _TierFormSheetState();
}

class _TierFormSheetState extends State<_TierFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _capCtrl;
  late TextEditingController _descCtrl;
  late bool _hasCapLimit;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _priceCtrl = TextEditingController(text: widget.initialPrice ?? '');
    _capCtrl = TextEditingController(text: widget.initialCap ?? '');
    _descCtrl = TextEditingController(text: widget.initialDesc ?? '');
    _hasCapLimit = widget.initialHasCap;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _capCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _nameCtrl.text = preset['label'] as String;
      if ((preset['desc'] as String).isNotEmpty) {
        _descCtrl.text = preset['desc'] as String;
      }
    });
    HapticUtils.light();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final cap = _hasCapLimit ? (int.tryParse(_capCtrl.text.trim())) : null;
    final desc = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
    widget.onSave(name, price, cap, desc);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.h)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.signinoptioncolor.withValues(alpha: 0.96),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(4.h)),
              border:
                  Border.all(color: AppColors.textColorPrimary.withValues(alpha: 0.08)),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 10.w,
                        height: 0.5.h,
                        decoration: BoxDecoration(
                          color: AppColors.textColorPrimary.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(1.h),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Title
                    Text(
                      widget.isEditing ? 'Edit Tier' : 'Add Ticket Tier',
                      style: TextStyle(
                        color: AppColors.textColorPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      widget.isEditing
                          ? 'Update the details for this tier.'
                          : 'Define who can buy this tier and at what price.',
                      style: TextStyle(
                          color: AppColors.textColorPrimary.withValues(alpha: 0.38), fontSize: 10.sp),
                    ),

                    // Preset chips (only on add)
                    if (!widget.isEditing) ...[
                      SizedBox(height: 2.h),
                      Text('QUICK PICK',
                          style: TextStyle(
                              color: AppColors.textColorPrimary.withValues(alpha: 0.38),
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2)),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: _kPresets
                            .map((p) => GestureDetector(
                                  onTap: () => _applyPreset(p),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 0.9.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.blueColor
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(3.h),
                                      border: Border.all(
                                          color: AppColors.blueColor
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      '${p['emoji']} ${p['label']}',
                                      style: TextStyle(
                                        color: AppColors.textColorPrimary,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],

                    SizedBox(height: 2.5.h),

                    // Tier name
                    _label('TIER NAME'),
                    SizedBox(height: 0.8.h),
                    _field(
                      controller: _nameCtrl,
                      hint: 'e.g. Adult, VIP, Child, Senior 55+',
                      icon: Icons.label_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Tier name is required'
                          : null,
                    ),

                    SizedBox(height: 2.h),

                    // Price
                    _label('PRICE (USD)'),
                    SizedBox(height: 0.8.h),
                    _field(
                      controller: _priceCtrl,
                      hint: '0.00  (set 0 for free)',
                      icon: Icons.attach_money_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Price is required';
                        }
                        final n = double.tryParse(v.trim());
                        if (n == null || n < 0) return 'Enter a valid price';
                        return null;
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Quantity cap toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('LIMIT QUANTITY'),
                            Text('Set max tickets for this tier',
                                style: TextStyle(
                                    color: AppColors.textColorPrimary.withValues(alpha: 0.38),
                                    fontSize: 8.5.sp)),
                          ],
                        ),
                        Switch(
                          value: _hasCapLimit,
                          activeThumbColor: AppColors.blueColor,
                          onChanged: (v) =>
                              setState(() => _hasCapLimit = v),
                        ),
                      ],
                    ),

                    if (_hasCapLimit) ...[
                      SizedBox(height: 1.h),
                      _field(
                        controller: _capCtrl,
                        hint: 'e.g. 100',
                        icon: Icons.people_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (!_hasCapLimit) return null;
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter a quantity';
                          }
                          final n = int.tryParse(v.trim());
                          if (n == null || n < 1) {
                            return 'Must be at least 1';
                          }
                          return null;
                        },
                      ),
                    ],

                    SizedBox(height: 2.h),

                    // Description (optional)
                    _label('DESCRIPTION  (optional)'),
                    SizedBox(height: 0.8.h),
                    _field(
                      controller: _descCtrl,
                      hint: 'e.g. Ages 12 and under, Valid ID required…',
                      icon: Icons.notes_rounded,
                      maxLines: 2,
                    ),

                    SizedBox(height: 3.h),

                    // Save button
                    GestureDetector(
                      onTap: _submit,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.blueColor,
                              AppColors.lightColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(4.h),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blueColor
                                  .withValues(alpha: 0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.isEditing ? 'Save Changes' : 'Add Tier',
                            style: TextStyle(
                              color: AppColors.textColorPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          color: AppColors.textColorPrimary,
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textColorPrimary, fontSize: 12.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textColorPrimary.withValues(alpha: 0.24), fontSize: 11.sp),
        prefixIcon: Icon(icon, color: AppColors.blueColor, size: 14.sp),
        filled: true,
        fillColor: AppColors.textColorPrimary.withValues(alpha: 0.04),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.h),
          borderSide:
              BorderSide(color: AppColors.textColorPrimary.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.h),
          borderSide:
              BorderSide(color: AppColors.textColorPrimary.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.h),
          borderSide:
              BorderSide(color: AppColors.blueColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.h),
          borderSide: BorderSide(
              color: Colors.red.withValues(alpha: 0.6), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.h),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        errorStyle: TextStyle(color: Colors.red, fontSize: 9.sp),
      ),
    );
  }
}
