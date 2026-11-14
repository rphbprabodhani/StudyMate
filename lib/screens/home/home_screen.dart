import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/task_store.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_dialog.dart';

class HomeScreen extends StatelessWidget {
  /// Called when the user taps "View all" (MainScreen switches to the Tasks tab).
  final VoidCallback? onViewAll;

  const HomeScreen({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final store = TaskStore.instance;

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
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final progress = store.progress;

          final upcoming = store.tasks.where((task) => !task.isCompleted).toList()
            ..sort((a, b) => a.deadline.compareTo(b.deadline));
          final shown = upcoming.take(3).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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
                        'Overall Progress',
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
                        '${store.totalCount}',
                        Icons.menu_book,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        'Completed',
                        '${store.completedCount}',
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
                      'Upcoming Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    TextButton(
                      onPressed: onViewAll,
                      child: const Text('View all'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (shown.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text('No pending tasks. Great job! 🎉'),
                    ),
                  ),

                ...shown.map((task) => TaskCard(key: ObjectKey(task), task: task)),
              ],
            ),
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