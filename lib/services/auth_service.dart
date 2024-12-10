import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';

import '../exceptions/auth.dart';
import '../models/auth_user.dart';
import '../models/user.dart';
import '../utils/logger.dart';
import '../utils/platform.dart';
import 'firebase_service.dart';

typedef FirebaseUser = auth.User;

/// Service for user authentication with Firebase
class AuthService {
  final FirebaseService firebaseService = FirebaseService();

  /// Get the current firebase user from Firebase Auth
  FirebaseUser? get currentAuthUser => firebaseService.auth.currentUser;

  /// Check if the user is logged in
  bool get isLoggedIn => currentAuthUser != null;

  /// Register a new user account with [email], [password] and [name].
  ///
  /// Returns the registered [User].
  ///
  /// Throws [AuthException] if there is some error creating the user.
  Future<User> register({
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
        'Authentication failed (Register Email/Password)',
      );
    }
    final AuthUser authUser = await _signInWithBackend(userCredential.user!);
    final User user = authUser.user;
    if (user.isAnonymous) {
      user.name = name;
    }
    debug('Register: $authUser');
    return user;
  }

  /// Log in an existing user with [email] and [password].
  ///
  /// Returns [UserCredential] for the authenticated user.
  ///
  /// Throws [AuthException] if the credentials are invalid
  /// or some other authentication error occurs.
  Future<User> login({
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
        'Authentication failed (Login Email/Password)',
      );
    }
    final AuthUser authUser = await _signInWithBackend(userCredential.user!);
    debug('Login: $authUser');
    return authUser.user;
  }

  /// Sign in user with their Google account.
  ///
  /// Returns [UserCredential] for the authenticated user.
  ///
  /// Throws [AuthException] if some authentication error occurs.
  Future<User> signInWithGoogle() async {
    if (isWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      UserCredential userCredential = await _wrapAuthExceptions(
        isEmailPassword: false,
        // Trigger the authentication flow with a popup window
        () => firebaseService.auth.signInWithPopup(googleProvider),
      );
      if (userCredential.user == null) {
        throw AuthenticationFailedException(
          'Authentication failed (Login Google)',
        );
      }
      final AuthUser authUser = await _signInWithBackend(userCredential.user!);
      debug('Login (Google): $authUser');
      return authUser.user;
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
      throw AuthenticationFailedException(
        'Authentication failed (Login Google)',
      );
    }
    final AuthUser authUser = await _signInWithBackend(userCredential.user!);
    debug('Login (Google): $authUser');
    return authUser.user;
  }

  /// Sign out the current user
  Future<void> logout() async {
    try {
      await firebaseService.auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationFailedException('Failed to logout (${e.message})');
    }
  }

  /// Sign in user with backend
  Future<AuthUser> _signInWithBackend(FirebaseUser firebaseUser) async {
    final AuthToken authToken = await getAuthToken(firebaseUser);
    final User user = User.fromFirebase(firebaseUser);
    final AuthUser authUser = AuthUser(user: user, token: authToken);
    return authUser;
  }

  /// Get the user authentication token
  Future<AuthToken> getAuthToken(FirebaseUser firebaseUser) async {
    final IdTokenResult idTokenResult = await firebaseUser.getIdTokenResult();
    return AuthToken(
      token: idTokenResult.token!,
      issuedAt: idTokenResult.issuedAtTime,
      expiration: idTokenResult.expirationTime,
      lastLogin: idTokenResult.authTime,
    );
  }
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
