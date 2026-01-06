import 'package:flutter/material.dart';
import 'package:event_app/Services/square_connect_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SquareOAuthWebView extends StatefulWidget {
  const SquareOAuthWebView({super.key});

  @override
  State<SquareOAuthWebView> createState() => _SquareOAuthWebViewState();
}

class _SquareOAuthWebViewState extends State<SquareOAuthWebView> {
  bool isLoading = true;
  String? oauthUrl;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('SquareOAuthWebView: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('SquareOAuthWebView: PostFrameCallback - starting to load URL');
      _loadOAuthUrl();
    });
  }

  Future<void> _loadOAuthUrl() async {
    print('SquareOAuthWebView: _loadOAuthUrl called');
    try {
      print('SquareOAuthWebView: Calling SquareConnectService.getOAuthUrl()');
      final result = await SquareConnectService.getOAuthUrl();
      print('SquareOAuthWebView: Result received: ${result['success']}');
      print('SquareOAuthWebView: Full result: $result');

      if (result['success'] == true && result['oauth_url'] != null) {
        final url = result['oauth_url'] as String;
        print('SquareOAuthWebView: URL is valid: $url');
        if (mounted) {
          setState(() {
            oauthUrl = url;
            isLoading = false;
            hasError = false;
          });
          print('SquareOAuthWebView: State updated with URL');
        }
        // Don't auto-open - let user tap the button
        // This ensures they can see the button and manually open if needed
        print('SquareOAuthWebView: URL loaded, showing button for user to tap');
      } else {
        // Handle error from service
        final errorType = result['error_type'] ?? 'unknown';
        final errorMsg =
            result['error'] ?? 'Failed to load Square connection page';
        final statusCode = result['status_code'];

        print(
            'SquareOAuthWebView: Error received - Type: $errorType, Message: $errorMsg');

        String displayError = errorMsg.toString();
        if (statusCode != null) {
          displayError = 'Server Error $statusCode: $errorMsg';
        } else if (errorType == 'network') {
          displayError =
              'Network Error: $errorMsg\n\nPlease check your internet connection.';
        } else if (errorType == 'auth') {
          displayError =
              'Authentication Error: $errorMsg\n\nPlease log out and log back in.';
        }

        if (mounted) {
          setState(() {
            isLoading = false;
            hasError = true;
            errorMessage = displayError;
          });
          print('SquareOAuthWebView: State updated with error');
        }
      }
    } catch (e, stackTrace) {
      print('SquareOAuthWebView: Exception in _loadOAuthUrl: $e');
      print('SquareOAuthWebView: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Unexpected error: $e';
        });
        print('SquareOAuthWebView: State updated with exception error');
      }
    }
  }

  Future<void> _openInExternalBrowser(String url) async {
    try {
      final uri = Uri.parse(url);
      print('Square OAuth: Attempting to open URL in external browser: $url');

      bool launched = false;

      // Try launching directly - canLaunchUrl can return false on Android even for valid URLs
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print(
            'Square OAuth: launchUrl (externalApplication) returned: $launched');
      } catch (e) {
        print('Square OAuth: Exception with externalApplication: $e');
        // Try with platformDefault mode as fallback
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
          print(
              'Square OAuth: launchUrl (platformDefault) returned: $launched');
        } catch (e2) {
          print('Square OAuth: Exception with platformDefault: $e2');
        }
      }

      if (launched) {
        print('Square OAuth: launchUrl returned true - browser should open');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Opening Square connection in your browser. If it doesn\'t open, tap the button below.'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.blue,
            ),
          );
          // Don't auto-close - let user see the button in case browser didn't open
        }
      } else {
        print('Square OAuth: launchUrl returned false - showing manual option');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Could not open browser automatically. Please tap the "Open in Browser" button below.'),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error opening external browser: $e');
      if (mounted) {
        setState(() {
          hasError = false; // Show manual option instead of error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Could not open automatically. Please use the button below. Error: $e'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'SquareOAuthWebView: build called - isLoading: $isLoading, hasError: $hasError, oauthUrl: ${oauthUrl != null ? "exists" : "null"}');

    // Always show something - never return empty
    Widget bodyWidget;

    if (isLoading) {
      print('SquareOAuthWebView: Rendering loading state');
      bodyWidget = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Loading Square connection...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    } else if (hasError) {
      print('SquareOAuthWebView: Rendering error state');
      bodyWidget = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    } else if (oauthUrl != null) {
      print('SquareOAuthWebView: Rendering URL state with button');
      bodyWidget = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.link, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Connect Your Square Account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the button below to open Square connection in your browser.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 18, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Sandbox Account Setup',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If the Square page is blank on mobile Chrome:\n\n1. Tap menu (⋮) → "Desktop site" → Reload\n2. Try incognito/private mode\n3. Clear Chrome cache\n4. Try Firefox or Edge browser\n5. Make sure test account is launched in Square Console',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  print('SquareOAuthWebView: Manual button pressed');
                  await _openInExternalBrowser(oauthUrl!);
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open in Browser'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Show URL for manual copy
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link, size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Troubleshooting:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If the page is blank on mobile, copy this URL and paste it in Chrome or Firefox:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      oauthUrl!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );
    } else {
      // Fallback - should never reach here, but just in case
      print('SquareOAuthWebView: Rendering fallback state');
      bodyWidget = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Initializing...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Square Account'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: bodyWidget,
    );
  }
}
