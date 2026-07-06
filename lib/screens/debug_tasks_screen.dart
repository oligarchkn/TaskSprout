import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/task_provider.dart';

class DebugTasksScreen extends StatelessWidget {
  const DebugTasksScreen({super.key});

  Future<void> _clearAllData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data cleared! Restart the app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Tasks'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total tasks in _tasks: ${taskProvider.totalCount}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Active count: ${taskProvider.activeCount}'),
                Text('Completed count: ${taskProvider.completedCount}'),
                const SizedBox(height: 16),
                Text(
                  'Current Filters:',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Status Filter: ${taskProvider.currentFilter}'),
                Text('Priority Filter: ${taskProvider.priorityFilter ?? 'None'}'),
                Text('Date Filter: ${taskProvider.dateFilter}'),
                Text('Category Filter: ${taskProvider.categoryFilter ?? 'None'}'),
                const SizedBox(height: 16),
                Text(
                  'Filtered tasks (tasks getter): ${taskProvider.tasks.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check Chrome Console (F12) for detailed logs',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    taskProvider.clearFilters();
                  },
                  child: const Text('Clear All Filters'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    taskProvider.addTask('Test Task ${DateTime.now().millisecondsSinceEpoch}');
                  },
                  child: const Text('Add Test Task (No Date)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    taskProvider.addTask(
                      'Test Task with Date ${DateTime.now().millisecondsSinceEpoch}',
                      dueDate: DateTime.now().add(const Duration(days: 1)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Add Test Task (With Date)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    taskProvider.loadTasks();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Reload Tasks'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _clearAllData(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Clear All Data (Storage)'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
