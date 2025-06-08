import 'package:flutter/material.dart';
import 'package:kanju/notification_service.dart';
import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Usage Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
