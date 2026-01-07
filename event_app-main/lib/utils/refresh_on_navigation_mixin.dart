import 'package:flutter/material.dart';

/// Mixin that automatically refreshes data when the screen becomes visible
/// 
/// Usage:
/// ```dart
/// class MyScreen extends StatefulWidget {
///   @override
///   State<MyScreen> createState() => _MyScreenState();
/// }
/// 
/// class _MyScreenState extends State<MyScreen> with RefreshOnNavigation {
///   @override
///   void refreshData() {
///     // Call your refresh methods here
///     controller.fetchData();
///   }
/// }
/// ```
mixin RefreshOnNavigation<T extends StatefulWidget> on State<T> {
  bool _isInitialized = false;
  bool _hasRefreshed = false;
  
  /// Override this method to define what should be refreshed
  void refreshData();

  @override
  void initState() {
    super.initState();
    _isInitialized = true;
    // Refresh on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        refreshData();
        _hasRefreshed = true;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when screen becomes visible again (after being hidden)
    if (_isInitialized && !_hasRefreshed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          refreshData();
          _hasRefreshed = true;
        }
      });
    }
  }

  @override
  void deactivate() {
    // Reset flag when screen is deactivated (navigated away from)
    _hasRefreshed = false;
    super.deactivate();
  }

  @override
  void activate() {
    // Screen is becoming active again (navigated back to)
    super.activate();
    // Refresh when coming back to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        refreshData();
        _hasRefreshed = true;
      }
    });
  }
}
