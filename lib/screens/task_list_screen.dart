import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/notification_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/task_list_item.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/quick_add_task_bar.dart';
import '../widgets/notification_dropdown.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndCheckTasks();
      _setupTaskListener();
    });
  }

  Future<void> _loadAndCheckTasks() async {
    final taskProvider = context.read<TaskProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    // Спочатку завантажуємо завдання
    await taskProvider.loadTasks();

    // Потім перевіряємо прострочені
    await notificationProvider.checkOverdueTasks(taskProvider.allTasks);

    debugPrint('Tasks loaded: ${taskProvider.allTasks.length}');
    debugPrint('Checking for overdue tasks...');
  }

  void _setupTaskListener() {
    // Listen to task changes and check for notifications cleanup
    context.read<TaskProvider>().addListener(_onTasksChanged);
  }

  void _onTasksChanged() {
    if (!mounted) return;

    final taskProvider = context.read<TaskProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    // Check overdue tasks again
    notificationProvider.checkOverdueTasks(taskProvider.allTasks);

    // Clean up notifications for completed or deleted tasks
    final allTaskIds = taskProvider.allTasks.map((t) => t.id).toSet();
    final completedTaskIds = taskProvider.allTasks
        .where((t) => t.isCompleted)
        .map((t) => t.id)
        .toSet();

    // Remove notifications for tasks that don't exist or are completed
    final notificationsToRemove = notificationProvider.notifications
        .where((notification) =>
            !allTaskIds.contains(notification.taskId) ||
            completedTaskIds.contains(notification.taskId))
        .map((n) => n.taskId)
        .toSet();

    for (final taskId in notificationsToRemove) {
      notificationProvider.removeNotificationsForTask(taskId);
    }
  }

  @override
  void dispose() {
    context.read<TaskProvider>().removeListener(_onTasksChanged);
    super.dispose();
  }

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.eco_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            // Notification bell
            const NotificationDropdown(),
          ],
        ),
        actions: [
          // Language toggle
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              return IconButton(
                icon: Icon(
                  Icons.language_rounded,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => localeProvider.toggleLocale(),
                tooltip: l10n.toggleLanguage,
              );
            },
          ),
          // Theme toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: l10n.toggleTheme,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          const FilterChipBar(),

          // Task list
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final tasks = taskProvider.tasks;

                if (tasks.isEmpty) {
                  return EmptyState(
                    filter: taskProvider.currentFilter,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 8,
                  ),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskListItem(
                      key: ValueKey(task.id),
                      task: task,
                    );
                  },
                );
              },
            ),
          ),

          // Quick add task bar at the bottom
          const QuickAddTaskBar(),
        ],
      ),
    );
  }
}
