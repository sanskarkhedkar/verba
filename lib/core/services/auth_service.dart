import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  const AuthService();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Anonymous ──────────────────────────────────────────────────────────────
  Future<UserCredential> signInAnonymously() =>
      _auth.signInAnonymously();

  // ── Google ─────────────────────────────────────────────────────────────────
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final currentUser = _auth.currentUser;
    // Link anonymous account to Google, or sign in fresh
    if (currentUser != null && currentUser.isAnonymous) {
      return currentUser.linkWithCredential(credential);
    }
    return _auth.signInWithCredential(credential);
  }

  // ── Apple ──────────────────────────────────────────────────────────────────
  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      return currentUser.linkWithCredential(oauthCredential);
    }
    return _auth.signInWithCredential(oauthCredential);
  }

  // ── Email/Password ─────────────────────────────────────────────────────────
  Future<UserCredential> createWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);

  // ── Password reset ─────────────────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  // ── Link anonymous account to email/password ───────────────────────────────
  Future<UserCredential> linkEmailToAnonymous(
      String email, String password) async {
    final credential =
        EmailAuthProvider.credential(email: email.trim(), password: password);
    return _auth.currentUser!.linkWithCredential(credential);
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // ── Delete account ─────────────────────────────────────────────────────────
  Future<void> deleteAccount() => _auth.currentUser!.delete();
}
