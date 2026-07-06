import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'database/database_factory_initializer.dart';
import 'services/notification_service.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/category_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/note_provider.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Потрібно для виклику async-коду до runApp (наприклад, ініціалізація БД).
  WidgetsFlutterBinding.ensureInitialized();

  // Ініціалізуємо фабрику бази даних відповідно до платформи
  // (SQLite через FFI на desktop / WASM+IndexedDB на web / плагін на mobile).
  // Це ГАРАНТУЄ, що завдання зберігаються локально і переживають перезапуск.
  await initDatabaseFactory();

  // Ініціалізуємо сервіс системних сповіщень
  await NotificationService.instance.initialize();

  // Налаштовуємо фонову перевірку (7:30, 12:00, 15:00, та щоденне о 9:00)
  await NotificationService.instance.setupBackgroundCheck();

  runApp(const TaskSproutApp());
}

class TaskSproutApp extends StatelessWidget {
  const TaskSproutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadThemeMode(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider()..loadLocale(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider()..loadTasks(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProfileProvider()..loadProfile(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NoteProvider()..loadNotes(),
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'TaskSprout',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
