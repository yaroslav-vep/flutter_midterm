import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Событие: Начало теста
  Future<void> logQuizStart() async {
    await _analytics.logEvent(
      name: 'quiz_started',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    debugPrint('Analytics: Quiz Started');
  }

  /// Событие: Ответ на вопрос
  Future<void> logAnswer(String questionText, String selectedOption, bool isCorrect) async {
    await _analytics.logEvent(
      name: 'answer_selected',
      parameters: {
        'question': questionText.length > 40 ? questionText.substring(0, 40) : questionText,
        'option': selectedOption,
        'is_correct': isCorrect ? 1 : 0,
      },
    );
    debugPrint('Analytics: Answer Logged');
  }

  /// Событие: Завершение теста
  Future<void> logQuizComplete(int score, int total) async {
    await _analytics.logEvent(
      name: 'quiz_completed',
      parameters: {
        'final_score': score,
        'total_questions': total,
        'percent': (score / total * 100).round(),
      },
    );
    debugPrint('Analytics: Quiz Completed');
  }
}
