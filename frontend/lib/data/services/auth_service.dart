// File: lib/data/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Cek user saat ini
  User? get currentUser => _firebaseAuth.currentUser;

  // Login Email
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<User?> signUpWithEmail(String email, String password, String name) async {
    try {
      // 1. Buat akun di Firebase
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 2. Update Nama Pengguna (DisplayName)
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload(); // Refresh data user
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Login Google
  Future<User?> loginWithGoogle() async {
    try {
      // 1. Memicu flow autentikasi
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // Jika user membatalkan login (menutup pop-up)
      if (googleUser == null) return null;

      // 2. Mendapatkan detail otentikasi
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Membuat kredensial baru untuk Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in ke Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw Exception('Google Sign In Gagal: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}