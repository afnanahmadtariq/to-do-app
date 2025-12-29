import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_tile.dart';

class TaskSearchDelegate extends SearchDelegate {
  final List<Task> tasks;

  TaskSearchDelegate(this.tasks);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = tasks.where((task) =>
        task.title.toLowerCase().contains(query.toLowerCase()) ||
        task.notes.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => TaskTile(task: results[index]),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = tasks.where((task) =>
        task.title.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) => TaskTile(task: suggestions[index]),
    );
  }
}
