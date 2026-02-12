import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://eventgo-live.com/terms'));
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
          'Terms & Conditions',
          style: TextStyles.heading.copyWith(fontSize: 14.sp),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User-Generated Content Policy (Guideline 1.2)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User-Generated Content Policy',
                      style: TextStyles.heading.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      'EventGo has zero tolerance for objectionable content or abusive users. By using this app, you agree to:',
                      style: TextStyles.regulartext.copyWith(
                        fontSize: 11.sp,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    _buildUgcBullet(
                        'Not post content that is offensive, harmful, or inappropriate.'),
                    _buildUgcBullet(
                        'Report any objectionable content or abusive behavior you encounter.'),
                    _buildUgcBullet(
                        'Use the block feature to prevent abusive users from appearing in your feed.'),
                    _buildUgcBullet(
                        'Understand that we act on reports within 24 hours by removing content and taking action against offending accounts.'),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
              Divider(color: Colors.white24, height: 1),
              SizedBox(
                height: 60.h,
                child: WebViewWidget(controller: _controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUgcBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyles.regulartext.copyWith(
              fontSize: 11.sp,
              color: Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyles.regulartext.copyWith(
                fontSize: 11.sp,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
