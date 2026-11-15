import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileStore extends ChangeNotifier {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  static const _nameKey = 'profile_name';
  static const _goalKey = 'profile_goal';

  String _name = 'Student';
  String _goal = '';

  String get name => _name;
  String get goal => _goal;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey) ?? 'Student';
    _goal = prefs.getString(_goalKey) ?? '';
    notifyListeners();
  }

  Future<void> save({required String name, required String goal}) async {
    _name = name.trim().isEmpty ? 'Student' : name.trim();
    _goal = goal.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _name);
    await prefs.setString(_goalKey, _goal);
  }
}
