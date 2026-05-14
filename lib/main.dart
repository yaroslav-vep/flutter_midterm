import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'viewmodels/quiz_viewmodel.dart';
import 'ui/screens/welcome_screen.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase: инициализирован успешно');
  } catch (e) {
    debugPrint('Firebase Error: $e');
  }

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
      title: 'Flutter Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      // Стартовый экран — WelcomeScreen (он сам решит, куда дальше)
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}