import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Micro Invest'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Micro Invest!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.pureBlack,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Home screen coming soon...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.blackSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

