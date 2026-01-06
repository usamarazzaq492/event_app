import 'dart:convert';
import 'package:event_app/Services/ticket_checkin_service.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

class TicketCheckInScanner extends StatefulWidget {
  const TicketCheckInScanner({super.key});

  @override
  State<TicketCheckInScanner> createState() => _TicketCheckInScannerState();
}

class _TicketCheckInScannerState extends State<TicketCheckInScanner> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  bool _hasPermission = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    try {
      // Check camera permission first
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        // Permission already granted, initialize scanner
        _controller = MobileScannerController();
        setState(() {
          _hasPermission = true;
          _isInitializing = false;
        });
      } else {
        // Request permission
        final requestResult = await Permission.camera.request();
        if (requestResult.isGranted) {
          _controller = MobileScannerController();
          setState(() {
            _hasPermission = true;
            _isInitializing = false;
          });
        } else {
          setState(() {
            _hasPermission = false;
            _isInitializing = false;
          });
          if (mounted) {
            Get.snackbar(
              'Camera Permission Required',
              'Please grant camera permission to scan ticket QR codes',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      }
    } catch (e) {
      print('Error initializing scanner: $e');
      setState(() {
        _hasPermission = false;
        _isInitializing = false;
      });
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to initialize camera. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted && _controller == null) {
        _controller = MobileScannerController();
      }
      setState(() {
        _hasPermission = status.isGranted;
      });
      if (!_hasPermission) {
        Get.snackbar(
          'Camera Permission Required',
          'Please grant camera permission to scan ticket QR codes',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error requesting camera permission: $e');
      Get.snackbar(
        'Error',
        'Failed to request camera permission. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleQrCode(String rawValue) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    HapticUtils.success();

    try {
      // Clean and prepare the QR code data
      String cleanedValue = rawValue.trim();
      
      print('🔍 Scanned QR Code - Raw value: $rawValue');
      print('🔍 Scanned QR Code - Length: ${rawValue.length}');
      
      // Try URL decoding in case the QR code was URL-encoded
      try {
        final decoded = Uri.decodeComponent(cleanedValue);
        if (decoded != cleanedValue) {
          print('🔍 URL decoded QR code');
          cleanedValue = decoded;
        }
      } catch (e) {
        // If URL decoding fails, use original value
        print('⚠️ URL decode failed, using original: $e');
      }

      // Try to parse as JSON (ticket QR codes are JSON strings)
      Map<String, dynamic>? qrData;
      String qrDataString = cleanedValue;
      
      try {
        // First, try parsing directly
        qrData = jsonDecode(cleanedValue);
        print('✅ Successfully parsed QR code as JSON');
        print('🔍 QR Data keys: ${qrData?.keys.toList() ?? []}');
      } catch (e) {
        print('⚠️ Direct JSON parse failed: $e');
        // If direct parsing fails, try parsing as a string that contains JSON
        try {
          // Remove any surrounding quotes if present
          if (cleanedValue.startsWith('"') && cleanedValue.endsWith('"')) {
            cleanedValue = cleanedValue.substring(1, cleanedValue.length - 1);
            // Unescape JSON string
            cleanedValue = cleanedValue.replaceAll('\\"', '"').replaceAll('\\\\', '\\');
            print('🔍 Removed surrounding quotes');
          }
          qrData = jsonDecode(cleanedValue);
          qrDataString = cleanedValue;
          print('✅ Successfully parsed QR code after cleaning');
        } catch (e2) {
          print('❌ QR Code parsing error: $e2');
          print('📋 Raw QR value: $rawValue');
          print('📋 Cleaned value: $cleanedValue');
          print('📋 First 100 chars: ${cleanedValue.length > 100 ? cleanedValue.substring(0, 100) : cleanedValue}');
          throw Exception('Invalid QR code format. Please scan a valid ticket QR code.\n\nScanned: ${cleanedValue.length > 50 ? cleanedValue.substring(0, 50) + "..." : cleanedValue}\n\nError: ${e2.toString()}');
        }
      }

      // Verify required fields
      if (qrData == null || !qrData.containsKey('booking_id')) {
        print('Missing booking_id in QR data: $qrData');
        throw Exception('Invalid ticket QR code format. Missing booking_id.');
      }

      // Check if this is old format (missing ticket_num and hash)
      final bool isOldFormat = !qrData.containsKey('ticket_num') || !qrData.containsKey('hash');
      
      if (isOldFormat) {
        print('⚠️ Old format QR code detected (missing ticket_num or hash)');
        print('📋 QR Data: $qrData');
        // Still try to check in - backend will handle old format
        // But show a warning to the user
      } else {
        print('✅ New format QR code detected (has ticket_num and hash)');
      }

      // Use the cleaned JSON string for the API call
      // Check in the ticket
      final result = await TicketCheckInService.checkInTicket(qrDataString);

      if (result['success'] == true) {
        // Success - ticket checked in
        final data = result['data'];
        HapticUtils.success();
        
        Get.snackbar(
          '✅ Ticket Checked In',
          'Ticket #${data['ticket_number']} checked in successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // Show success dialog with details
        _showCheckInSuccess(data);
      } else {
        // Error - might be already checked in
        final message = result['message'] ?? 'Failed to check in ticket';
        final checkedInAt = result['checked_in_at'];
        final warning = result['warning'];

        HapticUtils.error();

        // Show warning dialog for duplicate check-in
        _showDuplicateWarning(message, checkedInAt, warning);
      }
    } catch (e) {
      HapticUtils.error();
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showCheckInSuccess(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.signinoptioncolor,
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Text(
              'Ticket Checked In',
              style: TextStyles.heading.copyWith(color: Colors.green),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Ticket Number', data['ticket_number'] ?? 'N/A'),
            const SizedBox(height: 10),
            _buildInfoRow('Attendee', data['user_name'] ?? 'Unknown'),
            if (data['user_email'] != null) ...[
              const SizedBox(height: 10),
              _buildInfoRow('Email', data['user_email']),
            ],
            const SizedBox(height: 10),
            _buildInfoRow('Checked In At', data['checked_in_at'] ?? 'Now'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: TextStyles.buttontext.copyWith(color: AppColors.blueColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showDuplicateWarning(String message, String? checkedInAt, String? warning) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.signinoptioncolor,
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ticket Already Checked In',
                style: TextStyles.heading.copyWith(color: Colors.orange),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyles.regularwhite,
            ),
            if (checkedInAt != null) ...[
              const SizedBox(height: 15),
              _buildInfoRow('First Checked In', checkedInAt),
            ],
            if (warning != null) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        warning,
                        style: TextStyles.regularwhite.copyWith(
                          color: Colors.orangeAccent,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: TextStyles.buttontext.copyWith(color: AppColors.blueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyles.regularwhite.copyWith(
              color: Colors.grey,
              fontSize: 12.sp,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyles.regularwhite.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan Ticket QR Code',
          style: TextStyles.heading,
        ),
      ),
      body: Stack(
        children: [
          if (_isInitializing)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueColor),
              ),
            )
          else if (_hasPermission && _controller != null)
            MobileScanner(
              controller: _controller!,
              onDetect: (capture) {
                if (_isProcessing) return; // Prevent multiple scans
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _handleQrCode(barcode.rawValue!);
                    break; // Process only first QR code
                  }
                }
              },
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Camera Permission Required',
                    style: TextStyles.heading,
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: _checkCameraPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                    ),
                    child: Text(
                      'Grant Permission',
                      style: TextStyles.buttontext,
                    ),
                  ),
                ],
              ),
            ),

          // Overlay with scanning frame
          if (_hasPermission && !_isInitializing)
            Center(
              child: Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.blueColor,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(2.h),
                ),
              ),
            ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueColor),
                ),
              ),
            ),

          // Instructions overlay
          if (_hasPermission && !_isProcessing && !_isInitializing)
            Positioned(
              bottom: 5.h,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4.w),
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2.h),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Point camera at ticket QR code',
                      style: TextStyles.regularwhite.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'The ticket will be marked as checked in automatically',
                      style: TextStyles.regularwhite.copyWith(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

