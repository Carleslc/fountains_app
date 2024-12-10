import 'user.dart';

/// Authenticated user
class AuthUser {
  /// User data
  final User user;

  /// Authentication token
  final AuthToken token;

  AuthUser({
    required this.user,
    required this.token,
  });

  @override
  String toString() => '[AuthUser]\n'
      '$user\n'
      '$token';
}

/// User authentication token
class AuthToken {
  /// Firebase Auth ID token
  final String token;

  /// Token issued at time
  final DateTime? issuedAt;

  /// Token expiration time
  final DateTime? expiration;

  /// User last login time
  final DateTime? lastLogin;

  AuthToken({
    required this.token,
    required this.issuedAt,
    required this.expiration,
    required this.lastLogin,
  });

  @override
  String toString() => '[AuthToken]\n'
      'token: $token\n'
      'issuedAt: $issuedAt\n'
      'expiration: $expiration\n'
      'lastLogin: $lastLogin';
}
