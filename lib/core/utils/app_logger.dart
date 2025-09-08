import 'dart:developer' as developer;

/// A utility class for logging throughout the application
/// Replaces print statements with proper logging
class AppLogger {
  static const String _tag = 'RikhhApp';

  /// Log debug messages
  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 500, // Debug level
    );
  }

  /// Log info messages
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800, // Info level
    );
  }

  /// Log warning messages
  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900, // Warning level
    );
  }

  /// Log error messages
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log network requests/responses
  static void network(String message, {String? tag}) {
    developer.log(
      message,
      name: '${tag ?? _tag}_Network',
      level: 700, // Network level
    );
  }

  /// Log authentication events
  static void auth(String message, {String? tag}) {
    developer.log(
      message,
      name: '${tag ?? _tag}_Auth',
      level: 800, // Auth level
    );
  }

  /// Log cart operations
  static void cart(String message, {String? tag}) {
    developer.log(
      message,
      name: '${tag ?? _tag}_Cart',
      level: 800, // Cart level
    );
  }

  /// Log checkout operations
  static void checkout(String message, {String? tag}) {
    developer.log(
      message,
      name: '${tag ?? _tag}_Checkout',
      level: 800, // Checkout level
    );
  }
}
