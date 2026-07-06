import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../l10n/app_localizations.dart';
import 'edit_task_dialog.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({
    super.key,
    required this.task,
  });

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTaskDialog(task: task),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showArchiveConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.archiveConfirmTitle),
        content: Text(l10n.archiveConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().archiveTask(task.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.archived),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(l10n.archive),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: Text(l10n.archive),
              onTap: () {
                Navigator.pop(context);
                _showArchiveConfirmation(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.delete,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.blue;
      case TaskPriority.none:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(TaskPriority priority, AppLocalizations l10n) {
    switch (priority) {
      case TaskPriority.high:
        return l10n.priorityHigh;
      case TaskPriority.medium:
        return l10n.priorityMedium;
      case TaskPriority.low:
        return l10n.priorityLow;
      case TaskPriority.none:
        return l10n.priorityNone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () => _showEditDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    context.read<TaskProvider>().toggleTask(task.id);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Focus star icon
              if (task.isFocused)
                Padding(
                  padding: const EdgeInsets.only(top: 12, right: 8),
                  child: Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task title
                    Text(
                      task.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.isCompleted
                            ? colorScheme.onSurface.withValues(alpha: 0.5)
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Metadata row
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // Priority
                        if (task.priority != TaskPriority.none)
                          Chip(
                            avatar: Icon(
                              Icons.flag_rounded,
                              size: 16,
                              color: _getPriorityColor(task.priority),
                            ),
                            label: Text(
                              _getPriorityLabel(task.priority, l10n),
                              style: theme.textTheme.labelSmall,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),

                        // Category
                        if (task.category != null && task.category!.isNotEmpty)
                          Chip(
                            avatar: Icon(
                              Icons.label_rounded,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            label: Text(
                              task.category!,
                              style: theme.textTheme.labelSmall,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),

                        // Due date with time
                        if (task.dueDate != null)
                          Chip(
                            avatar: Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: _isDueDateOverdue(task.dueDate!)
                                  ? colorScheme.error
                                  : colorScheme.primary,
                            ),
                            label: Text(
                              _formatDueDate(task.dueDate!),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _isDueDateOverdue(task.dueDate!)
                                    ? colorScheme.error
                                    : null,
                              ),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),

                        // Completed at
                        if (task.isCompleted && task.completedAt != null)
                          Chip(
                            avatar: Icon(
                              Icons.check_circle,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            label: Text(
                              _formatCompletedAt(task.completedAt!),
                              style: theme.textTheme.labelSmall,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Options menu button
              IconButton(
                icon: const Icon(Icons.more_vert),
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                onPressed: () => _showOptionsMenu(context),
                tooltip: 'Options',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDueDateOverdue(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today) && !task.isCompleted;
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final hasTime = dueDate.hour != 0 || dueDate.minute != 0;

    // If it's today and has time, show only time
    if (dueDay.isAtSameMomentAs(today) && hasTime) {
      return DateFormat.Hm().format(dueDate);
    }

    // If it's not today, show date and optionally time
    if (hasTime) {
      return '${DateFormat.MMMd().format(dueDate)} ${DateFormat.Hm().format(dueDate)}';
    }

    return DateFormat.MMMd().format(dueDate);
  }

  String _formatCompletedAt(DateTime completedAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedDay = DateTime(completedAt.year, completedAt.month, completedAt.day);

    // If completed today, show time
    if (completedDay.isAtSameMomentAs(today)) {
      return DateFormat.Hm().format(completedAt);
    }

    // Otherwise show date
    return DateFormat.MMMd().format(completedAt);
  }
}
