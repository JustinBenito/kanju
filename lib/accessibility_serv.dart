import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:math';
import 'app_usage_tracker.dart';

class AccessibilityService {
  static final AccessibilityService _instance =
      AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AppUsageTracker _usageTracker = AppUsageTracker();
  final Random _random = Random();

  final Map<String, String> _monitoredApps = {
    'com.google.android.apps.nbu.paisa.user': 'Google Pay',
    'com.phonepe.app': 'PhonePe',
    'net.one97.paytm': 'Paytm',
    'in.org.npci.upiapp': 'BHIM',
    'in.amazon.mShop.android.shopping': 'Amazon Pay',
    'com.whatsapp': 'WhatsApp',
    'com.mobikwik_new': 'Mobikwik',
    'com.freecharge.android': 'Freecharge',
    'com.tatadigital.tcp.dev': 'Tata Neu',
    'com.dreamplug.androidapp': 'CRED',
    'com.bajajfinserv.upi': 'Bajaj Pay UPI',
    'com.jio.myjio': 'Jio Pay',
    'com.myairtelapp': 'Airtel Thanks',
    'com.msf.kbank.mobile': 'Kotak UPI App',
    'com.sbi.SBIFreedomPlus': 'SBI YONO',
    'com.enstage.wibmo.hdfc': 'HDFC PayZapp',
    'com.csam.icici.bank.imobile': 'ICICI iMobile',
    'com.axis.mobile': 'Axis Mobile',
    'com.bankofbaroda.mpassbook': 'Bank of Baroda',
    'com.bob.banking': 'Bank of Baroda',
  };

  final List<String> _insultingMessages = [
    "Idiot, don't use {app}! You'll end up broke!",
    "Stop being a moron! Close {app} right now!",
    "Are you really that stupid? {app} will drain your bank account!",
    "Your brain cells are dying every time you open {app}!",
    "You're a financial disaster waiting to happen with {app}!",
    "Your wallet is crying because you opened {app}!",
    "Your bank account is having a panic attack because of {app}!",
    "Your future self hates you for using {app}!",
    "Your savings are running away from {app}!",
    "You're basically burning money by using {app}!",
    "Your financial IQ drops to zero when you open {app}!",
    "Your money is begging you to close {app}!",
    "You're one tap away from financial ruin with {app}!",
    "Your bank balance is having a heart attack because of {app}!",
    "You're a walking financial disaster with {app}!",
  ];

  Future<void> initialize() async {
    debugPrint('Initializing AccessibilityService');

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);

    // Request accessibility permission
    final bool hasPermission =
        await FlutterAccessibilityService.requestAccessibilityPermission();
    if (!hasPermission) {
      debugPrint('Accessibility permission not granted');
      return;
    }
    debugPrint('Accessibility permission granted');

    // Listen to accessibility events
    FlutterAccessibilityService.accessStream.listen((event) async {
      if (event.packageName != null) {
        debugPrint('App opened: ${event.packageName}');
        debugPrint('Event type: ${event.eventType}');

        // Check for monitored apps
        if (_monitoredApps.containsKey(event.packageName)) {
          debugPrint('Monitored app detected: ${event.packageName}');

          // Increment usage count
          await _usageTracker.incrementUsage(event.packageName!);
          debugPrint('Usage count incremented for ${event.packageName}');

          if (await _usageTracker.areNotificationsEnabled()) {
            debugPrint('Notifications are enabled, showing notification');
            await _showNotification(event.packageName!);
          }
        }
      }
    });
  }

  Future<void> _showNotification(String packageName) async {
    try {
      final usageCount = await _usageTracker.getTodayUsage();
      final appCount = usageCount[packageName] ?? 0;
      debugPrint('Current usage count for $packageName: $appCount');

      final random = _random.nextInt(_insultingMessages.length);
      final message = _insultingMessages[random]
          .replaceAll('{app}', _monitoredApps[packageName]!);

      const androidDetails = AndroidNotificationDetails(
        'app_usage_channel',
        'App Usage Notifications',
        channelDescription: 'Notifications about app usage',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'Financial Warning',
        '$message\n\nYou\'ve opened ${_monitoredApps[packageName]} $appCount times today.',
        notificationDetails,
      );
      debugPrint('Notification shown for $packageName');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  Map<String, String> getMonitoredApps() => _monitoredApps;
}
