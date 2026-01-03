import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for 2-3 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    
    // Check if user has seen onboarding
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    
    // Check if user is logged in
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final phoneNumber = prefs.getString('phone_number');

    if (!hasSeenOnboarding) {
      // First time user - show onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else if (isLoggedIn && phoneNumber != null) {
      // User is logged in - go to home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // User has seen onboarding but not logged in - show login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon (using a simple icon for now)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.pureBlack,
                borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: AppColors.warmWhite,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            Text(
              'Micro Invest',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.pureBlack,
                  ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'Investing for Everyone',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.blackSecondary,
                  ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.pureBlack),
              ),
            ),
            const SizedBox(height: 32),
            // Version number
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.blackSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

