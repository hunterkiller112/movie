import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future<User> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    var credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User user = credential.user!;
    await user.updateDisplayName(name);
    await user.sendEmailVerification();
    return user;
  }

  static Future<User> login({
    required String email,
    required String password,
  }) async {
    var credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  static Future<void> resetPassword({required String email}) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }
}
