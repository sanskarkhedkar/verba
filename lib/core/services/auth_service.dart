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

  // ── Anonymous ──────────────────────────────────────────────────────────────
  Future<UserCredential> signInAnonymously() {
    if (!_isReady) throw Exception('Firebase not initialized');
    return _auth.signInAnonymously();
  }

  bool _isChannelError(Object e) {
    if (e is FirebaseAuthException && e.code == 'channel-error') return true;
    final s = e.toString();
    return s.contains('channel-error') || s.contains('FirebaseAuthHostApi');
  }

  // After GoogleSignIn().signIn() or SignInWithApple() returns, the Flutter
  // activity is resuming from a sub-activity (SignInHubActivity / ASWebAuth).
  // During this transition, firebase_auth's onAttachedToActivity re-runs on
  // the Android main thread to re-bind FirebaseAuthHostApi, while the Dart
  // side immediately wants to call signInWithCredential through that same
  // Pigeon channel — causing the channel-error race.
  //
  // The fix: make a cheap, side-effect-free FirebaseAuthHostApi call right
  // after the external sign-in returns. Once that call succeeds we know the
  // Pigeon binding is complete and signInWithCredential will succeed.
  // signOut() is a genuine no-op when no user is signed in; getIdToken()
  // is safe to call on an existing (anonymous) user.
  Future<void> _warmUpAuthChannel() async {
    const maxAttempts = 6;
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await user.getIdToken(); // uses FirebaseAuthHostApi
        } else {
          await _auth.signOut(); // uses FirebaseAuthHostApi; no-op with no user
        }
        return; // channel is bound
      } catch (e) {
        if (!_isChannelError(e) || i == maxAttempts - 1) return;
        await Future<void>.delayed(Duration(milliseconds: 200 * (i + 1)));
      }
    }
  }

  Future<UserCredential> _signInWithCredentialResilient(
    AuthCredential credential,
  ) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await _auth.signInWithCredential(credential);
      } catch (e) {
        if (!_isChannelError(e)) rethrow;
        if (attempt == 2) rethrow;
        // Exponential back-off: 600 ms, 1 200 ms — gives the Pigeon channel
        // time to fully bind on slow/cold-start devices.
        await Future<void>.delayed(Duration(milliseconds: 600 * (attempt + 1)));
      }
    }
    // Unreachable but required by the type system.
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> _linkWithCredentialResilient(
    User user,
    AuthCredential credential,
  ) async {
    try {
      return await user.linkWithCredential(credential);
    } catch (e) {
      if (!_isChannelError(e)) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return user.linkWithCredential(credential);
    }
  }

  // ── Google ─────────────────────────────────────────────────────────────────
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    // signIn() launches SignInHubActivity. When it finishes, firebase_auth's
    // onAttachedToActivity re-binds FirebaseAuthHostApi concurrently with our
    // return to Dart. Warm up the Pigeon channel before the credential call
    // so that race is resolved before we need the channel.
    await _warmUpAuthChannel();

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      try {
        return await _linkWithCredentialResilient(currentUser, credential);
      } on FirebaseAuthException catch (e) {
        // Account already exists — just sign in directly
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use' ||
            e.code == 'account-exists-with-different-credential') {
          return _signInWithCredentialResilient(e.credential ?? credential);
        }
        rethrow;
      }
    }
    return _signInWithCredentialResilient(credential);
  }

  // ── Apple ──────────────────────────────────────────────────────────────────
  Future<UserCredential> signInWithApple() async {
    // Sign in with Apple does not work on iOS Simulator.
    // It requires a real device with an Apple ID signed in via Settings.
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        !kIsWeb &&
        await _isSimulator()) {
      throw Exception(
        'Sign in with Apple is not supported on the iOS Simulator.\n'
        'Please test on a real iPhone device.',
      );
    }

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // Same race as Google sign-in: ASWebAuthenticationSession / SFSafariVC
    // causes a view-controller transition that can disrupt the Pigeon binding.
    await _warmUpAuthChannel();

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      try {
        return await _linkWithCredentialResilient(currentUser, oauthCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use' ||
            e.code == 'account-exists-with-different-credential') {
          return _signInWithCredentialResilient(
              e.credential ?? oauthCredential);
        }
        rethrow;
      }
    }
    return _signInWithCredentialResilient(oauthCredential);
  }

  /// Returns true when running inside the iOS Simulator.
  Future<bool> _isSimulator() async {
    // sign_in_with_apple exposes a static availability check
    return !await SignInWithApple.isAvailable();
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
