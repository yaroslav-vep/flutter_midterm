import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import '../../core/services/notification_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Quiz')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Тест по Dart и Flutter', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                // Отправляем уведомление о старте теста
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
    );
  }
}