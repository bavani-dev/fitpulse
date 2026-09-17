// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitpulse/services/storage_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  static const Color green = Color(0xFF7CFF6B);
  static const Color card = Color(0xFF171D25);
  static const String customGoalsKey = 'fitpulse_custom_goals';

  // Current values
  double dailySteps = 7842;
  double dailyCalories = 642;
  double dailyWater = 1.8;
  int weeklyWorkouts = 4;

  // Standard goal targets
  double stepsTarget = 10000;
  double caloriesTarget = 1000;
  double waterTarget = 3;
  int workoutTarget = 5;

  // Custom goals
  List<Map<String, dynamic>> customGoals = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  // ------------------------------------------------------------
  // LOAD ALL GOALS
  // ------------------------------------------------------------

  Future<void> _loadGoals() async {
    try {
      final savedStepsTarget = await StorageService.getStepsTarget();
      final savedCaloriesTarget =
          await StorageService.getCaloriesTarget();
      final savedWaterTarget = await StorageService.getWaterTarget();
      final savedWorkoutTarget =
          await StorageService.getWorkoutTarget();

      final prefs = await SharedPreferences.getInstance();

      final savedCustomGoals = prefs.getString(customGoalsKey);

      List<Map<String, dynamic>> loadedCustomGoals = [];

      if (savedCustomGoals != null && savedCustomGoals.isNotEmpty) {
        try {
          final decoded = jsonDecode(savedCustomGoals);

          if (decoded is List) {
            loadedCustomGoals = decoded
                .whereType<Map>()
                .map<Map<String, dynamic>>(
                  (goal) => Map<String, dynamic>.from(goal),
                )
                .toList();
          }
        } catch (_) {
          loadedCustomGoals = [];
        }
      }

      if (!mounted) return;

      setState(() {
        stepsTarget = savedStepsTarget;
        caloriesTarget = savedCaloriesTarget;
        waterTarget = savedWaterTarget;
        workoutTarget = savedWorkoutTarget;

        customGoals = loadedCustomGoals;

        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ------------------------------------------------------------
  // SAVE CUSTOM GOALS
  // ------------------------------------------------------------

  Future<void> _saveCustomGoals() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      customGoalsKey,
      jsonEncode(customGoals),
    );
  }

  // ------------------------------------------------------------
  // STANDARD GOAL TARGET SAVING
  // ------------------------------------------------------------

  Future<void> _saveStepsTarget(double value) async {
    await StorageService.saveStepsTarget(value);

    if (!mounted) return;

    setState(() {
      stepsTarget = value;
    });
  }

  Future<void> _saveCaloriesTarget(double value) async {
    await StorageService.saveCaloriesTarget(value);

    if (!mounted) return;

    setState(() {
      caloriesTarget = value;
    });
  }

  Future<void> _saveWaterTarget(double value) async {
    await StorageService.saveWaterTarget(value);

    if (!mounted) return;

    setState(() {
      waterTarget = value;
    });
  }

  Future<void> _saveWorkoutTarget(int value) async {
    await StorageService.saveWorkoutTarget(value);

    if (!mounted) return;

    setState(() {
      workoutTarget = value;
    });
  }

  // ------------------------------------------------------------
  // EDIT STANDARD GOAL
  // ------------------------------------------------------------

  void _showEditGoalDialog({
    required String title,
    required double target,
    required String unit,
    required Future<void> Function(double) onSave,
  }) {
    final controller = TextEditingController(
      text: target % 1 == 0
          ? target.toStringAsFixed(0)
          : target.toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit $title Goal'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: 'Target',
              suffixText: unit,
              border: const OutlineInputBorder(),
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
              onPressed: () async {
                final value = double.tryParse(controller.text.trim());

                if (value == null || value <= 0) {
                  return;
                }

                await onSave(value);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // DAILY ACTIONS
  // ------------------------------------------------------------

  void _addSteps() {
    setState(() {
      dailySteps += 500;

      if (dailySteps > stepsTarget) {
        dailySteps = stepsTarget;
      }
    });
  }

  void _addWater() {
    setState(() {
      dailyWater += 0.25;

      if (dailyWater > waterTarget) {
        dailyWater = waterTarget;
      }
    });
  }

  void _removeWater() {
    setState(() {
      dailyWater -= 0.25;

      if (dailyWater < 0) {
        dailyWater = 0;
      }
    });
  }

  void _addWorkout() {
    setState(() {
      weeklyWorkouts++;

      if (weeklyWorkouts > workoutTarget) {
        weeklyWorkouts = workoutTarget;
      }
    });
  }

  // ------------------------------------------------------------
  // ADD CUSTOM GOAL
  // ------------------------------------------------------------

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    String selectedUnit = 'times';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add New Goal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Goal Name',
                        hintText: 'Example: Running',
                        prefixIcon: Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: targetController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Target',
                        hintText: 'Example: 5',
                        prefixIcon: Icon(Icons.track_changes),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      initialValue: selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'times',
                          child: Text('times'),
                        ),
                        DropdownMenuItem(
                          value: 'minutes',
                          child: Text('minutes'),
                        ),
                        DropdownMenuItem(
                          value: 'km',
                          child: Text('km'),
                        ),
                        DropdownMenuItem(
                          value: 'hours',
                          child: Text('hours'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedUnit = value;
                          });
                        }
                      },
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
                ElevatedButton.icon(
                  onPressed: () async {
                    final goalName =
                        titleController.text.trim();

                    final target =
                        double.tryParse(
                      targetController.text.trim(),
                    );

                    // Validate
                    if (goalName.isEmpty ||
                        target == null ||
                        target <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid goal name and target.',
                          ),
                        ),
                      );
                      return;
                    }

                    // Create the goal
                    final newGoal = <String, dynamic>{
                      'id': DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                      'title': goalName,
                      'target': target,
                      'unit': selectedUnit,
                      'current': 0.0,
                    };

                    // IMPORTANT:
                    // Add goal to the list immediately.
                    setState(() {
                      customGoals.add(newGoal);
                    });

                    // Save it permanently.
                    await _saveCustomGoals();

                    if (!context.mounted) return;

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$goalName goal added successfully!',
                        ),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Goal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // EDIT CUSTOM GOAL
  // ------------------------------------------------------------

  void _showEditCustomGoalDialog(
    int index,
  ) {
    final goal = customGoals[index];

    final titleController = TextEditingController(
      text: goal['title']?.toString() ?? '',
    );

    final targetController = TextEditingController(
      text: _formatNumber(
        _toDouble(goal['target']),
      ),
    );

    String selectedUnit =
        goal['unit']?.toString() ?? 'times';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Goal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Goal Name',
                        prefixIcon: Icon(Icons.flag_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: targetController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Target',
                        prefixIcon:
                            Icon(Icons.track_changes),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      initialValue: selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'times',
                          child: Text('times'),
                        ),
                        DropdownMenuItem(
                          value: 'minutes',
                          child: Text('minutes'),
                        ),
                        DropdownMenuItem(
                          value: 'km',
                          child: Text('km'),
                        ),
                        DropdownMenuItem(
                          value: 'hours',
                          child: Text('hours'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedUnit = value;
                          });
                        }
                      },
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
                  onPressed: () async {
                    final title =
                        titleController.text.trim();

                    final target =
                        double.tryParse(
                      targetController.text.trim(),
                    );

                    if (title.isEmpty ||
                        target == null ||
                        target <= 0) {
                      return;
                    }

                    setState(() {
                      customGoals[index] = {
                        ...customGoals[index],
                        'title': title,
                        'target': target,
                        'unit': selectedUnit,
                      };
                    });

                    await _saveCustomGoals();

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Goal updated successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // DELETE CUSTOM GOAL
  // ------------------------------------------------------------

  Future<void> _deleteCustomGoal(int index) async {
    final goalName =
        customGoals[index]['title']?.toString() ??
            'Goal';

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Goal?'),
          content: Text(
            'Are you sure you want to delete "$goalName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      customGoals.removeAt(index);
    });

    await _saveCustomGoals();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$goalName deleted.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ------------------------------------------------------------
  // UPDATE CUSTOM GOAL PROGRESS
  // ------------------------------------------------------------

  Future<void> _updateCustomGoalProgress(
    int index,
  ) async {
    final goal = customGoals[index];

    final current =
        _toDouble(goal['current']);

    final target =
        _toDouble(goal['target']);

    final controller = TextEditingController(
      text: _formatNumber(current),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            goal['title']?.toString() ?? 'Update Goal',
          ),
          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: 'Current Progress',
              suffixText:
                  goal['unit']?.toString() ?? '',
              border: const OutlineInputBorder(),
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
                final value =
                    double.tryParse(controller.text.trim());

                if (value == null || value < 0) {
                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    setState(() {
      customGoals[index] = {
        ...customGoals[index],
        'current': result > target ? target : result,
      };
    });

    await _saveCustomGoals();
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final standardCompleted = [
      dailySteps >= stepsTarget,
      dailyCalories >= caloriesTarget,
      dailyWater >= waterTarget,
      weeklyWorkouts >= workoutTarget,
    ].where((completed) => completed).length;

    int customCompleted = 0;

    for (final goal in customGoals) {
      final current = _toDouble(goal['current']);
      final target = _toDouble(goal['target']);

      if (target > 0 && current >= target) {
        customCompleted++;
      }
    }

    final totalGoals =
        4 + customGoals.length;

    final totalCompleted =
        standardCompleted + customCompleted;

    final overallProgress = totalGoals == 0
        ? 0.0
        : totalCompleted / totalGoals;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Goals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadGoals,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGoals,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            30,
          ),
          children: [
            const Text(
              'Fitness Goals',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Track your daily targets and stay consistent.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 22),

            // --------------------------------------------------
            // OVERALL PROGRESS
            // --------------------------------------------------

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 78,
                    height: 78,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 78,
                          height: 78,
                          child: CircularProgressIndicator(
                            value: overallProgress,
                            strokeWidth: 7,
                            backgroundColor: Colors.white10,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                              green,
                            ),
                          ),
                        ),
                        Text(
                          '$totalCompleted/$totalGoals',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Goal Progress',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          customGoals.isEmpty
                              ? 'Complete your targets and build a stronger routine.'
                              : 'You have ${customGoals.length} custom goal${customGoals.length == 1 ? '' : 's'} in your routine.',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Daily Goals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // --------------------------------------------------
            // STEPS
            // --------------------------------------------------

            _GoalCard(
              icon: Icons.directions_walk_rounded,
              title: 'Daily Steps',
              current: dailySteps,
              target: stepsTarget,
              unit: 'steps',
              onEdit: () {
                _showEditGoalDialog(
                  title: 'Daily Steps',
                  target: stepsTarget,
                  unit: 'steps',
                  onSave: _saveStepsTarget,
                );
              },
              action: IconButton(
                onPressed: _addSteps,
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: green,
                ),
              ),
            ),

            // --------------------------------------------------
            // CALORIES
            // --------------------------------------------------

            _GoalCard(
              icon: Icons.local_fire_department_rounded,
              title: 'Calories',
              current: dailyCalories,
              target: caloriesTarget,
              unit: 'kcal',
              onEdit: () {
                _showEditGoalDialog(
                  title: 'Calories',
                  target: caloriesTarget,
                  unit: 'kcal',
                  onSave: _saveCaloriesTarget,
                );
              },
            ),

            // --------------------------------------------------
            // WATER
            // --------------------------------------------------

            _GoalCard(
              icon: Icons.water_drop_rounded,
              title: 'Water',
              current: dailyWater,
              target: waterTarget,
              unit: 'L',
              onEdit: () {
                _showEditGoalDialog(
                  title: 'Water',
                  target: waterTarget,
                  unit: 'L',
                  onSave: _saveWaterTarget,
                );
              },
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _removeWater,
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.white54,
                    ),
                  ),
                  IconButton(
                    onPressed: _addWater,
                    icon: const Icon(
                      Icons.add_circle_rounded,
                      color: green,
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------
            // WORKOUTS
            // --------------------------------------------------

            _GoalCard(
              icon: Icons.fitness_center_rounded,
              title: 'Weekly Workouts',
              current: weeklyWorkouts.toDouble(),
              target: workoutTarget.toDouble(),
              unit: 'workouts',
              onEdit: () {
                _showEditGoalDialog(
                  title: 'Weekly Workouts',
                  target: workoutTarget.toDouble(),
                  unit: 'workouts',
                  onSave: (value) {
                    return _saveWorkoutTarget(
                      value.round(),
                    );
                  },
                );
              },
              action: IconButton(
                onPressed: _addWorkout,
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: green,
                ),
              ),
            ),

            // --------------------------------------------------
            // CUSTOM GOALS
            // --------------------------------------------------

            if (customGoals.isNotEmpty) ...[
              const SizedBox(height: 18),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Custom Goals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x227CFF6B),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${customGoals.length}',
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              ...customGoals.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final goal = entry.value;

                  return _CustomGoalCard(
                    title:
                        goal['title']?.toString() ??
                            'Custom Goal',
                    current:
                        _toDouble(goal['current']),
                    target:
                        _toDouble(goal['target']),
                    unit:
                        goal['unit']?.toString() ??
                            'times',
                    onEdit: () {
                      _showEditCustomGoalDialog(index);
                    },
                    onDelete: () {
                      _deleteCustomGoal(index);
                    },
                    onProgress: () {
                      _updateCustomGoalProgress(index);
                    },
                  );
                },
              ),
            ],

            const SizedBox(height: 10),

            // --------------------------------------------------
            // ADD NEW GOAL BUTTON
            // --------------------------------------------------

            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _showAddGoalDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add New Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // MOTIVATION
            // --------------------------------------------------

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0x227CFF6B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0x337CFF6B),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: green,
                    size: 30,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Small progress every day leads to big results. Keep going! 💪',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STANDARD GOAL CARD
// ============================================================

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double current;
  final double target;
  final String unit;
  final VoidCallback onEdit;
  final Widget? action;

  const _GoalCard({
    required this.icon,
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.onEdit,
    this.action,
  });

  double _progress() {
    if (target <= 0) return 0;

    final value = current / target;

    if (value > 1) return 1;
    if (value < 0) return 0;

    return value;
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress();
    final completed = current >= target;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171D25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed
              ? const Color(0x337CFF6B)
              : Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x227CFF6B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF7CFF6B),
                  size: 27,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatNumber(current)} / ${_formatNumber(target)} $unit',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              if (completed)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF7CFF6B),
                  size: 24,
                )
              else
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.white10,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    Color(0xFF7CFF6B),
                  ),
                ),
              ),

              if (action != null) ...[
                const SizedBox(width: 5),
                action!,
              ],
            ],
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                color: Color(0xFF7CFF6B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CUSTOM GOAL CARD
// ============================================================

class _CustomGoalCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final String unit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onProgress;

  const _CustomGoalCard({
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.onEdit,
    required this.onDelete,
    required this.onProgress,
  });

  double _progress() {
    if (target <= 0) return 0;

    final value = current / target;

    if (value > 1) return 1;
    if (value < 0) return 0;

    return value;
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress();
    final completed = current >= target;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171D25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed
              ? const Color(0x557CFF6B)
              : const Color(0x227CFF6B),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7CFF6B),
                      Color(0xFF36D97A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.black,
                  size: 26,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatNumber(current)} / ${_formatNumber(target)} $unit',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              if (completed)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF7CFF6B),
                  size: 24,
                ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.white10,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    Color(0xFF7CFF6B),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF7CFF6B),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onProgress,
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 18,
                ),
                label: const Text('Progress'),
              ),
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white60,
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}