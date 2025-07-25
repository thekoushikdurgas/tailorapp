import 'package:flutter/foundation.dart';

/// Debug Logger for comprehensive logging across the application
///
/// This utility provides categorized logging to help with debugging
/// different parts of the application like authentication, navigation,
/// intro flow, storage operations, etc.
class DebugLogger {
  static const bool _debugMode = kDebugMode;

  // ANSI color codes for terminal output
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';
  static const String _gray = '\x1B[90m';

  /// Log intro/onboarding related messages
  static void intro(String message) {
    if (!_debugMode) return;
    _log('🎯 INTRO', message, _blue);
  }

  /// Log authentication related messages
  static void auth(String message) {
    if (!_debugMode) return;
    _log('🔐 AUTH', message, _green);
  }

  /// Log navigation related messages
  static void navigation(String message) {
    if (!_debugMode) return;
    _log('🧭 NAV', message, _cyan);
  }

  /// Log storage/database operations
  static void storage(String message) {
    if (!_debugMode) return;
    _log('💾 STORAGE', message, _magenta);
  }

  /// Log user-related operations
  static void user(String message) {
    if (!_debugMode) return;
    _log('👤 USER', message, _yellow);
  }

  /// Log theme-related operations
  static void theme(String message) {
    if (!_debugMode) return;
    _log('🎨 THEME', message, _white);
  }

  /// Log general information
  static void info(String message) {
    if (!_debugMode) return;
    _log('ℹ️ INFO', message, _blue);
  }

  /// Log success messages
  static void success(String message) {
    if (!_debugMode) return;
    _log('✅ SUCCESS', message, _green);
  }

  /// Log error messages
  static void error(String message) {
    if (!_debugMode) return;
    _log('❌ ERROR', message, _red);
  }

  /// Log warning messages
  static void warning(String message) {
    if (!_debugMode) return;
    _log('⚠️ WARNING', message, _yellow);
  }

  /// Log debug information
  static void debug(String message) {
    if (!_debugMode) return;
    _log('🐛 DEBUG', message, _gray);
  }

  /// Log API operations
  static void api(String message) {
    if (!_debugMode) return;
    _log('🌐 API', message, _cyan);
  }

  /// Log service operations
  static void service(String message) {
    if (!_debugMode) return;
    _log('⚙️ SERVICE', message, _magenta);
  }

  /// Log state management operations
  static void state(String message) {
    if (!_debugMode) return;
    _log('📊 STATE', message, _blue);
  }

  /// Internal logging method
  static void _log(String category, String message, String color) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    debugPrint('$color[$timestamp] $category$_reset: $message');
  }

  /// Log method entry with parameters
  static void methodEntry(
    String className,
    String methodName, [
    Map<String, dynamic>? params,
  ]) {
    if (!_debugMode) return;
    final paramsStr = params != null ? ' | Params: $params' : '';
    debug('→ $className.$methodName()$paramsStr');
  }

  /// Log method exit with result
  static void methodExit(
    String className,
    String methodName, [
    dynamic result,
  ]) {
    if (!_debugMode) return;
    final resultStr = result != null ? ' | Result: $result' : '';
    debug('← $className.$methodName()$resultStr');
  }

  /// Log exception with stack trace
  static void exception(
    String message,
    Object exception, [
    StackTrace? stackTrace,
  ]) {
    if (!_debugMode) return;
    error('$message: $exception');
    if (stackTrace != null) {
      debug('Stack trace: $stackTrace');
    }
  }

  /// Log performance timing
  static void performance(String operation, Duration duration) {
    if (!_debugMode) return;
    final ms = duration.inMilliseconds;
    final color = ms > 1000
        ? _red
        : ms > 500
            ? _yellow
            : _green;
    _log('⏱️ PERF', '$operation took ${ms}ms', color);
  }

  /// Start a performance timer
  static Stopwatch startTimer(String operation) {
    if (!_debugMode) return Stopwatch();
    debug('Starting timer for: $operation');
    return Stopwatch()..start();
  }

  /// End a performance timer
  static void endTimer(String operation, Stopwatch timer) {
    if (!_debugMode) return;
    timer.stop();
    performance(operation, timer.elapsed);
  }
}
