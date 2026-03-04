import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_app/Services/square_connect_service.dart';
import 'package:event_app/app/config/app_colors.dart';
import 'package:event_app/app/config/app_text_style.dart';
import 'package:event_app/utils/haptic_utils.dart';

class SquareOAuthWebView extends StatefulWidget {
  const SquareOAuthWebView({super.key});

  @override
  State<SquareOAuthWebView> createState() => _SquareOAuthWebViewState();
}

class _SquareOAuthWebViewState extends State<SquareOAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _oauthUrl;
  bool _hasError = false;
  String? _errorMessage;
  double _loadProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebview();
  }

  Future<void> _initializeWebview() async {
    try {
      final result = await SquareConnectService.getOAuthUrl();

      if (result['success'] == true && result['oauth_url'] != null) {
        _oauthUrl = result['oauth_url'] as String;

        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(AppColors.backgroundColor)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                debugPrint('Page started loading: $url');
                if (mounted) setState(() => _isLoading = true);
              },
              onProgress: (int progress) {
                if (mounted) setState(() => _loadProgress = progress / 100);
              },
              onPageFinished: (String url) {
                debugPrint('Page finished loading: $url');
                if (mounted) setState(() => _isLoading = false);

                // Detect completion - usually server redirects to a success page
                if (url.contains('success') || url.contains('connected')) {
                  debugPrint('Success detected on page finished: $url');
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) Navigator.of(context).pop(true);
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('Square Webview Error: ${error.description}');
                debugPrint('Error Type: ${error.errorType}');
                debugPrint('Failing URL: ${error.url}');
              },
              onNavigationRequest: (NavigationRequest request) {
                debugPrint('Navigating to: ${request.url}');

                // Detection of success redirect
                if (request.url.contains('success') ||
                    request.url.contains('connected')) {
                  debugPrint(
                      'Success detected in navigation request: ${request.url}');
                  Navigator.of(context).pop(true);
                  return NavigationDecision.prevent;
                }

                // IMPORTANT: Allow the callback URL to load so the backend gets the code!
                if (request.url.contains('callback')) {
                  debugPrint('Allowing callback URL: ${request.url}');
                  return NavigationDecision.navigate;
                }

                // Handle about:blank or other system pages
                if (request.url.startsWith('about:')) {
                  return NavigationDecision.navigate;
                }

                if (request.url.startsWith('http')) {
                  return NavigationDecision.navigate;
                }

                return NavigationDecision.prevent;
              },
            ),
          )
          ..loadRequest(Uri.parse(_oauthUrl!));

        if (mounted) {
          setState(() {
            _hasError = false;
          });
        }
      } else {
        _handleError(result['error'] ?? 'Failed to load authentication page');
      }
    } catch (e) {
      _handleError('Unexpected error: $e');
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = message;
      });
    }
  }

  Future<void> _launchInBrowser() async {
    if (_oauthUrl != null) {
      HapticUtils.buttonPress();
      final uri = Uri.parse(_oauthUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          Navigator.of(context)
              .pop(); // Close webview screen as user is in browser
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening connection in browser...'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          /// Glassmorphic Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 1.h,
              left: 4.w,
              right: 4.w,
              bottom: 2.h,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor,
                  AppColors.backgroundColor,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () {
                    HapticUtils.navigation();
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  'Square Connection',
                  style: TextStyles.heading.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_browser, color: Colors.blue),
                  onPressed: _launchInBrowser,
                  tooltip: 'Open in Browser',
                ),
              ],
            ),
          ),

          /// Progress Bar
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadProgress > 0 ? _loadProgress : null,
              backgroundColor: Colors.transparent,
              color: AppColors.blueColor,
              minHeight: 2,
            ),

          /// Main Content
          Expanded(
            child: _hasError
                ? _buildErrorView()
                : (_oauthUrl == null
                    ? _buildLoadingView()
                    : Stack(
                        children: [
                          WebViewWidget(controller: _controller),
                          if (_isLoading && _loadProgress < 0.1)
                            _buildLoadingView(),
                        ],
                      )),
          ),

          /// Troubleshooting Footer
          if (!_hasError && _oauthUrl != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.5.h),
              child: TextButton(
                onPressed: _launchInBrowser,
                child: Text(
                  'Blank Screen? Open in Browser instead',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: AppColors.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.blueColor),
            SizedBox(height: 3.h),
            Text(
              'Preparing Square connection...',
              style: TextStyles.regularwhite.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.red.shade400, size: 48.sp),
            SizedBox(height: 3.h),
            Text(
              'Connection Failed',
              style: TextStyles.heading.copyWith(fontSize: 18.sp),
            ),
            SizedBox(height: 1.5.h),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyles.regularwhite.copyWith(color: Colors.white70),
            ),
            SizedBox(height: 5.h),
            SizedBox(
              width: 50.w,
              child: ElevatedButton(
                onPressed: () {
                  HapticUtils.buttonPress();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
                child: Text('Go Back', style: TextStyles.buttontext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
