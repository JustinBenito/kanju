import 'package:shared_preferences/shared_preferences.dart';

class AppUsageTracker {
  static final AppUsageTracker _instance = AppUsageTracker._internal();
  factory AppUsageTracker() => _instance;
  AppUsageTracker._internal();

  static const String _lastResetKey = 'last_reset_date';
  static const String _usageCountKey = 'usage_count';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  Future<void> incrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastReset = prefs.getString(_lastResetKey);

    if (lastReset != today) {
      await prefs.setString(_lastResetKey, today);
      await prefs.setInt(_usageCountKey, 1);
    } else {
      final currentCount = prefs.getInt(_usageCountKey) ?? 0;
      await prefs.setInt(_usageCountKey, currentCount + 1);
    }
  }

  Future<int> getTodayUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastReset = prefs.getString(_lastResetKey);

    if (lastReset != today) {
      return 0;
    }
    return prefs.getInt(_usageCountKey) ?? 0;
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }
}
