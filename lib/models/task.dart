import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { pending, completed, archived }

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String notes;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String projectId;
  final List<String> tagIds;
  final List<SubTask> subTasks;
  final List<String> attachments;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.notes = '',
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    required this.projectId,
    this.tagIds = const [],
    this.subTasks = const [],
    this.attachments = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority.index,
      'status': status.index,
      'projectId': projectId,
      'tagIds': tagIds,
      'subTasks': subTasks.map((s) => s.toMap()).toList(),
      'attachments': attachments,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      notes: map['notes'] ?? '',
      dueDate: map['dueDate'] != null ? (map['dueDate'] as Timestamp).toDate() : null,
      priority: TaskPriority.values[map['priority'] ?? 1],
      status: TaskStatus.values[map['status'] ?? 0],
      projectId: map['projectId'] ?? '',
      tagIds: List<String>.from(map['tagIds'] ?? []),
      subTasks: (map['subTasks'] as List? ?? [])
          .map((s) => SubTask.fromMap(Map<String, dynamic>.from(s)))
          .toList(),
      attachments: List<String>.from(map['attachments'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
