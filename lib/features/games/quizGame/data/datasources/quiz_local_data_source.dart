import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../../core/services/local_storage_service.dart';
import '../models/quiz_question_model.dart';

abstract class QuizLocalDataSource {
  Future<List<QuizQuestionModel>> getQuestions();
  Future<int> getLastUnlockedLevel();
  Future<void> unlockLevel(int level);
  Future<void> saveLevelStars(int level, int stars);
  Future<int> getLevelStars(int level);
  Future<void> saveLevelScore(int level, int score);
  Future<int> getLevelScore(int level);
  Future<void> saveLevelBonus(int level, int bonus);
  Future<int> getLevelBonus(int level);
}

class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  final LocalStorageService localStorage;
  static const String _quizBox = 'quiz_box';
  static const String _progressKey = 'quiz_progress';

  QuizLocalDataSourceImpl({required this.localStorage});

  @override
  Future<List<QuizQuestionModel>> getQuestions() async {
    final String response = await rootBundle.loadString(
      'assets/data/quiz_questions.json',
    );
    final List<dynamic> data = json.decode(response);
    return data.map((json) => QuizQuestionModel.fromJson(json)).toList();
  }

  @override
  Future<int> getLastUnlockedLevel() async {
    final data = await localStorage.get(_quizBox, _progressKey);
    return data?['last_unlocked_level'] ?? 1;
  }

  @override
  Future<void> unlockLevel(int level) async {
    final currentData = await localStorage.get(_quizBox, _progressKey) ?? {};
    final currentUnlocked = currentData['last_unlocked_level'] ?? 1;
    if (level > currentUnlocked) {
      currentData['last_unlocked_level'] = level;
      await localStorage.save(
        _quizBox,
        _progressKey,
        Map<String, dynamic>.from(currentData),
      );
    }
  }

  @override
  Future<void> saveLevelStars(int level, int stars) async {
    final currentData = await localStorage.get(_quizBox, _progressKey) ?? {};
    Map<String, dynamic> starsMap = Map<String, dynamic>.from(
      currentData['stars'] ?? {},
    );
    starsMap[level.toString()] = stars;
    currentData['stars'] = starsMap;
    await localStorage.save(
      _quizBox,
      _progressKey,
      Map<String, dynamic>.from(currentData),
    );
  }

  @override
  Future<int> getLevelStars(int level) async {
    final data = await localStorage.get(_quizBox, _progressKey);
    final starsMap = data?['stars'] ?? {};
    return starsMap[level.toString()] ?? 0;
  }

  @override
  Future<void> saveLevelScore(int level, int score) async {
    final currentData = await localStorage.get(_quizBox, _progressKey) ?? {};
    Map<String, dynamic> scoresMap = Map<String, dynamic>.from(
      currentData['scores'] ?? {},
    );
    final currentHighScore = scoresMap[level.toString()] ?? 0;
    if (score > currentHighScore) {
      scoresMap[level.toString()] = score;
      currentData['scores'] = scoresMap;
      await localStorage.save(
        _quizBox,
        _progressKey,
        Map<String, dynamic>.from(currentData),
      );
    }
  }

  @override
  Future<int> getLevelScore(int level) async {
    final data = await localStorage.get(_quizBox, _progressKey);
    final scoresMap = data?['scores'] ?? {};
    return scoresMap[level.toString()] ?? 0;
  }

  @override
  Future<void> saveLevelBonus(int level, int bonus) async {
    final currentData = await localStorage.get(_quizBox, _progressKey) ?? {};
    Map<String, dynamic> bonusesMap = Map<String, dynamic>.from(
      currentData['bonuses'] ?? {},
    );
    final currentHighBonus = bonusesMap[level.toString()] ?? 0;
    if (bonus > currentHighBonus) {
      bonusesMap[level.toString()] = bonus;
      currentData['bonuses'] = bonusesMap;
      await localStorage.save(
        _quizBox,
        _progressKey,
        Map<String, dynamic>.from(currentData),
      );
    }
  }

  @override
  Future<int> getLevelBonus(int level) async {
    final data = await localStorage.get(_quizBox, _progressKey);
    final bonusesMap = data?['bonuses'] ?? {};
    return bonusesMap[level.toString()] ?? 0;
  }
}
