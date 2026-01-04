import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class DailyNudgeCard extends StatelessWidget {
  final int completedLessons;
  final int totalLessons;
  final VoidCallback onStartLearning;

  const DailyNudgeCard({
    super.key,
    required this.completedLessons,
    required this.totalLessons,
    required this.onStartLearning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.info,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learn Something New',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedLessons of $totalLessons lessons completed',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: totalLessons > 0 ? completedLessons / totalLessons : 0,
                    minHeight: 4,
                    backgroundColor: AppColors.info.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.info),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onStartLearning,
            icon: const Icon(Icons.arrow_forward_rounded),
            color: AppColors.info,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
