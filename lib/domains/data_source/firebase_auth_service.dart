import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  Stream<User?> get user {
    return FirebaseAuth.instance
        .authStateChanges()
        .map((firebaseUser) => firebaseUser);
  }

  Future<String?> loginWithEmailAndPass({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Không có lỗi, trả về null
    } on FirebaseAuthException catch (e) {
      return e.message; // Trả về thông báo lỗi
    }
  }

}
