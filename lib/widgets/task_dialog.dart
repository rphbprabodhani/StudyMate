import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../services/task_store.dart';

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatDeadline(DateTime date) {
  final today = DateTime.now();

  if (_sameDay(date, today)) return 'Today';

  if (_sameDay(date, today.add(const Duration(days: 1)))) return 'Tomorrow';

  return '${date.day}/${date.month}/${date.year}';
}

/// Opens the Add / Edit task dialog.
/// Pass [existing] to edit a task, leave it out to add a new one.
Future<void> showTaskDialog(BuildContext context, {StudyTask? existing}) {
  return showDialog(
    context: context,
    builder: (_) => _TaskDialog(existing: existing),
  );
}

class _TaskDialog extends StatefulWidget {
  final StudyTask? existing;

  const _TaskDialog({this.existing});

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late DateTime _selectedDate;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _subjectController = TextEditingController(
      text: widget.existing?.subject ?? '',
    );
    _selectedDate = widget.existing?.deadline ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final subject = _subjectController.text.trim();

    if (title.isEmpty || subject.isEmpty) return;

    if (_isEditing) {
      TaskStore.instance.update(
        widget.existing!,
        StudyTask(
          title: title,
          subject: subject,
          deadline: _selectedDate,
          isCompleted: widget.existing!.isCompleted,
        ),
      );
    } else {
      TaskStore.instance.add(
        StudyTask(title: title, subject: subject, deadline: _selectedDate),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        _isEditing ? 'Edit Task' : 'Add New Task',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                prefixIcon: Icon(Icons.book_outlined),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(formatDeadline(_selectedDate)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save Changes' : 'Add Task'),
        ),
      ],
    );
  }
}