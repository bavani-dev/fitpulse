import 'package:flutter/material.dart';

import 'workout_session_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseName;
  final String muscleGroup;
  final int sets;
  final int reps;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
  });

  static const Color green = Color(0xFF7CFF6B);
  static const Color card = Color(0xFF171D25);

  @override
  Widget build(BuildContext context) {
    final String targetText =
        exerciseName == 'Plank' ? '$reps seconds' : '$reps reps';

    return Scaffold(
      appBar: AppBar(
        title: Text(exerciseName),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EXERCISE ICON
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: green,
                  size: 90,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // NAME
            Text(
              exerciseName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              muscleGroup,
              style: const TextStyle(
                color: green,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            // SETS / REPS
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.repeat_rounded,
                    value: '$sets',
                    label: 'Sets',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.numbers_rounded,
                    value: targetText,
                    label: 'Target',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // HOW TO PERFORM
            const Text(
              'How to perform',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _instructions(),
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // START EXERCISE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutSessionScreen(
                        workoutName: exerciseName,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.play_arrow_rounded,
                ),
                label: const Text(
                  'Start Exercise',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _instructions() {
    switch (exerciseName) {
      case 'Push Ups':
        return 'Start in a high plank position with your hands slightly wider than your shoulders. Keep your body straight, lower your chest toward the floor, then push back up while keeping your core tight.';

      case 'Squats':
        return 'Stand with your feet about shoulder-width apart. Push your hips back and bend your knees to lower your body. Keep your chest up and then drive through your feet to return to the starting position.';

      case 'Plank':
        return 'Place your forearms on the floor and extend your legs behind you. Keep your body in a straight line from your head to your heels. Tighten your core and hold the position without dropping your hips.';

      case 'Bicep Curls':
        return 'Stand upright while holding the weights at your sides. Keep your elbows close to your body and curl the weights toward your shoulders. Slowly lower them back down with control.';

      default:
        return 'Perform the exercise with controlled movement and maintain proper form throughout the exercise.';
    }
  }
}


// ======================================================
// INFO CARD
// ======================================================

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InfoCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}