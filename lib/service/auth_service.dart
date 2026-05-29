import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/token_manager.dart';
import '../model/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Login using Firebase Auth
  Future<UserModel> login(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Login gagal: User tidak ditemukan');
    }

    // Get ID token
    final token = await firebaseUser.getIdToken() ?? '';

    // Fetch user profile from Firestore
    final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!userDoc.exists) {
      throw Exception('Profil user tidak ditemukan di database.');
    }

    final userData = userDoc.data()!;
    final user = UserModel(
      id: firebaseUser.uid,
      name: userData['name'] ?? firebaseUser.displayName ?? 'No Name',
      email: firebaseUser.email ?? email,
      token: token,
    );

    // Save token and user data locally
    await TokenManager.saveToken(token);
    await TokenManager.saveUserData(user.name);
    return user;
  }

  /// Logout using Firebase Auth
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } finally {
      await TokenManager.clearAll();
    }
  }
}
