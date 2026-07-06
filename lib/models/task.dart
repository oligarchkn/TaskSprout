enum TaskPriority { none, low, medium, high }

class Task {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final TaskPriority priority;
  final String? category;
  final bool isArchived;
  final bool isFocused;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.priority = TaskPriority.none,
    this.category,
    this.isArchived = false,
    this.isFocused = false,
  });

  // Create a copy of the task with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
    TaskPriority? priority,
    String? category,
    bool? isArchived,
    bool? isFocused,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isArchived: isArchived ?? this.isArchived,
      isFocused: isFocused ?? this.isFocused,
    );
  }

  // Convert task to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority.index,
      'category': category,
      'isArchived': isArchived,
      'isFocused': isFocused,
    };
  }

  // Create task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      priority: TaskPriority.values[json['priority'] as int? ?? 0],
      category: json['category'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      isFocused: json['isFocused'] as bool? ?? false,
    );
  }

  // Convert task to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': int.parse(id), // Convert string ID to int for SQLite
      'title': title,
      'description': description,
      'category_id': category != null ? _getCategoryId(category!) : null,
      'priority': priority.index,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'is_focused': isFocused ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create task from SQLite Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'].toString(), // Convert int ID back to string
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      priority: TaskPriority.values[map['priority'] as int? ?? 0],
      category: map['category_id'] != null
          ? _getCategoryName(map['category_id'] as int)
          : null,
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
      isFocused: (map['is_focused'] as int? ?? 0) == 1,
    );
  }

  // Helper: Get category ID from name (temporary, will be improved)
  static int? _getCategoryId(String categoryName) {
    const categoryMap = {
      'Робота': 1,
      'Особисте': 2,
      'Покупки': 3,
      'Здоров\'я': 4,
      'Інше': 5,
      'Work': 1,
      'Personal': 2,
      'Shopping': 3,
      'Health': 4,
      'Other': 5,
    };
    return categoryMap[categoryName];
  }

  // Helper: Get category name from ID (temporary, will be improved)
  static String? _getCategoryName(int categoryId) {
    const categoryMap = {
      1: 'Робота',
      2: 'Особисте',
      3: 'Покупки',
      4: 'Здоров\'я',
      5: 'Інше',
    };
    return categoryMap[categoryId];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
