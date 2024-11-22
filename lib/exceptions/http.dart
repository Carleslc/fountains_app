import 'dart:io';
import 'dart:math';

import 'error.dart';

///
/// Exceptions related to network status
///
abstract class NetworkError extends AppException {}

/// Device is not connected to Internet
class NoInternetException extends NetworkError {
  @override
  String get message => 'Internet connection is not available';
}

///
/// Exceptions related to http requests
///
class HttpResponseError extends AppException implements HttpException {
  final int status;
  final String? body;
  final Uri? uri;

  HttpResponseError({
    required this.status,
    this.uri,
    this.body,
  });

  @override
  String get message {
    String errorMessage = 'Status: $status';

    if (uri != null) {
      errorMessage += '. Url: $uri';
    }

    if (body != null) {
      final int bodyLength = body!.length;
      String bodyTrim = body!.substring(0, min(1000, bodyLength));

      if (bodyTrim.length < bodyLength) {
        bodyTrim += '... (+${bodyLength - bodyTrim.length} characters)';
      }

      errorMessage += '\nBody: $bodyTrim';
    }

    return errorMessage;
  }
}
