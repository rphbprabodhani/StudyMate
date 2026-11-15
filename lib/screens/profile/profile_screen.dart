import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/profile_store.dart';
import '../../services/task_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TaskStore.instance;
    final profile = ProfileStore.instance;

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
        listenable: Listenable.merge([store, profile]),
        builder: (context, _) {
          final name = profile.name;
          final goal = profile.goal;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
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
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => _showEditDialog(context),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit profile'),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.flag_outlined, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Study goal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      goal.isEmpty
                          ? 'Tap "Edit profile" to set your study goal.'
                          : goal,
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _EditProfileDialog(),
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

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog();

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    final profile = ProfileStore.instance;
    _nameController = TextEditingController(text: profile.name);
    _goalController = TextEditingController(text: profile.goal);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              maxLength: 30,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _goalController,
              maxLength: 80,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Study goal',
                hintText: 'e.g. Finish all semester revision',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            ProfileStore.instance.save(
              name: _nameController.text,
              goal: _goalController.text,
            );
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}