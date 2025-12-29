import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_search_delegate.dart';
import 'add_task_screen.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedView = 'All Tasks';
  String? _selectedProjectId;
  String? _selectedTagId;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        var tasks = taskProvider.tasks;

        // Apply View Filters
        if (_selectedView == 'Today') {
          tasks = taskProvider.todayTasks;
        } else if (_selectedView == 'High Priority') {
          tasks = taskProvider.highPriorityTasks;
        } else if (_selectedView == 'Overdue') {
          tasks = taskProvider.overdueTasks;
        } else if (_selectedView == 'Completed') {
          tasks = taskProvider.completedTasks;
        } else if (_selectedProjectId != null) {
          tasks = tasks.where((t) => t.projectId == _selectedProjectId).toList();
        } else if (_selectedTagId != null) {
          tasks = tasks.where((t) => t.tagIds.contains(_selectedTagId)).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_selectedView),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: TaskSearchDelegate(taskProvider.tasks),
                  );
                },
              ),
            ],
          ),
          drawer: _buildDrawer(context, taskProvider),
          body: tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks in $_selectedView',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Dismissible(
                      key: Key(task.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        taskProvider.deleteTask(task.id);
                      },
                      child: TaskTile(task: task),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, TaskProvider provider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(height: 12),
                const Text(
                  'FireTask Manager',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${provider.tasks.where((t) => t.status == TaskStatus.pending).length} pending tasks',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('All Tasks'),
            selected: _selectedView == 'All Tasks',
            onTap: () => _setView('All Tasks'),
          ),
          ListTile(
            leading: const Icon(Icons.today, color: Colors.green),
            title: const Text('Today'),
            selected: _selectedView == 'Today',
            onTap: () => _setView('Today'),
          ),
          ListTile(
            leading: const Icon(Icons.error_outline, color: Colors.red),
            title: const Text('Overdue'),
            selected: _selectedView == 'Overdue',
            onTap: () => _setView('Overdue'),
          ),
          ListTile(
            leading: const Icon(Icons.priority_high, color: Colors.orange),
            title: const Text('High Priority'),
            selected: _selectedView == 'High Priority',
            onTap: () => _setView('High Priority'),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.blue),
            title: const Text('Completed'),
            selected: _selectedView == 'Completed',
            onTap: () => _setView('Completed'),
          ),
          const Divider(),
          _buildSectionHeader(context, 'PROJECTS', () => _showCreateProjectDialog(context, provider)),
          ...provider.projects.map((project) {
            final projectTasks = provider.tasks.where((t) => t.projectId == project.id).toList();
            final completedCount = projectTasks.where((t) => t.status == TaskStatus.completed).length;
            final progress = projectTasks.isEmpty ? 0.0 : completedCount / projectTasks.length;

            return ListTile(
              leading: Icon(
                IconData(project.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: Color(project.colorValue),
              ),
              title: Text(project.name),
              subtitle: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Color(project.colorValue)),
              ),
              selected: _selectedProjectId == project.id,
              onTap: () => _setView(project.name, projectId: project.id),
            );
          }),
          const Divider(),
          _buildSectionHeader(context, 'TAGS', () => _showManageTagsDialog(context, provider)),
          ...provider.tags.map((tag) => ListTile(
                leading: Icon(Icons.label, color: Color(tag.colorValue)),
                title: Text(tag.name),
                selected: _selectedTagId == tag.id,
                onTap: () => _setView(tag.name, tagId: tag.id),
              )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onAdd) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }

  void _setView(String viewName, {String? projectId, String? tagId}) {
    setState(() {
      _selectedView = viewName;
      _selectedProjectId = projectId;
      _selectedTagId = tagId;
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showCreateProjectDialog(BuildContext context, TaskProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Project'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Project Name', autoFocus: true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.addProject(controller.text, Colors.blue.value);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showManageTagsDialog(BuildContext context, TaskProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Manage Tags'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: 'New Tag Name'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          provider.addTag(controller.text, Colors.grey.value);
                          controller.clear();
                          setDialogState(() {});
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.tags.length,
                    itemBuilder: (context, index) {
                      final tag = provider.tags[index];
                      return ListTile(
                        leading: Icon(Icons.label, color: Color(tag.colorValue)),
                        title: Text(tag.name),
                        dense: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}
