import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';

class AppAccessibilityService {
  static final AppAccessibilityService _instance = AppAccessibilityService._internal();
  factory AppAccessibilityService() => _instance;
  AppAccessibilityService._internal();

  final List<String> _monitoredApps = ['com.whatsapp', 'com.instagram.android'];
  bool _isOverlayVisible = false;

  Future<void> initialize() async {
    // Request accessibility permission
    final bool hasPermission = await FlutterAccessibilityService.requestAccessibilityPermission();
    if (!hasPermission) {
      debugPrint('Accessibility permission not granted');
      return;
    }

    // Listen to accessibility events
    FlutterAccessibilityService.accessStream.listen((event) {
      if (event.packageName != null && _monitoredApps.contains(event.packageName)) {
        if (event.eventType == 0x00000004 && !_isOverlayVisible) { // typeWindowStateChanged
          _showOverlay(event.packageName!);
        }
      }
    });
  }

  Future<void> _showOverlay(String packageName) async {
    _isOverlayVisible = true;
    await FlutterAccessibilityService.showOverlayWindow();
    
    // Wait for user response
    bool? userResponse;
    while (userResponse == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!userResponse) {
      // If user clicked "Not Okay", go back
      final actions = await FlutterAccessibilityService.getSystemActions();
      if (actions.isNotEmpty) {
        await FlutterAccessibilityService.performGlobalAction(actions.first);
      }
    }

    await FlutterAccessibilityService.hideOverlayWindow();
    _isOverlayVisible = false;
  }
} 