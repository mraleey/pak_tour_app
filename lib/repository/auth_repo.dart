import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Force account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user);
        await _saveUserToPrefs(user); // ⬅️ this is where it saves
      }

      return user;
    } catch (e) {
      debugPrint("❌ Login error: $e");
      rethrow;
    }
  }


  /// Save user to Firestore
  Future<void> _saveUserToFirestore(User? user) async {
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);

    await userDoc.set({
      'uid': user.uid,
      'name': user.displayName,
      'email': user.email,
      'photoUrl': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Save user to SharedPreferences
  Future<void> _saveUserToPrefs(User user) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', user.uid);
      await prefs.setString('email', user.email ?? '');
      await prefs.setString('name', user.displayName ?? '');
      await prefs.setString('photoUrl', user.photoURL ?? '');
      debugPrint("✅ Saved UID: ${user.uid}");
      debugPrint("✅ Saved Email: ${user.email}");
    } catch (e) {
      debugPrint("❌ Error saving to SharedPreferences: $e");
    }
  }


  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _firebaseAuth.currentUser != null;
  }

  /// Get user data from SharedPreferences
  Future<Map<String, String?>> getUserFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'uid': prefs.getString('uid'),
      'email': prefs.getString('email'),
      'name': prefs.getString('name'),
      'photoUrl': prefs.getString('photoUrl'),
    };
  }

  /// Get Firebase current user directly
  User? get currentUser => _firebaseAuth.currentUser;
}
