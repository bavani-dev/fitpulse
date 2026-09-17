import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../workout/workout_screen.dart';
import '../workout/workout_session_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color green = Color(0xFF7CFF6B);
  static const Color card = Color(0xFF171D25);

  double waterLiters = 1.8;
  int calories = 642;
  double? weight;

  @override
  void initState() {
    super.initState();
    _loadQuickActionData();
  }

  // ======================================================
  // LOAD SAVED DATA
  // ======================================================

  Future<void> _loadQuickActionData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedWater = prefs.getDouble('fitpulse_today_water');
    final savedCalories = prefs.getInt('fitpulse_today_calories');
    final savedWeight = prefs.getDouble('fitpulse_today_weight');

    if (!mounted) return;

    setState(() {
      if (savedWater != null) {
        waterLiters = savedWater;
      }

      if (savedCalories != null) {
        calories = savedCalories;
      }

      if (savedWeight != null) {
        weight = savedWeight;
      }
    });
  }

  // ======================================================
  // ADD WATER
  // ======================================================

  Future<void> _showAddWaterDialog() async {
    final customController = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          title: const Text(
            'Add Water 💧',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select the amount of water you drank.',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 18),

              _waterOption(dialogContext, 250),
              const SizedBox(height: 8),

              _waterOption(dialogContext, 500),
              const SizedBox(height: 8),

              _waterOption(dialogContext, 750),

              const SizedBox(height: 15),

              TextField(
                controller: customController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Custom amount (ml)',
                  hintText: 'Example: 1000',
                  prefixIcon: const Icon(Icons.water_drop_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final value = double.tryParse(
                      customController.text.trim(),
                    );

                    if (value != null && value > 0) {
                      Navigator.pop(dialogContext, value);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Add Custom Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    customController.dispose();

    if (amount == null) return;

    final addedLiters = amount / 1000;

    final prefs = await SharedPreferences.getInstance();

    final newWater = waterLiters + addedLiters;

    await prefs.setDouble(
      'fitpulse_today_water',
      newWater,
    );

    if (!mounted) return;

    setState(() {
      waterLiters = newWater;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${amount.toStringAsFixed(0)} ml water added 💧',
        ),
      ),
    );
  }

  Widget _waterOption(
    BuildContext dialogContext,
    int amount,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pop(
            dialogContext,
            amount.toDouble(),
          );
        },
        icon: const Icon(
          Icons.water_drop_rounded,
          color: green,
        ),
        label: Text('$amount ml'),
      ),
    );
  }

  // ======================================================
  // LOG MEAL
  // ======================================================

  Future<void> _showLogMealDialog() async {
    final caloriesController = TextEditingController();

    String mealType = 'Breakfast';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: card,
              title: const Text(
                'Log Meal 🍽️',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: mealType,
                      decoration: InputDecoration(
                        labelText: 'Meal Type',
                        prefixIcon: const Icon(
                          Icons.restaurant_rounded,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Breakfast',
                          child: Text('Breakfast'),
                        ),
                        DropdownMenuItem(
                          value: 'Lunch',
                          child: Text('Lunch'),
                        ),
                        DropdownMenuItem(
                          value: 'Dinner',
                          child: Text('Dinner'),
                        ),
                        DropdownMenuItem(
                          value: 'Snack',
                          child: Text('Snack'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          mealType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Calories',
                        hintText: 'Example: 450',
                        prefixIcon: const Icon(
                          Icons.local_fire_department_rounded,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
                  onPressed: () {
                    final value = int.tryParse(
                      caloriesController.text.trim(),
                    );

                    if (value != null && value > 0) {
                      Navigator.pop(
                        dialogContext,
                        {
                          'meal': mealType,
                          'calories': value,
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Save Meal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    caloriesController.dispose();

    if (result == null) return;

    final mealCalories = result['calories'] as int;
    final mealName = result['meal'] as String;

    final prefs = await SharedPreferences.getInstance();

    final newCalories = calories + mealCalories;

    await prefs.setInt(
      'fitpulse_today_calories',
      newCalories,
    );

    // Save meal history.
    final savedMeals = prefs.getStringList(
      'fitpulse_meal_history',
    ) ?? [];

    final mealData = {
      'meal': mealName,
      'calories': mealCalories,
      'date': DateTime.now().toIso8601String(),
    };

    savedMeals.add(jsonEncode(mealData));

    await prefs.setStringList(
      'fitpulse_meal_history',
      savedMeals,
    );

    if (!mounted) return;

    setState(() {
      calories = newCalories;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$mealName added • $mealCalories kcal 🔥',
        ),
      ),
    );
  }

  // ======================================================
  // WEIGHT
  // ======================================================

  Future<void> _showWeightDialog() async {
    final weightController = TextEditingController(
      text: weight?.toStringAsFixed(1) ?? '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          title: const Text(
            'Log Weight ⚖️',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: weightController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: 'Weight (kg)',
              hintText: 'Example: 68.5',
              prefixIcon: const Icon(
                Icons.monitor_weight_rounded,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                final value = double.tryParse(
                  weightController.text.trim(),
                );

                if (value != null && value > 0) {
                  Navigator.pop(dialogContext, value);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'Save Weight',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    weightController.dispose();

    if (result == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(
      'fitpulse_today_weight',
      result,
    );

    if (!mounted) return;

    setState(() {
      weight = result;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Weight saved: ${result.toStringAsFixed(1)} kg ⚖️',
        ),
      ),
    );
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =========================
              // HEADER
              // =========================

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning 👋',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white60,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Ready to move?',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Notifications coming soon 🔔',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =========================
              // DAILY GOAL
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 105,
                      height: 105,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: 0.72,
                              strokeWidth: 10,
                              backgroundColor: Colors.white12,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                green,
                              ),
                            ),
                          ),
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '72%',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Goal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 22),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Goal',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'You are doing great!',
                            style: TextStyle(
                              color: Colors.white60,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Keep going to complete your goal.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =========================
              // TODAY'S ACTIVITY
              // =========================

              const Text(
                'Today\'s Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: [
                  _StatCard(
                    icon:
                        Icons.local_fire_department_rounded,
                    value: '$calories',
                    label: 'Calories',
                  ),
                  const _StatCard(
                    icon: Icons.directions_walk_rounded,
                    value: '7,842',
                    label: 'Steps',
                  ),
                  _StatCard(
                    icon: Icons.water_drop_rounded,
                    value:
                        '${waterLiters.toStringAsFixed(1)} L',
                    label: 'Water',
                  ),
                  const _StatCard(
                    icon: Icons.timer_rounded,
                    value: '42 min',
                    label: 'Active Time',
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =========================
              // TODAY'S WORKOUT
              // =========================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today\'s Workout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const WorkoutScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: green,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color:
                                green.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: green,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Full Body Power',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '45 min • 320 kcal',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const WorkoutSessionScreen(
                                workoutName:
                                    'Full Body Power',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: Colors.black,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Start Workout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =========================
              // QUICK ACTIONS
              // =========================

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon:
                          Icons.fitness_center_rounded,
                      title: 'Log Workout',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const WorkoutScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _QuickAction(
                      icon:
                          Icons.water_drop_rounded,
                      title: 'Add Water',
                      onTap: _showAddWaterDialog,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon:
                          Icons.restaurant_rounded,
                      title: 'Log Meal',
                      onTap: _showLogMealDialog,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _QuickAction(
                      icon:
                          Icons.monitor_weight_rounded,
                      title: 'Weight',
                      onTap: _showWeightDialog,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =========================
              // WEIGHT DISPLAY
              // =========================

              if (weight != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              green.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.monitor_weight_rounded,
                          color: green,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Today\'s Weight',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                      Text(
                        '${weight!.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
              ],

              // =========================
              // STREAK
              // =========================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: green,
                      size: 38,
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7 Day Streak 🔥',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Keep your streak going!',
                          style: TextStyle(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ======================================================
// STAT CARD
// ======================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF171D25),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF7CFF6B),
            size: 28,
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ======================================================
// QUICK ACTION
// ======================================================

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF171D25),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF7CFF6B),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}