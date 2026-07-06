import 'package:flutter_test/flutter_test.dart';
import 'package:task_sprout/models/task.dart';
import 'package:task_sprout/providers/task_provider.dart';

void main() {
  group('Task Priority Tests', () {
    late TaskProvider taskProvider;

    setUp(() {
      taskProvider = TaskProvider();
    });

    test('Task should be created with specified priority', () async {
      await taskProvider.addTask(
        'High priority task',
        priority: TaskPriority.high,
      );

      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks[0].priority, TaskPriority.high);
      expect(taskProvider.tasks[0].title, 'High priority task');
    });

    test('Task should be created with default priority (none)', () async {
      await taskProvider.addTask('Task without priority');

      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks[0].priority, TaskPriority.none);
    });

    test('Task priority should be updated correctly', () async {
      await taskProvider.addTask(
        'Task to update',
        priority: TaskPriority.low,
      );

      final taskId = taskProvider.tasks[0].id;
      expect(taskProvider.tasks[0].priority, TaskPriority.low);

      // Update priority to high
      await taskProvider.updateTask(
        taskId,
        priority: TaskPriority.high,
      );

      expect(taskProvider.tasks[0].priority, TaskPriority.high);
      expect(taskProvider.tasks[0].title, 'Task to update');
    });

    test('Multiple tasks with different priorities should be handled', () async {
      await taskProvider.addTask('Low task', priority: TaskPriority.low);
      await taskProvider.addTask('Medium task', priority: TaskPriority.medium);
      await taskProvider.addTask('High task', priority: TaskPriority.high);
      await taskProvider.addTask('No priority task');

      expect(taskProvider.tasks.length, 4);
      expect(taskProvider.tasks[0].priority, TaskPriority.none);
      expect(taskProvider.tasks[1].priority, TaskPriority.high);
      expect(taskProvider.tasks[2].priority, TaskPriority.medium);
      expect(taskProvider.tasks[3].priority, TaskPriority.low);
    });

    test('Priority filter should work correctly', () async {
      await taskProvider.addTask('Low 1', priority: TaskPriority.low);
      await taskProvider.addTask('Medium 1', priority: TaskPriority.medium);
      await taskProvider.addTask('High 1', priority: TaskPriority.high);
      await taskProvider.addTask('Low 2', priority: TaskPriority.low);
      await taskProvider.addTask('High 2', priority: TaskPriority.high);

      // Filter by high priority
      taskProvider.setPriorityFilter(TaskPriority.high);
      expect(taskProvider.tasks.length, 2);
      expect(taskProvider.tasks.every((t) => t.priority == TaskPriority.high), true);

      // Filter by low priority
      taskProvider.setPriorityFilter(TaskPriority.low);
      expect(taskProvider.tasks.length, 2);
      expect(taskProvider.tasks.every((t) => t.priority == TaskPriority.low), true);

      // Clear filter
      taskProvider.clearFilters();
      expect(taskProvider.tasks.length, 5);
    });
  });

  group('Task Focus Tests', () {
    late TaskProvider taskProvider;

    setUp(() {
      taskProvider = TaskProvider();
    });

    test('Task should be created with focus flag', () async {
      await taskProvider.addTask(
        'Focused task',
        isFocused: true,
      );

      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks[0].isFocused, true);
      expect(taskProvider.tasks[0].title, 'Focused task');
    });

    test('Task should be created without focus by default', () async {
      await taskProvider.addTask('Regular task');

      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks[0].isFocused, false);
    });

    test('Task focus should be updated correctly', () async {
      await taskProvider.addTask('Task to focus', isFocused: false);

      final taskId = taskProvider.tasks[0].id;
      expect(taskProvider.tasks[0].isFocused, false);

      // Set focus to true
      await taskProvider.updateTask(taskId, isFocused: true);
      expect(taskProvider.tasks[0].isFocused, true);

      // Set focus back to false
      await taskProvider.updateTask(taskId, isFocused: false);
      expect(taskProvider.tasks[0].isFocused, false);
    });

    test('toggleTaskFocus should toggle focus status', () async {
      await taskProvider.addTask('Toggle task', isFocused: false);

      final taskId = taskProvider.tasks[0].id;
      expect(taskProvider.tasks[0].isFocused, false);

      // Toggle to true
      await taskProvider.toggleTaskFocus(taskId);
      expect(taskProvider.tasks[0].isFocused, true);

      // Toggle back to false
      await taskProvider.toggleTaskFocus(taskId);
      expect(taskProvider.tasks[0].isFocused, false);
    });

    test('focusedTasks should return only focused, active, non-archived tasks', () async {
      await taskProvider.addTask('Focused 1', isFocused: true);
      await taskProvider.addTask('Focused 2', isFocused: true);
      await taskProvider.addTask('Not focused', isFocused: false);
      await taskProvider.addTask('Focused 3', isFocused: true);

      expect(taskProvider.focusedTasks.length, 3);
      expect(taskProvider.focusedTasks.every((t) => t.isFocused), true);
      expect(taskProvider.focusedTasks.every((t) => !t.isCompleted), true);
      expect(taskProvider.focusedTasks.every((t) => !t.isArchived), true);
    });

    test('Completed focused tasks should not appear in focusedTasks', () async {
      await taskProvider.addTask('Focused 1', isFocused: true);
      await taskProvider.addTask('Focused 2', isFocused: true);

      final task1Id = taskProvider.tasks[1].id;

      // Complete first task
      await taskProvider.toggleTask(task1Id);

      expect(taskProvider.focusedTasks.length, 1);
      expect(taskProvider.focusedTasks[0].id, taskProvider.tasks[0].id);
    });

    test('Archived focused tasks should not appear in focusedTasks', () async {
      await taskProvider.addTask('Focused 1', isFocused: true);
      await taskProvider.addTask('Focused 2', isFocused: true);

      final task1Id = taskProvider.tasks[1].id;

      // Archive first task
      await taskProvider.archiveTask(task1Id);

      expect(taskProvider.focusedTasks.length, 1);
      expect(taskProvider.focusedTasks[0].id, taskProvider.tasks[0].id);
    });
  });

  group('Task Model Tests', () {
    test('Task should serialize and deserialize priority correctly', () {
      final task = Task(
        id: '123',
        title: 'Test task',
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
        isFocused: true,
      );

      final json = task.toJson();
      expect(json['priority'], TaskPriority.high.index);
      expect(json['isFocused'], true);

      final restored = Task.fromJson(json);
      expect(restored.priority, TaskPriority.high);
      expect(restored.isFocused, true);
      expect(restored.title, 'Test task');
    });

    test('Task copyWith should preserve priority and focus when not specified', () {
      final task = Task(
        id: '123',
        title: 'Original',
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
        isFocused: true,
      );

      final updated = task.copyWith(title: 'Updated');
      expect(updated.title, 'Updated');
      expect(updated.priority, TaskPriority.medium);
      expect(updated.isFocused, true);
    });

    test('Task copyWith should update priority and focus when specified', () {
      final task = Task(
        id: '123',
        title: 'Original',
        createdAt: DateTime.now(),
        priority: TaskPriority.low,
        isFocused: false,
      );

      final updated = task.copyWith(
        priority: TaskPriority.high,
        isFocused: true,
      );

      expect(updated.priority, TaskPriority.high);
      expect(updated.isFocused, true);
      expect(updated.title, 'Original');
    });
  });

  group('Combined Priority and Focus Tests', () {
    late TaskProvider taskProvider;

    setUp(() {
      taskProvider = TaskProvider();
    });

    test('Task with both priority and focus should work correctly', () async {
      await taskProvider.addTask(
        'Important focused task',
        priority: TaskPriority.high,
        isFocused: true,
      );

      expect(taskProvider.tasks.length, 1);
      expect(taskProvider.tasks[0].priority, TaskPriority.high);
      expect(taskProvider.tasks[0].isFocused, true);
      expect(taskProvider.focusedTasks.length, 1);
    });

    test('Should update both priority and focus simultaneously', () async {
      await taskProvider.addTask('Task');

      final taskId = taskProvider.tasks[0].id;

      await taskProvider.updateTask(
        taskId,
        priority: TaskPriority.high,
        isFocused: true,
      );

      expect(taskProvider.tasks[0].priority, TaskPriority.high);
      expect(taskProvider.tasks[0].isFocused, true);
      expect(taskProvider.focusedTasks.length, 1);
    });

    test('Priority filter should not affect focused tasks list', () async {
      await taskProvider.addTask('Low focused', priority: TaskPriority.low, isFocused: true);
      await taskProvider.addTask('High focused', priority: TaskPriority.high, isFocused: true);
      await taskProvider.addTask('Medium not focused', priority: TaskPriority.medium, isFocused: false);

      // All focused tasks should appear regardless of filter
      expect(taskProvider.focusedTasks.length, 2);

      // Apply priority filter
      taskProvider.setPriorityFilter(TaskPriority.high);
      expect(taskProvider.tasks.length, 1);

      // Focused tasks should still show all focused tasks
      expect(taskProvider.focusedTasks.length, 2);
    });
  });
}
