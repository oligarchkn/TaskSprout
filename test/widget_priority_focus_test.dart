import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_sprout/models/task.dart';
import 'package:task_sprout/providers/task_provider.dart';
import 'package:task_sprout/providers/category_provider.dart';
import 'package:task_sprout/widgets/add_task_dialog.dart';
import 'package:task_sprout/widgets/edit_task_dialog.dart';
import 'package:task_sprout/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('AddTaskDialog Widget Tests', () {
    testWidgets('Should display priority dropdown with all options', (tester) async {
      final taskProvider = TaskProvider();
      final categoryProvider = CategoryProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: categoryProvider),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AddTaskDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find priority dropdown
      expect(find.byIcon(Icons.flag_rounded), findsWidgets);

      // Tap on priority dropdown
      final priorityDropdown = find.byType(DropdownButtonFormField<TaskPriority>);
      expect(priorityDropdown, findsOneWidget);
    });

    testWidgets('Should display focus toggle switch', (tester) async {
      final taskProvider = TaskProvider();
      final categoryProvider = CategoryProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: categoryProvider),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AddTaskDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find focus switch
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('Should toggle focus switch when tapped', (tester) async {
      final taskProvider = TaskProvider();
      final categoryProvider = CategoryProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: categoryProvider),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AddTaskDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should show star_border (not focused)
      expect(find.byIcon(Icons.star_border), findsOneWidget);

      // Tap the switch
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // Should now show star (focused)
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('Should allow selecting priority and toggling focus', (tester) async {
      final taskProvider = TaskProvider();
      final categoryProvider = CategoryProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: categoryProvider),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AddTaskDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter task title
      await tester.enterText(
        find.byType(TextFormField).first,
        'Test task with priority',
      );
      await tester.pumpAndSettle();

      // Verify priority dropdown exists and can be opened
      final priorityDropdown = find.byType(DropdownButtonFormField<TaskPriority>);
      expect(priorityDropdown, findsOneWidget);

      await tester.tap(priorityDropdown);
      await tester.pumpAndSettle();

      // Verify all priority options are available
      expect(find.text('High'), findsWidgets);
      expect(find.text('Medium'), findsWidgets);
      expect(find.text('Low'), findsWidgets);

      // Select High priority
      await tester.tap(find.text('High').last);
      await tester.pumpAndSettle();

      // Verify focus switch exists and toggle it
      final focusSwitch = find.byType(SwitchListTile);
      expect(focusSwitch, findsOneWidget);

      // Should start with star_border (not focused)
      expect(find.byIcon(Icons.star_border), findsOneWidget);

      await tester.tap(focusSwitch);
      await tester.pumpAndSettle();

      // Should now show star (focused)
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('EditTaskDialog Widget Tests', () {
    testWidgets('Should display current priority and focus state', (tester) async {
      final taskProvider = TaskProvider();
      final categoryProvider = CategoryProvider();

      // Create a task with high priority and focused
      await taskProvider.addTask(
        'Edit test task',
        priority: TaskPriority.high,
        isFocused: true,
      );

      final task = taskProvider.tasks[0];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: categoryProvider),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: EditTaskDialog(task: task),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show focused star icon
      expect(find.byIcon(Icons.star), findsOneWidget);

      // Priority dropdown should show High
      expect(find.byType(DropdownButtonFormField<TaskPriority>), findsOneWidget);
    });

    testWidgets('Should allow updating task priority and focus', (tester) async {
      final taskProvider = TaskProvider();
      final categoryProvider = CategoryProvider();

      // Create a task with low priority and not focused
      await taskProvider.addTask(
        'Update test task',
        priority: TaskPriority.low,
        isFocused: false,
      );

      final task = taskProvider.tasks[0];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: categoryProvider),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: EditTaskDialog(task: task),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify priority dropdown exists
      final priorityDropdown = find.byType(DropdownButtonFormField<TaskPriority>);
      expect(priorityDropdown, findsOneWidget);

      // Change priority to High
      await tester.tap(priorityDropdown);
      await tester.pumpAndSettle();

      expect(find.text('High'), findsWidgets);
      await tester.tap(find.text('High').last);
      await tester.pumpAndSettle();

      // Verify focus switch exists and toggle it
      final focusSwitch = find.byType(SwitchListTile);
      expect(focusSwitch, findsOneWidget);

      await tester.tap(focusSwitch);
      await tester.pumpAndSettle();

      // Should now show star (focused)
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('Should show "Remove from Focus" text when task is focused', (tester) async {
      final taskProvider = TaskProvider();
      final categoryProvider = CategoryProvider();

      await taskProvider.addTask(
        'Focused task',
        isFocused: true,
      );

      final task = taskProvider.tasks[0];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: taskProvider),
            ChangeNotifierProvider.value(value: categoryProvider),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: EditTaskDialog(task: task),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show "Remove from Focus" text when focused
      expect(find.text('Remove from Focus'), findsOneWidget);
    });
  });

  group('Task Priority Colors', () {
    test('Priority colors should be correctly assigned', () {
      expect(TaskPriority.values.length, 4);
      expect(TaskPriority.none.index, 0);
      expect(TaskPriority.low.index, 1);
      expect(TaskPriority.medium.index, 2);
      expect(TaskPriority.high.index, 3);
    });
  });
}
