import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/task_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TaskStore.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.person, size: 52, color: Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Student',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'StudyMate user',
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('Total', '${store.totalCount}'),
                    _stat('Completed', '${store.completedCount}'),
                    _stat('Pending', '${store.pendingCount}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.info_outline, color: AppColors.primary),
                      title: Text('StudyMate'),
                      subtitle: Text('Version 1.0.0'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.save_outlined, color: AppColors.primary),
                      title: Text('Local storage'),
                      subtitle: Text('Your tasks are saved on this device.'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: AppColors.grey)),
      ],
    );
  }
}