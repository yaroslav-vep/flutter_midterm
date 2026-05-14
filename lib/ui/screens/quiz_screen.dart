import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quiz_viewmodel.dart';
import '../widgets/question_widget.dart';
import 'result_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuizViewModel>(context);

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.error != null) {
      return Scaffold(body: Center(child: Text('Ошибка: ${vm.error}')));
    }

    if (vm.isQuizFinished) {
      return const ResultScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Вопрос ${vm.currentIndex + 1} из ${vm.totalQuestions}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vm.currentQuestion.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const QuestionWidget(),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: vm.selectedAnswer == null ? null : () {
                  vm.nextQuestion();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: Text(
                  vm.currentIndex < vm.totalQuestions - 1 ? 'Далее' : 'Проверить результат',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}