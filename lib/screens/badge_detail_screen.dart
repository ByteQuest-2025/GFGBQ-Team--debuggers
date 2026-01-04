import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class BadgeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> badge;

  const BadgeDetailScreen({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final isEarned = badge['earned'] == true;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Badge Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isEarned
                      ? AppColors.pureBlack
                      : AppColors.dividerColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badge['icon'] as IconData,
                  color: isEarned
                      ? AppColors.warmWhite
                      : AppColors.blackSecondary,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                badge['name'] as String,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.pureBlack,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                badge['description'] as String,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.blackSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (isEarned)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pureBlack,
                    borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
                  ),
                  child: Text(
                    'Earned',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.warmWhite,
                        ),
                  ),
                )
              else
                Text(
                  'Not Earned Yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.blackSecondary,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

