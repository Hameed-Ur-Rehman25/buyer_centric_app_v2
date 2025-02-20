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

  //* Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //* Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate email and password
      if (email.isEmpty || password.isEmpty) {
        throw 'Email and password cannot be empty';
      }

      // Attempt to sign in
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update user model
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
        // Handle specific Firebase authentication errors
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

  //* Sign up with email, password, and username
  Future<void> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Attempt to create a new user
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name
      await result.user!.updateDisplayName(username);

      // Update user model
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

  //* Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      throw 'Failed to sign out: ${e.toString()}';
    }
  }

  //* Check the current authentication state
  Future<void> checkAuthState() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Update user model if a user is currently signed in
      _user = UserModel(
        uid: currentUser.uid,
        email: currentUser.email!,
        username: currentUser.displayName,
      );
      notifyListeners();
    }
  }
}
