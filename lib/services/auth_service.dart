import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('users');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

      // Check if email is verified
      if (!result.user!.emailVerified) {
        await _auth.signOut();
        _user = null;
        notifyListeners();
        throw Exception('Please verify your email first');
      }

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

      // Check if username already exists
      final usernameExists = await _checkIfUsernameExists(username);
      if (usernameExists) {
        throw Exception('This username is already taken');
      }

      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(username);

      // Send verification email
      await result.user?.sendEmailVerification();

      // Sign out the user immediately
      await _auth.signOut();
      _user = null;
      notifyListeners();

      // Store user data in Firestore with verification status
      await _firestore.collection('users').doc(result.user?.uid).set({
        'uid': result.user?.uid,
        'email': email.trim(),
        'username': username,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

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
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await _auth.signOut();
      _user = null;
      notifyListeners();
      return;
    }
    await _updateUserModel(user);
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

  //* Store username in Firestore for chat purposes
  Future<void> _storeUsernameForChat(User? user, String username) async {
    if (user != null) {
      await _firestore.collection('usernames').doc(username).set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  //* Check if username already exists in the usernames collection
  Future<bool> _checkIfUsernameExists(String username) async {
    try {
      final doc = await _firestore.collection('usernames').doc(username).get();
      return doc.exists;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  Future<bool> checkIfUserExists(String email) async {
    try {
      // Query Firestore to check if a user with this email exists
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  //* Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      if (email.isEmpty) {
        throw Exception('Email cannot be empty');
      }

      // Check if user exists before sending reset email
      final userExists = await checkIfUserExists(email);
      if (!userExists) {
        throw Exception('No account found with this email address');
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    } finally {
      _setLoading(false);
    }
  }
}
