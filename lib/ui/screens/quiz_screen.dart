import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../viewmodels/quiz_viewmodel.dart';
import '../widgets/question_widget.dart';
import '../widgets/coach_mark_overlay.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final GlobalKey _questionTextKey = GlobalKey();
  final GlobalKey _answersKey = GlobalKey();
  final GlobalKey _nextButtonKey = GlobalKey();
  bool _showCoachMarks = false;

  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
  }

  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('quiz_coach_done') ?? false;
    if (!seen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showCoachMarks = true);
      });
    }
  }

  Future<void> _dismissCoachMarks() async {
    setState(() => _showCoachMarks = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quiz_coach_done', true);
  }

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
      body: Stack(
        children: [
          // Основной контент
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.currentQuestion.text,
                  key: _questionTextKey,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Container(
                  key: _answersKey,
                  child: const QuestionWidget(),
                ),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    key: _nextButtonKey,
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

          // Подсказки поверх экрана
          if (_showCoachMarks)
            CoachMarkOverlay(
              steps: [
                CoachMarkStep(
                  targetKey: _questionTextKey,
                  title: '📖 Вопрос',
                  description: 'Здесь отображается текст вопроса. Внимательно прочитайте его перед тем, как выбрать ответ.',
                ),
                CoachMarkStep(
                  targetKey: _answersKey,
                  title: '✅ Варианты ответа',
                  description: 'Выберите один из вариантов. После выбора активируется кнопка «Далее».',
                ),
                CoachMarkStep(
                  targetKey: _nextButtonKey,
                  title: '➡️ Следующий вопрос',
                  description: 'Нажмите, чтобы перейти к следующему вопросу. На последнем вопросе кнопка покажет «Проверить результат».',
                ),
              ],
              onFinish: _dismissCoachMarks,
            ),
        ],
      ),
    );
  }
}