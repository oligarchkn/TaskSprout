import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

enum TaskFilter { all, active, completed }
enum DateFilter { all, today, week, month }

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  TaskPriority? _priorityFilter;
  DateFilter _dateFilter = DateFilter.all;
  String? _categoryFilter;
  bool _isLoading = false;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  static const String _prefFilter = 'filter_status';
  static const String _prefPriority = 'filter_priority';
  static const String _prefDate = 'filter_date';
  static const String _prefCategory = 'filter_category';

  List<Task> get tasks {
    var filteredTasks = _tasks.where((task) => !task.isArchived).toList();

    switch (_currentFilter) {
      case TaskFilter.active:
        filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.completed:
        filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.all:
        break;
    }

    if (_priorityFilter != null) {
      filteredTasks = filteredTasks
          .where((task) => task.priority == _priorityFilter)
          .toList();
    }

    if (_dateFilter != DateFilter.all) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      filteredTasks = filteredTasks.where((task) {
        if (task.dueDate == null) return false;

        final dueDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );

        switch (_dateFilter) {
          case DateFilter.today:
            return dueDate.isAtSameMomentAs(today);
          case DateFilter.week:
            final weekFromNow = today.add(const Duration(days: 7));
            return dueDate.isAfter(today.subtract(const Duration(days: 1))) &&
                dueDate.isBefore(weekFromNow.add(const Duration(days: 1)));
          case DateFilter.month:
            final monthFromNow = DateTime(now.year, now.month + 1, now.day);
            return dueDate.isAfter(today.subtract(const Duration(days: 1))) &&
                dueDate.isBefore(monthFromNow.add(const Duration(days: 1)));
          case DateFilter.all:
            return true;
        }
      }).toList();
    }

    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      filteredTasks = filteredTasks
          .where((task) => task.category == _categoryFilter)
          .toList();
    }

    return List.unmodifiable(filteredTasks);
  }

  List<Task> get allTasks => List.unmodifiable(_tasks);

  TaskFilter get currentFilter => _currentFilter;
  TaskPriority? get priorityFilter => _priorityFilter;
  DateFilter get dateFilter => _dateFilter;
  String? get categoryFilter => _categoryFilter;
  bool get isLoading => _isLoading;

  int get totalCount => _tasks.length;
  int get activeCount => _tasks.where((task) => !task.isCompleted).length;
  int get completedCount => _tasks.where((task) => task.isCompleted).length;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadFilters();
      _tasks = await _dbHelper.readAllTasks();
      _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint('Tasks loaded from database: ${_tasks.length}');
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(
    String title, {
    String? description,
    TaskPriority priority = TaskPriority.none,
    String? category,
    DateTime? dueDate,
    bool isFocused = false,
  }) async {
    if (title.trim().isEmpty) return;

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description,
      priority: priority,
      category: category,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      isFocused: isFocused,
    );

    try {
      final taskId = await _dbHelper.createTask(task);
      final savedTask = task.copyWith(id: taskId.toString());
      _tasks.insert(0, savedTask);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> updateTask(
    String id, {
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    String? category,
    DateTime? dueDate,
    bool? isFocused,
  }) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final oldTask = _tasks[index];
    _tasks[index] = oldTask.copyWith(
      title: title,
      description: description,
      isCompleted: isCompleted,
      priority: priority,
      category: category,
      dueDate: dueDate,
      isFocused: isFocused,
      completedAt: (isCompleted == true && oldTask.completedAt == null)
          ? DateTime.now()
          : oldTask.completedAt,
    );

    try {
      await _dbHelper.updateTask(_tasks[index]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    final newCompletedStatus = !task.isCompleted;

    _tasks[index] = task.copyWith(
      isCompleted: newCompletedStatus,
      completedAt: newCompletedStatus ? DateTime.now() : null,
    );

    try {
      await _dbHelper.updateTask(_tasks[index]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);

    try {
      await _dbHelper.deleteTask(int.parse(id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    _saveFilters();
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    _saveFilters();
    notifyListeners();
  }

  void setDateFilter(DateFilter filter) {
    _dateFilter = filter;
    _saveFilters();
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    _saveFilters();
    notifyListeners();
  }

  void clearFilters() {
    _currentFilter = TaskFilter.all;
    _priorityFilter = null;
    _dateFilter = DateFilter.all;
    _categoryFilter = null;
    _saveFilters();
    notifyListeners();
  }

  List<String> get categories {
    final cats = _tasks
        .where((task) => task.category != null && task.category!.isNotEmpty)
        .map((task) => task.category!)
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  Future<void> clearCompleted() async {
    final completedIds = _tasks
        .where((task) => task.isCompleted)
        .map((task) => task.id)
        .toList();

    _tasks.removeWhere((task) => task.isCompleted);

    try {
      for (final id in completedIds) {
        await _dbHelper.deleteTask(int.parse(id));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing completed tasks: $e');
    }
  }

  Future<void> archiveTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(isArchived: true);

    try {
      await _dbHelper.updateTask(_tasks[index]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error archiving task: $e');
    }
  }

  Future<void> unarchiveTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(isArchived: false);

    try {
      await _dbHelper.updateTask(_tasks[index]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error unarchiving task: $e');
    }
  }

  Future<void> archiveCompleted() async {
    final tasksToArchive = <Task>[];

    for (var i = 0; i < _tasks.length; i++) {
      if (_tasks[i].isCompleted && !_tasks[i].isArchived) {
        _tasks[i] = _tasks[i].copyWith(isArchived: true);
        tasksToArchive.add(_tasks[i]);
      }
    }

    try {
      for (final task in tasksToArchive) {
        await _dbHelper.updateTask(task);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error archiving completed tasks: $e');
    }
  }

  int get archivedCount => _tasks.where((task) => task.isArchived).length;

  List<Task> get archivedTasks {
    return _tasks.where((task) => task.isArchived).toList();
  }

  List<Task> get focusedTasks {
    return _tasks
        .where((task) => task.isFocused && !task.isArchived && !task.isCompleted)
        .toList();
  }

  Future<void> toggleTaskFocus(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(
      isFocused: !_tasks[index].isFocused,
    );

    try {
      await _dbHelper.updateTask(_tasks[index]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling task focus: $e');
    }
  }

  Future<void> _saveFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefFilter, _currentFilter.name);
      await prefs.setInt(_prefPriority, _priorityFilter?.index ?? -1);
      await prefs.setString(_prefDate, _dateFilter.name);
      await prefs.setString(_prefCategory, _categoryFilter ?? '');
    } catch (e) {
      debugPrint('Error saving filters: $e');
    }
  }

  Future<void> _loadFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final filterName = prefs.getString(_prefFilter);
      if (filterName != null) {
        _currentFilter = TaskFilter.values.firstWhere(
          (f) => f.name == filterName,
          orElse: () => TaskFilter.all,
        );
      }

      final priorityIndex = prefs.getInt(_prefPriority);
      if (priorityIndex != null && priorityIndex >= 0) {
        _priorityFilter = TaskPriority.values[priorityIndex];
      }

      final dateName = prefs.getString(_prefDate);
      if (dateName != null) {
        _dateFilter = DateFilter.values.firstWhere(
          (f) => f.name == dateName,
          orElse: () => DateFilter.all,
        );
      }

      final category = prefs.getString(_prefCategory);
      if (category != null && category.isNotEmpty) {
        _categoryFilter = category;
      }
    } catch (e) {
      debugPrint('Error loading filters: $e');
    }
  }
}
