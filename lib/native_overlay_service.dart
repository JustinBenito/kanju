import 'package:flutter/services.dart';

class NativeOverlayService {
  static const MethodChannel _channel =
      MethodChannel('com.example.kanju/overlay');
  static final NativeOverlayService _instance =
      NativeOverlayService._internal();

  factory NativeOverlayService() => _instance;
  NativeOverlayService._internal();

  Future<bool> showOverlay() async {
    try {
      final bool result = await _channel.invokeMethod('showOverlay');
      return result;
    } on PlatformException catch (e) {
      print('Error showing overlay: ${e.message}');
      return false;
    }
  }

  Future<bool> hideOverlay() async {
    try {
      final bool result = await _channel.invokeMethod('hideOverlay');
      return result;
    } on PlatformException catch (e) {
      print('Error hiding overlay: ${e.message}');
      return false;
    }
  }

  Future<bool> updateMessage(String message) async {
    try {
      final bool result = await _channel.invokeMethod('updateMessage', {
        'message': message,
      });
      return result;
    } on PlatformException catch (e) {
      print('Error updating message: ${e.message}');
      return false;
    }
  }

  Future<bool> updateCountdown(int countdown) async {
    try {
      final bool result = await _channel.invokeMethod('updateCountdown', {
        'countdown': countdown,
      });
      return result;
    } on PlatformException catch (e) {
      print('Error updating countdown: ${e.message}');
      return false;
    }
  }
}
