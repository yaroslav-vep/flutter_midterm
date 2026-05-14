import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_screen.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/analytics_service.dart';
import '../widgets/coach_mark_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Ключи для подсказок
  final GlobalKey _startButtonKey = GlobalKey();
  final GlobalKey _titleKey = GlobalKey();
  bool _showCoachMarks = false;

  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
  }

  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('home_coach_done') ?? false;
    if (!seen) {
      // Ждём пока виджеты отрисуются, затем показываем подсказки
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showCoachMarks = true);
      });
    }
  }

  Future<void> _dismissCoachMarks() async {
    setState(() => _showCoachMarks = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('home_coach_done', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Quiz')),
      body: Stack(
        children: [
          // Основной контент
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Тест по Dart и Flutter',
                  key: _titleKey,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  key: _startButtonKey,
                  onPressed: () async {
                    await AnalyticsService().logQuizStart();
                    await NotificationService().showStartNotification();

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuizScreen()),
                      );
                    }
                  },
                  child: const Text('Начать тест', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),

          // Подсказки поверх экрана
          if (_showCoachMarks)
            CoachMarkOverlay(
              steps: [
                CoachMarkStep(
                  targetKey: _titleKey,
                  title: '👋 Добро пожаловать!',
                  description: 'Это ваш тест по Dart и Flutter. Здесь вы проверите свои знания.',
                ),
                CoachMarkStep(
                  targetKey: _startButtonKey,
                  title: '🚀 Начните тест',
                  description: 'Нажмите эту кнопку, чтобы начать отвечать на вопросы. Вы получите уведомление о старте.',
                ),
              ],
              onFinish: _dismissCoachMarks,
            ),
        ],
      ),
    );
  }
}