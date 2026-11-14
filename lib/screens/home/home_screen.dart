import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StudyTask {
  String title;
  String subject;
  DateTime deadline;
  bool isCompleted;

  StudyTask({
    required this.title,
    required this.subject,
    required this.deadline,
    this.isCompleted = false,
  });

  // Convert task into JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject': subject,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Convert JSON back into task
  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      title: json['title'],
      subject: json['subject'],
      deadline: DateTime.parse(json['deadline']),
      isCompleted: json['isCompleted'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<StudyTask> tasks = [
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
  ];
  String selectedFilter = 'All';
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final String encodedTasks = jsonEncode(
      tasks.map((task) => task.toJson()).toList(),
    );

    await prefs.setString('study_tasks', encodedTasks);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final String? savedTasks = prefs.getString('study_tasks');

    if (savedTasks != null) {
      final List<dynamic> decodedTasks = jsonDecode(savedTasks);

      setState(() {
        tasks.clear();

        tasks.addAll(decodedTasks.map((task) => StudyTask.fromJson(task)));
      });
    } else {
      await _saveTasks();
    }
  }

  int get completedTasks => tasks.where((task) => task.isCompleted).length;

  double get progress => tasks.isEmpty ? 0 : completedTasks / tasks.length;

  String formatDeadline(DateTime date) {
    final today = DateTime.now();

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    }

    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> addTask({int? editIndex}) async {
    final isEditing = editIndex != null;

    final existingTask = isEditing ? tasks[editIndex] : null;

    final titleController = TextEditingController(
      text: existingTask?.title ?? '',
    );

    final subjectController = TextEditingController(
      text: existingTask?.subject ?? '',
    );

    DateTime selectedDate = existingTask?.deadline ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                isEditing ? 'Edit Task' : 'Add New Task',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        prefixIcon: Icon(Icons.edit_note),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject Name',
                        prefixIcon: Icon(Icons.book_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2035),
                        );

                        if (date != null) {
                          updateDialog(() {
                            selectedDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(formatDeadline(selectedDate)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        subjectController.text.trim().isEmpty) {
                      return;
                    }

                    setState(() {
                      if (isEditing) {
                        tasks[editIndex] = StudyTask(
                          title: titleController.text.trim(),
                          subject: subjectController.text.trim(),
                          deadline: selectedDate,
                          isCompleted: existingTask!.isCompleted,
                        );
                      } else {
                        tasks.add(
                          StudyTask(
                            title: titleController.text.trim(),
                            subject: subjectController.text.trim(),
                            deadline: selectedDate,
                          ),
                        );
                      }
                    });

                    _saveTasks();
                    Navigator.pop(dialogContext);
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Add Task'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    subjectController.dispose();
  }

  List<StudyTask> get filteredTasks {
    List<StudyTask> result = tasks;

    if (selectedFilter == 'Pending') {
      result = result.where((task) => !task.isCompleted).toList();
    } else if (selectedFilter == 'Completed') {
      result = result.where((task) => task.isCompleted).toList();
    }

    final query = searchQuery.trim().toLowerCase();

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
          'StudyMate',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, Student 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Ready to achieve your goals?',
              style: TextStyle(color: AppColors.grey),
            ),

            const SizedBox(height: 25),

            // Progress Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9A87E5), Color(0xFF7560C5)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Progress",
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    '${(progress * 100).round()}% Completed',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    backgroundColor: Colors.white38,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Total Tasks',
                    '${tasks.length}',
                    Icons.menu_book,
                    AppColors.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    'Completed',
                    '$completedTasks',
                    Icons.check_circle_outline,
                    AppColors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Study Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),

                TextButton.icon(
                  onPressed: addTask,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
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

            if (tasks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text('No tasks yet. Add your first task!'),
                ),
              ),
            if (tasks.isNotEmpty && filteredTasks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text('No matching tasks found.'),
                ),
              ),
              
            ...filteredTasks.map((task) {
              final index = tasks.indexOf(task);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: task.isCompleted,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          task.isCompleted = value ?? false;
                        });
                        _saveTasks();
                      },
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: AppColors.dark,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            task.subject,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            formatDeadline(task.deadline),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        addTask(editIndex: index);
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.deepPurple,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          tasks.removeAt(index);
                        });
                        _saveTasks();
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTask,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String filter) {
    final bool isSelected = selectedFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = filter;
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

  Widget _statCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 12, color: AppColors.grey)),
        ],
      ),
    );
  }
}
