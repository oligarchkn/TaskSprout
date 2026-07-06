enum NotificationType {
  overdue, // Прострочене завдання
}

class TaskNotification {
  final String id;
  final String taskId;
  final String taskTitle;
  final DateTime taskDueDate;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  TaskNotification({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.taskDueDate,
    required this.createdAt,
    this.isRead = false,
    this.type = NotificationType.overdue,
  });

  TaskNotification copyWith({
    String? id,
    String? taskId,
    String? taskTitle,
    DateTime? taskDueDate,
    DateTime? createdAt,
    bool? isRead,
    NotificationType? type,
  }) {
    return TaskNotification(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      taskDueDate: taskDueDate ?? this.taskDueDate,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'taskDueDate': taskDueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type.index,
    };
  }

  factory TaskNotification.fromJson(Map<String, dynamic> json) {
    return TaskNotification(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String,
      taskDueDate: DateTime.parse(json['taskDueDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: NotificationType.values[json['type'] as int? ?? 0],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
