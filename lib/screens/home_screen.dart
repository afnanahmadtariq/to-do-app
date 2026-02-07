import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_search_delegate.dart';
import 'add_task_screen.dart';
import 'project_detail_screen.dart';
import 'login_screen.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return _buildHeader(context, taskProvider);
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _selectedView,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  var tasks = _getFilteredTasks(taskProvider);

                  return tasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          key: ValueKey('task-list-${_selectedView}-${_selectedProjectId ?? ''}-${_selectedTagId ?? ''}'),
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Dismissible(
                              key: ValueKey(task.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Delete Task'),
                                      content: Text('Are you sure you want to delete "${task.title}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                ) ?? false;
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                color: Colors.red.shade50,
                                child: Icon(Icons.delete_outline, color: Colors.red.shade400),
                              ),
                              onDismissed: (direction) async {
                                try {
                                  await taskProvider.deleteTask(task.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Task "${task.title}" deleted'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error deleting task: $e'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: TaskTile(task: task),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  List<Task> _getFilteredTasks(TaskProvider taskProvider) {
    var tasks = taskProvider.tasks;

    if (_selectedView == 'Today') {
      return taskProvider.todayTasks;
    } else if (_selectedView == 'High Priority') {
      return taskProvider.highPriorityTasks;
    } else if (_selectedView == 'Overdue') {
      return taskProvider.overdueTasks;
    } else if (_selectedView == 'Completed') {
      return taskProvider.completedTasks;
    } else if (_selectedProjectId != null) {
      return tasks.where((t) => t.projectId == _selectedProjectId).toList();
    } else if (_selectedTagId != null) {
      return tasks.where((t) => t.tagIds.contains(_selectedTagId)).toList();
    }
    return tasks;
  }

  Widget _buildHeader(BuildContext context, TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => _buildCircleButton(
              Icons.menu,
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          _buildCircleButton(
            Icons.search,
            onTap: () => showSearch(
              context: context,
              delegate: TaskSearchDelegate(provider.tasks),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'All clear for now',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddTaskScreen()),
      ),
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AppAuthProvider>(context);
    
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            // User Info Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 28,
                    child: Text(
                      (authProvider.displayName?.isNotEmpty == true
                          ? authProvider.displayName![0]
                          : authProvider.userEmail?[0] ?? 'U').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.displayName ?? 'User',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          authProvider.userEmail ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildDrawerItem('All Tasks', Icons.grid_view_rounded, _selectedView == 'All Tasks', 
                    () => _setView('All Tasks')),
                  _buildDrawerItem('Today', Icons.today_rounded, _selectedView == 'Today', 
                    () => _setView('Today')),
                  _buildDrawerItem('High Priority', Icons.priority_high_rounded, _selectedView == 'High Priority', 
                    () => _setView('High Priority')),
                  _buildDrawerItem('Completed', Icons.check_circle_outline_rounded, _selectedView == 'Completed', 
                    () => _setView('Completed')),
                  
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 32, bottom: 16),
                    child: Text('PROJECTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                  ),
                  ...provider.projects.map((p) => _buildDrawerItem(
                    p.name, 
                    Icons.folder_open_rounded, 
                    _selectedProjectId == p.id,
                    () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectDetailScreen(project: p)));
                    },
                  )),
                ],
              ),
            ),
            const Divider(height: 1),
            // Sign Out Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                onTap: () => _handleSignOut(context, authProvider),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 22),
                title: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context, AppAuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await authProvider.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildDrawerItem(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      selected: isSelected,
      selectedTileColor: Colors.grey.shade50,
      leading: Icon(icon, color: isSelected ? Colors.black : Colors.grey.shade400, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _setView(String viewName, {String? projectId, String? tagId}) {
    setState(() {
      _selectedView = viewName;
      _selectedProjectId = projectId;
      _selectedTagId = tagId;
    });
    Navigator.pop(context);
  }
}
