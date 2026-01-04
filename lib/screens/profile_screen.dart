import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'badge_detail_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Investor';
  String _phoneNumber = '';
  int _currentLevel = 1;
  int _totalXP = 0;
  double _totalInvested = 0.0;
  double _currentValue = 0.0;
  int _completedLessons = 0;
  int _currentStreak = 0;
  int _investmentCount = 0;
  String _joinDate = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Investor';
      _phoneNumber = prefs.getString('phone_number') ?? '';
      _currentLevel = prefs.getInt('current_level') ?? 1;
      _totalXP = prefs.getInt('total_xp') ?? 0;
      _totalInvested = prefs.getDouble('total_invested') ?? 0.0;
      _currentValue = prefs.getDouble('current_value') ?? 0.0;
      _completedLessons = prefs.getInt('completed_lessons') ?? 0;
      _currentStreak = prefs.getInt('current_streak') ?? 0;
      _investmentCount = prefs.getInt('investment_count') ?? 0;
      
      final joinDateStr = prefs.getString('join_date');
      if (joinDateStr != null) {
        _joinDate = joinDateStr;
      } else {
        _joinDate = DateTime.now().toString().split(' ')[0];
        prefs.setString('join_date', _joinDate);
      }
    });
  }

  String _getLevelName(int level) {
    if (level == 1) return 'Beginner';
    if (level == 2) return 'Learner';
    if (level == 3) return 'Investor';
    return 'Pro';
  }

  List<Map<String, dynamic>> _getBadges() {
    final badges = <Map<String, dynamic>>[];
    
    // First Lesson badge
    if (_completedLessons >= 1) {
      badges.add({
        'id': 'first_lesson',
        'name': 'First Steps',
        'description': 'Completed your first lesson',
        'icon': Icons.school,
        'earned': true,
      });
    } else {
      badges.add({
        'id': 'first_lesson',
        'name': 'First Steps',
        'description': 'Complete 1 lesson to earn',
        'icon': Icons.school,
        'earned': false,
      });
    }
    
    // Knowledge Seeker badge
    if (_completedLessons >= 5) {
      badges.add({
        'id': 'knowledge_seeker',
        'name': 'Knowledge Seeker',
        'description': 'Completed 5 lessons',
        'icon': Icons.menu_book,
        'earned': true,
      });
    } else {
      badges.add({
        'id': 'knowledge_seeker',
        'name': 'Knowledge Seeker',
        'description': 'Complete 5 lessons to earn',
        'icon': Icons.menu_book,
        'earned': false,
      });
    }
    
    // First Investment badge
    if (_totalInvested > 0) {
      badges.add({
        'id': 'first_investment',
        'name': 'First Investment',
        'description': 'Made your first investment',
        'icon': Icons.account_balance_wallet,
        'earned': true,
      });
    } else {
      badges.add({
        'id': 'first_investment',
        'name': 'First Investment',
        'description': 'Make your first investment',
        'icon': Icons.account_balance_wallet,
        'earned': false,
      });
    }
    
    // Regular Investor badge
    if (_investmentCount >= 10) {
      badges.add({
        'id': 'regular_investor',
        'name': 'Regular Investor',
        'description': 'Made 10 investments',
        'icon': Icons.trending_up,
        'earned': true,
      });
    } else {
      badges.add({
        'id': 'regular_investor',
        'name': 'Regular Investor',
        'description': 'Make 10 investments to earn',
        'icon': Icons.trending_up,
        'earned': false,
      });
    }
    
    // Streak badges
    if (_currentStreak >= 7) {
      badges.add({
        'id': 'weekly_warrior',
        'name': 'Weekly Warrior',
        'description': '7 day streak',
        'icon': Icons.local_fire_department,
        'earned': true,
      });
    } else {
      badges.add({
        'id': 'weekly_warrior',
        'name': 'Weekly Warrior',
        'description': 'Maintain 7 day streak',
        'icon': Icons.local_fire_department,
        'earned': false,
      });
    }
    
    if (_currentStreak >= 30) {
      badges.add({
        'id': 'monthly_master',
        'name': 'Monthly Master',
        'description': '30 day streak',
        'icon': Icons.emoji_events,
        'earned': true,
      });
    } else {
      badges.add({
        'id': 'monthly_master',
        'name': 'Monthly Master',
        'description': 'Maintain 30 day streak',
        'icon': Icons.emoji_events,
        'earned': false,
      });
    }
    
    return badges;
  }

  @override
  Widget build(BuildContext context) {
    final badges = _getBadges();
    final earnedBadges = badges.where((b) => b['earned'] == true).length;
    final returns = _currentValue - _totalInvested;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(),
              const SizedBox(height: 24),
              
              // Achievements Section
              _buildAchievementsSection(badges, earnedBadges),
              const SizedBox(height: 24),
              
              // Investment Stats
              _buildInvestmentStats(returns),
              const SizedBox(height: 24),
              
              // Learning Stats
              _buildLearningStats(),
              const SizedBox(height: 24),
              
              // Settings Section
              _buildSettingsSection(),
              const SizedBox(height: 24),
              
              // Help Section
              _buildHelpSection(),
              const SizedBox(height: 24),
              
              // Logout Button
              _buildLogoutButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.pureBlack,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'I',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.warmWhite,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.pureBlack,
                          ),
                    ),
                    if (_phoneNumber.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+91 $_phoneNumber',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.blackSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.dividerColor),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Level $_currentLevel',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                  Text(
                    _getLevelName(_currentLevel),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.dividerColor,
              ),
              Column(
                children: [
                  Text(
                    '$_totalXP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                  Text(
                    'XP',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.dividerColor,
              ),
              Column(
                children: [
                  Text(
                    _joinDate.split('-')[0],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                  Text(
                    'Joined',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(
      List<Map<String, dynamic>> badges, int earnedCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.pureBlack,
                  ),
            ),
            Text(
              '$earnedCount/${badges.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.blackSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final isEarned = badge['earned'] == true;
            
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BadgeDetailScreen(badge: badge),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isEarned
                      ? AppColors.pureBlack
                      : AppColors.warmWhite,
                  border: Border.all(
                    color: isEarned
                        ? AppColors.pureBlack
                        : AppColors.dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      badge['icon'] as IconData,
                      color: isEarned
                          ? AppColors.warmWhite
                          : AppColors.blackSecondary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge['name'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isEarned
                                ? AppColors.warmWhite
                                : AppColors.blackSecondary,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInvestmentStats(double returns) {
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
            'Investment Stats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.pureBlack,
                ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            icon: Icons.account_balance_wallet,
            label: 'Total Invested',
            value: '₹${_totalInvested.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.trending_up,
            label: 'Total Returns',
            value: '${returns >= 0 ? '+' : ''}₹${returns.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.repeat,
            label: 'Investments',
            value: '$_investmentCount',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.local_fire_department,
            label: 'Longest Streak',
            value: '$_currentStreak days',
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStats() {
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
            'Learning Stats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.pureBlack,
                ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            icon: Icons.school,
            label: 'Lessons Completed',
            value: '$_completedLessons',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.quiz,
            label: 'Quizzes Passed',
            value: '${(_completedLessons / 5).floor()}',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.local_fire_department,
            label: 'Current Streak',
            value: '$_currentStreak days',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.star,
            label: 'Total XP',
            value: '$_totalXP',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
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

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.pureBlack,
              ),
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.settings,
          title: 'App Settings',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Help & Support',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.pureBlack,
              ),
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.help_outline,
          title: 'Help & FAQ',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpScreen()),
            );
          },
        ),
        _buildSettingsTile(
          icon: Icons.info_outline,
          title: 'About App',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.warmWhite,
                title: const Text('About Micro Invest'),
                content: const Text(
                  'Version 1.0.0\n\nA simple, transparent micro-investment platform for first-time users. Start investing with as low as ₹10.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          border: Border.all(color: AppColors.dividerColor),
          borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.pureBlack),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.pureBlack,
                    ),
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.pureBlack),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Logout'),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              await prefs.remove('phone_number');
              
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
