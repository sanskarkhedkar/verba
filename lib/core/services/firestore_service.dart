import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/onboarding/models/onboarding_state.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.targetLanguage,
    required this.level,
    required this.goalCategory,
    required this.dailyGoalMinutes,
    required this.focusAreas,
    this.xp = 0,
    this.streak = 0,
    this.wordsLearned = 0,
    this.lessonsCompleted = 0,
    this.isPremium = false,
    this.onboardingComplete = false,
    this.notificationTime,
    this.fcmToken,
  });

  final String uid;
  final String displayName;
  final String targetLanguage;
  final String level;
  final String goalCategory;
  final int dailyGoalMinutes;
  final List<String> focusAreas;
  final int xp;
  final int streak;
  final int wordsLearned;
  final int lessonsCompleted;
  final bool isPremium;
  final bool onboardingComplete;
  final String? notificationTime;
  final String? fcmToken;

  factory UserProfile.fromOnboarding(String uid, OnboardingState state) {
    return UserProfile(
      uid: uid,
      displayName: state.displayName,
      targetLanguage: state.targetLanguage,
      level: state.level,
      goalCategory: state.goalCategory,
      dailyGoalMinutes: state.dailyGoalMinutes,
      focusAreas: state.focusAreas,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'targetLanguage': targetLanguage,
        'level': level,
        'goalCategory': goalCategory,
        'dailyGoalMinutes': dailyGoalMinutes,
        'focusAreas': focusAreas,
        'xp': xp,
        'streak': streak,
        'wordsLearned': wordsLearned,
        'lessonsCompleted': lessonsCompleted,
        'isPremium': isPremium,
        'onboardingComplete': onboardingComplete,
        'notificationTime': notificationTime,
        'fcmToken': fcmToken,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// Firestore read/write operations for Verba user data.
class FirestoreService {
  const FirestoreService();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection('users');

  // ── User Profile ──────────────────────────────────────────────────────────
  Future<void> createUserProfile(UserProfile profile) =>
      _users.doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String uid) {
    return _users.doc(uid).snapshots().cast<DocumentSnapshot<Map<String, dynamic>>>();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) =>
      (_users.doc(uid) as DocumentReference<Map<String, dynamic>>).get();

  // ── Progress updates ──────────────────────────────────────────────────────
  Future<void> addXp(String uid, int xp) => _users.doc(uid).update({
        'xp': FieldValue.increment(xp),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> recordLessonComplete(
      String uid, int xpGained, int wordsCount) async {
    await _users.doc(uid).update({
      'xp': FieldValue.increment(xpGained),
      'lessonsCompleted': FieldValue.increment(1),
      'wordsLearned': FieldValue.increment(wordsCount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFcmToken(String uid, String token) =>
      _users.doc(uid).update({'fcmToken': token});

  Future<void> markOnboardingComplete(String uid) => _users.doc(uid).update({
        'onboardingComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> updateSubscription(String uid, {required bool isPremium}) =>
      _users.doc(uid).set({
        'isPremium': isPremium,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  // ── Saved phrases (phrasebook) ─────────────────────────────────────────────
  Future<void> savePhrase(String uid, Map<String, dynamic> phrase) =>
      _users.doc(uid).collection('phrases').add({
        ...phrase,
        'savedAt': FieldValue.serverTimestamp(),
      });

  Stream<QuerySnapshot<Map<String, dynamic>>> getPhrases(String uid) {
    // ignore: unnecessary_cast — Firestore requires explicit typed reference
    final col = _users
        .doc(uid)
        .collection('phrases') as CollectionReference<Map<String, dynamic>>;
    return col.orderBy('savedAt', descending: true).limit(50).snapshots();
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> fields) =>
      _users.doc(uid).update({
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  // ── Account deletion ──────────────────────────────────────────────────────
  Future<void> deleteUserData(String uid) async {
    final phrases = await _users.doc(uid).collection('phrases').get();
    for (final doc in phrases.docs) {
      await doc.reference.delete();
    }
    await _users.doc(uid).delete();
  }
}
