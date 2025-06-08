import 'package:flutter/material.dart';
import 'package:kanju/notification_service.dart';
import 'accessibility_serv.dart';
import 'app_usage_tracker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppUsageTracker _usageTracker = AppUsageTracker();
  bool _notificationsEnabled = true;
  int _usageCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeAccessibilityService();
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

  Future<void> _initializeAccessibilityService() async {
    await AccessibilityService().initialize();
  }

  Future<void> _toggleNotifications(bool value) async {
    await _usageTracker.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  String _getTagline() {
    if (_usageCount == 0) {
      return "You're doing great! Keep up the good work! 💪";
    } else if (_usageCount == 1) {
      return "First slip of the day... Don't make it a habit! 😤";
    } else if (_usageCount <= 3) {
      return "You're testing my patience... 🤨";
    } else if (_usageCount <= 5) {
      return "Are you even trying? 😒";
    } else {
      return "You're hopeless... 😫";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Guardian'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Image
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                ),
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/profile.png'),
                  radius: 75,
                ),
              ),
              const SizedBox(height: 24),

              // Usage Counter
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Today\'s App Usage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_usageCount attempts',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tagline
              Text(
                _getTagline(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Notification Toggle
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Get warned when opening payment apps'),
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
