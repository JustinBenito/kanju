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
  final AccessibilityService _accessibilityService = AccessibilityService();
  bool _notificationsEnabled = true;
  Map<String, int> _usageCount = {};

  @override
  void initState() {
    super.initState();
    _initializeAccessibilityService();
    _loadState();
    // Set up periodic refresh
    _setupPeriodicRefresh();
  }

  void _setupPeriodicRefresh() {
    // Refresh every 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _loadState();
        _setupPeriodicRefresh();
      }
    });
  }

  Future<void> _loadState() async {
    debugPrint('Loading state in HomePage');
    final notificationsEnabled = await _usageTracker.areNotificationsEnabled();
    final usageCount = await _usageTracker.getTodayUsage();
    debugPrint('Current usage count: $usageCount');

    if (mounted) {
      setState(() {
        _notificationsEnabled = notificationsEnabled;
        _usageCount = usageCount;
      });
    }
  }

  Future<void> _initializeAccessibilityService() async {
    debugPrint('Initializing accessibility service in HomePage');
    await AccessibilityService().initialize();
  }

  Future<void> _toggleNotifications(bool value) async {
    debugPrint('Toggling notifications to: $value');
    await _usageTracker.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  String _getTagline() {
    final totalUsage = _usageCount.values.fold(0, (sum, count) => sum + count);
    debugPrint('Total usage for tagline: $totalUsage');

    if (totalUsage == 0) {
      return "You're doing great! Keep up the good work! 💪";
    } else if (totalUsage == 1) {
      return "First slip of the day... Don't make it a habit! 😤";
    } else if (totalUsage <= 3) {
      return "You're testing my patience... 🤨";
    } else if (totalUsage <= 5) {
      return "Are you even trying? 😒";
    } else {
      return "You're hopeless... 😫";
    }
  }

  @override
  Widget build(BuildContext context) {
    final monitoredApps = _accessibilityService.getMonitoredApps();
    final usedApps =
        _usageCount.entries.where((entry) => entry.value > 0).toList();
    debugPrint('Building HomePage with used apps: $usedApps');

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
              if (usedApps.isNotEmpty) ...[
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
                      ...usedApps.map((entry) {
                        final appName = monitoredApps[entry.key] ?? entry.key;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '$appName: ${entry.value} times',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No apps used today!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
