import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUsageTracker {
  static final AppUsageTracker _instance = AppUsageTracker._internal();
  factory AppUsageTracker() => _instance;
  AppUsageTracker._internal();

  static const String _lastResetKey = 'last_reset_date';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _usagePrefix = 'usage_';

  Future<void> incrementUsage(String packageName) async {
    debugPrint('Incrementing usage for $packageName');
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastReset = prefs.getString(_lastResetKey);
    debugPrint('Last reset date: $lastReset, Today: $today');

    if (lastReset != today) {
      debugPrint('New day detected, resetting counters');
      await prefs.setString(_lastResetKey, today);
      // Clear all usage data for the new day
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_usagePrefix)) {
          await prefs.remove(key);
          debugPrint('Cleared counter for key: $key');
        }
      }
      await prefs.setInt('${_usagePrefix}$packageName', 1);
      debugPrint('Set initial count for $packageName to 1');
    } else {
      final currentCount = prefs.getInt('${_usagePrefix}$packageName') ?? 0;
      final newCount = currentCount + 1;
      await prefs.setInt('${_usagePrefix}$packageName', newCount);
      debugPrint(
          'Incremented count for $packageName from $currentCount to $newCount');
    }
  }

  Future<Map<String, int>> getTodayUsage() async {
    debugPrint('Getting today\'s usage');
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastReset = prefs.getString(_lastResetKey);
    debugPrint('Last reset date: $lastReset, Today: $today');

    if (lastReset != today) {
      debugPrint('New day detected, returning empty usage map');
      return {};
    }

    final Map<String, int> usage = {};
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_usagePrefix)) {
        final packageName = key.substring(_usagePrefix.length);
        final count = prefs.getInt(key) ?? 0;
        if (count > 0) {
          usage[packageName] = count;
          debugPrint('Found usage for $packageName: $count');
        }
      }
    }
    debugPrint('Total usage map: $usage');
    return usage;
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    debugPrint('Notifications enabled: $enabled');
    return enabled;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    debugPrint('Setting notifications enabled to: $enabled');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }
}
