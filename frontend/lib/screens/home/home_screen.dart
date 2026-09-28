import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/calories_card.dart';
import '../../widgets/fitflow_bottom_navigation.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/streak_card.dart';
import '../../widgets/todays_workout_card.dart';
import '../../widgets/welcome_card.dart';
import '../nutrition/nutrition_screen.dart';
import '../progress/progress_screen.dart';
import '../workout/ai_workout_planner_screen.dart';

/// Static placeholder data until real user data is wired up.
const String _userName = 'Shan';
const String _greeting = 'Good Morning,';
const String _workoutName = 'Full Body';
const String _workoutDuration = '20 min';
const double _weeklyProgress = 0.75;
const int _caloriesLeft = 1800;
const int _streakDays = 5;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = FitFlowDestination.home.index;

  void _onDestinationSelected(int index) {
    // Plan, Progress and Nutrition have screens; remaining tabs only update
    // selection.
    if (index == FitFlowDestination.plan.index) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AiWorkoutPlannerScreen()),
      );
      return;
    }
    if (index == FitFlowDestination.progress.index) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProgressScreen()),
      );
      return;
    }
    if (index == FitFlowDestination.nutrition.index) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NutritionScreen()),
      );
      return;
    }
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _HomeAppBar(),
      bottomNavigationBar: FitFlowBottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Greeting(greeting: _greeting, name: _userName),
              const SizedBox(height: AppSpacing.lg),
              WelcomeCard(quote: MotivationalQuote.ofToday()),
              const SizedBox(height: AppSpacing.lg),
              TodaysWorkoutCard(
                workoutName: _workoutName,
                duration: _workoutDuration,
                onStartWorkout: () =>
                    _showMessage("Starting today's workout..."),
              ),
              const SizedBox(height: AppSpacing.lg),
              // IntrinsicHeight keeps both statistic cards exactly the same
              // height without hardcoding one.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Expanded(child: ProgressCard(progress: _weeklyProgress)),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(child: CaloriesCard(caloriesLeft: _caloriesLeft)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              StreakCard(
                streakDays: _streakDays,
                onTap: () => _showMessage('Opening your streak details...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        tooltip: 'Menu',
        onPressed: () {},
      ),
      title: const Text('FitFlow'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: GestureDetector(
            onTap: () {},
            child: const _ProfileAvatar(initials: 'S'),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Profile',
      button: true,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.greeting, required this.name});

  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$greeting '),
          TextSpan(text: '$name!', style: textTheme.headlineSmall),
        ],
      ),
      style: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
