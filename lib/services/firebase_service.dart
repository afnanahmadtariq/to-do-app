import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../models/tag.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Projects
  Stream<List<Project>> getProjects() {
    return _db.collection('projects').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Project.fromMap(doc.data())).toList());
  }

  Future<void> addProject(Project project) {
    return _db.collection('projects').doc(project.id).set(project.toMap());
  }

  Future<void> updateProject(Project project) {
    return _db.collection('projects').doc(project.id).update(project.toMap());
  }

  // Tags
  Stream<List<Tag>> getTags() {
    return _db.collection('tags').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Tag.fromMap(doc.data())).toList());
  }

  Future<void> addTag(Tag tag) {
    return _db.collection('tags').doc(tag.id).set(tag.toMap());
  }

  // Tasks
  Stream<List<Task>> getTasks() {
    return _db.collection('tasks').orderBy('createdAt', descending: true).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList());
  }

  Future<void> addTask(Task task) {
    return _db.collection('tasks').doc(task.id).set(task.toMap());
  }

  Future<void> updateTask(Task task) {
    return _db.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) {
    return _db.collection('tasks').doc(taskId).delete();
  }
}
