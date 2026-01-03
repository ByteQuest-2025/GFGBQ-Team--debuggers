import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'learning_screen.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  int _currentStreak = 0;
  int _totalXP = 0;
  bool _todayChallengeCompleted = false;
  String _todayChallenge = 'Read 1 lesson';
  int _challengeReward = 20;

  @override
  void initState() {
    super.initState();
    _loadChallengeData();
  }

  Future<void> _loadChallengeData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastChallengeDate = prefs.getString('last_challenge_date');
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    setState(() {
      _currentStreak = prefs.getInt('current_streak') ?? 0;
      _totalXP = prefs.getInt('total_xp') ?? 0;
      _todayChallengeCompleted = lastChallengeDate == today;
    });
  }

  Future<void> _completeChallenge() async {
    if (_todayChallengeCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Challenge already completed today!'),
          backgroundColor: AppColors.pureBlack,
        ),
      );
      return;
    }

    // Navigate to relevant screen based on challenge
    if (_todayChallenge.contains('lesson')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LearningScreen()),
      ).then((_) => _claimReward());
    } else {
      _claimReward();
    }
  }

  Future<void> _claimReward() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastChallengeDate = prefs.getString('last_challenge_date');
    final yesterday = DateTime.now().subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];

    // Update streak
    int newStreak;
    if (lastChallengeDate == yesterday) {
      // Continue streak
      newStreak = (prefs.getInt('current_streak') ?? 0) + 1;
    } else if (lastChallengeDate == today) {
      // Already completed today
      return;
    } else {
      // New streak
      newStreak = 1;
    }

    // Award XP
    final currentXP = prefs.getInt('total_xp') ?? 0;
    final newXP = currentXP + _challengeReward;

    // Save data
    await prefs.setString('last_challenge_date', today);
    await prefs.setInt('current_streak', newStreak);
    await prefs.setInt('total_xp', newXP);

    // Check level up
    final currentLevel = prefs.getInt('current_level') ?? 1;
    final newLevel = newXP ~/ 1000 + 1;
    if (newLevel > currentLevel) {
      await prefs.setInt('current_level', newLevel);
    }

    if (!mounted) return;
    setState(() {
      _todayChallengeCompleted = true;
      _currentStreak = newStreak;
      _totalXP = newXP;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Challenge completed! +$_challengeReward XP'),
        backgroundColor: AppColors.pureBlack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Daily Challenge'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Challenge Card
            _buildTodayChallengeCard(),
            const SizedBox(height: 24),
            
            // Streak Section
            _buildStreakSection(),
            const SizedBox(height: 24),
            
            // Weekly Summary
            _buildWeeklySummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayChallengeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        border: Border.all(
          color: _todayChallengeCompleted
              ? AppColors.pureBlack
              : AppColors.dividerColor,
          width: _todayChallengeCompleted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Challenge",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.pureBlack,
                    ),
              ),
              if (_todayChallengeCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pureBlack,
                    borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
                  ),
                  child: Text(
                    'Completed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warmWhite,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.pureBlack,
                  borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.warmWhite,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _todayChallenge,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.pureBlack,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reward: +$_challengeReward XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.blackSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _todayChallengeCompleted ? null : _completeChallenge,
              child: Text(
                _todayChallengeCompleted ? 'Completed' : 'Complete Challenge',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        border: Border.all(color: AppColors.dividerColor),
        borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔥'),
              const SizedBox(width: 8),
              Text(
                'Current Streak',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.pureBlack,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$_currentStreak days',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.pureBlack,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentStreak == 0
                ? 'Start your streak today!'
                : _currentStreak < 7
                    ? 'Keep it going!'
                    : _currentStreak < 30
                        ? 'Great progress!'
                        : 'Amazing dedication!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.blackSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        border: Border.all(color: AppColors.dividerColor),
        borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.pureBlack,
                ),
          ),
          const SizedBox(height: 16),
          _buildSummaryItem(
            icon: Icons.check_circle,
            label: 'Challenges Completed',
            value: _todayChallengeCompleted ? '1' : '0',
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.star,
            label: 'XP Earned',
            value: '$_totalXP',
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '$_currentStreak days',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.blackSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.blackSecondary,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.pureBlack,
                fontWeight: FontWeight.w400,
              ),
        ),
      ],
    );
  }
}
