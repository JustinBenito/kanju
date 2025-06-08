import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app_usage_tracker.dart';

class AccessibilityService {
  static final AccessibilityService _instance =
      AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AppUsageTracker _usageTracker = AppUsageTracker();

  final Map<String, String> _monitoredApps = {
    'com.whatsapp': 'WhatsApp',
    'com.instagram.android': 'Instagram',
    'com.facebook.katana': 'Facebook',
    'com.twitter.android': 'Twitter',
    'com.snapchat.android': 'Snapchat',
    'com.tiktok.android': 'TikTok',
    'com.reddit.frontpage': 'Reddit',
    'com.pinterest': 'Pinterest',
  };

  final List<String> _insultingMessages = [
    "Oh look, another attempt to waste your life on social media.",
    "Your productivity is crying in the corner.",
    "Do you really need to check that notification? No, you don't.",
    "Your future self hates you right now.",
    "Congratulations on choosing instant gratification over long-term success!",
    "Your willpower is weaker than a wet paper towel.",
    "Another day, another opportunity to disappoint yourself.",
    "Your phone addiction is showing...",
    "Do you even remember what productivity means?",
    "You're a lost cause. Just give up already.",
    "Your brain cells are leaving the chat.",
    "This is why you can't have nice things.",
    "Your future self is facepalming right now.",
    "Another step closer to becoming a social media zombie.",
    "Your productivity is taking a permanent vacation.",
  ];

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);
  }

  Future<void> handleAppOpen(String packageName) async {
    if (!await _usageTracker.areNotificationsEnabled()) return;

    if (_monitoredApps.containsKey(packageName)) {
      await _usageTracker.incrementUsage(packageName);
      final usageCount = await _usageTracker.getTodayUsage();
      final appCount = usageCount[packageName] ?? 0;

      final random =
          DateTime.now().millisecondsSinceEpoch % _insultingMessages.length;
      final message = _insultingMessages[random];

      await _showNotification(
        'App Usage Alert',
        '$message\n\nYou\'ve opened ${_monitoredApps[packageName]} $appCount times today.',
      );
    }
  }

  Future<void> _showNotification(String title, String body) async {
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
      title,
      body,
      notificationDetails,
    );
  }

  Map<String, String> getMonitoredApps() => _monitoredApps;
}
