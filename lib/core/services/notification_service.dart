import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Сервис для управления локальными push-уведомлениями.
/// Singleton-паттерн — один экземпляр на всё приложение.
class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Детали канала уведомлений для Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'quiz_channel', // id
    'Quiz Notifications', // name
    description: 'Уведомления приложения Quiz',
    importance: Importance.high,
  );

  /// Инициализация плагина и запрос разрешений
  Future<void> initialize() async {
    if (_initialized) return;

    // Настройки для Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher', // Иконка из ресурсов приложения
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Создаём канал уведомлений (Android 8+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            _channel.id,
            _channel.name,
            description: _channel.description,
            importance: _channel.importance,
          ),
        );

    // Запрашиваем разрешение на уведомления (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
    debugPrint('NotificationService: инициализирован');
  }

  /// Обработчик нажатия на уведомление
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Уведомление нажато: ${response.payload}');
  }

  /// Показать уведомление при старте теста
  Future<void> showStartNotification() async {
    await _showNotification(
      id: 0,
      title: '🚀 Тест начат!',
      body: 'Удачи! Ответьте на все вопросы правильно',
      payload: 'quiz_start',
    );
  }

  /// Показать уведомление о прогрессе (каждые 5 вопросов)
  Future<void> showProgressNotification(int answeredCount) async {
    await _showNotification(
      id: 1,
      title: '💡 Продолжайте!',
      body: 'Вы ответили на $answeredCount вопросов. Так держать!',
      payload: 'quiz_progress',
    );
  }

  /// Показать уведомление с результатом теста
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
      payload: 'quiz_result',
    );
  }

  /// Базовый метод отправки уведомления
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(id, title, body, details, payload: payload);
    debugPrint('NotificationService: отправлено [$title] $body');
  }
}
