import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'accessibility_serv.dart';
import 'dart:async';

class OverlayScreen extends StatefulWidget {
  final String appName;

  const OverlayScreen({
    super.key,
    required this.appName,
  });

  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  int _countdown = 10;
  Timer? _timer;
  bool _isNotOkPressed = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
          AccessibilityService().handleUserResponse(true);
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building OverlayScreen. isNotOkPressed: $_isNotOkPressed');

    return Material(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              key: ValueKey(_isNotOkPressed),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isNotOkPressed) ...[
                  const Text(
                    'You are using an app',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You are about to enter ${widget.appName}',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          debugPrint('OK button pressed');
                          _startCountdown();
                        },
                        child: Text(_countdown > 0 ? 'OK ($_countdown)' : 'OK'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          debugPrint('Not OK button pressed - before setState');
                          _timer?.cancel(); // Cancel countdown if running
                          setState(() {
                            _isNotOkPressed = true;
                            debugPrint(
                                '_isNotOkPressed set to: $_isNotOkPressed');
                          });
                          debugPrint('Not OK button pressed - after setState');
                        },
                        child: const Text('Not OK'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ] else ...[
                  const Center(
                    child: Text(
                      'You are doing great, now close this app idiot',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
