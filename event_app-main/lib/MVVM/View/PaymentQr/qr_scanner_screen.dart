import 'dart:convert';
import 'dart:ui';
import 'package:event_app/MVVM/View/bookEvent/book_event_screen.dart';
import 'package:event_app/Services/payment_qr_service.dart';
import 'package:event_app/app/config/app_colors.dart';
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
        'Camera Access',
        'Camera permission is needed to scan QR codes.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: EdgeInsets.all(4.w),
        borderRadius: 1.5.h,
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

      try {
        final jsonData = json.decode(rawValue);
        if (jsonData is Map && jsonData.containsKey('app')) {
          deepLinkUrl = jsonData['app'] as String;
        } else if (jsonData is Map && jsonData.containsKey('web')) {
          deepLinkUrl = jsonData['web'] as String;
        }
      } catch (e) {
        deepLinkUrl = rawValue;
      }

      final uri = Uri.parse(deepLinkUrl);

      if (uri.scheme != 'eventgo' || uri.host != 'pay') {
        throw Exception(
            'Invalid QR code format. Please scan a valid EventGo payment QR code.');
      }

      final eventId = int.parse(uri.queryParameters['eventId'] ?? '0');
      final ticketType = uri.queryParameters['ticketType'] ?? 'general';
      final token = uri.queryParameters['token'] ?? '';

      if (eventId == 0 || token.isEmpty) {
        throw Exception('Missing required parameters in QR code');
      }

      final response = await _qrService.validatePaymentQr(
        token: token,
        eventId: eventId,
        ticketType: ticketType,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final eventData = responseData['data'];

        Get.back();
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
        'Scan Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: EdgeInsets.all(4.w),
        borderRadius: 1.5.h,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
            _buildPermissionPlaceholder(),

          // 🔷 Custom Glassmorphic Overlay
          if (_hasPermission) ...[
            _buildScannerOverlay(),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildHeader(),
            ),
            Positioned(
              bottom: 10.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3.h),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    'Align QR code within the frame',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],

          // 🔷 Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.blueColor),
                      SizedBox(height: 2.h),
                      const Text('Validating...',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 1.5.h,
              left: 4.w,
              right: 4.w),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: const Border(
              bottom: BorderSide(color: Colors.white10, width: 0.5),
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
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16.sp),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Scan QR Code',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
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

  Widget _buildScannerOverlay() {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.7),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3.h),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.blueColor, width: 2),
              borderRadius: BorderRadius.circular(3.h),
            ),
            child: Stack(
              children: [
                // Corner Accents
                _buildCorner(0, 0, 0, 0), // Top Left
                _buildCorner(0, null, null, 0), // Top Right
                _buildCorner(null, 0, 0, null), // Bottom Left
                _buildCorner(null, null, null, null), // Bottom Right
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(
      double? top, double? bottom, double? left, double? right) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          border: Border(
            top: top == 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            bottom: bottom == 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            left: left == 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            right: right == 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top == 0 && left == 0 ? Radius.circular(3.h) : Radius.zero,
            topRight:
                top == 0 && right == 0 ? Radius.circular(3.h) : Radius.zero,
            bottomLeft:
                bottom == 0 && left == 0 ? Radius.circular(3.h) : Radius.zero,
            bottomRight:
                bottom == 0 && right == 0 ? Radius.circular(3.h) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionPlaceholder() {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt_rounded,
                size: 60.sp, color: Colors.white24),
          ),
          SizedBox(height: 4.h),
          Text('Camera Access Needed',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              'We need camera permission to scan ticket QR codes and process your payment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 11.sp),
            ),
          ),
          SizedBox(height: 5.h),
          GestureDetector(
            onTap: _checkCameraPermission,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(4.h),
              ),
              child: const Text('Grant Permission',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
