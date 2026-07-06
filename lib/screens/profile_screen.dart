import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/task_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/edit_profile_dialog.dart';
import 'debug_tasks_screen.dart';
import 'archived_tasks_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProfile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header card
          Consumer<UserProfileProvider>(
            builder: (context, profileProvider, child) {
              final profile = profileProvider.profile;

              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            profile.avatarEmoji ?? '👤',
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Name
                      Text(
                        profile.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (profile.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile.email!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],

                      if (profile.bio != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          profile.bio!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Edit button
                      FilledButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const EditProfileDialog(),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Statistics card
          Consumer2<UserProfileProvider, TaskProvider>(
            builder: (context, profileProvider, taskProvider, child) {
              final profile = profileProvider.profile;
              final totalTasks = taskProvider.tasks.length;
              final completedTasks = taskProvider.tasks.where((t) => t.isCompleted).length;
              final completionRate = totalTasks > 0
                  ? (completedTasks / totalTasks * 100).round()
                  : 0;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Daily goal progress
                      Row(
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Goal',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: completedTasks / profile.dailyGoal,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$completedTasks / ${profile.dailyGoal}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      // Stats grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: Icons.task_alt,
                              label: 'Total Tasks',
                              value: '$totalTasks',
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.check_circle,
                              label: 'Completed',
                              value: '$completedTasks',
                              color: Colors.green,
                            ),
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.percent,
                              label: 'Rate',
                              value: '$completionRate%',
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Archive section
          Card(
            child: ListTile(
              leading: Icon(
                Icons.archive_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(l10n.archived),
              subtitle: Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  final count = taskProvider.archivedCount;
                  return Text('$count ${count == 1 ? 'task' : 'tasks'}');
                },
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArchivedTasksScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Archive completed tasks button
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final completedCount = taskProvider.tasks
                  .where((task) => task.isCompleted)
                  .length;

              if (completedCount == 0) {
                return const SizedBox.shrink();
              }

              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.archive_outlined,
                    color: theme.colorScheme.secondary,
                  ),
                  title: Text(l10n.archiveCompleted),
                  subtitle: Text('$completedCount ${completedCount == 1 ? 'task' : 'tasks'}'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.archiveCompletedConfirm),
                        content: Text('Archive $completedCount completed ${completedCount == 1 ? 'task' : 'tasks'}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              taskProvider.archiveCompleted();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$completedCount ${completedCount == 1 ? 'task' : 'tasks'} archived'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Text(l10n.archive),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Debug section
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DebugTasksScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bug_report),
              label: const Text('Debug Tasks'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
