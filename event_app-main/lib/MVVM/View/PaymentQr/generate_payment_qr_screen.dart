import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:event_app/Services/payment_qr_service.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class GeneratePaymentQrScreen extends StatefulWidget {
  final int eventId;

  const GeneratePaymentQrScreen({super.key, required this.eventId});

  @override
  State<GeneratePaymentQrScreen> createState() =>
      _GeneratePaymentQrScreenState();
}

class _GeneratePaymentQrScreenState extends State<GeneratePaymentQrScreen> {
  final PaymentQrService _qrService = PaymentQrService();
  final GlobalKey _qrCodeKey = GlobalKey();
  final TextEditingController _expiresAtController = TextEditingController();
  final TextEditingController _maxUsesController = TextEditingController();

  String? _selectedTicketType = 'general';
  DateTime? _selectedExpiresAt;
  int? _maxUses;
  bool _isGenerating = false;
  bool _isLoadingQrCodes = false;
  List<dynamic> _existingQrCodes = [];
  Map<String, dynamic>? _newQrData;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingQrCodes();
  }

  @override
  void dispose() {
    _expiresAtController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -10.h,
            left: -10.w,
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blueColor.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Description
                        Text(
                          'Generate a QR code for your event. Users can scan it to quickly purchase tickets.',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 3.h),

                        // Success Message
                        if (_successMessage != null)
                          _buildStatusMessage(_successMessage!, true),

                        // Error Message
                        if (_errorMessage != null)
                          _buildStatusMessage(_errorMessage!, false),

                        // Generate Form
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2.5.h),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(2.5.h),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildLabel('Ticket Type'),
                                  SizedBox(height: 1.5.h),
                                  _buildDropdown(),
                                  SizedBox(height: 3.h),

                                  _buildLabel('Expires At (Optional)'),
                                  SizedBox(height: 1.5.h),
                                  _buildDatePicker(),
                                  SizedBox(height: 3.h),

                                  _buildLabel('Max Uses (Optional)'),
                                  SizedBox(height: 1.5.h),
                                  _buildTextField(),
                                  SizedBox(height: 4.h),

                                  // Generate Button
                                  _buildGenerateButton(),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // New QR Code Display
                        if (_newQrData != null) ...[
                          SizedBox(height: 4.h),
                          _buildQrCodeDisplay(_newQrData!),
                          SizedBox(height: 3.h),
                          _buildActionButtons(_newQrData!),
                        ],

                        // Existing QR Codes List
                        if (_existingQrCodes.isNotEmpty) ...[
                          SizedBox(height: 5.h),
                          _buildSectionHeader('Existing QR Codes'),
                          SizedBox(height: 2.h),
                          _buildExistingQrCodesList(),
                        ],
                      ],
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

  Widget _buildStatusMessage(String message, bool isSuccess) {
    final color = isSuccess ? Colors.greenAccent : Colors.redAccent;
    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.only(bottom: 2.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: color, size: 18.sp),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: color.withValues(alpha: 0.9),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: color, size: 18.sp),
            onPressed: () => setState(() {
              if (isSuccess) {
                _successMessage = null;
              } else {
                _errorMessage = null;
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.sp,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white24, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(1.5.h),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedTicketType,
        dropdownColor: const Color(0xFF1C1C23),
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          border: InputBorder.none,
        ),
        style: TextStyle(color: Colors.white, fontSize: 11.sp),
        items: const [
          DropdownMenuItem(value: 'general', child: Text('General Admission')),
          DropdownMenuItem(value: 'vip', child: Text('VIP Ticket')),
        ],
        onChanged: (value) => setState(() => _selectedTicketType = value),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectExpiresAt,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(1.5.h),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: AppColors.blueColor, size: 16.sp),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                _selectedExpiresAt != null
                    ? DateFormat('MMM d, yyyy  •  HH:mm')
                        .format(_selectedExpiresAt!)
                    : 'Set expiration date',
                style: TextStyle(
                  color: _selectedExpiresAt != null
                      ? Colors.white
                      : Colors.white38,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _maxUsesController,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.white, fontSize: 11.sp),
      decoration: InputDecoration(
        hintText: 'Unlimited uses',
        hintStyle: TextStyle(color: Colors.white24, fontSize: 11.sp),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1.5.h),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1.5.h),
          borderSide:
              BorderSide(color: AppColors.blueColor.withValues(alpha: 0.5)),
        ),
      ),
      onChanged: (value) =>
          setState(() => _maxUses = value.isEmpty ? null : int.tryParse(value)),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      height: 6.5.h,
      child: GestureDetector(
        onTap: _isGenerating ? null : _generateQrCode,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.blueColor,
                AppColors.blueColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(1.5.h),
            boxShadow: [
              BoxShadow(
                color: AppColors.blueColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: _isGenerating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_rounded,
                          color: Colors.white, size: 18.sp),
                      SizedBox(width: 3.w),
                      Text(
                        'Generate QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectExpiresAt() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedExpiresAt ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null || !mounted) return;
    setState(() {
      _selectedExpiresAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _expiresAtController.text =
          DateFormat('yyyy-MM-dd HH:mm').format(_selectedExpiresAt!);
    });
  }

  Future<void> _loadExistingQrCodes() async {
    setState(() {
      _isLoadingQrCodes = true;
    });

    try {
      final response = await _qrService.getEventQrCodes(widget.eventId);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          _existingQrCodes = responseData['data'] ?? [];
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

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticUtils.navigation();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(1.2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Event QR Codes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrCodeDisplay(Map<String, dynamic> qrData) {
    final qrCodeData = qrData['qrCodeData'];
    Map<String, dynamic> qrDataMap;

    try {
      qrDataMap = json.decode(qrCodeData);
    } catch (e) {
      qrDataMap = {'web': qrCodeData, 'app': qrCodeData};
    }

    final qrString = qrDataMap['web'] ?? (qrDataMap['app'] ?? qrCodeData);

    return RepaintBoundary(
      key: _qrCodeKey,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.5.h),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.5.h),
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
                QrImageView(
                  data: qrString,
                  version: QrVersions.auto,
                  size: 65.w,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                SizedBox(height: 3.h),
                _buildTicketTypeBadge(qrData['ticketType']),
                SizedBox(height: 1.5.h),
                Text(
                  'USD ${qrData['price'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketTypeBadge(String ticketType) {
    bool isVip = ticketType.toLowerCase() == 'vip';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isVip ? AppColors.blueColor : Colors.black12,
        borderRadius: BorderRadius.circular(1.2.h),
      ),
      child: Text(
        ticketType.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: isVip ? Colors.white : Colors.black54,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> qrData) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
              Icons.download_rounded, 'Download', _downloadQrCode),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildActionButton(Icons.share_rounded, 'Share', _shareQrCode),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 6.h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(1.5.h),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16.sp),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingQrCodesList() {
    if (_isLoadingQrCodes) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _existingQrCodes.length,
      itemBuilder: (context, index) {
        final qr = _existingQrCodes[index];
        return _buildQrCodeCard(qr);
      },
    );
  }

  Widget _buildQrCodeCard(Map<String, dynamic> qr) {
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
    final expiresAt = qr['expiresAt'];

    return Container(
      margin: EdgeInsets.only(bottom: 2.5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(2.5.h),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.h),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.h),
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(4.w),
                    child: QrImageView(
                      data: qrString,
                      version: QrVersions.auto,
                      size: 45.w,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTicketTypeBadge(ticketType),
                    if (maxUses != null && currentUses >= maxUses) ...[
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 0.8.h),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(1.h),
                          border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          'LIMIT REACHED',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (expiresAt != null) ...[
                  SizedBox(height: 1.h),
                  Text(
                    'Expires: ${DateFormat('MMM d, y HH:mm').format(DateTime.parse(expiresAt))}',
                    style: TextStyle(fontSize: 9.sp, color: Colors.white38),
                  ),
                ],
                SizedBox(height: 2.h),
                GestureDetector(
                  onTap: () => _deactivateQrCode(qr['qrId']),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.2.h),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.h),
                      border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.power_settings_new_rounded,
                            color: Colors.redAccent, size: 14.sp),
                        SizedBox(width: 2.w),
                        Text(
                          'Deactivate',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateQrCode() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _successMessage = null;
      _newQrData = null;
    });

    try {
      HapticUtils.buttonPress();

      String? expiresAtString;
      if (_selectedExpiresAt != null) {
        expiresAtString =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedExpiresAt!);
      }

      final response = await _qrService.generatePaymentQr(
        eventId: widget.eventId,
        ticketType: _selectedTicketType!,
        expiresAt: expiresAtString,
        maxUses: _maxUses,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          _newQrData = responseData['data'];
          _isGenerating = false;
          _successMessage = 'QR code generated successfully!';
          // Reset form
          _selectedExpiresAt = null;
          _expiresAtController.clear();
          _maxUsesController.clear();
          _maxUses = null;
        });
        // Reload existing QR codes
        _loadExistingQrCodes();
      } else {
        setState(() {
          _errorMessage =
              responseData['message'] ?? 'Failed to generate QR code';
          _isGenerating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isGenerating = false;
      });
    }
  }

  Future<void> _deactivateQrCode(int qrId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Deactivate QR Code',
          style: TextStyles.heading,
        ),
        content: Text(
          'Are you sure you want to deactivate this QR code?',
          style: TextStyles.regularwhite,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyles.regularwhite,
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Deactivate',
              style: TextStyles.regularwhite.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      HapticUtils.buttonPress();
      final response = await _qrService.deactivateQrCode(qrId);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        Get.snackbar(
          'Success',
          'QR code deactivated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.blueColor,
          colorText: Colors.white,
        );
        // Reload QR codes
        _loadExistingQrCodes();
      } else {
        Get.snackbar(
          'Error',
          responseData['message'] ?? 'Failed to deactivate QR code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to deactivate QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadQrCode() async {
    try {
      HapticUtils.buttonPress();
      final image = await _captureWidget();
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/payment_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      await imageFile.writeAsBytes(byteData.buffer.asUint8List());

      Get.snackbar(
        'Success',
        'QR code saved to Documents',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.blueColor,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _shareQrCode() async {
    try {
      HapticUtils.buttonPress();
      final image = await _captureWidget();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/payment_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      await imageFile.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Scan this QR code to purchase tickets!',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share QR code: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<ui.Image?> _captureWidget() async {
    try {
      final RenderRepaintBoundary boundary = _qrCodeKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      return image;
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }
}
