import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('uk'),
  ];

  // App name
  String get appName => locale.languageCode == 'uk' ? 'TaskSprout' : 'TaskSprout';

  // Bottom navigation
  String get navTasks => locale.languageCode == 'uk' ? 'Завдання' : 'Tasks';
  String get navCalendar => locale.languageCode == 'uk' ? 'Календар' : 'Calendar';
  String get navFocus => locale.languageCode == 'uk' ? 'Фокус' : 'Focus';
  String get navProfile => locale.languageCode == 'uk' ? 'Профіль' : 'Profile';

  // Task list screen
  String get addTask => locale.languageCode == 'uk' ? 'Додати завдання' : 'Add Task';
  String get addTaskHint => locale.languageCode == 'uk' ? 'Введіть нове завдання...' : 'Enter new task...';
  String get searchTasks => locale.languageCode == 'uk' ? 'Пошук завдань' : 'Search tasks';

  // Filters
  String get filterAll => locale.languageCode == 'uk' ? 'Всі' : 'All';
  String get filterActive => locale.languageCode == 'uk' ? 'Активні' : 'Active';
  String get filterCompleted => locale.languageCode == 'uk' ? 'Завершені' : 'Completed';

  // Priority
  String get priorityHigh => locale.languageCode == 'uk' ? 'Високий' : 'High';
  String get priorityMedium => locale.languageCode == 'uk' ? 'Середній' : 'Medium';
  String get priorityLow => locale.languageCode == 'uk' ? 'Низький' : 'Low';
  String get priorityNone => locale.languageCode == 'uk' ? 'Без пріоритету' : 'No priority';

  // Date filters
  String get dateToday => locale.languageCode == 'uk' ? 'Сьогодні' : 'Today';
  String get dateWeek => locale.languageCode == 'uk' ? 'Тиждень' : 'Week';
  String get dateMonth => locale.languageCode == 'uk' ? 'Місяць' : 'Month';
  String get dateAll => locale.languageCode == 'uk' ? 'Всі дати' : 'All dates';

  // Task dialog
  String get taskTitle => locale.languageCode == 'uk' ? 'Назва завдання' : 'Task title';
  String get taskDescription => locale.languageCode == 'uk' ? 'Опис (необов\'язково)' : 'Description (optional)';
  String get taskPriority => locale.languageCode == 'uk' ? 'Пріоритет' : 'Priority';
  String get taskCategory => locale.languageCode == 'uk' ? 'Категорія' : 'Category';
  String get taskDueDate => locale.languageCode == 'uk' ? 'Дата виконання' : 'Due date';
  String get save => locale.languageCode == 'uk' ? 'Зберегти' : 'Save';
  String get cancel => locale.languageCode == 'uk' ? 'Скасувати' : 'Cancel';
  String get delete => locale.languageCode == 'uk' ? 'Видалити' : 'Delete';
  String get edit => locale.languageCode == 'uk' ? 'Редагувати' : 'Edit';

  // Empty states
  String get noTasksAll => locale.languageCode == 'uk'
      ? 'Немає завдань. Додайте нове завдання!'
      : 'No tasks yet. Add your first task!';
  String get noTasksActive => locale.languageCode == 'uk'
      ? 'Немає активних завдань'
      : 'No active tasks';
  String get noTasksCompleted => locale.languageCode == 'uk'
      ? 'Немає завершених завдань'
      : 'No completed tasks';

  // Voice input
  String get voiceInputHint => locale.languageCode == 'uk'
      ? 'Натисніть та говоріть...'
      : 'Tap and speak...';
  String get listeningVoice => locale.languageCode == 'uk'
      ? 'Слухаю...'
      : 'Listening...';
  String get voiceInputError => locale.languageCode == 'uk'
      ? 'Помилка розпізнавання мови'
      : 'Voice recognition error';

  // Tooltips
  String get toggleTheme => locale.languageCode == 'uk' ? 'Змінити тему' : 'Toggle theme';
  String get toggleLanguage => locale.languageCode == 'uk' ? 'Змінити мову' : 'Change language';
  String get sendTask => locale.languageCode == 'uk' ? 'Відправити' : 'Send';
  String get voiceInput => locale.languageCode == 'uk' ? 'Голосовий ввід' : 'Voice input';

  // Categories
  String get categoryWork => locale.languageCode == 'uk' ? 'Робота' : 'Work';
  String get categoryPersonal => locale.languageCode == 'uk' ? 'Особисте' : 'Personal';
  String get categoryShopping => locale.languageCode == 'uk' ? 'Покупки' : 'Shopping';
  String get categoryHealth => locale.languageCode == 'uk' ? 'Здоров\'я' : 'Health';
  String get categoryOther => locale.languageCode == 'uk' ? 'Інше' : 'Other';

  // Archive
  String get archive => locale.languageCode == 'uk' ? 'Архівувати' : 'Archive';
  String get unarchive => locale.languageCode == 'uk' ? 'Розархівувати' : 'Unarchive';
  String get archived => locale.languageCode == 'uk' ? 'Архів' : 'Archived';
  String get archiveCompleted => locale.languageCode == 'uk' ? 'Архівувати виконані' : 'Archive completed';
  String get noArchivedTasks => locale.languageCode == 'uk'
      ? 'Немає архівованих завдань'
      : 'No archived tasks';
  String get archiveConfirmTitle => locale.languageCode == 'uk'
      ? 'Архівувати завдання?'
      : 'Archive task?';
  String get archiveConfirmMessage => locale.languageCode == 'uk'
      ? 'Це завдання буде переміщено в архів'
      : 'This task will be moved to archive';
  String get archiveCompletedConfirm => locale.languageCode == 'uk'
      ? 'Архівувати всі виконані завдання?'
      : 'Archive all completed tasks?';

  // Focus
  String get focus => locale.languageCode == 'uk' ? 'Фокус' : 'Focus';
  String get addToFocus => locale.languageCode == 'uk' ? 'Додати до фокусу' : 'Add to focus';
  String get removeFromFocus => locale.languageCode == 'uk' ? 'Прибрати з фокусу' : 'Remove from focus';
  String get noFocusTasks => locale.languageCode == 'uk'
      ? 'Немає завдань у фокусі.\nПозначте важливі завдання зірочкою!'
      : 'No tasks in focus.\nStar important tasks!';

  // Time
  String get selectTime => locale.languageCode == 'uk' ? 'Виберіть час' : 'Select time';
  String get time => locale.languageCode == 'uk' ? 'Час' : 'Time';
  String get dueTime => locale.languageCode == 'uk' ? 'Час виконання' : 'Due time';

  // Completed
  String get completedAt => locale.languageCode == 'uk' ? 'Виконано' : 'Completed at';

  // Categories management
  String get manageCategories => locale.languageCode == 'uk' ? 'Керувати категоріями' : 'Manage categories';
  String get addCategory => locale.languageCode == 'uk' ? 'Додати категорію' : 'Add category';
  String get editCategory => locale.languageCode == 'uk' ? 'Редагувати категорію' : 'Edit category';
  String get deleteCategory => locale.languageCode == 'uk' ? 'Видалити категорію' : 'Delete category';
  String get categoryName => locale.languageCode == 'uk' ? 'Назва категорії' : 'Category name';
  String get enterCategoryName => locale.languageCode == 'uk' ? 'Введіть назву категорії' : 'Enter category name';
  String get categoryExists => locale.languageCode == 'uk' ? 'Ця категорія вже існує' : 'Category already exists';
  String get deleteCategoryConfirm => locale.languageCode == 'uk'
      ? 'Видалити цю категорію?'
      : 'Delete this category?';

  // View archived
  String get viewArchived => locale.languageCode == 'uk' ? 'Переглянути архів' : 'View archived';

  // Notifications
  String get notifications => locale.languageCode == 'uk' ? 'Сповіщення' : 'Notifications';
  String get noNotifications => locale.languageCode == 'uk'
      ? 'Немає сповіщень'
      : 'No notifications';
  String get markAllRead => locale.languageCode == 'uk'
      ? 'Прочитати всі'
      : 'Mark all read';
  String get clearAll => locale.languageCode == 'uk'
      ? 'Очистити всі'
      : 'Clear all';
  String get overdueSince => locale.languageCode == 'uk'
      ? 'Прострочено з'
      : 'Overdue since';
  String get justNow => locale.languageCode == 'uk'
      ? 'Щойно'
      : 'Just now';

  String minutesAgo(int minutes) => locale.languageCode == 'uk'
      ? '$minutes хв. тому'
      : '$minutes min ago';

  String hoursAgo(int hours) => locale.languageCode == 'uk'
      ? '$hours год. тому'
      : '$hours hr ago';

  String daysAgo(int days) => locale.languageCode == 'uk'
      ? '$days дн. тому'
      : '$days d ago';

  String moreNotifications(int count) => locale.languageCode == 'uk'
      ? 'Ще $count сповіщень...'
      : '$count more notifications...';

  String get overdueTask => locale.languageCode == 'uk'
      ? 'Прострочене завдання'
      : 'Overdue task';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'uk'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
