// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/storage_service.dart';
import '../goals/goals_screen.dart';
import '../workout/workout_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color green = Color(0xFF7CFF6B);
  static const Color dark = Color(0xFF0B0F14);
  static const Color card = Color(0xFF171D25);

  String userName = '';
  String fitnessLevel = 'Beginner';
  String fitnessGoal = 'Build Strength';

  bool notificationsEnabled = true;
  bool workoutReminders = true;
  bool vibrationEnabled = true;

  int totalWorkouts = 0;
  int steps = 7842;

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  Future<void> _loadEverything() async {
    final name = await StorageService.getName();
    final level = await StorageService.getFitnessLevel();
    final goal = await StorageService.getFitnessGoal();
    final notifications = await StorageService.getNotifications();

    final history = await StorageService.getWorkoutHistory();

    final prefs = await SharedPreferences.getInstance();

    final savedSteps =
        prefs.getInt('fitpulse_today_steps') ?? 7842;

    final reminders =
        prefs.getBool('fitpulse_workout_reminders') ?? true;

    final vibration =
        prefs.getBool('fitpulse_vibration') ?? true;

    if (!mounted) return;

    setState(() {
      userName = name;
      fitnessLevel = level;
      fitnessGoal = goal;
      notificationsEnabled = notifications;
      workoutReminders = reminders;
      vibrationEnabled = vibration;
      totalWorkouts = history.length;
      steps = savedSteps;
    });
  }

  // ============================================================
  // PERSONAL INFORMATION
  // ============================================================

  Future<void> _editName() async {
    final controller =
        TextEditingController(text: userName);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Your Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: green,
              ),
              filled: true,
              fillColor: dark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();

                await StorageService.saveName(name);

                if (!mounted) return;

                setState(() {
                  userName = name;
                });

                Navigator.pop(dialogContext);

                _message('Profile updated successfully');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  // ============================================================
  // FITNESS LEVEL
  // ============================================================

  Future<void> _editFitnessLevel() async {
    String selected = fitnessLevel;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Fitness Level'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _choiceTile(
                    'Beginner',
                    selected,
                    (value) {
                      setDialogState(() {
                        selected = value;
                      });
                    },
                  ),
                  _choiceTile(
                    'Intermediate',
                    selected,
                    (value) {
                      setDialogState(() {
                        selected = value;
                      });
                    },
                  ),
                  _choiceTile(
                    'Advanced',
                    selected,
                    (value) {
                      setDialogState(() {
                        selected = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await StorageService
                        .saveFitnessLevel(selected);

                    if (!mounted) return;

                    setState(() {
                      fitnessLevel = selected;
                    });

                    Navigator.pop(dialogContext);

                    _message('Fitness level updated');
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

  Widget _choiceTile(
    String value,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    final isSelected = value == selected;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? green.withValues(alpha: 0.10)
              : dark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? green.withValues(alpha: 0.45)
                : Colors.transparent,
          ),
        ),
        child: ListTile(
          leading: Icon(
            isSelected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: isSelected
                ? green
                : Colors.white38,
          ),
          title: Text(value),
        ),
      ),
    );
  }

  // ============================================================
  // FITNESS GOAL
  // ============================================================

  Future<void> _editGoal() async {
    String selected = fitnessGoal;

    final goals = [
      'Build Strength',
      'Lose Weight',
      'Improve Fitness',
      'Stay Healthy',
    ];

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Fitness Goal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: goals.map((goal) {
                  return _choiceTile(
                    goal,
                    selected,
                    (value) {
                      setDialogState(() {
                        selected = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await StorageService
                        .saveFitnessGoal(selected);

                    if (!mounted) return;

                    setState(() {
                      fitnessGoal = selected;
                    });

                    Navigator.pop(dialogContext);

                    _message('Fitness goal updated');
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

  // ============================================================
  // SETTINGS
  // ============================================================

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          notificationsEnabled: notificationsEnabled,
          workoutReminders: workoutReminders,
          vibrationEnabled: vibrationEnabled,
          onNotificationsChanged: _changeNotifications,
          onRemindersChanged: _changeReminders,
          onVibrationChanged: _changeVibration,
          onClearHistory: _clearHistory,
        ),
      ),
    );
  }

  Future<void> _changeNotifications(bool value) async {
    await StorageService.saveNotifications(value);

    if (!mounted) return;

    setState(() {
      notificationsEnabled = value;
    });
  }

  Future<void> _changeReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'fitpulse_workout_reminders',
      value,
    );

    if (!mounted) return;

    setState(() {
      workoutReminders = value;
    });
  }

  Future<void> _changeVibration(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'fitpulse_vibration',
      value,
    );

    if (!mounted) return;

    setState(() {
      vibrationEnabled = value;
    });
  }

  // ============================================================
  // CLEAR HISTORY
  // ============================================================

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Clear Workout History?'),
          content: const Text(
            'All completed workout records will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await StorageService.clearWorkoutHistory();

    if (!mounted) return;

    setState(() {
      totalWorkouts = 0;
    });

    _message('Workout history cleared');
  }

  // ============================================================
  // ABOUT
  // ============================================================

  void _showAbout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: green,
                ),
              ),
              const SizedBox(width: 12),
              const Text('FitPulse'),
            ],
          ),
          content: const Text(
            'Your personal fitness companion.\n\n'
            'Track workouts, goals, steps and progress in one place.\n\n'
            'Version 1.0.0',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HELP
  // ============================================================

  void _showHelp() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Help & Support'),
          content: const Text(
            'Workout\n'
            'Complete exercises and finish workouts to update your progress.\n\n'
            'Goals\n'
            'Create and manage your fitness targets.\n\n'
            'Progress\n'
            'View workouts, calories, time, steps and achievements.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('FitPulse'),
          content: const Text(
            'FitPulse is currently running locally. '
            'There is no online account system connected.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final name =
        userName.trim().isEmpty ? 'Fitness Warrior' : userName;

    return Scaffold(
      backgroundColor: dark,

      body: RefreshIndicator(
        color: green,
        onRefresh: _loadEverything,

        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          slivers: [
            // ==================================================
            // PREMIUM HEADER
            // ==================================================

            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  58,
                  20,
                  28,
                ),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF18251D),
                      Color(0xFF0B0F14),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'MY PROFILE',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: _openSettings,

                          child: Container(
                            padding:
                                const EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.06),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),

                            child: const Icon(
                              Icons.settings_rounded,
                              size: 21,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 82,
                          height: 82,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                                const LinearGradient(
                              colors: [
                                green,
                                Color(0xFF39C95A),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: green.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 25,
                                spreadRadius: 2,
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Hello,',
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.55),
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                name,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color: green.withValues(
                                    alpha: 0.10,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                child: Text(
                                  fitnessLevel
                                      .toUpperCase(),

                                  style:
                                      const TextStyle(
                                    color: green,
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(
                          onTap: _editName,

                          child: Container(
                            padding:
                                const EdgeInsets.all(11),

                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon:
                                Icons
                                    .fitness_center_rounded,
                            value:
                                '$totalWorkouts',
                            label: 'WORKOUTS',
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _StatCard(
                            icon:
                                Icons
                                    .local_fire_department_rounded,
                            value: '4',
                            label: 'DAY STREAK',
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _StatCard(
                            icon:
                                Icons
                                    .directions_walk_rounded,
                            value:
                                _formatSteps(steps),
                            label: 'STEPS',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                35,
              ),

              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Current Goal
                  _SectionTitle(
                    title: 'CURRENT GOAL',
                    action: 'EDIT',
                    onTap: _editGoal,
                  ),

                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: _editGoal,

                    child: Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1D3523),
                            Color(0xFF142019),
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(24),

                        border: Border.all(
                          color: green.withValues(
                            alpha: 0.16,
                          ),
                        ),
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,

                            decoration: BoxDecoration(
                              color: green.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                17,
                              ),
                            ),

                            child: const Icon(
                              Icons.flag_rounded,
                              color: green,
                              size: 27,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  'My fitness goal',
                                  style: TextStyle(
                                    color:
                                        Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  fitnessGoal,
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons
                                .arrow_forward_ios_rounded,
                            size: 15,
                            color: Colors.white38,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Fitness Journey
                  const _SectionTitle(
                    title: 'YOUR FITNESS JOURNEY',
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _JourneyCard(
                          icon:
                              Icons
                                  .flag_outlined,
                          title: 'My Goals',
                          subtitle:
                              'Track targets',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const GoalsScreen(),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _JourneyCard(
                          icon:
                              Icons
                                  .history_rounded,
                          title: 'History',
                          subtitle:
                              'Past workouts',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const WorkoutHistoryScreen(),
                              ),
                            );

                            _loadEverything();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Personal
                  const _SectionTitle(
                    title: 'PERSONAL',
                  ),

                  const SizedBox(height: 12),

                  _ProfileTile(
                    icon:
                        Icons
                            .person_outline_rounded,
                    title:
                        'Personal Information',
                    subtitle:
                        userName.isEmpty
                            ? 'Add your name'
                            : userName,
                    onTap: _editName,
                  ),

                  _ProfileTile(
                    icon:
                        Icons
                            .speed_rounded,
                    title:
                        'Fitness Level',
                    subtitle:
                        fitnessLevel,
                    onTap:
                        _editFitnessLevel,
                  ),

                  _ProfileTile(
                    icon:
                        Icons
                            .flag_outlined,
                    title:
                        'Fitness Goal',
                    subtitle:
                        fitnessGoal,
                    onTap: _editGoal,
                  ),

                  const SizedBox(height: 18),

                  // App
                  const _SectionTitle(
                    title: 'APP',
                  ),

                  const SizedBox(height: 12),

                  _ProfileTile(
                    icon:
                        Icons
                            .notifications_none_rounded,
                    title:
                        'Notifications',
                    subtitle:
                        notificationsEnabled
                            ? 'Enabled'
                            : 'Disabled',
                    trailing:
                        notificationsEnabled
                            ? const Icon(
                                Icons
                                    .check_circle_rounded,
                                color: green,
                                size: 20,
                              )
                            : const Icon(
                                Icons
                                    .notifications_off_rounded,
                                color: Colors.white38,
                                size: 20,
                              ),
                    onTap:
                        () async {
                      final value =
                          !notificationsEnabled;

                      await StorageService
                          .saveNotifications(
                        value,
                      );

                      if (!mounted) return;

                      setState(() {
                        notificationsEnabled =
                            value;
                      });
                    },
                  ),

                  _ProfileTile(
                    icon:
                        Icons
                            .settings_outlined,
                    title:
                        'Settings',
                    subtitle:
                        'Preferences & controls',
                    onTap:
                        _openSettings,
                  ),

                  _ProfileTile(
                    icon:
                        Icons
                            .help_outline_rounded,
                    title:
                        'Help & Support',
                    subtitle:
                        'Learn how FitPulse works',
                    onTap:
                        _showHelp,
                  ),

                  _ProfileTile(
                    icon:
                        Icons
                            .info_outline_rounded,
                    title:
                        'About FitPulse',
                    subtitle:
                        'Version 1.0.0',
                    onTap:
                        _showAbout,
                  ),

                  const SizedBox(height: 25),

                  // Logout
                  GestureDetector(
                    onTap: _logout,

                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 17,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.redAccent
                            .withValues(alpha: 0.07),
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.redAccent
                              .withValues(alpha: 0.18),
                        ),
                      ),

                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color:
                                Colors.redAccent,
                            size: 20,
                          ),
                          SizedBox(width: 9),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color:
                                  Colors.redAccent,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Center(
                    child: Text(
                      'FITPULSE  •  TRAIN SMARTER',
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: 0.20),
                        fontSize: 10,
                        fontWeight:
                            FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSteps(int value) {
    if (value >= 1000) {
      final result = value / 1000;

      if (result == result.roundToDouble()) {
        return '${result.toInt()}K';
      }

      return '${result.toStringAsFixed(1)}K';
    }

    return '$value';
  }
}

// ============================================================
// SETTINGS SCREEN
// ============================================================

class SettingsScreen extends StatefulWidget {
  final bool notificationsEnabled;
  final bool workoutReminders;
  final bool vibrationEnabled;

  final Future<void> Function(bool)
      onNotificationsChanged;

  final Future<void> Function(bool)
      onRemindersChanged;

  final Future<void> Function(bool)
      onVibrationChanged;

  final Future<void> Function()
      onClearHistory;

  const SettingsScreen({
    super.key,
    required this.notificationsEnabled,
    required this.workoutReminders,
    required this.vibrationEnabled,
    required this.onNotificationsChanged,
    required this.onRemindersChanged,
    required this.onVibrationChanged,
    required this.onClearHistory,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  static const Color green =
      Color(0xFF7CFF6B);

  static const Color dark =
      Color(0xFF0B0F14);

  late bool notifications;
  late bool reminders;
  late bool vibration;

  @override
  void initState() {
    super.initState();

    notifications =
        widget.notificationsEnabled;

    reminders =
        widget.workoutReminders;

    vibration =
        widget.vibrationEnabled;
  }

  Future<void> _notifications(
    bool value,
  ) async {
    setState(() {
      notifications = value;
    });

    await widget.onNotificationsChanged(
      value,
    );
  }

  Future<void> _reminders(
    bool value,
  ) async {
    setState(() {
      reminders = value;
    });

    await widget.onRemindersChanged(
      value,
    );
  }

  Future<void> _vibration(
    bool value,
  ) async {
    setState(() {
      vibration = value;
    });

    await widget.onVibrationChanged(
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,

      appBar: AppBar(
        backgroundColor: dark,
        elevation: 0,

        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),

        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFF17251B),
                  Color(0xFF10151A),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(24),
            ),

            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,

                  decoration:
                      BoxDecoration(
                    color: green.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: const Icon(
                    Icons.tune_rounded,
                    color: green,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 15),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalize FitPulse',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Control your app experience',
                        style: TextStyle(
                          color:
                              Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const _SettingsTitle(
            title: 'NOTIFICATIONS',
          ),

          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              _SwitchTile(
                icon:
                    Icons
                        .notifications_active_outlined,
                title:
                    'Notifications',
                subtitle:
                    'Receive FitPulse notifications',
                value:
                    notifications,
                onChanged:
                    _notifications,
              ),

              _SettingsDivider(),

              _SwitchTile(
                icon:
                    Icons
                        .alarm_outlined,
                title:
                    'Workout Reminders',
                subtitle:
                    'Stay consistent with reminders',
                value:
                    reminders,
                enabled:
                    notifications,
                onChanged:
                    _reminders,
              ),
            ],
          ),

          const SizedBox(height: 25),

          const _SettingsTitle(
            title: 'EXPERIENCE',
          ),

          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              _SwitchTile(
                icon:
                    Icons
                        .vibration_rounded,
                title:
                    'Vibration',
                subtitle:
                    'Use vibration during interactions',
                value:
                    vibration,
                onChanged:
                    _vibration,
              ),
            ],
          ),

          const SizedBox(height: 25),

          const _SettingsTitle(
            title: 'DATA',
          ),

          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),

                leading:
                    _SettingsIcon(
                  icon:
                      Icons
                          .delete_outline_rounded,
                  danger: true,
                ),

                title: const Text(
                  'Clear Workout History',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                subtitle: const Text(
                  'Remove all completed workouts',
                  style: TextStyle(
                    color:
                        Colors.white38,
                    fontSize: 11,
                  ),
                ),

                trailing:
                    const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 14,
                  color:
                      Colors.white30,
                ),

                onTap:
                    widget.onClearHistory,
              ),
            ],
          ),

          const SizedBox(height: 25),

          const _SettingsTitle(
            title: 'FITPULSE',
          ),

          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),

                leading:
                    _SettingsIcon(
                  icon:
                      Icons
                          .fitness_center_rounded,
                ),

                title: const Text(
                  'FitPulse',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                subtitle: const Text(
                  'Stay strong. Stay consistent.',
                  style: TextStyle(
                    color:
                        Colors.white38,
                    fontSize: 11,
                  ),
                ),

                trailing:
                    const Text(
                  '1.0.0',
                  style: TextStyle(
                    color:
                        Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

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
      padding:
          const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 5,
      ),

      decoration: BoxDecoration(
        color: Colors.white
            .withValues(alpha: 0.045),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white
              .withValues(alpha: 0.05),
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color:
                const Color(0xFF7CFF6B),
            size: 20,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style:
                const TextStyle(
              color: Colors.white38,
              fontSize: 8,
              fontWeight:
                  FontWeight.bold,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;

  const _SectionTitle({
    required this.title,
    this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight:
                FontWeight.bold,
            letterSpacing: 1.4,
          ),
        ),

        const Spacer(),

        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'EDIT',
              style:
                  TextStyle(
                color: Color(0xFF7CFF6B),
                fontSize: 10,
                fontWeight:
                    FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// JOURNEY CARD
// ============================================================

class _JourneyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _JourneyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(17),

        decoration: BoxDecoration(
          color: const Color(0xFF171D25),
          borderRadius:
              BorderRadius.circular(21),
          border: Border.all(
            color: Colors.white
                .withValues(alpha: 0.05),
          ),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Container(
              width: 43,
              height: 43,

              decoration: BoxDecoration(
                color: const Color(
                  0x227CFF6B,
                ),
                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color:
                    const Color(
                  0xFF7CFF6B,
                ),
                size: 22,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style:
                  const TextStyle(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE TILE
// ============================================================

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 9,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF171D25),
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: ListTile(
        onTap: onTap,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),

        leading: Container(
          width: 43,
          height: 43,

          decoration: BoxDecoration(
            color: const Color(
              0x227CFF6B,
            ),
            borderRadius:
                BorderRadius.circular(13),
          ),

          child: Icon(
            icon,
            color:
                const Color(
              0xFF7CFF6B,
            ),
            size: 21,
          ),
        ),

        title: Text(
          title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
            fontSize: 13,
          ),
        ),

        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 3,
          ),
          child: Text(
            subtitle,
            style:
                const TextStyle(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
        ),

        trailing:
            trailing ??
            const Icon(
              Icons
                  .arrow_forward_ios_rounded,
              color: Colors.white24,
              size: 13,
            ),
      ),
    );
  }
}

// ============================================================
// SETTINGS TITLE
// ============================================================

class _SettingsTitle
    extends StatelessWidget {
  final String title;

  const _SettingsTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:
          const TextStyle(
        color: Colors.white54,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}

// ============================================================
// SETTINGS CARD
// ============================================================

class _SettingsCard
    extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171D25),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ============================================================
// SETTINGS ICON
// ============================================================

class _SettingsIcon
    extends StatelessWidget {
  final IconData icon;
  final bool danger;

  const _SettingsIcon({
    required this.icon,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,

      decoration: BoxDecoration(
        color: danger
            ? Colors.redAccent
                .withValues(alpha: 0.10)
            : const Color(0x227CFF6B),
        borderRadius:
            BorderRadius.circular(13),
      ),

      child: Icon(
        icon,
        color: danger
            ? Colors.redAccent
            : const Color(0xFF7CFF6B),
        size: 21,
      ),
    );
  }
}

// ============================================================
// SWITCH TILE
// ============================================================

class _SwitchTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),

      secondary:
          _SettingsIcon(
        icon: icon,
      ),

      title: Text(
        title,
        style:
            const TextStyle(
          fontWeight:
              FontWeight.w600,
          fontSize: 13,
        ),
      ),

      subtitle: Text(
        subtitle,
        style:
            const TextStyle(
          color: Colors.white38,
          fontSize: 10,
        ),
      ),

      value: value,
      activeColor:
          const Color(0xFF7CFF6B),
      onChanged:
          enabled ? onChanged : null,
    );
  }
}

// ============================================================
// DIVIDER
// ============================================================

class _SettingsDivider
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 73,
      endIndent: 16,
      color: Colors.white
          .withValues(alpha: 0.05),
    );
  }
}