import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';
import 'add_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    // Find the current version of the task from the provider
    final currentTask = provider.tasks.firstWhere((t) => t.id == task.id, orElse: () => task);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(taskToEdit: currentTask),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              provider.deleteTask(currentTask.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: currentTask.status == TaskStatus.completed,
                  onChanged: (_) => provider.toggleTaskStatus(currentTask),
                ),
                Expanded(
                  child: Text(
                    currentTask.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          decoration: currentTask.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentTask.notes.isNotEmpty) ...[
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(currentTask.notes),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(currentTask.dueDate != null
                    ? DateFormat('MMM d, yyyy HH:mm').format(currentTask.dueDate!)
                    : 'No due date'),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Sub-tasks', style: TextStyle(fontWeight: FontWeight.bold)),
            ...currentTask.subTasks.map((sub) => CheckboxListTile(
                  title: Text(sub.title),
                  value: sub.isCompleted,
                  onChanged: (val) {
                    _toggleSubTask(provider, currentTask, sub);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                )),
            TextButton.icon(
              onPressed: () => _showAddSubTaskDialog(context, provider, currentTask),
              icon: const Icon(Icons.add),
              label: const Text('Add Sub-task'),
            ),
            const Divider(),
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: currentTask.tagIds.map((tagId) {
                final tag = provider.tags.firstWhere((t) => t.id == tagId,
                    orElse: () => Tag(id: '', name: 'Unknown'));
                return Chip(
                  label: Text(tag.name),
                  backgroundColor: Color(tag.colorValue).withOpacity(0.2),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSubTask(TaskProvider provider, Task task, SubTask subTask) {
    final updatedSubTasks = task.subTasks.map((s) {
      if (s.id == subTask.id) {
        return SubTask(id: s.id, title: s.title, isCompleted: !s.isCompleted);
      }
      return s;
    }).toList();

    final updatedTask = Task(
      id: task.id,
      title: task.title,
      notes: task.notes,
      dueDate: task.dueDate,
      priority: task.priority,
      status: task.status,
      projectId: task.projectId,
      tagIds: task.tagIds,
      subTasks: updatedSubTasks,
      attachments: task.attachments,
      createdAt: task.createdAt,
    );
    provider.updateTask(updatedTask);
  }

  void _showAddSubTaskDialog(BuildContext context, TaskProvider provider, Task task) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Sub-task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Sub-task title'),
          autoFocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newSub = SubTask(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: controller.text,
                );
                final updatedTask = Task(
                  id: task.id,
                  title: task.title,
                  notes: task.notes,
                  dueDate: task.dueDate,
                  priority: task.priority,
                  status: task.status,
                  projectId: task.projectId,
                  tagIds: task.tagIds,
                  subTasks: [...task.subTasks, newSub],
                  attachments: task.attachments,
                  createdAt: task.createdAt,
                );
                provider.updateTask(updatedTask);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
