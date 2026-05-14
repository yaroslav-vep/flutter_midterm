import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quiz_viewmodel.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuizViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Результат')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Правильных: ${vm.score} из ${vm.totalQuestions}', style: const TextStyle(fontSize: 24)),
              Text('${vm.getPercent().toStringAsFixed(1)}%', style: const TextStyle(fontSize: 32)),
              Text(vm.getResultText(), style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 20),
              const Text('Детальный разбор:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...List.generate(vm.totalQuestions, (index) {
                final question = vm.questions[index];
                final userAnswer = vm.userAnswers[index];
                final isCorrect = userAnswer == question.correctIndex;
                return Card(
                  color: isCorrect ? Colors.green[100] : Colors.red[100],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Вопрос ${index + 1}: ${question.text}'),
                        Text('Ваш ответ: ${userAnswer != null ? question.options[userAnswer] : 'Не отвечено'}'),
                        Text('Правильный: ${question.options[question.correctIndex]}'),
                        Text(isCorrect ? 'Правильно!' : 'Неправильно'),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      vm.reset();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
                    },
                    child: const Text('Пройти ещё раз'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      vm.reset();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                    },
                    child: const Text('На главную'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}