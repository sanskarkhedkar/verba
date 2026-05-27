import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  const AuthService();

  bool get _isReady {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser {
    if (!_isReady) return null;
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges {
    if (!_isReady) return const Stream.empty();
    return _auth.authStateChanges();
  }

  // ─────────────────────────────────────────────────────────────
  // Anonymous Sign In
  // ─────────────────────────────────────────────────────────────

  Future<UserCredential> signInAnonymously() async {
    if (!_isReady) {
      throw Exception('Firebase not initialized');
    }

    return await _auth.signInAnonymously();
  }

  // ─────────────────────────────────────────────────────────────
  // Google Sign In
  // ─────────────────────────────────────────────────────────────

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId:
          '411659663243-i13s0deaio3vb7j16g3agqubo2iudvt4.apps.googleusercontent.com',
    );

    // Trigger Google Sign-In flow
    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign in cancelled');
    }

    // Get authentication tokens
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create Firebase credential
    final AuthCredential credential =
        GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User? currentUser = _auth.currentUser;

    // If anonymous user exists -> link account
    if (currentUser != null && currentUser.isAnonymous) {
      try {
        return await currentUser.linkWithCredential(
          credential,
        );
      } on FirebaseAuthException catch (e) {
        // Account already exists
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use' ||
            e.code ==
                'account-exists-with-different-credential') {
          try {
            await currentUser.delete();
          } catch (_) {}

          return await _auth.signInWithCredential(
            credential,
          );
        }

        rethrow;
      }
    }

    // Normal Google sign in
    return await _auth.signInWithCredential(
      credential,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Apple Sign In
  // ─────────────────────────────────────────────────────────────

  Future<UserCredential> signInWithApple() async {
    // Apple Sign-In does not work on iOS Simulator
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        !kIsWeb &&
        await _isSimulator()) {
      throw Exception(
        'Sign in with Apple is not supported on the iOS Simulator.\n'
        'Please test on a real iPhone device.',
      );
    }

    final appleCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential =
        OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken:
          appleCredential.authorizationCode,
    );

    final currentUser = _auth.currentUser;

    // Link anonymous account
    if (currentUser != null &&
        currentUser.isAnonymous) {
      try {
        return await currentUser
            .linkWithCredential(oauthCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code ==
                'credential-already-in-use' ||
            e.code ==
                'email-already-in-use' ||
            e.code ==
                'account-exists-with-different-credential') {
          try {
            await currentUser.delete();
          } catch (_) {}

          return await _auth
              .signInWithCredential(
            oauthCredential,
          );
        }

        rethrow;
      }
    }

    // Normal Apple sign in
    return await _auth.signInWithCredential(
      oauthCredential,
    );
  }

  Future<bool> _isSimulator() async {
    return !await SignInWithApple.isAvailable();
  }

  // ─────────────────────────────────────────────────────────────
  // Email / Password
  // ─────────────────────────────────────────────────────────────

  Future<UserCredential> createWithEmail(
    String email,
    String password,
  ) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail(
    String email,
    String password,
  ) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Password Reset
  // ─────────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(
    String email,
  ) {
    return _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Link Email To Anonymous
  // ─────────────────────────────────────────────────────────────

  Future<UserCredential> linkEmailToAnonymous(
    String email,
    String password,
  ) async {
    final credential =
        EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );

    return await _auth.currentUser!
        .linkWithCredential(credential);
  }

  // ─────────────────────────────────────────────────────────────
  // Sign Out
  // ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────────────────────
  // Delete Account
  // ─────────────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}