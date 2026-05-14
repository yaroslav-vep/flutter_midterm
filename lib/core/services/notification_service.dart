import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Импорт FCM

/// Сервис для управления уведомлениями (Локальные + Firebase).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();
  
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'quiz_channel',
    'Quiz Notifications',
    description: 'Уведомления приложения Quiz',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Инициализация локальных уведомлений
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Уведомление нажато: ${details.payload}');
      },
    );

    // 2. Настройка FCM (Cloud Messaging)
    await _setupFirebaseMessaging();

    _initialized = true;
    debugPrint('NotificationService: Полная инициализация завершена');
  }

  Future<void> _setupFirebaseMessaging() async {
    // Запрос разрешений для iOS/Android 13+
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('FCM: Разрешение получено');
      
      // Получение токена (нужен для отправки уведомлений конкретному пользователю)
      String? token = await _fcm.getToken();
      debugPrint('FCM Token: $token'); // Выводим в консоль для тестов
    }

    // Обработка уведомлений, когда приложение открыто (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Получено сообщение в foreground: ${message.notification?.title}');
      
      // Показываем локальное уведомление, так как в foreground они не всплывают сами
      if (message.notification != null) {
        _showLocalFromRemote(message.notification!);
      }
    });
  }

  /// Показ локального уведомления на основе данных из Firebase
  Future<void> _showLocalFromRemote(RemoteNotification notification) async {
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    await _localPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails),
    );
  }

  // --- Методы для локальных уведомлений (остаются без изменений) ---

  Future<void> showStartNotification() async {
    await _showNotification(
      id: 0,
      title: '🚀 Тест начат!',
      body: 'Удачи! Ответьте на все вопросы правильно',
    );
  }

  Future<void> showProgressNotification(int answeredCount) async {
    await _showNotification(
      id: 1,
      title: '💡 Продолжайте!',
      body: 'Вы ответили на $answeredCount вопросов. Так держать!',
    );
  }

  Future<void> showResultNotification({
    required int score,
    required int total,
    required double percent,
    required String resultText,
  }) async {
    await _showNotification(
      id: 2,
      title: '🏆 Тест завершён!',
      body: 'Результат: $score из $total (${percent.toStringAsFixed(1)}%) — $resultText',
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );

    await _localPlugin.show(id, title, body, NotificationDetails(android: androidDetails));
  }
}
