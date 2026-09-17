import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // ---------------- PROFILE ----------------

  static const String _nameKey = 'user_name';
  static const String _fitnessLevelKey = 'fitness_level';
  static const String _fitnessGoalKey = 'fitness_goal';
  static const String _notificationsKey = 'notifications_enabled';

  // ---------------- GOALS ----------------

  static const String _stepsTargetKey = 'steps_target';
  static const String _caloriesTargetKey = 'calories_target';
  static const String _waterTargetKey = 'water_target';
  static const String _workoutTargetKey = 'workout_target';

  // ---------------- WORKOUT HISTORY ----------------

  static const String _workoutHistoryKey = 'workout_history';

  // =========================================================
  // PROFILE
  // =========================================================

  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? '';
  }

  static Future<void> saveFitnessLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fitnessLevelKey, level);
  }

  static Future<String> getFitnessLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fitnessLevelKey) ?? 'Beginner';
  }

  static Future<void> saveFitnessGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fitnessGoalKey, goal);
  }

  static Future<String> getFitnessGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fitnessGoalKey) ?? 'Build Strength';
  }

  static Future<void> saveNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  static Future<bool> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // =========================================================
  // GOALS
  // =========================================================

  static Future<void> saveStepsTarget(double target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_stepsTargetKey, target);
  }

  static Future<double> getStepsTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_stepsTargetKey) ?? 10000;
  }

  static Future<void> saveCaloriesTarget(double target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_caloriesTargetKey, target);
  }

  static Future<double> getCaloriesTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_caloriesTargetKey) ?? 1000;
  }

  static Future<void> saveWaterTarget(double target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_waterTargetKey, target);
  }

  static Future<double> getWaterTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_waterTargetKey) ?? 3;
  }

  static Future<void> saveWorkoutTarget(int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_workoutTargetKey, target);
  }

  static Future<int> getWorkoutTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_workoutTargetKey) ?? 5;
  }

  // =========================================================
  // WORKOUT HISTORY
  // =========================================================

  static Future<void> addWorkoutHistory({
    required String name,
    required String date,
    required String duration,
    required String calories,
    required String exercises,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final history = await getWorkoutHistory();

    final workout = <String, String>{
      'name': name,
      'date': date,
      'duration': duration,
      'calories': calories,
      'exercises': exercises,
    };

    // New workout appears at the top.
    history.insert(0, workout);

    await prefs.setString(
      _workoutHistoryKey,
      jsonEncode(history),
    );
  }

  static Future<List<Map<String, String>>> getWorkoutHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_workoutHistoryKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(savedData);

      if (decoded is! List) {
        return [];
      }

      return decoded.map<Map<String, String>>((item) {
        final map = Map<String, dynamic>.from(item);

        return map.map(
          (key, value) => MapEntry(
            key.toString(),
            value.toString(),
          ),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearWorkoutHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_workoutHistoryKey);
  }
}