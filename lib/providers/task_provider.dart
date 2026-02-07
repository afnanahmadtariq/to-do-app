import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../models/tag.dart';
import '../services/firebase_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class TaskProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final _uuid = const Uuid();

  String? _userId;
  List<Task> _tasks = [];
  List<Project> _projects = [];
  List<Tag> _tags = [];

  // Stream subscriptions
  StreamSubscription? _tasksSubscription;
  StreamSubscription? _projectsSubscription;
  StreamSubscription? _tagsSubscription;

  // Cache for expensive filtered lists
  List<Task>? _cachedTodayTasks;
  List<Task>? _cachedUpcomingTasks;
  List<Task>? _cachedOverdueTasks;
  List<Task>? _cachedCompletedTasks;
  List<Task>? _cachedHighPriorityTasks;

  String? get userId => _userId;
  List<Task> get tasks => _tasks;
  List<Project> get projects => _projects;
  List<Tag> get tags => _tags;

  // Debounce timer for batching notifyListeners calls
  Timer? _debounceTimer;
  bool _hasUpdates = false;

  // Set user and initialize data streams
  void setUser(String? userId) {
    if (_userId == userId) return;
    
    _userId = userId;
    
    // Cancel existing subscriptions
    _tasksSubscription?.cancel();
    _projectsSubscription?.cancel();
    _tagsSubscription?.cancel();

    // Clear data
    _tasks = [];
    _projects = [];
    _tags = [];
    _invalidateCache();

    if (userId != null) {
      _initUserData(userId);
    }
    
    notifyListeners();
  }

  void _initUserData(String userId) {
    _tasksSubscription = _firebaseService.getTasks(userId).listen((tasks) {
      _tasks = tasks;
      _invalidateCache();
      _scheduleNotify();
    });
    
    _projectsSubscription = _firebaseService.getProjects(userId).listen((projects) {
      _projects = projects;
      _scheduleNotify();
    });
    
    _tagsSubscription = _firebaseService.getTags(userId).listen((tags) {
      _tags = tags;
      _scheduleNotify();
    });
  }

  // Batch multiple updates together to reduce rebuilds
  void _scheduleNotify() {
    _hasUpdates = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      if (_hasUpdates) {
        _hasUpdates = false;
        notifyListeners();
      }
    });
  }

  // Invalidate all caches when tasks change
  void _invalidateCache() {
    _cachedTodayTasks = null;
    _cachedUpcomingTasks = null;
    _cachedOverdueTasks = null;
    _cachedCompletedTasks = null;
    _cachedHighPriorityTasks = null;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tasksSubscription?.cancel();
    _projectsSubscription?.cancel();
    _tagsSubscription?.cancel();
    super.dispose();
  }

  // Project Operations
  Future<void> addProject(String name, int colorValue) async {
    if (_userId == null) return;
    
    final project = Project(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
      iconCodePoint: Icons.folder.codePoint,
    );
    await _firebaseService.addProject(project, _userId!);
  }

  // Tag Operations
  Future<void> addTag(String name, int colorValue) async {
    if (_userId == null) return;
    
    final tag = Tag(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
    );
    await _firebaseService.addTag(tag, _userId!);
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
    if (_userId == null) return;
    
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
    await _firebaseService.addTask(task, _userId!);
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
    // Optimistic update: remove from local state immediately
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;
    
    final deletedTask = _tasks[taskIndex];
    _tasks.removeAt(taskIndex);
    _invalidateCache();
    notifyListeners();

    try {
      // Delete from Firestore
      await _firebaseService.deleteTask(taskId);
    } catch (e) {
      // Rollback: restore the task if deletion fails
      _tasks.insert(taskIndex, deletedTask);
      _invalidateCache();
      notifyListeners();
      rethrow; // Re-throw to let UI handle the error
    }
  }

  // Helper getters for Smart Views with caching
  List<Task> get todayTasks {
    if (_cachedTodayTasks != null) return _cachedTodayTasks!;
    
    final now = DateTime.now();
    _cachedTodayTasks = _tasks.where((task) {
      if (task.dueDate == null || task.status == TaskStatus.completed) return false;
      return task.dueDate!.year == now.year &&
          task.dueDate!.month == now.month &&
          task.dueDate!.day == now.day;
    }).toList();
    return _cachedTodayTasks!;
  }

  List<Task> get upcomingTasks {
    if (_cachedUpcomingTasks != null) return _cachedUpcomingTasks!;
    
    final now = DateTime.now();
    _cachedUpcomingTasks = _tasks.where((task) {
      if (task.dueDate == null || task.status == TaskStatus.completed) return false;
      return task.dueDate!.isAfter(now);
    }).toList();
    return _cachedUpcomingTasks!;
  }

  List<Task> get overdueTasks {
    if (_cachedOverdueTasks != null) return _cachedOverdueTasks!;
    
    final now = DateTime.now();
    _cachedOverdueTasks = _tasks.where((task) {
      if (task.dueDate == null || task.status == TaskStatus.completed) return false;
      return task.dueDate!.isBefore(now);
    }).toList();
    return _cachedOverdueTasks!;
  }

  List<Task> get completedTasks {
    if (_cachedCompletedTasks != null) return _cachedCompletedTasks!;
    
    _cachedCompletedTasks = _tasks.where((task) => task.status == TaskStatus.completed).toList();
    return _cachedCompletedTasks!;
  }

  List<Task> get highPriorityTasks {
    if (_cachedHighPriorityTasks != null) return _cachedHighPriorityTasks!;
    
    _cachedHighPriorityTasks = _tasks.where((task) => 
      task.priority == TaskPriority.high && task.status != TaskStatus.completed
    ).toList();
    return _cachedHighPriorityTasks!;
  }
}
