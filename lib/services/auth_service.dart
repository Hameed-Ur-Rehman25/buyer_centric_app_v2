import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (email.isEmpty || password.isEmpty) {
        throw 'Email and password cannot be empty';
      }

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = UserModel(
        uid: result.user!.uid,
        email: result.user!.email!,
        username: result.user!.displayName,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            throw 'No user found with this email';
          case 'wrong-password':
            throw 'Wrong password';
          case 'invalid-email':
            throw 'Invalid email address';
          default:
            throw e.message ?? 'Authentication failed';
        }
      }
      rethrow;
    }
  }

  Future<void> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      _isLoading = true;
      notifyListeners();

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user!.updateDisplayName(username);

      _user = UserModel(
        uid: result.user!.uid,
        email: result.user!.email!,
        username: username,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      throw 'Failed to sign out: ${e.toString()}';
    }
  }

  Future<void> checkAuthState() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _user = UserModel(
        uid: currentUser.uid,
        email: currentUser.email!,
        username: currentUser.displayName,
      );
      notifyListeners();
    }
  }
}
