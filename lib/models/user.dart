import 'package:firebase_auth/firebase_auth.dart' as auth;

/// Authenticated user
class User {
  /// User unique ID
  final String id;

  /// User email address
  final String? email;

  /// User display name
  String get name => _name ?? 'Anonymous';
  String? _name;

  /// User profile picture URL
  String? picture;

  /// User created timestamp
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    String? name,
    this.picture,
    this.createdAt,
  }) : _name = name;

  /// Create a User from a Firebase Auth user
  factory User.fromFirebase(auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      name: firebaseUser.displayName,
      picture: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime,
    );
  }

  bool get isAnonymous => _name == null;

  set name(String? name) => _name = name;

  @override
  String toString() =>
      'User(id: $id, email: $email, name: $name, picture: $picture, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == id &&
          other._name == _name &&
          other.picture == picture);

  @override
  int get hashCode => Object.hash(id, _name, picture);
}
