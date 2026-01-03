import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'learning_screen.dart';
import 'investment_screen.dart';
import 'profile_screen.dart';
import 'challenge_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Investor';
  double _totalInvested = 0.0;
  double _currentValue = 0.0;
  int _currentStreak = 0;
  int _currentLevel = 1;
  int _totalXP = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Investor';
      _totalInvested = prefs.getDouble('total_invested') ?? 0.0;
      _currentValue = prefs.getDouble('current_value') ?? 0.0;
      _currentStreak = prefs.getInt('current_streak') ?? 0;
      _currentLevel = prefs.getInt('current_level') ?? 1;
      _totalXP = prefs.getInt('total_xp') ?? 0;
    });
  }

  double _getReturns() {
    return _currentValue - _totalInvested;
  }

  double _getReturnsPercentage() {
    if (_totalInvested == 0) return 0.0;
    return ((_currentValue - _totalInvested) / _totalInvested) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final returns = _getReturns();
    final returnsPercentage = _getReturnsPercentage();

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Micro Invest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              _buildGreetingSection(),
              const SizedBox(height: 24),
              
              // Level and XP Section
              _buildLevelSection(),
              const SizedBox(height: 24),
              
              // Portfolio Summary
              _buildPortfolioSummary(returns, returnsPercentage),
              const SizedBox(height: 24),
              
              // Quick Action Cards
              _buildQuickActions(),
              const SizedBox(height: 24),
              
              // Daily Challenge Card
              _buildDailyChallengeCard(),
              const SizedBox(height: 24),
              
              // Recent Activity
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.blackSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          _userName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.pureBlack,
                fontWeight: FontWeight.w400,
              ),
        ),
      ],
    );
  }

  Widget _buildLevelSection() {
    // Calculate XP needed for next level (simplified: 1000 XP per level)
    final xpForNextLevel = _currentLevel * 1000;
    final xpProgress = _totalXP % 1000;
    final progressPercentage = xpForNextLevel > 0 ? (xpProgress / 1000) : 0.0;

    String levelName;
    if (_currentLevel == 1) {
      levelName = 'Beginner';
    } else if (_currentLevel == 2) {
      levelName = 'Learner';
    } else if (_currentLevel == 3) {
      levelName = 'Investor';
    } else {
      levelName = 'Pro';
    }

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
                    'Level $_currentLevel: $levelName',
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
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress to Level ${_currentLevel + 1}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                  Text(
                    '${(progressPercentage * 100).toStringAsFixed(0)}%',
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
                  value: progressPercentage,
                  minHeight: 8,
                  backgroundColor: AppColors.dividerColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pureBlack),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$xpProgress / 1000 XP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.blackSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary(double returns, double returnsPercentage) {
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
            'Portfolio',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.pureBlack,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Invested',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_totalInvested.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Current Value',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_currentValue.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                ],
              ),
            ],
          ),
          if (_totalInvested > 0) ...[
            const SizedBox(height: 16),
            Divider(color: AppColors.dividerColor),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Returns',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.pureBlack,
                      ),
                ),
                Text(
                  '${returns >= 0 ? '+' : ''}₹${returns.toStringAsFixed(0)} (${returnsPercentage >= 0 ? '+' : ''}${returnsPercentage.toStringAsFixed(1)}%)',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: returns >= 0 ? AppColors.pureBlack : AppColors.pureBlack,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.pureBlack,
              ),
        ),
        const SizedBox(height: 12),
        // Start Learning Card
        _buildActionCard(
          icon: Icons.school,
          title: 'Start Learning',
          subtitle: 'Module 1 of 5',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LearningScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        // Invest Now Card
        _buildActionCard(
          icon: Icons.account_balance_wallet,
          title: 'Invest Now',
          subtitle: 'Start with ₹10',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InvestmentScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          border: Border.all(color: AppColors.dividerColor),
          borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.pureBlack,
                borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
              ),
              child: Icon(
                icon,
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
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.blackSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengeCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChallengeScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          border: Border.all(color: AppColors.dividerColor),
          borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
        ),
        child: Row(
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
                    'Daily Challenge',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (_currentStreak > 0) ...[
                        const Text('🔥'),
                        const SizedBox(width: 4),
                        Text(
                          '$_currentStreak day streak',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.blackSecondary,
                              ),
                        ),
                      ] else
                        Text(
                          'Read 1 lesson today',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.blackSecondary,
                              ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.blackSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.pureBlack,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full activity screen (to be implemented)
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_totalInvested == 0 && _totalXP == 0)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.warmWhite,
              border: Border.all(color: AppColors.dividerColor),
              borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
            ),
            child: Center(
              child: Text(
                'No activity yet. Start learning or investing!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.blackSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warmWhite,
              border: Border.all(color: AppColors.dividerColor),
              borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
            ),
            child: Column(
              children: [
                if (_totalInvested > 0)
                  _buildActivityItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Invested ₹${_totalInvested.toStringAsFixed(0)}',
                    subtitle: 'Portfolio updated',
                    time: 'Today',
                  ),
                if (_totalXP > 0) ...[
                  if (_totalInvested > 0) const SizedBox(height: 12),
                  _buildActivityItem(
                    icon: Icons.school,
                    title: 'Earned $_totalXP XP',
                    subtitle: 'Level $_currentLevel',
                    time: 'This week',
                  ),
                ],
                if (_currentStreak > 0) ...[
                  if (_totalInvested > 0 || _totalXP > 0) const SizedBox(height: 12),
                  _buildActivityItem(
                    icon: Icons.local_fire_department,
                    title: '$_currentStreak day streak',
                    subtitle: 'Keep it going!',
                    time: 'Active',
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? time,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.pureBlack.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.pureBlack,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.pureBlack,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.blackSecondary,
                    ),
              ),
            ],
          ),
        ),
        if (time != null)
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.blackSecondary,
                ),
          ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LearningScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InvestmentScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Invest',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
