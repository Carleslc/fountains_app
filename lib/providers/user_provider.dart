import 'dart:async';

import 'package:flutter/foundation.dart';

import '../exceptions/auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

/// Provider of user state
class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  /// Current user
  User? get user => _user;
  User? _user;

  /// Check if the user is logged in
  bool get isLoggedIn => _user != null;

  /// Set current user state and notify listeners
  void _setUser(final User? user) {
    if (_user != user) {
      _user = user;
      notifyListeners();
    }
  }

  /// Listener to user auth state changes
  StreamSubscription<User?>? _userAuthListener;

  /// Start listening to auth state changes
  void listenToUserUpdates() {
    if (_userAuthListener == null) {
      // TODO: _authService.onAuthStateChanged stream (decouple firebaseService)
      _userAuthListener = _authService.firebaseService.auth
          .authStateChanges()
          .map(
            (authUser) => authUser != null ? User.fromFirebase(authUser) : null,
          )
          .listen(_onAuthStateChanged);
    }
  }

  /// Handle auth state changes
  void _onAuthStateChanged(final User? user) {
    if (user != null) {
      // User signed in
      debug('User signed in: $user');
      _setUser(user);
    } else if (_user != null) {
      // User signed out
      debug('User signed out');
      _setUser(null);
    }
  }

  /// Register a new user
  ///
  /// Throws [AuthException] if there is some error creating the user.
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final user = await _authService.register(
      email: email,
      password: password,
      name: name,
    );
    _setUser(user);
  }

  /// Login existing user
  ///
  /// Throws [AuthException] if the credentials are invalid or some other authentication error occurs.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final user = await _authService.login(
      email: email,
      password: password,
    );
    _setUser(user);
  }

  /// Sign in with Google
  ///
  /// Throws [AuthException] if some authentication error occurs.
  Future<void> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    _setUser(user);
  }

  /// Sign out current user
  Future<void> logout() async {
    await _authService.logout();
    _setUser(null);
  }

  @override
  void dispose() {
    _userAuthListener?.cancel();
    super.dispose();
  }
}
