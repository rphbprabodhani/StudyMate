import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'screens/main_screen.dart';
import 'services/task_store.dart';
import 'services/profile_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TaskStore.instance.load();
  await ProfileStore.instance.load();
  runApp(const StudyMateApp());
}

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyMate',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const MainScreen(),
    );
  }
}