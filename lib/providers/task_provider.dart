import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../models/tag.dart';
import '../services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final _uuid = const Uuid();

  List<Task> _tasks = [];
  List<Project> _projects = [];
  List<Tag> _tags = [];

  List<Task> get tasks => _tasks;
  List<Project> get projects => _projects;
  List<Tag> get tags => _tags;

  TaskProvider() {
    _init();
  }

  void _init() {
    _firebaseService.getTasks().listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
    _firebaseService.getProjects().listen((projects) {
      _projects = projects;
      notifyListeners();
    });
    _firebaseService.getTags().listen((tags) {
      _tags = tags;
      notifyListeners();
    });
  }

  // Project Operations
  Future<void> addProject(String name, int colorValue) async {
    final project = Project(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
      iconCodePoint: Icons.folder.codePoint,
    );
    await _firebaseService.addProject(project);
  }

  // Tag Operations
  Future<void> addTag(String name, int colorValue) async {
    final tag = Tag(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
    );
    await _firebaseService.addTag(tag);
  }

  // Task Operations
  Future<void> addTask({
    required String title,
    String notes = '',
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    required String projectId,
    List<String> tagIds = const [],
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      notes: notes,
      dueDate: dueDate,
      priority: priority,
      projectId: projectId,
      tagIds: tagIds,
      createdAt: DateTime.now(),
    );
    await _firebaseService.addTask(task);
  }

  Future<void> updateTask(Task task) async {
    await _firebaseService.updateTask(task);
  }

  Future<void> toggleTaskStatus(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      notes: task.notes,
      dueDate: task.dueDate,
      priority: task.priority,
      status: task.status == TaskStatus.completed ? TaskStatus.pending : TaskStatus.completed,
      projectId: task.projectId,
      tagIds: task.tagIds,
      subTasks: task.subTasks,
      attachments: task.attachments,
      createdAt: task.createdAt,
    );
    await _firebaseService.updateTask(updatedTask);
  }

  Future<void> deleteTask(String taskId) async {
    await _firebaseService.deleteTask(taskId);
  }

  // Helper getters for Smart Views
  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null || task.status == TaskStatus.completed) return false;
      return task.dueDate!.year == now.year &&
          task.dueDate!.month == now.month &&
          task.dueDate!.day == now.day;
    }).toList();
  }

  List<Task> get upcomingTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null || task.status == TaskStatus.completed) return false;
      return task.dueDate!.isAfter(now);
    }).toList();
  }

  List<Task> get overdueTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null || task.status == TaskStatus.completed) return false;
      return task.dueDate!.isBefore(now);
    }).toList();
  }

  List<Task> get completedTasks =>
      _tasks.where((task) => task.status == TaskStatus.completed).toList();

  List<Task> get highPriorityTasks =>
      _tasks.where((task) => task.priority == TaskPriority.high && task.status != TaskStatus.completed).toList();
}
