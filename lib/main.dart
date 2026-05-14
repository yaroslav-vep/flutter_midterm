import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/quiz_viewmodel.dart';
import 'ui/screens/home_screen.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  // Обязательно для асинхронных операций до runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем сервис уведомлений
  await NotificationService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => QuizViewModel()..loadQuestions(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quiz - Ваша Фамилия',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}