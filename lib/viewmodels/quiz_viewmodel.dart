import 'package:flutter/material.dart';
import '../data/quiz_repository.dart';
import '../models/question.dart';
import '../core/services/notification_service.dart';
import '../core/services/analytics_service.dart'; // Импорт аналитики

class QuizViewModel extends ChangeNotifier {
  final QuizRepository _repository = QuizRepository();
  final NotificationService _notifications = NotificationService();
  final AnalyticsService _analytics = AnalyticsService(); // Сервис аналитики

  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  List<int?> _userAnswers = [];
  bool _isLoading = true;
  String? _error;
  bool _isQuizFinished = false;

  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  int get totalQuestions => _questions.length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Question get currentQuestion => _questions[_currentIndex];
  int? get selectedAnswer => _selectedAnswer;
  List<int?> get userAnswers => _userAnswers;
  bool get isQuizFinished => _isQuizFinished;

  Future<void> loadQuestions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _questions = await _repository.loadQuestions();
      if (_questions.isEmpty) {
        _error = 'Нет вопросов';
      } else {
        _userAnswers = List<int?>.filled(_questions.length, null);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAnswer(int index) {
    _selectedAnswer = index;
    _userAnswers[_currentIndex] = index;
    notifyListeners();
  }

  void nextQuestion() {
    if (_selectedAnswer != null) {
      bool isCorrect = _selectedAnswer == currentQuestion.correctIndex;
      if (isCorrect) {
        _score++;
      }

      // ЛОГИРУЕМ ОТВЕТ: какой вопрос, какой вариант и правильно ли
      _analytics.logAnswer(
        currentQuestion.text,
        currentQuestion.options[_selectedAnswer!],
        isCorrect,
      );
    }

    _selectedAnswer = null;

    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;

      if (_currentIndex % 5 == 0) {
        _notifications.showProgressNotification(_currentIndex);
      }
    } else {
      _isQuizFinished = true;

      // ЛОГИРУЕМ ЗАВЕРШЕНИЕ: итоговый результат
      _analytics.logQuizComplete(_score, totalQuestions);

      _notifications.showResultNotification(
        score: _score,
        total: totalQuestions,
        percent: getPercent(),
        resultText: getResultText(),
      );
    }

    notifyListeners();
  }

  void reset() {
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _isQuizFinished = false;
    _userAnswers = List<int?>.filled(_questions.length, null);
    
    // ЛОГИРУЕМ ПЕРЕЗАПУСК (как старт нового теста)
    _analytics.logQuizStart();
    
    notifyListeners();
  }

  String getResultText() {
    double percent = totalQuestions > 0 ? (_score / totalQuestions) * 100 : 0;
    if (percent < 50) return 'Нужно подтянуть знания';
    if (percent < 80) return 'Хорошо!';
    return 'Отлично!';
  }

  double getPercent() {
    return totalQuestions > 0 ? (_score / totalQuestions) * 100 : 0;
  }
}