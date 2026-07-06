import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/task_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class NotificationDropdown extends StatelessWidget {
  const NotificationDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                notificationProvider.hasUnread
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              if (notificationProvider.hasUnread)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      notificationProvider.unreadCount > 9
                          ? '9+'
                          : notificationProvider.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          itemBuilder: (context) {
            final notifications = notificationProvider.notifications;
            final l10n = AppLocalizations.of(context);

        if (notifications.isEmpty) {
          return [
            PopupMenuItem<String>(
              enabled: false,
              child: SizedBox(
                width: 300,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noNotifications,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        final items = <PopupMenuEntry<String>>[];

        // Заголовок
        items.add(
          PopupMenuItem<String>(
            enabled: false,
            child: SizedBox(
              width: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.notifications,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (notificationProvider.hasUnread)
                    TextButton(
                      onPressed: () {
                        notificationProvider.markAllAsRead();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.markAllRead,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );

        items.add(const PopupMenuDivider());

        // Список сповіщень (максимум 5)
        final displayNotifications = notifications.take(5).toList();

        for (var i = 0; i < displayNotifications.length; i++) {
          final notification = displayNotifications[i];

          items.add(
            PopupMenuItem<String>(
              value: notification.id,
              padding: EdgeInsets.zero,
              child: _NotificationItem(
                notification: notification,
                onTap: () {
                  Navigator.pop(context);
                  notificationProvider.markAsRead(notification.id);
                  // Переходимо до завдання
                  final taskProvider = context.read<TaskProvider>();
                  taskProvider.setFilter(TaskFilter.all);
                },
                onDismiss: () {
                  notificationProvider.deleteNotification(notification.id);
                },
              ),
            ),
          );

          if (i < displayNotifications.length - 1) {
            items.add(const PopupMenuDivider(height: 1));
          }
        }

        // Якщо є більше 5 сповіщень
        if (notifications.length > 5) {
          items.add(const PopupMenuDivider());
          items.add(
            PopupMenuItem<String>(
              enabled: false,
              child: SizedBox(
                width: 300,
                child: Center(
                  child: Text(
                    l10n.moreNotifications(notifications.length - 5),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Кнопка очистити всі
        if (notifications.isNotEmpty) {
          items.add(const PopupMenuDivider());
          items.add(
            PopupMenuItem<String>(
              child: SizedBox(
                width: 300,
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      notificationProvider.clearAll();
                    },
                    icon: const Icon(Icons.clear_all_rounded, size: 18),
                    label: Text(l10n.clearAll),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return items;
      },
    );
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final dynamic notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final timeAgo = _getTimeAgo(notification.createdAt, l10n);

    return Container(
      width: 300,
      color: notification.isRead
          ? Colors.transparent
          : theme.colorScheme.primary.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.taskTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.overdueSince} ${DateFormat.yMd().format(notification.taskDueDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return DateFormat.yMd().format(dateTime);
    }
  }
}
