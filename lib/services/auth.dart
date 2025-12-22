import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.sendEmailVerification();

      Fluttertoast.showToast(
        msg: 'Verification link sent. Check inbox or spam.',
        toastLength: Toast.LENGTH_LONG,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: _getErrorMessage(e.code));
      return null;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
      return null;
    }
  }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null && !cred.user!.emailVerified) {
        Fluttertoast.showToast(
          msg: 'Please verify your email first.',
          toastLength: Toast.LENGTH_LONG,
        );
        await _auth.signOut();
        return null;
      }
      return cred.user;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: _getErrorMessage(e.code));
      return null;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
      return null;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Fluttertoast.showToast(msg: 'Verification email resent.');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to resend: $e');
    }
  }

  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> logout() async => await _auth.signOut();

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email already in use';
      case 'invalid-email':
        return 'Invalid email';
      case 'weak-password':
        return 'Weak password';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Wrong password';
      case 'too-many-requests':
        return 'Too many attempts. Try later';
      default:
        return 'Error: $code';
    }
  }
}