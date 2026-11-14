import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_task.dart';

/// One shared place for all tasks, used by every screen.
/// Screens listen to it, so when a task changes every tab updates.
class TaskStore extends ChangeNotifier {
  TaskStore._();

  static final TaskStore instance = TaskStore._();

  static const String _storageKey = 'study_tasks';

  final List<StudyTask> _tasks = [];

  List<StudyTask> get tasks => List.unmodifiable(_tasks);

  int get totalCount => _tasks.length;

  int get completedCount => _tasks.where((task) => task.isCompleted).length;

  int get pendingCount => totalCount - completedCount;

  double get progress => _tasks.isEmpty ? 0 : completedCount / _tasks.length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(_storageKey);

    _tasks.clear();

    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);
      _tasks.addAll(
        decoded.map((item) => StudyTask.fromJson(item as Map<String, dynamic>)),
      );
    } else {
      _tasks.addAll([
        StudyTask(
          title: 'Complete Flutter Assignment',
          subject: 'Mobile Application Development',
          deadline: DateTime.now(),
        ),
        StudyTask(
          title: 'Study Database Concepts',
          subject: 'Advanced Database Systems',
          deadline: DateTime.now().add(const Duration(days: 1)),
        ),
        StudyTask(
          title: 'Prepare Project Documentation',
          subject: 'Software Engineering',
          deadline: DateTime.now().add(const Duration(days: 2)),
        ),
      ]);
      await _save();
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _tasks.map((task) => task.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  void add(StudyTask task) {
    _tasks.add(task);
    _changed();
  }

  void update(StudyTask oldTask, StudyTask newTask) {
    final int index = _tasks.indexOf(oldTask);
    if (index == -1) return;
    _tasks[index] = newTask;
    _changed();
  }

  void remove(StudyTask task) {
    _tasks.remove(task);
    _changed();
  }

  void setCompleted(StudyTask task, bool value) {
    task.isCompleted = value;
    _changed();
  }

  void _changed() {
    notifyListeners();
    _save();
  }
}