import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:semaphore_quiz/presentation/score/model/score_history.dart';

class ScoreHistoryService {
  ScoreHistoryService._();

  static final ScoreHistoryService instance = ScoreHistoryService._();
  static const String _storageKey = 'score_history';

  Future<List<ScoreHistory>> getHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final rawHistory = preferences.getStringList(_storageKey) ?? <String>[];

    final history = <ScoreHistory>[];
    for (final rawItem in rawHistory) {
      try {
        final json = jsonDecode(rawItem) as Map<String, dynamic>;
        history.add(ScoreHistory.fromJson(json));
      } catch (_) {
        // Abaikan data lama/rusak agar halaman riwayat tetap dapat dibuka.
      }
    }

    history.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return history;
  }

  Future<void> saveScore(ScoreHistory scoreHistory) async {
    final preferences = await SharedPreferences.getInstance();
    final history = preferences.getStringList(_storageKey) ?? <String>[];
    history.add(jsonEncode(scoreHistory.toJson()));
    await preferences.setStringList(_storageKey, history);
  }

  Future<void> clearHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
