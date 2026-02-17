import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class LoggerService {
  static void log(String message,
      {LogLevel level = LogLevel.info, Object? error, StackTrace? stackTrace}) {
    if (kReleaseMode && level == LogLevel.debug) return;

    final timestamp = DateTime.now().toIso8601String();
    final label = level.name.toUpperCase();

    developer.log(
      '[$timestamp] [$label] $message',
      name: 'DrShine',
      error: error,
      stackTrace: stackTrace,
      level: _getDeveloperLevel(level),
    );

    // In a real production app, we would also send errors to Sentry/Crashlytics here
    if (level == LogLevel.error && error != null) {
      // reportToCrashlytics(error, stackTrace);
    }
  }

  static int _getDeveloperLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  static void debug(String message) => log(message, level: LogLevel.debug);
  static void info(String message) => log(message, level: LogLevel.info);
  static void warn(String message) => log(message, level: LogLevel.warning);
  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);
}
