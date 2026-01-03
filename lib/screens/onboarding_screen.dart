import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Start Small',
      description: 'Start investing with just ₹10',
      subtext: 'No need for large amounts',
      icon: Icons.account_balance_wallet,
    ),
    OnboardingSlide(
      title: 'Learn & Earn',
      description: 'Learn about investing as you go',
      subtext: 'Simple lessons, no jargon',
      icon: Icons.school,
    ),
    OnboardingSlide(
      title: 'Safe & Secure',
      description: 'Your money is safe with us',
      subtext: 'Transparent, no hidden charges',
      icon: Icons.security,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top right)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.blackSecondary,
                      ),
                ),
              ),
            ),
            
            // Page view with slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index]);
                },
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => _buildPageIndicator(index == _currentPage),
              ),
            ),
            const SizedBox(height: 32),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  child: Text(
                    _currentPage < _slides.length - 1 ? 'Next' : 'Get Started',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.pureBlack,
              borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
            ),
            child: Icon(
              slide.icon,
              color: AppColors.warmWhite,
              size: 60,
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            slide.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.pureBlack,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Description
          Text(
            slide.description,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.pureBlack,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Subtext
          Text(
            slide.subtext,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.blackSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.pureBlack : AppColors.dividerColor,
        borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final String subtext;
  final IconData icon;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.subtext,
    required this.icon,
  });
}

