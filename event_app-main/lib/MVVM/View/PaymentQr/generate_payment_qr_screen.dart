import 'dart:convert';
import 'dart:ui' as ui;
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
  State<GeneratePaymentQrScreen> createState() => _GeneratePaymentQrScreenState();
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
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Generate Payment QR',
          style: TextStyles.heading,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Description
            Text(
              'Generate a QR code for your event. Users can scan it to quickly purchase tickets.',
              style: TextStyles.regularwhite.copyWith(
                fontSize: 11.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 3.h),

            // Success Message
            if (_successMessage != null)
              Container(
                padding: EdgeInsets.all(3.w),
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2.h),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyles.regularwhite.copyWith(color: Colors.green),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.green, size: 20),
                      onPressed: () {
                        setState(() {
                          _successMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(3.w),
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2.h),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyles.regularwhite.copyWith(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            // Generate Form
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C23),
                borderRadius: BorderRadius.circular(2.h),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ticket Type Dropdown
                  Text(
                    'Ticket Type',
                    style: TextStyles.regularwhite.copyWith(fontSize: 12.sp),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(2.h),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedTicketType,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2.h),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      dropdownColor: AppColors.backgroundColor,
                      style: TextStyles.regularwhite,
                      items: const [
                        DropdownMenuItem(value: 'general', child: Text('General Admission')),
                        DropdownMenuItem(value: 'vip', child: Text('VIP (Very Important Person)')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTicketType = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Expires At (Optional)
                  Text(
                    'Expires At (Optional)',
                    style: TextStyles.regularwhite.copyWith(fontSize: 12.sp),
                  ),
                  SizedBox(height: 1.h),
                  GestureDetector(
                    onTap: _selectExpiresAt,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(2.h),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedExpiresAt != null
                                  ? DateFormat('yyyy-MM-dd HH:mm').format(_selectedExpiresAt!)
                                  : 'Leave empty for no expiration',
                              style: TextStyles.regularwhite.copyWith(
                                color: _selectedExpiresAt != null ? Colors.white : Colors.white54,
                              ),
                            ),
                          ),
                          if (_selectedExpiresAt != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                              onPressed: () {
                                setState(() {
                                  _selectedExpiresAt = null;
                                  _expiresAtController.clear();
                                });
                              },
                            ),
                          const Icon(Icons.calendar_today, color: Colors.white54),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Leave empty for no expiration',
                    style: TextStyles.regularwhite.copyWith(
                      fontSize: 9.sp,
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Max Uses (Optional)
                  Text(
                    'Max Uses (Optional)',
                    style: TextStyles.regularwhite.copyWith(fontSize: 12.sp),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _maxUsesController,
                    keyboardType: TextInputType.number,
                    style: TextStyles.regularwhite,
                    decoration: InputDecoration(
                      hintText: 'Leave empty for unlimited uses',
                      hintStyle: TextStyles.regularwhite.copyWith(color: Colors.white54),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                      contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.h),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _maxUses = value.isEmpty ? null : int.tryParse(value);
                      });
                    },
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Leave empty for unlimited uses',
                    style: TextStyles.regularwhite.copyWith(
                      fontSize: 9.sp,
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Generate Button
                  ElevatedButton(
                    onPressed: _isGenerating ? null : _generateQrCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.h),
                      ),
                    ),
                    child: _isGenerating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code, color: Colors.white),
                              SizedBox(width: 2.w),
                              Text(
                                'Generate QR Code',
                                style: TextStyles.buttontext.copyWith(fontSize: 14.sp),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            // New QR Code Display (if just generated)
            if (_newQrData != null) ...[
              SizedBox(height: 3.h),
              _buildQrCodeDisplay(_newQrData!),
              SizedBox(height: 2.h),
              _buildActionButtons(_newQrData!),
            ],

            // Existing QR Codes List
            if (_existingQrCodes.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Divider(color: Colors.white24),
              SizedBox(height: 2.h),
              Text(
                'Existing QR Codes',
                style: TextStyles.subheading,
              ),
              SizedBox(height: 2.h),
              _buildExistingQrCodesList(),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectExpiresAt() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedExpiresAt ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedExpiresAt = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _expiresAtController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedExpiresAt!);
        });
      }
    }
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

  Widget _buildQrCodeDisplay(Map<String, dynamic> qrData) {
    final qrCodeData = qrData['qrCodeData'];
    Map<String, dynamic> qrDataMap;
    
    try {
      qrDataMap = json.decode(qrCodeData);
    } catch (e) {
      qrDataMap = {'web': qrCodeData, 'app': qrCodeData};
    }
    
    // Use web URL for QR code (works with all scanners, including iPhone)
    final qrString = qrDataMap['web'] ?? (qrDataMap['app'] ?? qrCodeData);

    return RepaintBoundary(
      key: _qrCodeKey,
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.h),
        ),
        child: Column(
          children: [
            QrImageView(
              data: qrString,
              version: QrVersions.auto,
              size: 60.w,
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 2.h),
            _buildTicketTypeBadge(qrData['ticketType']),
            SizedBox(height: 1.h),
            Text(
              'Price: \$${qrData['price'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black87,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketTypeBadge(String ticketType) {
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
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(2.h),
      ),
      child: Text(
        ticketType.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> qrData) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _downloadQrCode,
            icon: const Icon(Icons.download, color: Colors.white),
            label: Text('Download', style: TextStyles.buttontext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareQrCode,
            icon: const Icon(Icons.share, color: Colors.white),
            label: Text('Share', style: TextStyles.buttontext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueColor,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
          ),
        ),
      ],
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
    
    // Use web URL for QR code (works with all scanners, including iPhone)
    final qrString = qrDataMap['web'] ?? (qrDataMap['app'] ?? qrCodeData);
    final ticketType = qr['ticketType'] ?? 'general';
    final currentUses = qr['currentUses'] ?? 0;
    final maxUses = qr['maxUses'];
    final expiresAt = qr['expiresAt'];

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.h),
      ),
      child: Column(
        children: [
          QrImageView(
            data: qrString,
            version: QrVersions.auto,
            size: 50.w,
            backgroundColor: Colors.white,
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTicketTypeBadge(ticketType),
              if (maxUses != null && currentUses >= maxUses) ...[
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(1.h),
                  ),
                  child: Text(
                    'LIMIT REACHED',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (expiresAt != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              'Expires: ${DateFormat('MMM d, y HH:mm').format(DateTime.parse(expiresAt))}',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black87,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () => _deactivateQrCode(qr['qrId']),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.h),
              ),
            ),
            child: Text(
              'Deactivate',
              style: TextStyles.buttontext.copyWith(fontSize: 11.sp),
            ),
          ),
        ],
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
        expiresAtString = DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedExpiresAt!);
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
          _errorMessage = responseData['message'] ?? 'Failed to generate QR code';
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
      final imagePath = '${directory.path}/payment_qr_${DateTime.now().millisecondsSinceEpoch}.png';
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
      final imagePath = '${directory.path}/payment_qr_${DateTime.now().millisecondsSinceEpoch}.png';
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
      final RenderRepaintBoundary boundary =
          _qrCodeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      return image;
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }
}

