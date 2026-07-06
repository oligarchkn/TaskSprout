import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<TaskNotification> _notifications = [];
  Timer? _checkTimer;
  bool _permissionGranted = false;

  List<TaskNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  NotificationProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadNotifications();
    await _requestPermission();
    _startPeriodicCheck();
  }

  // Запит дозволу на системні сповіщення
  Future<void> _requestPermission() async {
    if (kIsWeb) {
      // Browser Notifications API для веб
      try {
        final permission = await _requestBrowserNotificationPermission();
        _permissionGranted = permission;
      } catch (e) {
        debugPrint('Notification permission error: $e');
      }
    }
  }

  // Нативний JS виклик для запиту дозволу
  Future<bool> _requestBrowserNotificationPermission() async {
    if (!kIsWeb) return false;

    // Перевіряємо чи підтримуються сповіщення
    try {
      // Використовуємо dart:html через умовний імпорт
      return await _checkNotificationPermission();
    } catch (e) {
      debugPrint('Browser notifications not supported: $e');
      return false;
    }
  }

  Future<bool> _checkNotificationPermission() async {
    // Буде реалізовано через dart:html у web-специфічному файлі
    // Поки що повертаємо false для десктопу
    return false;
  }

  // Перевірка завдань на прострочені дедлайни
  Future<void> checkOverdueTasks(List<Task> tasks) async {
    debugPrint('=== Checking overdue tasks ===');
    debugPrint('Total tasks to check: ${tasks.length}');
    debugPrint('Current time: ${DateTime.now()}');

    final now = DateTime.now();
    final overdueTasksNotNotified = <Task>[];
    final allOverdueTasks = <Task>[];

    for (final task in tasks) {
      debugPrint('Checking task: ${task.title}');
      debugPrint('  - isCompleted: ${task.isCompleted}');
      debugPrint('  - isArchived: ${task.isArchived}');
      debugPrint('  - dueDate: ${task.dueDate}');

      // Пропускаємо виконані та архівовані завдання
      if (task.isCompleted || task.isArchived) {
        debugPrint('  - SKIPPED (completed or archived)');
        continue;
      }

      // Пропускаємо завдання без дати виконання
      if (task.dueDate == null) {
        debugPrint('  - SKIPPED (no due date)');
        continue;
      }

      // Перевіряємо чи завдання прострочене
      final taskDueDate = task.dueDate!;
      final hasTime = taskDueDate.hour != 0 || taskDueDate.minute != 0 || taskDueDate.second != 0;

      final dueDate = hasTime
          ? taskDueDate
          : DateTime(
              taskDueDate.year,
              taskDueDate.month,
              taskDueDate.day,
              23,
              59,
              59,
            );

      debugPrint('  - Due date with time: $dueDate');
      debugPrint('  - Has specific time: $hasTime');
      debugPrint('  - Is overdue: ${dueDate.isBefore(now)}');

      if (dueDate.isBefore(now)) {
        allOverdueTasks.add(task);

        // Перевіряємо чи вже є сповіщення для цього завдання
        final hasExistingNotification = _notifications.any(
          (n) => n.taskId == task.id && n.type == NotificationType.overdue,
        );

        debugPrint('  - Has existing notification: $hasExistingNotification');

        if (!hasExistingNotification) {
          overdueTasksNotNotified.add(task);
          debugPrint('  - ADDED to notification queue');
        }
      }
    }

    debugPrint('Tasks to notify: ${overdueTasksNotNotified.length}');
    debugPrint('Total overdue tasks: ${allOverdueTasks.length}');

    // Створюємо внутрішні сповіщення для нових прострочених завдань
    for (final task in overdueTasksNotNotified) {
      await _createNotification(task, type: NotificationType.overdue);
      debugPrint('✓ Created internal notification for task: ${task.title}');
    }

    // Показуємо системні сповіщення
    if (overdueTasksNotNotified.isNotEmpty) {
      if (overdueTasksNotNotified.length > 5) {
        // Групове сповіщення
        await NotificationService.instance.showGroupedOverdueNotification(overdueTasksNotNotified);
      } else {
        // Окремі сповіщення
        for (final task in overdueTasksNotNotified) {
          await NotificationService.instance.showOverdueTaskNotification(task);
        }
      }
    }

    debugPrint('Total internal notifications now: ${_notifications.length}');
    debugPrint('=== Check complete ===');
  }

  // Створення нового сповіщення
  Future<void> _createNotification(Task task, {NotificationType type = NotificationType.overdue}) async {
    debugPrint('Creating notification for task: ${task.title}');

    final notification = TaskNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: task.id,
      taskTitle: task.title,
      taskDueDate: task.dueDate!,
      createdAt: DateTime.now(),
      isRead: false,
      type: type,
    );

    _notifications.insert(0, notification);
    debugPrint('Notification added to list. Total: ${_notifications.length}');

    await _saveNotifications();
    debugPrint('Notifications saved to storage');

    notifyListeners();
    debugPrint('Listeners notified');

    // Показуємо системне сповіщення
    if (_permissionGranted) {
      await _showBrowserNotification(notification);
    }
  }

  // Показати браузерне сповіщення
  Future<void> _showBrowserNotification(TaskNotification notification) async {
    if (!kIsWeb || !_permissionGranted) return;

    try {
      // Використовуємо Browser Notifications API
      await _displayBrowserNotification(
        title: 'TaskSprout - Прострочене завдання',
        body: notification.taskTitle,
      );
    } catch (e) {
      debugPrint('Error showing browser notification: $e');
    }
  }

  Future<void> _displayBrowserNotification({
    required String title,
    required String body,
  }) async {
    // Буде реалізовано через dart:html для веб-платформи
    debugPrint('Notification: $title - $body');
  }

  // Позначити сповіщення як прочитане
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  // Позначити всі як прочитані
  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    await _saveNotifications();
    notifyListeners();
  }

  // Видалити сповіщення
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    notifyListeners();
  }

  // Очистити всі сповіщення
  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  // Видалити сповіщення для конкретного завдання (коли завдання виконане)
  Future<void> removeNotificationsForTask(String taskId) async {
    _notifications.removeWhere((n) => n.taskId == taskId);
    await _saveNotifications();

    // Також скасовуємо системне сповіщення
    await NotificationService.instance.cancelNotification(taskId);

    notifyListeners();
  }

  // Періодична перевірка (кожні 5 хвилин)
  void _startPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) {
        // Перевірка буде викликатися автоматично через TaskProvider
        notifyListeners();
      },
    );
  }

  // Збереження сповіщень
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications
          .map((n) => n.toJson())
          .toList();
      await prefs.setString('notifications', jsonEncode(notificationsJson));
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  // Завантаження сповіщень
  Future<void> _loadNotifications() async {
    debugPrint('Loading notifications from storage...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsString = prefs.getString('notifications');

      if (notificationsString != null && notificationsString.isNotEmpty) {
        debugPrint('Found notifications in storage: $notificationsString');
        final List<dynamic> notificationsJson = jsonDecode(notificationsString);
        _notifications = notificationsJson
            .map((json) => TaskNotification.fromJson(json))
            .toList();
        debugPrint('Loaded ${_notifications.length} notifications');
        notifyListeners();
      } else {
        debugPrint('No notifications in storage');
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      _notifications = [];
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}
