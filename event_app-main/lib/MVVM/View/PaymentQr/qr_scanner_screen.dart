import 'dart:convert';
import 'package:event_app/MVVM/View/bookEvent/book_event_screen.dart';
import 'package:event_app/Services/payment_qr_service.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final PaymentQrService _qrService = PaymentQrService();
  bool _isProcessing = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
    if (!_hasPermission) {
      Get.snackbar(
        'Camera Permission Required',
        'Please grant camera permission to scan QR codes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleQrCode(String rawValue) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    HapticUtils.success();

    try {
      String deepLinkUrl = rawValue;
      
      // Check if the scanned value is JSON (in case QR code contains JSON)
      try {
        final jsonData = json.decode(rawValue);
        if (jsonData is Map && jsonData.containsKey('app')) {
          deepLinkUrl = jsonData['app'] as String;
        } else if (jsonData is Map && jsonData.containsKey('web')) {
          // Fallback to web URL if app link not available
          deepLinkUrl = jsonData['web'] as String;
        }
      } catch (e) {
        // Not JSON, use raw value as-is
        deepLinkUrl = rawValue;
      }

      // Parse the deep link
      // Format: eventgo://pay?eventId=123&ticketType=general&token=abc123...
      final uri = Uri.parse(deepLinkUrl);
      
      if (uri.scheme != 'eventgo' || uri.host != 'pay') {
        throw Exception('Invalid QR code format. Please scan a valid EventGo payment QR code.');
      }

      final eventId = int.parse(uri.queryParameters['eventId'] ?? '0');
      final ticketType = uri.queryParameters['ticketType'] ?? 'general';
      final token = uri.queryParameters['token'] ?? '';

      if (eventId == 0 || token.isEmpty) {
        throw Exception('Missing required parameters in QR code');
      }

      // Validate QR code with backend
      final response = await _qrService.validatePaymentQr(
        token: token,
        eventId: eventId,
        ticketType: ticketType,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final eventData = responseData['data'];
        
        // Navigate to booking screen with pre-filled data
        Get.back(); // Close scanner
        Get.to(
          () => BookEventScreen(
            id: eventId,
            preFilledTicketType: ticketType,
            preFilledPrice: eventData['price']?.toDouble() ?? 0.0,
          ),
        );
      } else {
        throw Exception(responseData['message'] ?? 'Invalid QR code');
      }
    } catch (e) {
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
          'Scan Payment QR Code',
          style: TextStyles.heading,
        ),
      ),
      body: Stack(
        children: [
          if (_hasPermission)
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _handleQrCode(barcode.rawValue!);
                    break;
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
          if (_hasPermission)
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
        ],
      ),
    );
  }
}

