import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';
import '../database/database_helper.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  NotificationService._init();

  // Ініціалізація сервісу сповіщень
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Ініціалізація timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Kiev'));

    // Android налаштування
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS налаштування
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Створюємо канал для Android
    await _createNotificationChannel();

    // Запитуємо дозвіл на сповіщення (Android 13+)
    await _requestPermissions();

    _isInitialized = true;
    debugPrint('NotificationService initialized');
  }

  // Запит дозволів
  Future<bool> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  // Створення каналу сповіщень для Android
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'overdue_tasks_channel',
      'Прострочені завдання',
      description: 'Сповіщення про прострочені завдання',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // Показати сповіщення про одне прострочене завдання
  Future<void> showOverdueTaskNotification(Task task) async {
    final androidDetails = AndroidNotificationDetails(
      'overdue_tasks_channel',
      'Прострочені завдання',
      channelDescription: 'Сповіщення про прострочені завдання',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFF44336),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      task.id.hashCode,
      'Прострочене завдання',
      task.title,
      notificationDetails,
      payload: 'overdue_task:${task.id}',
    );

    debugPrint('Notification shown for task: ${task.title}');
  }

  // Показати групове сповіщення про кілька прострочених завдань
  Future<void> showGroupedOverdueNotification(List<Task> tasks) async {
    if (tasks.isEmpty) return;

    if (tasks.length == 1) {
      await showOverdueTaskNotification(tasks.first);
      return;
    }

    // Групове сповіщення для Android
    final androidDetails = AndroidNotificationDetails(
      'overdue_tasks_channel',
      'Прострочені завдання',
      channelDescription: 'Сповіщення про прострочені завдання',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFF44336),
      enableVibration: true,
      playSound: true,
      styleInformation: InboxStyleInformation(
        tasks.take(5).map((t) => t.title).toList(),
        contentTitle: '${tasks.length} прострочених завдань',
        summaryText: 'Натисніть щоб переглянути',
      ),
      groupKey: 'overdue_tasks_group',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999999, // ID для групового сповіщення
      'Прострочені завдання',
      'У вас ${tasks.length} прострочених завдань',
      notificationDetails,
      payload: 'overdue_tasks:all',
    );

    debugPrint('Grouped notification shown for ${tasks.length} tasks');
  }

  // Обробка натискання на сповіщення
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('Notification tapped with payload: $payload');

    // TODO: Відкрити додаток з фільтром прострочених завдань
    // Це буде оброблено через deep link в main.dart
  }

  // Скасувати всі сповіщення
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Скасувати сповіщення для конкретного завдання
  Future<void> cancelNotification(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }

  // Налаштувати запрограмовані сповіщення на конкретний час
  Future<void> setupBackgroundCheck() async {
    debugPrint('Setting up scheduled notifications');

    // Плануємо перевірку о 7:30
    await _scheduleNotification(7, 30);

    // Плануємо перевірку о 12:00
    await _scheduleNotification(12, 0);

    // Плануємо перевірку о 15:00
    await _scheduleNotification(15, 0);

    // Плануємо щоденне нагадування о 9:00
    await _scheduleNotification(9, 0);

    debugPrint('Background checks scheduled');
  }

  // Запланувати сповіщення на конкретний час
  Future<void> _scheduleNotification(int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Якщо час вже минув сьогодні, запланувати на завтра
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      '$hour$minute'.hashCode, // Унікальний ID на основі часу
      'Перевірка завдань',
      'Перевіряємо прострочені завдання...',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'overdue_tasks_channel',
          'Прострочені завдання',
          channelDescription: 'Сповіщення про прострочені завдання',
          importance: Importance.low,
          priority: Priority.low,
          silent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'check_overdue',
    );

    debugPrint('Scheduled notification for $hour:$minute');
  }
}
