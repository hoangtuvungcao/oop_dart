import 'package:flutter/foundation.dart';

/// Logger đơn giản dùng khi debug với nhiều cấp độ log khác nhau
/// Ví dụ sử dụng:
/// `Logger.d('Storage', 'Initialized');`
/// `Logger.i('Session', 'Loaded settings');`
/// `Logger.w('Game', 'Low time: $secondsLeft');`
/// `Logger.e('Audio', 'Failed to play: $asset');`
class Logger {
  static LogLevel _level = LogLevel.debug;

  static void setLevel(LogLevel level) => _level = level;

  static bool _enabled(LogLevel l) => kDebugMode && l.index >= _level.index;

  static void _log(String level, String tag, String msg) {
    final ts = DateTime.now().toIso8601String();
    debugPrint('[$ts][$level][$tag] $msg');
  }

  static void d(String tag, String msg) {
    if (_enabled(LogLevel.debug)) _log('D', tag, msg);
  }

  static void i(String tag, String msg) {
    if (_enabled(LogLevel.info)) _log('I', tag, msg);
  }

  static void w(String tag, String msg) {
    if (_enabled(LogLevel.warn)) _log('W', tag, msg);
  }

  static void e(String tag, String msg) {
    if (_enabled(LogLevel.error)) _log('E', tag, msg);
  }
}

enum LogLevel { debug, info, warn, error }
