import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/study_task.dart';
import '../../services/task_store.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_dialog.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudyTask> _filtered(List<StudyTask> all) {
    List<StudyTask> result = all;

    if (_selectedFilter == 'Pending') {
      result = result.where((task) => !task.isCompleted).toList();
    } else if (_selectedFilter == 'Completed') {
      result = result.where((task) => task.isCompleted).toList();
    }

    final query = _searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result
          .where(
            (task) =>
                task.title.toLowerCase().contains(query) ||
                task.subject.toLowerCase().contains(query),
          )
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'My Tasks',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: TaskStore.instance,
        builder: (context, _) {
          final all = TaskStore.instance.tasks;
          final filtered = _filtered(all);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _filterButton('All'),
                  const SizedBox(width: 8),
                  _filterButton('Pending'),
                  const SizedBox(width: 8),
                  _filterButton('Completed'),
                ],
              ),
              const SizedBox(height: 15),

              if (all.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('No tasks yet. Add your first task!'),
                  ),
                ),

              if (all.isNotEmpty && filtered.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('No matching tasks found.'),
                  ),
                ),

              ...filtered.map((task) => TaskCard(key: ObjectKey(task), task: task)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => showTaskDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _filterButton(String filter) {
    final bool isSelected = _selectedFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              filter,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.dark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}