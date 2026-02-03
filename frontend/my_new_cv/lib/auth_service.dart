import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> loginWithPython() async {
    try {
      // 1. ከጎግል ቶከን ማግኘት
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // 2. ቶከኑን ወደ Python API መላክ
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8005/api/sync-cv/google-login'),
        body: jsonEncode({'idToken': googleAuth.idToken}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // ሎጊን ተሳክቷል!
        return true;
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

// በ auth_service.dart ውስጥ መጨመር ያለበት
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }
}
