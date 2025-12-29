import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_search_delegate.dart';
import 'add_task_screen.dart';
import 'project_detail_screen.dart';

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
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            var tasks = taskProvider.tasks;

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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, taskProvider),
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
                  child: tasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Dismissible(
                              key: Key(task.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                color: Colors.red.shade50,
                                child: Icon(Icons.delete_outline, color: Colors.red.shade400),
                              ),
                              onDismissed: (_) => taskProvider.deleteTask(task.id),
                              child: TaskTile(task: task),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
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
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.black, radius: 24, child: Icon(Icons.bolt, color: Colors.white)),
                  SizedBox(width: 16),
                  Text('FireTask', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
          ],
        ),
      ),
    );
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
