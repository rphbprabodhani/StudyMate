import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/study_task.dart';
import '../../services/task_store.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  String _message(double progress, int total) {
    if (total == 0) return 'Add some tasks to get started!';
    if (progress >= 1) return 'All tasks completed! 🎉';
    if (progress >= 0.5) return 'Almost there, keep going!';
    if (progress > 0) return 'Good start, keep it up!';
    return "Let's get started!";
  }

  @override
  Widget build(BuildContext context) {
    final store = TaskStore.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Progress',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final progress = store.progress;

          final Map<String, List<StudyTask>> bySubject = {};
          for (final task in store.tasks) {
            bySubject.putIfAbsent(task.subject, () => []).add(task);
          }
          final subjects = bySubject.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
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
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _message(progress, store.totalCount),
                      style: const TextStyle(color: Colors.white),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _miniStat('Total', '${store.totalCount}', AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _miniStat('Completed', '${store.completedCount}', AppColors.green),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _miniStat('Pending', '${store.pendingCount}', Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'By Subject',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 15),

              if (subjects.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('No tasks yet.'),
                  ),
                ),

              ...subjects.map((subject) {
                final list = bySubject[subject]!;
                final done = list.where((task) => task.isCompleted).length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              subject,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                          Text(
                            '$done/${list.length}',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: done / list.length,
                        minHeight: 8,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _miniStat(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: AppColors.grey)),
        ],
      ),
    );
  }
}