import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'progress/progress_screen.dart';
import 'tasks/tasks_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onViewAll: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const TasksScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Progress'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}