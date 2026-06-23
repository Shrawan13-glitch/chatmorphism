import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ForegroundService {
  static const _channel = MethodChannel('com.kino.app/foreground_service');

  static Future<void> start() async {
    try {
      await _channel.invokeMethod('startService');
    } catch (e) {
      debugPrint('ForegroundService.start error: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopService');
    } catch (e) {
      debugPrint('ForegroundService.stop error: $e');
    }
  }

  static Future<void> updateNotification({
    String title = 'Kino',
    String content = 'Generating response...',
  }) async {
    try {
      await _channel.invokeMethod('updateNotification', {
        'title': title,
        'content': content,
      });
    } catch (e) {
      debugPrint('ForegroundService.updateNotification error: $e');
    }
  }
}
