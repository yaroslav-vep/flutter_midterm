import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuizRepository {
  Future<List<Question>> loadQuestions() async {
    try {
      final String data = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Ошибка загрузки вопросов: $e');
    }
  }
}