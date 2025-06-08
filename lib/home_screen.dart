import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_usage_tracker.dart';
import 'accessibility_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppUsageTracker _usageTracker = AppUsageTracker();
  final AccessibilityService _accessibilityService = AccessibilityService();
  bool _notificationsEnabled = true;
  Map<String, int> _usageCount = {};

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final notificationsEnabled = await _usageTracker.areNotificationsEnabled();
    final usageCount = await _usageTracker.getTodayUsage();
    setState(() {
      _notificationsEnabled = notificationsEnabled;
      _usageCount = usageCount;
    });
  }

  Future<void> _toggleNotifications() async {
    await _usageTracker.setNotificationsEnabled(!_notificationsEnabled);
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
    });
  }

  String _getTagline() {
    final totalUsage = _usageCount.values.fold(0, (sum, count) => sum + count);

    if (totalUsage == 0) {
      return "You're doing great! Keep it up!";
    } else if (totalUsage < 5) {
      return "Still trying to be productive?";
    } else if (totalUsage < 10) {
      return "Your willpower is weaker than a wet paper towel";
    } else if (totalUsage < 15) {
      return "Your phone addiction is showing...";
    } else if (totalUsage < 20) {
      return "Do you even remember what productivity means?";
    } else {
      return "You're a lost cause. Just give up already.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final monitoredApps = _accessibilityService.getMonitoredApps();
    final usedApps =
        _usageCount.entries.where((entry) => entry.value > 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanju'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            if (usedApps.isNotEmpty) ...[
              const Text(
                'Today\'s Usage:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...usedApps.map((entry) {
                final appName = monitoredApps[entry.key] ?? entry.key;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '$appName: ${entry.value} times',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                );
              }).toList(),
            ] else
              const Text(
                'No apps used today!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              _getTagline(),
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (value) => _toggleNotifications(),
            ),
          ],
        ),
      ),
    );
  }
}
