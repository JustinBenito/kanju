import 'package:flutter/material.dart';
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

  // Add debounce tracking
  final Map<String, DateTime> _lastNotificationTime = {};
  static const _debounceDuration = Duration(seconds: 5);

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

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'app_usage_channel',
      'App Usage Notifications',
      description: 'Notifications about app usage',
      importance: Importance.high,
    );
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

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
      // Check if we should debounce this notification
      final now = DateTime.now();
      final lastTime = _lastNotificationTime[packageName];

      if (lastTime != null) {
        final timeSinceLastNotification = now.difference(lastTime);
        debugPrint(
            'Time since last notification for $packageName: ${timeSinceLastNotification.inSeconds} seconds');

        if (timeSinceLastNotification < _debounceDuration) {
          debugPrint(
              'Debouncing notification for $packageName. Will show again in ${_debounceDuration.inSeconds - timeSinceLastNotification.inSeconds} seconds');
          return;
        }
      }

      _lastNotificationTime[packageName] = now;
      debugPrint(
          'Showing notification for $packageName. Next notification will be available in ${_debounceDuration.inSeconds} seconds');

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
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      // Generate a unique notification ID based on timestamp and package name
      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000) +
              packageName.hashCode.remainder(100000);

      await _notifications.show(
        notificationId,
        'Financial Warning',
        '$message\n\nYou\'ve opened ${_monitoredApps[packageName]} $appCount times today.',
        notificationDetails,
      );
      debugPrint(
          'Notification shown for $packageName with ID: $notificationId');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  Map<String, String> getMonitoredApps() => _monitoredApps;
}
