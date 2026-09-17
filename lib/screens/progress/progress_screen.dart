// ignore_for_file: unnecessary_import, use_null_aware_elements, unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/storage_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xFF0B0F14);
  static const Color card = Color(0xFF171D25);
  static const Color cardLight = Color(0xFF1D2530);
  static const Color green = Color(0xFF7CFF6B);
  static const Color white = Color(0xFFF5F7FA);
  static const Color grey = Color(0xFF9AA4B2);

  // ============================================================
  // DATA
  // ============================================================

  List<Map<String, String>> workouts = [];

  bool isLoading = true;

  int totalWorkouts = 0;
  int totalCalories = 0;
  int totalMinutes = 0;
  int todaySteps = 7842;

  double weeklyGoal = 5;
  double weeklyProgress = 0;

  Timer? _refreshTimer;

  final List<String> days = [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  List<double> weeklyActivity = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadProgress();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        _loadProgress(silent: true);
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // LOAD PROGRESS
  // ============================================================

  Future<void> _loadProgress({bool silent = false}) async {
    try {
      final savedWorkouts =
          await StorageService.getWorkoutHistory();

      final prefs = await SharedPreferences.getInstance();

      int calories = 0;
      int minutes = 0;

      for (final workout in savedWorkouts) {
        calories += _parseNumber(workout['calories']);
        minutes += _parseDuration(workout['duration']);
      }

      final steps =
          prefs.getInt('fitpulse_today_steps') ?? 7842;

      final goal =
          prefs.getInt('fitpulse_workout_target') ?? 5;

      if (!mounted) return;

      setState(() {
        workouts = savedWorkouts;
        totalWorkouts = savedWorkouts.length;
        totalCalories = calories;
        totalMinutes = minutes;
        todaySteps = steps;
        weeklyGoal = goal.toDouble();

        weeklyProgress =
            weeklyGoal == 0
                ? 0
                : (totalWorkouts / weeklyGoal).clamp(0.0, 1.0);

        weeklyActivity =
            _buildWeeklyActivity(savedWorkouts);

        if (!silent) {
          isLoading = false;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // NUMBER HELPERS
  // ============================================================

  int _parseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 0;
    }

    final match = RegExp(r'\d+').firstMatch(value);

    if (match == null) {
      return 0;
    }

    return int.tryParse(match.group(0)!) ?? 0;
  }

  int _parseDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 0;
    }

    final text = value.trim().toLowerCase();

    final hoursMatch =
        RegExp(r'(\d+)\s*h').firstMatch(text);

    final minutesMatch =
        RegExp(r'(\d+)\s*m').firstMatch(text);

    final secondsMatch =
        RegExp(r'(\d+)\s*s').firstMatch(text);

    if (hoursMatch != null ||
        minutesMatch != null ||
        secondsMatch != null) {
      final hours = hoursMatch == null
          ? 0
          : int.tryParse(hoursMatch.group(1)!) ?? 0;

      final minutes = minutesMatch == null
          ? 0
          : int.tryParse(minutesMatch.group(1)!) ?? 0;

      final seconds = secondsMatch == null
          ? 0
          : int.tryParse(secondsMatch.group(1)!) ?? 0;

      return (hours * 60) + minutes + (seconds / 60).round();
    }

    final numbers = RegExp(r'\d+')
        .allMatches(text)
        .map((e) => int.tryParse(e.group(0)!) ?? 0)
        .toList();

    if (numbers.isEmpty) {
      return 0;
    }

    return numbers.first;
  }

  // ============================================================
  // WEEKLY ACTIVITY
  // ============================================================

  List<double> _buildWeeklyActivity(
    List<Map<String, String>> data,
  ) {
    final values = List<double>.filled(7, 0);

    final now = DateTime.now();

    for (final workout in data) {
      final dateString = workout['date'] ?? '';

      DateTime? date;

      try {
        date = DateTime.tryParse(dateString);
      } catch (_) {
        date = null;
      }

      if (date == null) {
        continue;
      }

      final difference =
          DateTime(
            now.year,
            now.month,
            now.day,
          ).difference(
            DateTime(
              date.year,
              date.month,
              date.day,
            ),
          ).inDays;

      if (difference >= 0 && difference < 7) {
        final index =
            (DateTime.now().weekday - 1 - difference) % 7;

        if (index >= 0 && index < 7) {
          values[index] += 1;
        }
      }
    }

    return values;
  }

  // ============================================================
  // STEPS
  // ============================================================

  Future<void> _editSteps() async {
    final controller = TextEditingController(
      text: todaySteps.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: card,
          title: const Text('Update Steps'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter today's steps",
              prefixIcon: const Icon(Icons.directions_walk),
              filled: true,
              fillColor: cardLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: green, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final value =
                    int.tryParse(controller.text.trim());

                if (value != null && value >= 0) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'fitpulse_today_steps',
      result,
    );

    if (!mounted) return;

    setState(() {
      todaySteps = result;
    });
  }

  // ============================================================
  // PULL TO REFRESH
  // ============================================================

  Future<void> _refresh() async {
    await _loadProgress();
  }

  // ============================================================
  // FITNESS LEVEL
  // ============================================================

  String get fitnessLevel {
    if (totalWorkouts >= 30) {
      return 'Elite';
    }

    if (totalWorkouts >= 15) {
      return 'Advanced';
    }

    if (totalWorkouts >= 7) {
      return 'Intermediate';
    }

    if (totalWorkouts >= 3) {
      return 'Beginner+';
    }

    return 'Beginner';
  }

  // ============================================================
  // OVERALL SCORE
  // ============================================================

  double get overallProgress {
    final workoutScore =
        (totalWorkouts / 10).clamp(0.0, 1.0);

    final caloriesScore =
        (totalCalories / 5000).clamp(0.0, 1.0);

    final stepsScore =
        (todaySteps / 10000).clamp(0.0, 1.0);

    final timeScore =
        (totalMinutes / 300).clamp(0.0, 1.0);

    return (
      workoutScore +
      caloriesScore +
      stepsScore +
      timeScore
    ) / 4;
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  List<_Achievement> get achievements {
    return [
      _Achievement(
        title: 'First Step',
        subtitle: 'Complete your first workout',
        icon: Icons.flag_rounded,
        unlocked: totalWorkouts >= 1,
      ),
      _Achievement(
        title: '1K Calories',
        subtitle: 'Burn 1,000 calories',
        icon: Icons.local_fire_department_rounded,
        unlocked: totalCalories >= 1000,
      ),
      _Achievement(
        title: '5 Workouts',
        subtitle: 'Complete 5 workouts',
        icon: Icons.fitness_center_rounded,
        unlocked: totalWorkouts >= 5,
      ),
      _Achievement(
        title: '10K Steps',
        subtitle: 'Walk 10,000 steps',
        icon: Icons.directions_walk_rounded,
        unlocked: todaySteps >= 10000,
      ),
      _Achievement(
        title: '5 Hours',
        subtitle: 'Train for 5 hours',
        icon: Icons.timer_rounded,
        unlocked: totalMinutes >= 300,
      ),
      _Achievement(
        title: 'Consistency',
        subtitle: 'Complete 10 workouts',
        icon: Icons.workspace_premium_rounded,
        unlocked: totalWorkouts >= 10,
      ),
    ];
  }

  // ============================================================
  // MOTIVATION
  // ============================================================

  String get motivationTitle {
    if (totalWorkouts == 0) {
      return 'Your journey starts today';
    }

    if (totalWorkouts < 3) {
      return 'Great start! Keep moving';
    }

    if (totalWorkouts < 7) {
      return 'You are building momentum';
    }

    if (totalWorkouts < 15) {
      return 'You are becoming consistent';
    }

    return 'You are on fire!';
  }

  String get motivationText {
    if (totalWorkouts == 0) {
      return 'Complete your first workout and start building your fitness journey.';
    }

    if (todaySteps < 5000) {
      return 'A short walk today can make a big difference. Keep going!';
    }

    if (totalWorkouts < 5) {
      return 'Every workout counts. Stay consistent and your progress will follow.';
    }

    return 'Your hard work is showing. Keep pushing toward your next milestone.';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Progress',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: green,
              ),
            )
          : RefreshIndicator(
              color: green,
              backgroundColor: card,
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  30,
                ),
                children: [
                  _buildHeroCard(),

                  const SizedBox(height: 18),

                  _buildStatGrid(),

                  const SizedBox(height: 18),

                  _buildWeeklyCard(),

                  const SizedBox(height: 18),

                  _buildPerformanceCard(),

                  const SizedBox(height: 18),

                  _buildAchievementsCard(),

                  const SizedBox(height: 18),

                  _buildRecentWorkoutsCard(),

                  const SizedBox(height: 18),

                  _buildMindsetCard(),

                  const SizedBox(height: 18),

                  _buildChallengeCard(),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHeroCard() {
    final progress = overallProgress;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: green.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OVERALL PROGRESS',
                      style: TextStyle(
                        color: green.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      motivationTitle,
                      style: const TextStyle(
                        color: white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Fitness level • $fitnessLevel',
                      style: const TextStyle(
                        color: grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _buildProgressRing(progress),
            ],
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  Colors.white.withValues(alpha: 0.07),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                green,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).round()}% overall',
                style: const TextStyle(
                  color: green,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$totalWorkouts workouts completed',
                style: const TextStyle(
                  color: grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(double progress) {
    return SizedBox(
      width: 105,
      height: 105,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 105,
            height: 105,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 9,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          SizedBox(
            width: 105,
            height: 105,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 9,
              strokeCap: StrokeCap.round,
              color: green,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'DONE',
                style: TextStyle(
                  color: grey,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT GRID
  // ============================================================

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard(
          icon: Icons.fitness_center_rounded,
          title: 'Workouts',
          value: '$totalWorkouts',
          subtitle: 'completed',
        ),
        _statCard(
          icon: Icons.local_fire_department_rounded,
          title: 'Calories',
          value: '$totalCalories',
          subtitle: 'kcal burned',
        ),
        _statCard(
          icon: Icons.timer_rounded,
          title: 'Workout Time',
          value: '${totalMinutes}m',
          subtitle: 'total training',
        ),
        _statCard(
          icon: Icons.directions_walk_rounded,
          title: 'Today Steps',
          value: _formatNumber(todaySteps),
          subtitle: 'tap to edit',
          onTap: _editSteps,
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          green.withValues(alpha: 0.10),
                      borderRadius:
                          BorderRadius.circular(11),
                    ),
                    child: Icon(
                      icon,
                      color: green,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    const Icon(
                      Icons.edit_rounded,
                      size: 15,
                      color: grey,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '$title • $subtitle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WEEKLY ACTIVITY
  // ============================================================

  Widget _buildWeeklyCard() {
    final maxValue =
        weeklyActivity.reduce(max).clamp(1.0, double.infinity);

    return _sectionCard(
      title: 'Weekly Activity',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: List.generate(
              7,
              (index) {
                final value =
                    weeklyActivity[index];

                final height =
                    24 + ((value / maxValue) * 95);

                final isToday =
                    index == DateTime.now().weekday - 1;

                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    child: Column(
                      children: [
                        Text(
                          value == 0
                              ? ''
                              : '${value.round()}',
                          style: const TextStyle(
                            color: green,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 500),
                          height: height,
                          decoration: BoxDecoration(
                            color: value > 0
                                ? green
                                : Colors.white.withValues(
                                    alpha: 0.07,
                                  ),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[index],
                          style: TextStyle(
                            color: isToday
                                ? green
                                : grey,
                            fontSize: 11,
                            fontWeight:
                                isToday
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.track_changes_rounded,
                  color: green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly target',
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$totalWorkouts / ${weeklyGoal.round()} workouts',
                        style: const TextStyle(
                          color: grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(weeklyProgress * 100).round()}%',
                  style: const TextStyle(
                    color: green,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERFORMANCE
  // ============================================================

  Widget _buildPerformanceCard() {
    final workoutScore =
        (totalWorkouts / 10).clamp(0.0, 1.0);

    final calorieScore =
        (totalCalories / 5000).clamp(0.0, 1.0);

    final timeScore =
        (totalMinutes / 300).clamp(0.0, 1.0);

    final stepsScore =
        (todaySteps / 10000).clamp(0.0, 1.0);

    return _sectionCard(
      title: 'Performance',
      icon: Icons.insights_rounded,
      child: Column(
        children: [
          _performanceRow(
            'Workouts',
            totalWorkouts.toString(),
            workoutScore,
            Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 18),
          _performanceRow(
            'Calories',
            '$totalCalories kcal',
            calorieScore,
            Icons.local_fire_department_rounded,
          ),
          const SizedBox(height: 18),
          _performanceRow(
            'Training Time',
            '${totalMinutes} min',
            timeScore,
            Icons.timer_rounded,
          ),
          const SizedBox(height: 18),
          _performanceRow(
            'Steps',
            _formatNumber(todaySteps),
            stepsScore,
            Icons.directions_walk_rounded,
          ),
        ],
      ),
    );
  }

  Widget _performanceRow(
    String title,
    String value,
    double progress,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: green,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor:
                Colors.white.withValues(alpha: 0.06),
            valueColor:
                const AlwaysStoppedAnimation<Color>(
              green,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  Widget _buildAchievementsCard() {
    final unlocked =
        achievements.where((a) => a.unlocked).length;

    return _sectionCard(
      title: 'Achievements',
      icon: Icons.emoji_events_rounded,
      trailing: Text(
        '$unlocked/${achievements.length}',
        style: const TextStyle(
          color: green,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: achievements.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.45,
        ),
        itemBuilder: (context, index) {
          final achievement =
              achievements[index];

          return _achievementTile(
            achievement,
          );
        },
      ),
    );
  }

  Widget _achievementTile(
    _Achievement achievement,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? green.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: achievement.unlocked
              ? green.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? green.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              size: 19,
              color: achievement.unlocked
                  ? green
                  : grey,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: achievement.unlocked
                        ? white
                        : grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  achievement.unlocked
                      ? 'Unlocked'
                      : 'Locked',
                  style: TextStyle(
                    color: achievement.unlocked
                        ? green
                        : grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT WORKOUTS
  // ============================================================

  Widget _buildRecentWorkoutsCard() {
    final recent =
        workouts.take(5).toList();

    return _sectionCard(
      title: 'Recent Workouts',
      icon: Icons.history_rounded,
      trailing: Text(
        '${workouts.length}',
        style: const TextStyle(
          color: green,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: recent.isEmpty
          ? _emptyWorkoutState()
          : Column(
              children: [
                for (int i = 0;
                    i < recent.length;
                    i++) ...[
                  _workoutTile(recent[i]),
                  if (i != recent.length - 1)
                    const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }

  Widget _emptyWorkoutState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 24,
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 38,
            color: grey.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 10),
          const Text(
            'No workouts yet',
            style: TextStyle(
              color: white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Complete a workout to see it here.',
            style: TextStyle(
              color: grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _workoutTile(
    Map<String, String> workout,
  ) {
    final name =
        workout['name'] ?? 'Workout';

    final calories =
        workout['calories'] ?? '0 kcal';

    final duration =
        workout['duration'] ?? '0 min';

    final date =
        workout['date'] ?? '';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: green,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                    color: grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                calories,
                style: const TextStyle(
                  color: green,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                duration,
                style: const TextStyle(
                  color: grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MINDSET
  // ============================================================

  Widget _buildMindsetCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            green.withValues(alpha: 0.15),
            card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: green.withValues(alpha: 0.13),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: green,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'DAILY MINDSET',
                  style: TextStyle(
                    color: green,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  motivationTitle,
                  style: const TextStyle(
                    color: white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  motivationText,
                  style: const TextStyle(
                    color: grey,
                    height: 1.4,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MINI CHALLENGE
  // ============================================================

  Widget _buildChallengeCard() {
    final stepsProgress =
        (todaySteps / 10000).clamp(0.0, 1.0);

    final remaining =
        max(0, 10000 - todaySteps);

    return _sectionCard(
      title: 'Today\'s Challenge',
      icon: Icons.bolt_rounded,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: green,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '10K Step Challenge',
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      remaining == 0
                          ? 'Challenge completed! 🎉'
                          : '$remaining steps remaining',
                      style: const TextStyle(
                        color: grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(stepsProgress * 100).round()}%',
                style: const TextStyle(
                  color: green,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: stepsProgress,
              minHeight: 9,
              backgroundColor:
                  Colors.white.withValues(alpha: 0.06),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                green,
              ),
            ),
          ),

          const SizedBox(height: 9),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatNumber(todaySteps),
                style: const TextStyle(
                  color: white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                '10,000',
                style: TextStyle(
                  color: grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _editSteps,
              icon: const Icon(
                Icons.edit_rounded,
                size: 17,
              ),
              label: const Text('Update Steps'),
              style: OutlinedButton.styleFrom(
                foregroundColor: green,
                side: BorderSide(
                  color: green.withValues(alpha: 0.3),
                ),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
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
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.045),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.09),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // FORMAT NUMBER
  // ============================================================

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 &&
          (text.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(text[i]);
    }

    return buffer.toString();
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(String value) {
    if (value.isEmpty) {
      return 'Recently completed';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    final now = DateTime.now();

    final difference = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(
      DateTime(
        date.year,
        date.month,
        date.day,
      ),
    ).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    if (difference > 1 && difference < 7) {
      return '$difference days ago';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// ================================================================
// ACHIEVEMENT MODEL
// ================================================================

class _Achievement {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool unlocked;

  const _Achievement({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.unlocked,
  });
}