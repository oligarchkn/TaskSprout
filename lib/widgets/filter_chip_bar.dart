import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/task.dart';

class FilterChipBar extends StatelessWidget {
  const FilterChipBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: l10n.filterAll,
                      count: taskProvider.totalCount,
                      isSelected: taskProvider.currentFilter == TaskFilter.all,
                      onSelected: () {
                        taskProvider.setFilter(TaskFilter.all);
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: l10n.filterActive,
                      count: taskProvider.activeCount,
                      isSelected: taskProvider.currentFilter == TaskFilter.active,
                      onSelected: () {
                        taskProvider.setFilter(TaskFilter.active);
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: l10n.filterCompleted,
                      count: taskProvider.completedCount,
                      isSelected: taskProvider.currentFilter == TaskFilter.completed,
                      onSelected: () {
                        taskProvider.setFilter(TaskFilter.completed);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Additional filters row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Priority filter
                    _buildPriorityMenu(context, taskProvider, l10n),
                    const SizedBox(width: 8),

                    // Date filter
                    _buildDateMenu(context, taskProvider, l10n),
                    const SizedBox(width: 8),

                    // Category filter
                    if (taskProvider.categories.isNotEmpty)
                      _buildCategoryMenu(context, taskProvider, l10n),

                    // Clear filters button
                    if (taskProvider.priorityFilter != null ||
                        taskProvider.dateFilter != DateFilter.all ||
                        taskProvider.categoryFilter != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () => taskProvider.clearFilters(),
                          tooltip: 'Clear filters',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriorityMenu(BuildContext context, TaskProvider taskProvider, AppLocalizations l10n) {
    return PopupMenuButton<TaskPriority?>(
      onSelected: (priority) => taskProvider.setPriorityFilter(priority),
      child: Chip(
        avatar: Icon(
          Icons.flag_rounded,
          size: 18,
          color: taskProvider.priorityFilter != null
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        label: Text(
          taskProvider.priorityFilter != null
              ? _getPriorityLabel(taskProvider.priorityFilter!, l10n)
              : l10n.taskPriority,
        ),
        backgroundColor: taskProvider.priorityFilter != null
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: null,
          child: Row(
            children: [
              if (taskProvider.priorityFilter == null)
                const Icon(Icons.check, size: 20),
              if (taskProvider.priorityFilter == null)
                const SizedBox(width: 8),
              Text(l10n.filterAll),
            ],
          ),
        ),
        PopupMenuItem(
          value: TaskPriority.high,
          child: Row(
            children: [
              if (taskProvider.priorityFilter == TaskPriority.high)
                const Icon(Icons.check, size: 20),
              if (taskProvider.priorityFilter == TaskPriority.high)
                const SizedBox(width: 8),
              Text(l10n.priorityHigh),
            ],
          ),
        ),
        PopupMenuItem(
          value: TaskPriority.medium,
          child: Row(
            children: [
              if (taskProvider.priorityFilter == TaskPriority.medium)
                const Icon(Icons.check, size: 20),
              if (taskProvider.priorityFilter == TaskPriority.medium)
                const SizedBox(width: 8),
              Text(l10n.priorityMedium),
            ],
          ),
        ),
        PopupMenuItem(
          value: TaskPriority.low,
          child: Row(
            children: [
              if (taskProvider.priorityFilter == TaskPriority.low)
                const Icon(Icons.check, size: 20),
              if (taskProvider.priorityFilter == TaskPriority.low)
                const SizedBox(width: 8),
              Text(l10n.priorityLow),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateMenu(BuildContext context, TaskProvider taskProvider, AppLocalizations l10n) {
    return PopupMenuButton<DateFilter>(
      initialValue: taskProvider.dateFilter,
      onSelected: (filter) => taskProvider.setDateFilter(filter),
      child: Chip(
        avatar: Icon(
          Icons.calendar_today_rounded,
          size: 18,
          color: taskProvider.dateFilter != DateFilter.all
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        label: Text(_getDateLabel(taskProvider.dateFilter, l10n)),
        backgroundColor: taskProvider.dateFilter != DateFilter.all
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: DateFilter.all,
          child: Text(l10n.dateAll),
        ),
        PopupMenuItem(
          value: DateFilter.today,
          child: Text(l10n.dateToday),
        ),
        PopupMenuItem(
          value: DateFilter.week,
          child: Text(l10n.dateWeek),
        ),
        PopupMenuItem(
          value: DateFilter.month,
          child: Text(l10n.dateMonth),
        ),
      ],
    );
  }

  Widget _buildCategoryMenu(BuildContext context, TaskProvider taskProvider, AppLocalizations l10n) {
    return PopupMenuButton<String?>(
      initialValue: taskProvider.categoryFilter,
      onSelected: (category) => taskProvider.setCategoryFilter(category),
      child: Chip(
        avatar: Icon(
          Icons.label_rounded,
          size: 18,
          color: taskProvider.categoryFilter != null
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        label: Text(taskProvider.categoryFilter ?? l10n.taskCategory),
        backgroundColor: taskProvider.categoryFilter != null
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: null,
          child: Text(l10n.filterAll),
        ),
        ...taskProvider.categories.map((category) {
          return PopupMenuItem(
            value: category,
            child: Text(category),
          );
        }),
      ],
    );
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

  String _getDateLabel(DateFilter filter, AppLocalizations l10n) {
    switch (filter) {
      case DateFilter.all:
        return l10n.dateAll;
      case DateFilter.today:
        return l10n.dateToday;
      case DateFilter.week:
        return l10n.dateWeek;
      case DateFilter.month:
        return l10n.dateMonth;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text('$label: $count'),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
      ),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
