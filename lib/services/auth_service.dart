import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../exceptions/auth.dart';
import '../utils/logger.dart';
import '../utils/platform.dart';
import 'firebase_service.dart';

/// Service for user authentication with Firebase
class AuthService {
  final FirebaseService firebaseService = FirebaseService();

  /// Get the current user from Firebase Auth
  auth.User? get currentAuthUser => firebaseService.auth.currentUser;

  /// Check if the user is logged in
  bool get isLoggedIn => currentAuthUser != null;

  /// Register a new user account with [email], [password] and [name].
  ///
  /// Returns [UserCredential] for the new user.
  ///
  /// Throws [AuthException] if there is some error creating the user.
  Future<auth.User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    UserCredential userCredential = await _wrapAuthExceptions(
      isEmailPassword: true,
      () async {
        // Create user with email and password
        final userCredential =
            await firebaseService.auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Set user name
        await userCredential.user?.updateDisplayName(name);
        await userCredential.user?.reload();
        return userCredential;
      },
    );
    if (userCredential.user == null) {
      throw AuthenticationFailedException(
          'Authentication failed (Register Email/Password)');
    }
    debug('Register: ${userCredential.user}');
    return userCredential.user!;
  }

  /// Log in an existing user with [email] and [password].
  ///
  /// Returns [UserCredential] for the authenticated user.
  ///
  /// Throws [AuthException] if the credentials are invalid
  /// or some other authentication error occurs.
  Future<auth.User> login({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await _wrapAuthExceptions(
      isEmailPassword: true,
      () => firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
    if (userCredential.user == null) {
      throw AuthenticationFailedException(
          'Authentication failed (Login Email/Password)');
    }
    debug('Login: ${userCredential.user}');
    return userCredential.user!;
  }

  /// Sign out the current user
  Future<void> logout() async {
    try {
      await firebaseService.auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationFailedException('Failed to logout (${e.message})');
    }
  }

  /// Sign in user with their Google account.
  ///
  /// Returns [UserCredential] for the authenticated user.
  ///
  /// Throws [AuthException] if some authentication error occurs.
  Future<auth.User> signInWithGoogle() async {
    if (isWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      UserCredential userCredential = await _wrapAuthExceptions(
        isEmailPassword: false,
        // Trigger the authentication flow with a popup window
        () => firebaseService.auth.signInWithPopup(googleProvider),
      );
      if (userCredential.user == null) {
        throw AuthenticationFailedException();
      }
      return userCredential.user!;
    }

    // Android / iOS
    UserCredential userCredential = await _wrapAuthExceptions(
      isEmailPassword: false,
      () async {
        // Trigger the mobile authentication flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        if (googleUser == null) {
          // User aborted the sign in process
          throw SignInCancelledException();
        }

        // Get the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new token credentials for Google authentication
        final googleAuthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with Firebase
        final userCredential = await firebaseService.auth
            .signInWithCredential(googleAuthCredential);

        // Set user name and photo url from Google profile
        await userCredential.user?.updateDisplayName(googleUser.displayName);
        await userCredential.user?.updatePhotoURL(googleUser.photoUrl);
        await userCredential.user?.reload();

        return userCredential;
      },
    );

    if (userCredential.user == null) {
      throw AuthenticationFailedException('Authentication failed (Google)');
    }
    return userCredential.user!;
  }

  /// Wrap firebase authentication exceptions with custom auth exceptions
  Future<UserCredential> _wrapAuthExceptions(
    Future<UserCredential> Function() auth, {
    required bool isEmailPassword,
  }) async {
    try {
      return await auth();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw WrongPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'too-many-requests') {
        throw TooManyRequestsException();
      } else if (e.code == 'user-token-expired') {
        throw UserTokenExpiredException();
      } else if (e.code == 'user-disabled') {
        throw UserDisabledException();
      } else if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedException();
      } else if (e.code == 'operation-not-allowed') {
        throw OperationNotAllowedException();
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS' ||
          e.code == 'invalid-credential') {
        if (isEmailPassword) {
          throw WrongPasswordException();
        }
        throw InvalidCredentialException();
      }
      rethrow;
    }
  }
}
