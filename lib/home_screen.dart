import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_usage_tracker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppUsageTracker _usageTracker = AppUsageTracker();
  bool _notificationsEnabled = true;
  int _usageCount = 0;

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
    if (_usageCount == 0) {
      return "You're doing great! Keep it up!";
    } else if (_usageCount < 5) {
      return "Still trying to be productive?";
    } else if (_usageCount < 10) {
      return "Your willpower is weaker than a wet paper towel";
    } else if (_usageCount < 15) {
      return "Your phone addiction is showing...";
    } else if (_usageCount < 20) {
      return "Do you even remember what productivity means?";
    } else {
      return "You're a lost cause. Just give up already.";
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Today\'s Usage: $_usageCount',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
