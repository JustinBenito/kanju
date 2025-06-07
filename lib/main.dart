import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'accessibility_service.dart';
import 'home.dart';
import 'overlay_screen.dart';

void main() {
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void accessibilityOverlay() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayScreen(
      appName: 'App',
      onResponse: (response) {
        // Handle response
      },
    ),
  ));
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
