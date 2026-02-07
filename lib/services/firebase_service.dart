import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../models/tag.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Projects - filtered by user
  Stream<List<Project>> getProjects(String userId) {
    return _db
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Project.fromMap(doc.data())).toList());
  }

  Future<void> addProject(Project project, String userId) {
    final data = project.toMap();
    data['userId'] = userId;
    return _db.collection('projects').doc(project.id).set(data);
  }

  Future<void> updateProject(Project project) {
    return _db.collection('projects').doc(project.id).update(project.toMap());
  }

  Future<void> deleteProject(String projectId) async {
    await _db.collection('projects').doc(projectId).delete();
  }

  // Tags - filtered by user
  Stream<List<Tag>> getTags(String userId) {
    return _db
        .collection('tags')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Tag.fromMap(doc.data())).toList());
  }

  Future<void> addTag(Tag tag, String userId) {
    final data = tag.toMap();
    data['userId'] = userId;
    return _db.collection('tags').doc(tag.id).set(data);
  }

  // Tasks - filtered by user
  Stream<List<Task>> getTasks(String userId) {
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList());
  }

  Future<void> addTask(Task task, String userId) {
    final data = task.toMap();
    data['userId'] = userId;
    return _db.collection('tasks').doc(task.id).set(data);
  }

  Future<void> updateTask(Task task) {
    return _db.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _db.collection('tasks').doc(taskId).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied: Cannot delete task');
      } else if (e.code == 'unavailable') {
        throw Exception('Network error: Please check your connection');
      } else if (e.code == 'not-found') {
        throw Exception('Task not found');
      } else {
        throw Exception('Failed to delete task: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error deleting task: $e');
    }
  }
}
