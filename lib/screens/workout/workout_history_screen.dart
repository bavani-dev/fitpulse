import 'package:flutter/material.dart';

import '../../services/storage_service.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  List<Map<String, String>> workoutHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await StorageService.getWorkoutHistory();

    if (!mounted) return;

    setState(() {
      workoutHistory = history;
      isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear History?'),
          content: const Text(
            'Are you sure you want to remove all workout history?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) return;

    await StorageService.clearWorkoutHistory();

    if (!mounted) return;

    setState(() {
      workoutHistory = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout history cleared'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        title: const Text(
          'Workout History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (workoutHistory.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear history',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (workoutHistory.isEmpty) {
      return const _EmptyHistory();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workoutHistory.length,
      itemBuilder: (context, index) {
        final workout = workoutHistory[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _WorkoutHistoryCard(
            name: workout['name'] ?? 'Workout',
            date: workout['date'] ?? '',
            duration: workout['duration'] ?? '0 min',
            calories: workout['calories'] ?? '0 kcal',
            exercises: workout['exercises'] ?? '0 exercises',
          ),
        );
      },
    );
  }
}

// =========================================================
// WORKOUT HISTORY CARD
// =========================================================

class _WorkoutHistoryCard extends StatelessWidget {
  final String name;
  final String date;
  final String duration;
  final String calories;
  final String exercises;

  const _WorkoutHistoryCard({
    required this.name,
    required this.date,
    required this.duration,
    required this.calories,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171D25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF7CFF6B)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Color(0xFF7CFF6B),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _HistoryInfo(
                  icon: Icons.timer_outlined,
                  label: duration,
                ),
              ),
              Expanded(
                child: _HistoryInfo(
                  icon: Icons.local_fire_department_outlined,
                  label: calories,
                ),
              ),
              Expanded(
                child: _HistoryInfo(
                  icon: Icons.fitness_center_outlined,
                  label: exercises,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================
// HISTORY INFO
// =========================================================

class _HistoryInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HistoryInfo({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF7CFF6B),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.75),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// =========================================================
// EMPTY HISTORY
// =========================================================

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
        ),
        Icon(
          Icons.history_rounded,
          size: 80,
          color: Colors.white.withValues(alpha: 0.18),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'No workouts yet',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Complete a workout and it will appear here.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}