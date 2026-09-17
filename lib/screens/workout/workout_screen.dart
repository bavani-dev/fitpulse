import 'package:flutter/material.dart';

import 'exercise_detail_screen.dart';
import 'workout_history_screen.dart';
import 'workout_session_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  static const Color green = Color(0xFF7CFF6B);
  static const Color card = Color(0xFF171D25);

  String selectedCategory = 'All';
  String searchText = '';

  final List<Map<String, dynamic>> exercises = [
    {
      'name': 'Push Ups',
      'muscle': 'Chest • Triceps',
      'sets': 3,
      'reps': 12,
      'icon': Icons.accessibility_new_rounded,
      'category': 'Strength',
    },
    {
      'name': 'Squats',
      'muscle': 'Legs • Glutes',
      'sets': 4,
      'reps': 15,
      'icon': Icons.directions_run_rounded,
      'category': 'Strength',
    },
    {
      'name': 'Plank',
      'muscle': 'Core • Abs',
      'sets': 3,
      'reps': 45,
      'icon': Icons.self_improvement_rounded,
      'category': 'Strength',
    },
    {
      'name': 'Bicep Curls',
      'muscle': 'Biceps • Arms',
      'sets': 3,
      'reps': 12,
      'icon': Icons.fitness_center_rounded,
      'category': 'Strength',
    },
    {
      'name': 'Jumping Jacks',
      'muscle': 'Full Body',
      'sets': 3,
      'reps': 30,
      'icon': Icons.directions_run_rounded,
      'category': 'Cardio',
    },
    {
      'name': 'Mountain Climbers',
      'muscle': 'Core • Cardio',
      'sets': 3,
      'reps': 20,
      'icon': Icons.speed_rounded,
      'category': 'Cardio',
    },
    {
      'name': 'Warrior Pose',
      'muscle': 'Legs • Flexibility',
      'sets': 2,
      'reps': 30,
      'icon': Icons.self_improvement_rounded,
      'category': 'Yoga',
    },
    {
      'name': 'Hamstring Stretch',
      'muscle': 'Hamstrings • Legs',
      'sets': 2,
      'reps': 30,
      'icon': Icons.accessibility_new_rounded,
      'category': 'Stretch',
    },
  ];

  List<Map<String, dynamic>> get filteredExercises {
    return exercises.where((exercise) {
      final matchesCategory = selectedCategory == 'All' ||
          exercise['category'] == selectedCategory;

      final name = exercise['name'].toString().toLowerCase();
      final muscle = exercise['muscle'].toString().toLowerCase();
      final search = searchText.toLowerCase();

      final matchesSearch =
          name.contains(search) || muscle.contains(search);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void openExercise(Map<String, dynamic> exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          exerciseName: exercise['name'],
          muscleGroup: exercise['muscle'],
          sets: exercise['sets'],
          reps: exercise['reps'],
        ),
      ),
    );
  }

  void startFullBodyWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WorkoutSessionScreen(
          workoutName: 'Full Body Power',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workouts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Text(
              'Train smarter.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose a workout and reach your goals.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            // SEARCH
            Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search exercises...',
                  hintStyle: TextStyle(
                    color: Colors.white38,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white54,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // CATEGORIES
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CategoryChip(
                    title: 'All',
                    icon: Icons.apps_rounded,
                    selected: selectedCategory == 'All',
                    onTap: () {
                      setState(() {
                        selectedCategory = 'All';
                      });
                    },
                  ),
                  _CategoryChip(
                    title: 'Strength',
                    icon: Icons.fitness_center_rounded,
                    selected: selectedCategory == 'Strength',
                    onTap: () {
                      setState(() {
                        selectedCategory = 'Strength';
                      });
                    },
                  ),
                  _CategoryChip(
                    title: 'Cardio',
                    icon: Icons.directions_run_rounded,
                    selected: selectedCategory == 'Cardio',
                    onTap: () {
                      setState(() {
                        selectedCategory = 'Cardio';
                      });
                    },
                  ),
                  _CategoryChip(
                    title: 'Yoga',
                    icon: Icons.self_improvement_rounded,
                    selected: selectedCategory == 'Yoga',
                    onTap: () {
                      setState(() {
                        selectedCategory = 'Yoga';
                      });
                    },
                  ),
                  _CategoryChip(
                    title: 'Stretch',
                    icon: Icons.accessibility_new_rounded,
                    selected: selectedCategory == 'Stretch',
                    onTap: () {
                      setState(() {
                        selectedCategory = 'Stretch';
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TODAY'S PLAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    green.withValues(alpha: 0.18),
                    card,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: green.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: green,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Plan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '4 exercises • 45 minutes',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // WORKOUT HISTORY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Workout History',
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
                            const WorkoutHistoryScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // FEATURED WORKOUT
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.flash_on_rounded,
                          color: green,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full Body Power',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Intermediate',
                              style: TextStyle(
                                color: green,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: green.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'POPULAR',
                          style: TextStyle(
                            color: green,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: Colors.white54,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '45 min',
                        style: TextStyle(
                          color: Colors.white60,
                        ),
                      ),
                      SizedBox(width: 20),
                      Icon(
                        Icons.local_fire_department_outlined,
                        size: 18,
                        color: Colors.white54,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '320 kcal',
                        style: TextStyle(
                          color: Colors.white60,
                        ),
                      ),
                      SizedBox(width: 20),
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 18,
                        color: Colors.white54,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '4 exercises',
                        style: TextStyle(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: startFullBodyWorkout,
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                      ),
                      label: const Text(
                        'Start Workout',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // EXERCISES HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercises',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${filteredExercises.length} found',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // EXERCISE LIST
            if (filteredExercises.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: Colors.white24,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No exercises found',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Try another search or category.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredExercises.map(
                (exercise) => _ExerciseCard(
                  icon: exercise['icon'],
                  name: exercise['name'],
                  muscleGroup: exercise['muscle'],
                  sets: exercise['sets'],
                  reps: exercise['reps'],
                  onTap: () => openExercise(exercise),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// CATEGORY CHIP
// ======================================================

class _CategoryChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF7CFF6B)
                : const Color(0xFF171D25),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Colors.black
                    : const Color(0xFF7CFF6B),
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  color: selected
                      ? Colors.black
                      : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
// EXERCISE CARD
// ======================================================

class _ExerciseCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String muscleGroup;
  final int sets;
  final int reps;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.icon,
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF171D25),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0x227CFF6B),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF7CFF6B),
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      muscleGroup,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$sets sets • $reps reps',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}