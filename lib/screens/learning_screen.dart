import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'lesson_view_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int _totalXP = 0;
  int _currentLevel = 1;
  int _completedLessons = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalXP = prefs.getInt('total_xp') ?? 0;
      _currentLevel = prefs.getInt('current_level') ?? 1;
      _completedLessons = prefs.getInt('completed_lessons') ?? 0;
    });
  }

  String _getLevelName(int level) {
    if (level == 1) return 'Beginner';
    if (level == 2) return 'Learner';
    if (level == 3) return 'Investor';
    return 'Pro';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Learning'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Header
            _buildProgressHeader(),
            const SizedBox(height: 24),
            
            // Module List
            Text(
              'Modules',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.pureBlack,
                  ),
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              moduleNumber: 1,
              title: 'What is Money?',
              description: 'Learn the basics of money and how it works',
              lessonsCount: 5,
              completedLessons: _completedLessons >= 5 ? 5 : (_completedLessons > 0 ? _completedLessons : 0),
              isLocked: false,
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              moduleNumber: 2,
              title: 'Saving vs Investing',
              description: 'Understand the difference and why investing matters',
              lessonsCount: 5,
              completedLessons: 0,
              isLocked: _completedLessons < 5,
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              moduleNumber: 3,
              title: 'Safe Investments for Beginners',
              description: 'Learn about low-risk investment options',
              lessonsCount: 5,
              completedLessons: 0,
              isLocked: _completedLessons < 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level $_currentLevel: ${_getLevelName(_currentLevel)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_totalXP XP',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pureBlack,
                  borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
                ),
                child: Text(
                  'L$_currentLevel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warmWhite,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Progress: $_completedLessons lessons completed',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.blackSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required int moduleNumber,
    required String title,
    required String description,
    required int lessonsCount,
    required int completedLessons,
    required bool isLocked,
  }) {
    final progress = lessonsCount > 0 ? (completedLessons / lessonsCount) : 0.0;
    final isCompleted = completedLessons >= lessonsCount;

    return InkWell(
      onTap: isLocked
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonViewScreen(
                    moduleNumber: moduleNumber,
                    moduleTitle: title,
                    totalLessons: lessonsCount,
                    completedLessons: completedLessons,
                  ),
                ),
              ).then((_) {
                _loadProgress();
                if (mounted) {
                  setState(() {});
                }
              });
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          border: Border.all(
            color: isLocked ? AppColors.dividerColor : AppColors.pureBlack,
          ),
          borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? AppColors.dividerColor
                        : AppColors.pureBlack,
                    borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
                  ),
                  child: Center(
                    child: isLocked
                        ? const Icon(
                            Icons.lock,
                            color: AppColors.blackSecondary,
                            size: 20,
                          )
                        : isCompleted
                            ? const Icon(
                                Icons.check,
                                color: AppColors.warmWhite,
                                size: 20,
                              )
                            : Text(
                                '$moduleNumber',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.warmWhite,
                                    ),
                              ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isLocked
                                  ? AppColors.blackSecondary
                                  : AppColors.pureBlack,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.blackSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isLocked) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedLessons/$lessonsCount lessons',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: AppColors.dividerColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.pureBlack,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Complete previous modules to unlock',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.blackSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
