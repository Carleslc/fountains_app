import '../utils/message.dart';

/// Base exception for all custom exceptions of this app
abstract class AppException implements Exception {
  String get message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Run a function [f] within a try-catch block.
///
/// Show an [errorMessage] if the function throws an exception.
///
/// [onErrorMessage] can be used instead to lazily generate the error message.\
/// [onErrorContext] is logged along with [onErrorLogMessage], [onErrorMessage] or [errorMessage].
Future<T?> tryOrShowError<T>(
  Future<T?> Function() f, {
  String? errorMessage,
  String Function()? onErrorMessage,
  Object Function()? onErrorContext,
  String Function(Object? e)? onErrorLogMessage,
}) async {
  assert(errorMessage != null || onErrorMessage != null);

  try {
    return await f();
  } catch (e, stackTrace) {
    String logError = onErrorLogMessage?.call(e) ??
        (e is AppException ? e.message : e.toString());

    ShowMessage.error(
      onErrorMessage?.call() ?? errorMessage ?? logError,
      log: logError,
      errorContext: onErrorContext?.call(),
      errorObject: e,
      stackTrace: stackTrace,
    );
  }
  return null;
}
