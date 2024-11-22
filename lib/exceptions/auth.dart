import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'error.dart';
import 'http.dart';

///
/// Exceptions related to authentication
///
abstract class AuthException extends AppException {
  /// Localized message to display to the user
  String localizedMessage(AppLocalizations l);

  /// Whether to report the error to Crashlytics
  bool get report => false;
}

/// Invalid email format
class InvalidEmailException extends AuthException {
  @override
  String get message => 'The email address format is invalid';

  @override
  String localizedMessage(AppLocalizations l) => l.invalidEmailFormat;
}

/// Email already exists
class EmailAlreadyInUseException extends AuthException {
  @override
  String get message => 'An account already exists with this email address';

  @override
  String localizedMessage(AppLocalizations l) => l.emailAlreadyInUse;
}

/// User not found
class UserNotFoundException extends AuthException {
  @override
  String get message => 'No user found for the given email';

  @override
  String localizedMessage(AppLocalizations l) => l.userNotFound;
}

/// Wrong password
class WrongPasswordException extends AuthException {
  @override
  String get message => 'Invalid password';

  @override
  String localizedMessage(AppLocalizations l) => l.wrongPassword;
}

/// Weak password
class WeakPasswordException extends AuthException {
  @override
  String get message => 'The password is not strong enough';

  @override
  String localizedMessage(AppLocalizations l) => l.weakPassword;
}

/// User has been disabled
class UserDisabledException extends AuthException {
  @override
  String get message => 'User account has been disabled';

  @override
  String localizedMessage(AppLocalizations l) => l.userDisabled;
}

/// Account exists with different credential
class AccountExistsWithDifferentCredentialException extends AuthException {
  @override
  String get message =>
      'An account already exists with the same email address but different sign-in credentials';

  @override
  String localizedMessage(AppLocalizations l) =>
      l.accountExistsWithDifferentCredential;
}

/// User aborted the sign in flow
class SignInCancelledException extends AuthException {
  @override
  String get message => 'Sign in cancelled by user';

  @override
  String localizedMessage(AppLocalizations l) => l.signInCancelled;
}

/// Too many requests
class TooManyRequestsException extends AuthException {
  @override
  String get message => 'Too many sign in attempts';

  @override
  String localizedMessage(AppLocalizations l) => l.tooManyRequests;
}

/// User token expired
class UserTokenExpiredException extends AuthException {
  @override
  String get message => 'User session has expired';

  @override
  String localizedMessage(AppLocalizations l) => l.userTokenExpired;
}

/// Invalid authentication credentials
class InvalidCredentialException extends AuthException {
  @override
  bool get report => true;

  @override
  String get message => 'Credential is malformed or has expired';

  @override
  String localizedMessage(AppLocalizations l) => l.invalidCredential;
}

/// Authentication method not allowed
class OperationNotAllowedException extends AuthException {
  @override
  bool get report => true;

  @override
  String get message => 'This authentication method is not enabled. '
      'Enable authentication method in Firebase Console -> Auth';

  @override
  String localizedMessage(AppLocalizations l) => l.operationNotAllowed;
}

/// Network request failed for authentication
class NetworkRequestFailedException extends AuthException
    implements NetworkError {
  @override
  String get message =>
      'Authentication failed due to network connectivity issues';

  @override
  String localizedMessage(AppLocalizations l) => l.networkRequestFailed;
}

/// Authentication failed for other reason
class AuthenticationFailedException extends AuthException {
  final String _message;

  AuthenticationFailedException([String? message])
      : _message = message ?? 'Authentication failed';

  @override
  String get message => _message;

  @override
  String localizedMessage(AppLocalizations l) => l.authenticationFailed;

  @override
  bool get report => true;
}
