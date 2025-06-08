import 'package:flutter/material.dart';
import 'accessibility_serv.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initializeAccessibilityService();
  }

  Future<void> _initializeAccessibilityService() async {
    await AccessibilityService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Usage Monitor'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Monitoring WhatsApp and Instagram usage...',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}