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

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
          ),
        );
      },
      leading: Checkbox(
        value: task.status == TaskStatus.completed,
        onChanged: (_) => taskProvider.toggleTaskStatus(task),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.status == TaskStatus.completed
              ? TextDecoration.lineThrough
              : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.notes.isNotEmpty)
            Text(
              task.notes,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          Row(
            children: [
              if (task.dueDate != null) ...[
                Icon(Icons.calendar_today, size: 12, color: _getDateColor(task.dueDate!)),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, HH:mm').format(task.dueDate!),
                  style: TextStyle(fontSize: 12, color: _getDateColor(task.dueDate!)),
                ),
                const SizedBox(width: 8),
              ],
              _getPriorityIcon(task.priority),
              const SizedBox(width: 8),
              if (task.subTasks.isNotEmpty) ...[
                const Icon(Icons.checklist, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${task.subTasks.where((s) => s.isCompleted).length}/${task.subTasks.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: task.tagIds.map((tagId) {
                      final tag = taskProvider.tags.firstWhere((t) => t.id == tagId,
                          orElse: () => Tag(id: '', name: ''));
                      if (tag.id.isEmpty) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(tag.colorValue).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag.name,
                          style: TextStyle(fontSize: 10, color: Color(tag.colorValue)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      isThreeLine: task.notes.isNotEmpty,
    );
  }

  Color _getDateColor(DateTime date) {
    if (date.isBefore(DateTime.now())) return Colors.red;
    return Colors.grey;
  }

  Widget _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Icon(Icons.priority_high, size: 16, color: Colors.red);
      case TaskPriority.medium:
        return const Icon(Icons.priority_high, size: 16, color: Colors.orange);
      case TaskPriority.low:
        return const Icon(Icons.low_priority, size: 16, color: Colors.blue);
    }
  }
}
