import 'package:flutter/material.dart';
import '../providers/task_provider.dart';
import '../l10n/app_localizations.dart';

class EmptyState extends StatelessWidget {
  final TaskFilter filter;

  const EmptyState({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    String title;
    String message;
    IconData icon;

    switch (filter) {
      case TaskFilter.all:
        title = l10n.noTasksAll;
        message = 'Add your first task to get started.';
        icon = Icons.task_alt;
        break;
      case TaskFilter.active:
        title = l10n.noTasksActive;
        message = 'You\'re all caught up! Add a new task or complete existing ones.';
        icon = Icons.check_circle_outline;
        break;
      case TaskFilter.completed:
        title = l10n.noTasksCompleted;
        message = 'Complete some tasks to see them here.';
        icon = Icons.pending_actions;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
