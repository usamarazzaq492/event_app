import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://eventgo-live.com/privacy'));
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
          onPressed: () {
            HapticUtils.navigation();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyles.heading.copyWith(fontSize: 14.sp),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
