import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class QuizRemoteDataSource {
  Future<void> unlockLevel(int level);
  Future<void> saveLevelStars(int level, int stars);
  Future<int> getLastUnlockedLevel();
  Future<Map<int, int>> getAllLevelStars();
  Future<void> saveLevelScore(int level, int score);
  Future<Map<int, int>> getAllLevelScores();
  Future<void> saveLevelBonus(int level, int bonus);
  Future<Map<int, int>> getAllLevelBonuses();
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  QuizRemoteDataSourceImpl({required this.firestore, required this.auth});

  String get _uid => auth.currentUser?.uid ?? '';

  DocumentReference get _userQuizDoc {
    if (_uid.isEmpty) throw Exception('User not logged in');
    return firestore
        .collection('users')
        .doc(_uid)
        .collection('games')
        .doc('quiz');
  }

  @override
  Future<void> unlockLevel(int level) async {
    if (_uid.isEmpty) return;

    final docSnapshot = await _userQuizDoc.get();
    int currentUnlocked = 1;
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      currentUnlocked = data['last_unlocked_level'] ?? 1;
    }

    if (level > currentUnlocked) {
      await _userQuizDoc.set({
        'last_unlocked_level': level,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Future<void> saveLevelStars(int level, int stars) async {
    if (_uid.isEmpty) return;

    await _userQuizDoc.set({
      'stars': {level.toString(): stars},
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<int> getLastUnlockedLevel() async {
    if (_uid.isEmpty) return 1;

    try {
      final docSnapshot = await _userQuizDoc.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['last_unlocked_level'] ?? 1;
      }
    } catch (e) {
      // Ignore errors
    }
    return 1;
  }

  @override
  Future<Map<int, int>> getAllLevelStars() async {
    if (_uid.isEmpty) return {};

    try {
      final docSnapshot = await _userQuizDoc.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final starsMap = data['stars'] as Map<String, dynamic>? ?? {};

        return starsMap.map(
          (key, value) => MapEntry(int.parse(key), value as int),
        );
      }
    } catch (e) {
      // Ignore
    }
    return {};
  }

  @override
  Future<void> saveLevelScore(int level, int score) async {
    if (_uid.isEmpty) return;

    await _userQuizDoc.set({
      'scores': {level.toString(): score},
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<Map<int, int>> getAllLevelScores() async {
    if (_uid.isEmpty) return {};

    try {
      final docSnapshot = await _userQuizDoc.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final scoresMap = data['scores'] as Map<String, dynamic>? ?? {};

        return scoresMap.map(
          (key, value) => MapEntry(int.parse(key), value as int),
        );
      }
    } catch (e) {
      // Ignore
    }
    return {};
  }

  @override
  Future<void> saveLevelBonus(int level, int bonus) async {
    if (_uid.isEmpty) return;

    await _userQuizDoc.set({
      'bonuses': {level.toString(): bonus},
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<Map<int, int>> getAllLevelBonuses() async {
    if (_uid.isEmpty) return {};

    try {
      final docSnapshot = await _userQuizDoc.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final bonusesMap = data['bonuses'] as Map<String, dynamic>? ?? {};

        return bonusesMap.map(
          (key, value) => MapEntry(int.parse(key), value as int),
        );
      }
    } catch (e) {
      // Ignore
    }
    return {};
  }
}
