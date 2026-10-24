import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// Thrown by [BaseAuth] implementations with a user-presentable [message].
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class BaseAuth {
  /// Emits the signed-in user's id, or `null` when signed out.
  Stream<String?> get onAuthStateChanged;
  String? get currentUserId;
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

class FirebaseAuthService implements BaseAuth {
  FirebaseAuthService([FirebaseAuth? firebaseAuth])
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<String?> get onAuthStateChanged =>
      _firebaseAuth.authStateChanges().map((user) => user?.uid);

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return _guard(() async {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user!.uid;
    });
  }

  @override
  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    return _guard(() async {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user!.uid;
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _guard(() => _firebaseAuth.sendPasswordResetEmail(email: email));
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed (${e.code}).');
    }
  }
}

/// Local, in-memory auth used for demo mode and tests.
class DemoAuth implements BaseAuth {
  DemoAuth({String? initialUserId}) : _currentUserId = initialUserId;

  final Map<String, ({String password, String uid})> _accounts = {};
  final StreamController<String?> _controller =
      StreamController<String?>.broadcast();
  String? _currentUserId;
  int _nextId = 1;

  @override
  Stream<String?> get onAuthStateChanged async* {
    yield _currentUserId;
    yield* _controller.stream;
  }

  @override
  String? get currentUserId => _currentUserId;

  @override
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw AuthException('Incorrect email or password.');
    }
    _setUser(account.uid);
    return account.uid;
  }

  @override
  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw AuthException('An account already exists for that email.');
    }
    final uid = 'demo-user-${_nextId++}';
    _accounts[key] = (password: password, uid: uid);
    _setUser(uid);
    return uid;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async => _setUser(null);

  void _setUser(String? uid) {
    _currentUserId = uid;
    _controller.add(uid);
  }
}
