import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;
  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _notes;
  DateTime? _dueDate;
  late TaskPriority _priority;
  String? _selectedProjectId;
  List<String> _selectedTagIds = [];

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _title = task?.title ?? '';
    _notes = task?.notes ?? '';
    _dueDate = task?.dueDate;
    _priority = task?.priority ?? TaskPriority.medium;
    _selectedProjectId = task?.projectId;
    _selectedTagIds = List.from(task?.tagIds ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final projects = taskProvider.projects;
    final tags = taskProvider.tags;

    // If editing and project is null, try to set it to first available if any
    if (_selectedProjectId == null && projects.isNotEmpty) {
      _selectedProjectId = projects.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskToEdit == null ? 'Add Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => _notes = value ?? '',
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(_dueDate == null
                    ? 'Set date'
                    : DateFormat('MMM d, yyyy HH:mm').format(_dueDate!)),
                leading: const Icon(Icons.calendar_today),
                trailing: _dueDate != null ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _dueDate = null),
                ) : null,
                onTap: _pickDateTime,
              ),
              const Divider(),
              const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: TaskPriority.values.map((p) {
                  return ChoiceChip(
                    label: Text(p.name.toUpperCase()),
                    selected: _priority == p,
                    onSelected: (selected) {
                      if (selected) setState(() => _priority = p);
                    },
                  );
                }).toList(),
              ),
              const Divider(),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Project'),
                initialValue: _selectedProjectId,
                items: projects.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedProjectId = val),
                validator: (val) => val == null ? 'Select a project' : null,
              ),
              const SizedBox(height: 16),
              const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: tags.map((tag) {
                  final isSelected = _selectedTagIds.contains(tag.id);
                  return FilterChip(
                    label: Text(tag.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTagIds.add(tag.id);
                        } else {
                          _selectedTagIds.remove(tag.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
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

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<TaskProvider>(context, listen: false);
      
      if (widget.taskToEdit == null) {
        provider.addTask(
          title: _title,
          notes: _notes,
          dueDate: _dueDate,
          priority: _priority,
          projectId: _selectedProjectId!,
          tagIds: _selectedTagIds,
        );
      } else {
        final updatedTask = Task(
          id: widget.taskToEdit!.id,
          title: _title,
          notes: _notes,
          dueDate: _dueDate,
          priority: _priority,
          status: widget.taskToEdit!.status,
          projectId: _selectedProjectId!,
          tagIds: _selectedTagIds,
          subTasks: widget.taskToEdit!.subTasks,
          attachments: widget.taskToEdit!.attachments,
          createdAt: widget.taskToEdit!.createdAt,
        );
        provider.updateTask(updatedTask);
      }
      Navigator.pop(context);
    }
  }
}
