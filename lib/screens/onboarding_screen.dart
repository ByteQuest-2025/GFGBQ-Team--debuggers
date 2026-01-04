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
      title: 'Sirf ₹10 se shuru karein',
      titleEn: 'Start with just ₹10',
      description: 'Koi bhi invest kar sakta hai, badi rakam ki zarurat nahi',
      descriptionEn: 'Anyone can invest, no need for large amounts',
      emoji: '💰',
      color: AppColors.primary,
      comparison: true,
    ),
    OnboardingSlide(
      title: '100% Safe & Secure',
      titleEn: 'Your money is protected',
      description: 'Aapka paisa bank jitna surakshit, lekin zyada badhta hai',
      descriptionEn: 'As safe as a bank, but grows more',
      emoji: '🛡️',
      color: AppColors.success,
      showTrustBadges: true,
    ),
    OnboardingSlide(
      title: 'Learn as You Invest',
      titleEn: 'Sikhte raho, badhte raho',
      description: 'Hum aapko sab sikhayenge, koi mushkil shabd nahi',
      descriptionEn: "We'll teach you everything, no jargon",
      emoji: '📚',
      color: AppColors.info,
      showBadges: true,
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
            // Top bar with skip and language
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          'EN',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
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
            
            // Bottom section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
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
                  SizedBox(
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
                        _currentPage < _slides.length - 1 
                            ? 'Next' 
                            : 'Start My Journey',
                      ),
                    ),
                  ),
                  
                  if (_currentPage == _slides.length - 1) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Guest mode - limited features
                        _completeOnboarding();
                      },
                      child: const Text('Explore without signup'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji/Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: slide.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Text(
                slide.emoji,
                style: const TextStyle(fontSize: 56),
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            slide.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            slide.titleEn,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Description
          Text(
            slide.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Special content based on slide
          if (slide.comparison) _buildComparisonCard(),
          if (slide.showTrustBadges) _buildTrustBadges(),
          if (slide.showBadges) _buildAchievementBadges(),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.account_balance_rounded, color: AppColors.textSecondary),
                const SizedBox(height: 8),
                Text(
                  'Bank Savings',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹3,650/year',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: AppColors.divider,
          ),
          Expanded(
            child: Column(
              children: [
                Icon(Icons.trending_up_rounded, color: AppColors.success),
                const SizedBox(height: 8),
                Text(
                  'InvestSathi',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹3,875/year',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '+₹225 extra',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadges() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTrustItem(Icons.verified_user_rounded, 'SEBI\nRegistered'),
            const SizedBox(width: 24),
            _buildTrustItem(Icons.lock_rounded, 'Bank-Grade\nSecurity'),
            const SizedBox(width: 24),
            _buildTrustItem(Icons.shield_rounded, 'Encrypted\nData'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('SBI', style: Theme.of(context).textTheme.labelMedium),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('HDFC', style: Theme.of(context).textTheme.labelMedium),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('ICICI', style: Theme.of(context).textTheme.labelMedium),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrustItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.success, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAchievementBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBadge('🎯', 'First ₹10', AppColors.bronze),
        const SizedBox(width: 16),
        _buildBadge('📚', 'Samjhe SIP', AppColors.silver),
        const SizedBox(width: 16),
        _buildBadge('💰', '₹100 Kamaya', AppColors.gold),
      ],
    );
  }

  Widget _buildBadge(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.divider,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final String emoji;
  final Color color;
  final bool comparison;
  final bool showTrustBadges;
  final bool showBadges;

  OnboardingSlide({
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.emoji,
    required this.color,
    this.comparison = false,
    this.showTrustBadges = false,
    this.showBadges = false,
  });
}
