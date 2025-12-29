import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';
import 'package:provider/provider.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final isCompleted = task.status == TaskStatus.completed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => taskProvider.toggleTaskStatus(task),
                child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.black : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? Colors.black : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.grey : Colors.black,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.dueDate != null || task.tagIds.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (task.dueDate != null) ...[
                            Icon(Icons.calendar_today_outlined, 
                              size: 12, 
                              color: _isOverdue(task.dueDate!) ? Colors.red : Colors.grey
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d').format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 12, 
                                color: _isOverdue(task.dueDate!) ? Colors.red : Colors.grey
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          ...task.tagIds.take(2).map((tagId) {
                            final tag = taskProvider.tags.firstWhere((t) => t.id == tagId,
                                orElse: () => Tag(id: '', name: ''));
                            if (tag.id.isEmpty) return const SizedBox.shrink();
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Text(
                                '#${tag.name}',
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: Color(tag.colorValue).withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              _getPriorityIndicator(task.priority),
            ],
          ),
        ),
      ),
    );
  }

  bool _isOverdue(DateTime date) {
    return date.isBefore(DateTime.now()) && task.status != TaskStatus.completed;
  }

  Widget _getPriorityIndicator(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        break;
      case TaskPriority.low:
        color = Colors.blue;
        break;
    }
    return Container(
      width: 4,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
