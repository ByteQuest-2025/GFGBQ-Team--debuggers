import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/learning_model.dart';
import 'lesson_view_screen.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.user;
        final currentStreak = user?.currentStreak ?? 0;
        final totalXP = user?.totalXP ?? 0;
        final completedLessons = appState.totalCompletedLessons;
        final totalLessons = appState.totalLessons;

        return Scaffold(
          backgroundColor: AppColors.warmWhite,
          appBar: AppBar(title: const Text('Daily Challenge')),
          body: RefreshIndicator(
            onRefresh: () => appState.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTodayChallengeCard(appState, completedLessons, totalLessons),
                  const SizedBox(height: 24),
                  _buildStreakSection(currentStreak),
                  const SizedBox(height: 24),
                  _buildProgressSection(totalXP, completedLessons, totalLessons),
                  const SizedBox(height: 24),
                  _buildWeeklyChallenges(appState),
                  const SizedBox(height: 24),
                  _buildRewardsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayChallengeCard(AppState appState, int completedLessons, int totalLessons) {
    // Determine today's challenge based on progress
    String challengeTitle;
    String challengeDescription;
    int xpReward;
    bool isCompleted = false;
    VoidCallback? onComplete;

    if (completedLessons == 0) {
      challengeTitle = 'Start Your Journey';
      challengeDescription = 'Complete your first lesson';
      xpReward = 50;
      onComplete = () => _navigateToLearn(appState);
    } else if (completedLessons < 5) {
      challengeTitle = 'Keep Learning';
      challengeDescription = 'Complete 1 more lesson today';
      xpReward = 30;
      onComplete = () => _navigateToLearn(appState);
    } else if (appState.investments.isEmpty) {
      challengeTitle = 'Make Your First Investment';
      challengeDescription = 'Invest as little as ₹10';
      xpReward = 100;
      onComplete = () => _navigateToInvest();
    } else {
      challengeTitle = 'Daily Check-in';
      challengeDescription = 'Review your portfolio';
      xpReward = 20;
      isCompleted = true;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isCompleted ? AppColors.successGradient : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: (isCompleted ? AppColors.success : AppColors.primary).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Challenge",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCompleted ? Icons.emoji_events_rounded : Icons.flag_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challengeTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challengeDescription,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '+$xpReward XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompleted && onComplete != null)
                ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Start'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(int currentStreak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak Day Streak',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentStreak == 0
                      ? 'Start your streak today!'
                      : currentStreak < 7
                          ? 'Keep it going! 🎯'
                          : currentStreak < 30
                              ? 'Great progress! 💪'
                              : 'Amazing dedication! 🏆',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(int totalXP, int completedLessons, int totalLessons) {
    final level = (totalXP ~/ 1000) + 1;
    final xpInLevel = totalXP % 1000;
    final progressToNextLevel = xpInLevel / 1000;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Progress', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.star_rounded,
                  label: 'Total XP',
                  value: '$totalXP',
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.school_rounded,
                  label: 'Lessons',
                  value: '$completedLessons/$totalLessons',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Level',
                  value: '$level',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Level $level Progress',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressToNextLevel,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$xpInLevel / 1000 XP to Level ${level + 1}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildWeeklyChallenges(AppState appState) {
    final challenges = [
      {'title': 'Complete 3 lessons', 'xp': 100, 'progress': appState.totalCompletedLessons, 'target': 3},
      {'title': 'Make 2 investments', 'xp': 150, 'progress': appState.investments.length, 'target': 2},
      {'title': 'Create a goal', 'xp': 50, 'progress': appState.goals.length, 'target': 1},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weekly Challenges', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ...challenges.map((challenge) {
          final progress = (challenge['progress'] as int);
          final target = (challenge['target'] as int);
          final isCompleted = progress >= target;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.successLight : AppColors.cardBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: isCompleted ? AppColors.success : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : Icons.flag_rounded,
                    color: isCompleted ? Colors.white : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge['title'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: (progress / target).clamp(0.0, 1.0),
                                minHeight: 4,
                                backgroundColor: AppColors.divider,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCompleted ? AppColors.success : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$progress/$target',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success.withOpacity(0.2) : AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${challenge['xp']} XP',
                    style: TextStyle(
                      color: isCompleted ? AppColors.success : AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRewardsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Streak Rewards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Maintain a 7-day streak to earn bonus XP!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLearn(AppState appState) {
    // Find the next incomplete module
    for (final module in LearningData.modules) {
      if (!appState.isModuleUnlocked(module.id)) continue;
      final completed = appState.getModuleCompletedLessons(module.id);
      if (completed < module.lessons.length) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonViewScreen(
              module: module,
              startLessonIndex: completed,
            ),
          ),
        );
        return;
      }
    }
    // If all completed, go to first module
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonViewScreen(
          module: LearningData.modules.first,
          startLessonIndex: 0,
        ),
      ),
    );
  }

  void _navigateToInvest() {
    Navigator.pop(context);
    // The parent will handle navigation to invest tab
  }
}
