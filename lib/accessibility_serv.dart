import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'dart:async';
import 'overlay_screen.dart';

class AccessibilityService {
  static final AccessibilityService _instance =
      AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  final List<String> _monitoredApps = ['com.whatsapp', 'com.instagram.android'];
  bool _isOverlayVisible = false;
  String? _currentPackageName;
  bool _showNotOkScreen = false;

  Future<void> initialize() async {
    // Initialize the accessibility service

    final bool hasPermission =
        await FlutterAccessibilityService.requestAccessibilityPermission();
    if (!hasPermission) {
      debugPrint('Accessibility permission not granted');
      return;
    }

    // Listen to accessibility events
    FlutterAccessibilityService.accessStream.listen((event) {
      // Print all app package names being opened
      if (event.packageName != null) {
        debugPrint('App opened: ${event.packageName}');
        debugPrint('Event type: ${event.eventType}');
      }

      // Check for monitored apps
      if (event.packageName != null &&
          _monitoredApps.contains(event.packageName)) {
        debugPrint('Monitored app detected: ${event.packageName}');

        // Show overlay for window state changes (app coming to foreground)
        if (event.eventType == EventType.typeWindowStateChanged &&
            !_isOverlayVisible) {
          debugPrint(
              'Window state changed - showing overlay for: ${event.packageName}');
          _showOverlay(event.packageName!);
        }
        // Also trigger on window content changes if window state change doesn't work
        else if (event.eventType == EventType.typeWindowContentChanged &&
            !_isOverlayVisible &&
            _currentPackageName != event.packageName) {
          debugPrint(
              'Window content changed - showing overlay for: ${event.packageName}');
          _showOverlay(event.packageName!);
        }
      }
    });
  }

  Future<void> _showOverlay(String packageName) async {
    if (_isOverlayVisible) {
      debugPrint('Overlay already visible, skipping');
      return;
    }

    debugPrint('=== SHOWING OVERLAY FOR: $packageName ===');
    _isOverlayVisible = true;
    _currentPackageName = packageName;
    _showNotOkScreen = false;

    try {
      debugPrint('Attempting to show overlay window...');
      await FlutterAccessibilityService.showOverlayWindow();
      debugPrint('Overlay window shown successfully');
    } catch (e) {
      debugPrint('Error in _showOverlay: $e');
      _isOverlayVisible = false;
      _currentPackageName = null;
    }
  }

  Future<void> _hideOverlay() async {
    debugPrint('=== HIDING OVERLAY ===');
    try {
      await FlutterAccessibilityService.hideOverlayWindow();
      debugPrint('Overlay window hidden successfully');
      _isOverlayVisible = false;
      _currentPackageName = null;
      _showNotOkScreen = false;
    } catch (e) {
      debugPrint('Error in _hideOverlay: $e');
    }
  }

  Future<void> showNotOkScreen() async {
    debugPrint('=== SHOWING NOT OK SCREEN ===');
    if (!_isOverlayVisible) {
      debugPrint('No overlay visible to transition from');
      return;
    }

    _showNotOkScreen = true;
    debugPrint('Not OK screen state updated');
  }

  Future<void> handleUserResponse(bool isOk) async {
    if (isOk) {
      debugPrint('=== HIDING OVERLAY FOR');
      await _hideOverlay();
    } else {
      try {
        debugPrint('=== HIDING OVERLAY FOR');
        await _hideOverlay();
        debugPrint('=== EXITING APP ===');
        Future.delayed(const Duration(seconds: 2), () {
          SystemNavigator.pop();
        });
        debugPrint('=== EXITING APP ===');

        FlutterExitApp.exitApp();
      } catch (e) {
        await _hideOverlay();
        debugPrint('Exit app failed: $e');
        SystemNavigator.pop();
      }
      debugPrint('App is closed');
    }
  }

  Widget getOverlayScreen() {
    debugPrint('Getting overlay screen. showNotOkScreen: $_showNotOkScreen');
    if (_showNotOkScreen) {
      return const NotOkOverlayScreen();
    }
    return OverlayScreen(appName: _currentPackageName ?? '');
  }
}
