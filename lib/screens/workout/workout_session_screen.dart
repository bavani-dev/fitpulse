import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/storage_service.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final String workoutName;

  const WorkoutSessionScreen({
    super.key,
    required this.workoutName,
  });

  @override
  State<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  Timer? _timer;

  int elapsedSeconds = 0;
  int currentExercise = 0;
  int completedSets = 0;

  final List<Map<String, dynamic>> exercises = [
    {
      'name': 'Push Ups',
      'sets': 3,
      'reps': '12 reps',
    },
    {
      'name': 'Squats',
      'sets': 4,
      'reps': '15 reps',
    },
    {
      'name': 'Plank',
      'sets': 3,
      'reps': '45 sec',
    },
    {
      'name': 'Bicep Curls',
      'sets': 3,
      'reps': '12 reps',
    },
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          elapsedSeconds++;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _completeSet() {
    final totalSets = exercises[currentExercise]['sets'] as int;

    if (completedSets < totalSets) {
      setState(() {
        completedSets++;
      });
    }

    if (completedSets >= totalSets) {
      _showExerciseCompleted();
    }
  }

  void _showExerciseCompleted() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exercise completed 🎉'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _nextExercise() {
    if (currentExercise < exercises.length - 1) {
      setState(() {
        currentExercise++;
        completedSets = 0;
      });
    } else {
      _finishWorkout();
    }
  }

  Future<void> _finishWorkout() async {
    _timer?.cancel();

    final minutes = (elapsedSeconds / 60).ceil();

    final durationText = minutes == 0
        ? '1 min'
        : '$minutes min';

    // Demo calorie calculation.
    final calories = (elapsedSeconds / 60 * 7).round();

    await StorageService.addWorkoutHistory(
      name: widget.workoutName,
      date: 'Today',
      duration: durationText,
      calories: '$calories kcal',
      exercises: '${exercises.length} exercises',
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Workout Complete 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 70,
                color: Color(0xFF7CFF6B),
              ),
              const SizedBox(height: 16),
              Text(
                widget.workoutName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('Duration: $durationText'),
              const SizedBox(height: 4),
              Text('Calories: $calories kcal'),
              const SizedBox(height: 4),
              Text('Exercises: ${exercises.length}'),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = exercises[currentExercise];

    final exerciseName = exercise['name'] as String;
    final sets = exercise['sets'] as int;
    final reps = exercise['reps'] as String;

    final progress =
        (currentExercise + 1) / exercises.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        title: Text(widget.workoutName),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // TIMER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 25,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF171D25),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Workout Time',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PROGRESS
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercise ${currentExercise + 1} of ${exercises.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: Color(0xFF7CFF6B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
                backgroundColor:
                    Colors.white.withValues(alpha: 0.08),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(
                  Color(0xFF7CFF6B),
                ),
              ),

              const SizedBox(height: 25),

              // EXERCISE CARD
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171D25),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.06,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7CFF6B)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          size: 48,
                          color: Color(0xFF7CFF6B),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Text(
                        exerciseName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '$sets sets • $reps',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'Completed sets',
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '$completedSets / $sets',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7CFF6B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // COMPLETE SET
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: completedSets < sets
                      ? _completeSet
                      : _nextExercise,
                  icon: Icon(
                    completedSets < sets
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    completedSets < sets
                        ? 'Complete Set'
                        : currentExercise <
                                exercises.length - 1
                            ? 'Next Exercise'
                            : 'Finish Workout',
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // FINISH BUTTON
              if (currentExercise <
                  exercises.length - 1)
                TextButton(
                  onPressed: _finishWorkout,
                  child: const Text(
                    'Finish Workout',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}