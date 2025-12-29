import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;
  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dueDate = DateTime.now();
  final TaskPriority _priority = TaskPriority.medium;
  String? _selectedProjectId;
  final List<String> _selectedTagIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _notesController.text = widget.taskToEdit!.notes;
      _dueDate = widget.taskToEdit!.dueDate;
      _selectedProjectId = widget.taskToEdit!.projectId;
      _selectedTagIds.addAll(widget.taskToEdit!.tagIds);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final projects = taskProvider.projects;

    if (_selectedProjectId == null && projects.isNotEmpty) {
      _selectedProjectId = projects.first.id;
    }

    final isToday = _dueDate != null &&
        _dueDate!.year == DateTime.now().year &&
        _dueDate!.month == DateTime.now().month &&
        _dueDate!.day == DateTime.now().day;
    final isTomorrow = _dueDate != null &&
        _dueDate!.year == DateTime.now().year &&
        _dueDate!.month == DateTime.now().month &&
        _dueDate!.day == DateTime.now().day + 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.black),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'New Task',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildDatePill(
                    label: 'Today',
                    isSelected: isToday,
                    onTap: () => setState(() => _dueDate = DateTime.now()),
                  ),
                  const SizedBox(width: 12),
                  _buildDatePill(
                    label: 'Tomorrow',
                    isSelected: isTomorrow,
                    onTap: () => setState(() => _dueDate = DateTime.now().add(const Duration(days: 1))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildIconButton(Icons.history, onTap: _pickDateTime),
                  const SizedBox(width: 12),
                  _buildIconButton(Icons.add_alert_outlined),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionLabel('PROJECTS'),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildAddProjectButton(),
                    const SizedBox(width: 12),
                    ...projects.map((project) {
                      final isSelected = _selectedProjectId == project.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: _buildProjectPill(project, isSelected),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionLabel('TITLE'),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Task Title',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _saveTask(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.taskToEdit == null ? 'Create' : 'Update',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDatePill({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  Widget _buildAddProjectButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Icon(Icons.add, size: 20, color: Colors.black),
    );
  }

  Widget _buildProjectPill(Project project, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedProjectId = project.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Colors.blue, Colors.purple])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          project.name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _dueDate != null ? TimeOfDay.fromDateTime(_dueDate!) : TimeOfDay.now(),
    );
    if (time == null) return;

    if (!mounted) return;
    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveTask(BuildContext context) async {
    if (_titleController.text.isEmpty) return;

    final provider = Provider.of<TaskProvider>(context, listen: false);

    if (widget.taskToEdit == null) {
      await provider.addTask(
        title: _titleController.text,
        notes: _notesController.text,
        dueDate: _dueDate,
        priority: _priority,
        projectId: _selectedProjectId!,
        tagIds: _selectedTagIds,
      );
    } else {
      final updatedTask = Task(
        id: widget.taskToEdit!.id,
        title: _titleController.text,
        notes: _notesController.text,
        dueDate: _dueDate,
        priority: _priority,
        status: widget.taskToEdit!.status,
        projectId: _selectedProjectId!,
        tagIds: _selectedTagIds,
        subTasks: widget.taskToEdit!.subTasks,
        attachments: widget.taskToEdit!.attachments,
        createdAt: widget.taskToEdit!.createdAt,
      );
      await provider.updateTask(updatedTask);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
