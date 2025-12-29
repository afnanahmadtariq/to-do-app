import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';
import 'add_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final currentTask = provider.tasks.firstWhere((t) => t.id == task.id, orElse: () => task);
    final isCompleted = currentTask.status == TaskStatus.completed;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(Icons.chevron_left, () => Navigator.pop(context)),
                  Row(
                    children: [
                      _buildCircleButton(Icons.edit_outlined, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTaskScreen(taskToEdit: currentTask),
                          ),
                        );
                      }),
                      const SizedBox(width: 12),
                      _buildCircleButton(Icons.delete_outline, () {
                        provider.deleteTask(currentTask.id);
                        Navigator.pop(context);
                      }, color: Colors.red.shade400),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => provider.toggleTaskStatus(currentTask),
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted ? Colors.black : Colors.transparent,
                              border: Border.all(
                                color: isCompleted ? Colors.black : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: isCompleted
                                ? const Icon(Icons.check, size: 20, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            currentTask.title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.grey : Colors.black,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (currentTask.notes.isNotEmpty) ...[
                      _buildSectionLabel('NOTES'),
                      const SizedBox(height: 8),
                      Text(
                        currentTask.notes,
                        style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                    ],
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.calendar_today_outlined,
                          currentTask.dueDate != null
                              ? DateFormat('MMM d, yyyy').format(currentTask.dueDate!)
                              : 'No deadline',
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.flag_outlined,
                          currentTask.priority.name.toUpperCase(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Divider(height: 1),
                    const SizedBox(height: 32),
                    _buildSectionLabel('SUB-TASKS'),
                    const SizedBox(height: 16),
                    ...currentTask.subTasks.map((sub) => _buildSubTaskTile(context, provider, currentTask, sub)),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => _showAddSubTaskDialog(context, provider, currentTask),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Add a sub-task', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionLabel('TAGS'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentTask.tagIds.map((tagId) {
                        final tag = provider.tags.firstWhere((t) => t.id == tagId,
                            orElse: () => Tag(id: '', name: 'Unknown'));
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(tag.colorValue).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#${tag.name}',
                            style: TextStyle(
                              color: Color(tag.colorValue),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, color: color ?? Colors.black, size: 20),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade400,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTaskTile(BuildContext context, TaskProvider provider, Task task, SubTask sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSubTask(provider, task, sub),
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sub.isCompleted ? Colors.black : Colors.transparent,
                border: Border.all(
                  color: sub.isCompleted ? Colors.black : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: sub.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              sub.title,
              style: TextStyle(
                fontSize: 16,
                color: sub.isCompleted ? Colors.grey : Colors.black87,
                decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('New Sub-task', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter sub-task title',
            border: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
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
            child: const Text('Add', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
