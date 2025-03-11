import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('users');
  UserModel? _user;
  bool _isLoading = false;

  //* Getters for user authentication state
  UserModel? get user => _user;
  UserModel? get currentUser => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _auth.currentUser != null;

  //* Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //* Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _updateUserModel(result.user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    } finally {
      _setLoading(false);
    }
  }

  //* Sign up with email, password, and username
  Future<void> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    _setLoading(true);
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        throw Exception('All fields are required');
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await result.user?.updateDisplayName(username);
      await _updateUserModel(result.user);

      // Store user data in Firebase Realtime Database
      await _storeUserData(result.user, username);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    } finally {
      _setLoading(false);
    }
  }

  //* Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  //* Check and update authentication state
  Future<void> checkAuthState() async {
    await _updateUserModel(_auth.currentUser);
  }

  //* Helper method to update the user model
  Future<void> _updateUserModel(User? firebaseUser) async {
    if (firebaseUser != null) {
      _user = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        username: firebaseUser.displayName ?? 'Unknown',
        profileImage: firebaseUser.photoURL ?? '',
      );
    } else {
      _user = null;
    }
    notifyListeners();
  }

  //* Helper method to set loading state
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  //* Handle Firebase authentication errors
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'weak-password':
        return 'Your password is too weak';
      case 'network-request-failed':
        return 'Please check your internet connection';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  //* Store user data in Firebase Realtime Database
  Future<void> _storeUserData(User? user, String username) async {
    if (user != null) {
      await _dbRef.child(user.uid).set({
        'username': username,
        'email': user.email,
      });
    }
  }
}
