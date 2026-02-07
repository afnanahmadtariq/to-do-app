import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_task_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Project _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final projectTasks = taskProvider.tasks.where((t) => t.projectId == _project.id).toList();
    final pendingTasks = projectTasks.where((t) => t.status == TaskStatus.pending).toList();
    final completedTasks = projectTasks.where((t) => t.status == TaskStatus.completed).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context, pendingTasks.length + completedTasks.length, completedTasks.length),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildTaskItem(context, pendingTasks[index], taskProvider);
                    },
                    childCount: pendingTasks.length,
                  ),
                ),
              ),
              if (completedTasks.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildCompletedSection(context, completedTasks, taskProvider),
                ),
            ],
          ),
          Positioned(
            top: 40,
            left: 20,
            child: _buildCircleButton(Icons.chevron_left, () => Navigator.pop(context)),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: _buildOptionsButton(context, taskProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsButton(BuildContext context, TaskProvider taskProvider) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(context, value, taskProvider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 45),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_horiz, color: Colors.black, size: 20),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 12),
              Text('Rename Project'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'change_color',
          child: Row(
            children: [
              Icon(Icons.palette_outlined, size: 20),
              SizedBox(width: 12),
              Text('Change Color'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete Project', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action, TaskProvider taskProvider) {
    switch (action) {
      case 'rename':
        _showRenameDialog(context, taskProvider);
        break;
      case 'change_color':
        _showColorPicker(context, taskProvider);
        break;
      case 'delete':
        _showDeleteConfirmation(context, taskProvider);
        break;
    }
  }

  Future<void> _showRenameDialog(BuildContext context, TaskProvider taskProvider) async {
    final nameController = TextEditingController(text: _project.name);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Project'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Project name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != _project.name && mounted) {
      final updatedProject = Project(
        id: _project.id,
        name: result,
        colorValue: _project.colorValue,
        iconCodePoint: _project.iconCodePoint,
      );
      await taskProvider.updateProject(updatedProject);
      setState(() {
        _project = updatedProject;
      });
    }
  }

  Future<void> _showColorPicker(BuildContext context, TaskProvider taskProvider) async {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) => GestureDetector(
            onTap: () => Navigator.pop(context, color),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: _project.colorValue == color.value
                    ? Border.all(color: Colors.black, width: 3)
                    : null,
              ),
              child: _project.colorValue == color.value
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedColor != null && mounted) {
      final updatedProject = Project(
        id: _project.id,
        name: _project.name,
        colorValue: selectedColor.value,
        iconCodePoint: _project.iconCodePoint,
      );
      await taskProvider.updateProject(updatedProject);
      setState(() {
        _project = updatedProject;
      });
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, TaskProvider taskProvider) async {
    final projectTasks = taskProvider.tasks.where((t) => t.projectId == _project.id).toList();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${_project.name}"?'),
            if (projectTasks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This project has ${projectTasks.length} task(s). They will become unassigned.',
                        style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await taskProvider.deleteProject(_project.id);
      if (mounted) {
        Navigator.pop(context); // Go back after deleting
      }
    }
  }

  Widget _buildHeader(BuildContext context, int total, int completed) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB74D), // Colors.orange.shade300
            Color(0xFFAB47BC), // Colors.purple.shade400
            Color(0xFF64B5F6), // Colors.blue.shade300
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background abstract pattern (simplified)
          Opacity(
            opacity: 0.3,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'), // Placeholder pattern
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _project.name,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildProgressIndicator(completed, total),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$completed/$total',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'tasks',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Positioned FAB-like button at the center bottom edge
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(0, 35),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTaskScreen(
                        taskToEdit: null, // New task
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, size: 30, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int completed, int total) {
    double progress = total == 0 ? 0 : completed / total;
    return Container(
      height: 60,
      width: 25,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 60 * progress,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task, TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => provider.toggleTaskStatus(task),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (task.notes.isNotEmpty)
                  Text(
                    task.notes,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSection(BuildContext context, List<Task> completedTasks, TaskProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COMPLETED (${completedTasks.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.1,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500, size: 20),
            ],
          ),
        ),
        ...completedTasks.map((task) => _buildCompletedTaskItem(context, task, provider)),
      ],
    );
  }

  Widget _buildCompletedTaskItem(BuildContext context, Task task, TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => provider.toggleTaskStatus(task),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 18, color: Colors.black),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
