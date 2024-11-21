import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Logger
final Logger _logger = _createLogger();

Logger _createLogger() {
  if (kDebugMode) {
    // Debug
    return Logger(
      level: Level.debug,
      printer: PrettyPrinter(
        dateTimeFormat: DateTimeFormat.onlyTime,
        printEmojis: true,
        methodCount: 0, // 2
        errorMethodCount: 8,
      ),
      filter: DevelopmentFilter(),
      output: ConsoleOutput(),
    );
  }
  // Production
  return Logger(
    level: Level.warning,
    printer: PrettyPrinter(
      dateTimeFormat: DateTimeFormat.none,
      printEmojis: false,
      methodCount: 0,
      errorMethodCount: 0,
    ),
    filter: ProductionFilter(),
    output: ConsoleOutput(),
  );
}

/// Log a debug [message] in console
///
/// [Level.debug]
void debug(dynamic message) {
  _logger.d(message);
}

/// Log an info [message] in console
///
/// [Level.info]
void info(String message) {
  _logger.i(message);
}

/// Log a warning [message] in console, with an optional [error] exception
///
/// [Level.warning]
void warning(String message, [Object? error, StackTrace? stackTrace]) {
  _logger.w(message, error: error, stackTrace: stackTrace);
}

/// Log an error [message] with an [error] in console
///
/// [Level.error]
void error(String? message, [Object? error, StackTrace? stackTrace]) {
  _logger.e(message ?? error?.toString(), error: error, stackTrace: stackTrace);
}

/// Log an [errorObject] exception in console
///
/// [Level.error]
void exception(Object? errorObject, [StackTrace? stackTrace]) {
  error(null, errorObject, stackTrace);
}

/// Log an [errorMessage] with an optional [errorObject] and [errorContext] in console
///
/// [Level.error]
void errorWithContext(
  String errorMessage, {
  Object? errorObject,
  StackTrace? stackTrace,
  Object? errorContext,
}) {
  error(
    messageWithContext(errorMessage, errorContext),
    errorObject,
    stackTrace,
  );
}

/// Log a warning [message] with an optional [errorObject] and [context] in console
///
/// [Level.warning]
void warningWithContext(
  String message, {
  Object? errorObject,
  StackTrace? stackTrace,
  Object? context,
}) {
  warning(messageWithContext(message, context), errorObject, stackTrace);
}

/// Join [message] with an optional [context]
String messageWithContext(String message, Object? context) {
  if (context != null) {
    message = '$message ($context)';
  }
  return message;
}
