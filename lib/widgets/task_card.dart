import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/study_task.dart';
import '../services/task_store.dart';
import 'task_dialog.dart';

class TaskCard extends StatelessWidget {
  final StudyTask task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
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
              TaskStore.instance.setCompleted(task, value ?? false);
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
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
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
            onPressed: () => showTaskDialog(context, existing: task),
            icon: const Icon(Icons.edit_outlined, color: Colors.deepPurple),
          ),
          IconButton(
            onPressed: () => TaskStore.instance.remove(task),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}