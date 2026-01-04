import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';
import '../../services/language_service.dart';
import '../../l10n/app_strings.dart';
import '../login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _getLevelName(int level) {
    switch (level) {
      case 1: return 'Beginner';
      case 2: return 'Learner';
      case 3: return 'Investor';
      default: return 'Pro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.user;
        final userName = user?.name ?? 'Investor';
        final phoneNumber = user?.phoneNumber ?? '';
        final totalInvested = appState.totalInvested;
        final currentValue = appState.currentValue;
        final totalXP = user?.totalXP ?? 0;
        final currentLevel = user?.currentLevel ?? 1;
        final completedLessons = appState.totalCompletedLessons;
        final earnedBadges = appState.earnedBadgesCount;
        final currentStreak = user?.currentStreak ?? 0;
        
        final lang = context.watch<LanguageService>();
        final s = (String key) => lang.str(AppStrings.profile, key);

        return Scaffold(
          backgroundColor: AppColors.warmWhite,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppColors.warmWhite,
                  title: Text(s('profile')),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => _showSettings(),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProfileHeader(userName, phoneNumber, currentLevel),
                      const SizedBox(height: 24),
                      _buildQuickStats(totalInvested, currentValue, totalXP, lang),
                      const SizedBox(height: 24),
                      _buildAchievementsSection(appState, lang),
                      const SizedBox(height: 24),
                      _buildSection(s('account'), [
                        _buildMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: s('personalDetails'),
                          subtitle: 'Name, DOB, Gender',
                          onTap: () => _showEditNameDialog(appState),
                        ),
                        _buildMenuItem(
                          icon: Icons.verified_user_outlined,
                          title: s('kycStatus'),
                          subtitle: user?.kycCompleted == true ? '${s('verified')} ✓' : 'Not verified',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user?.kycCompleted == true ? AppColors.successLight : AppColors.warningLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user?.kycCompleted == true ? s('verified') : s('pending'),
                              style: TextStyle(
                                color: user?.kycCompleted == true ? AppColors.success : AppColors.warning,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.account_balance_outlined,
                          title: s('bankAccounts'),
                          subtitle: '1 bank linked',
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(s('investmentSettings'), [
                        _buildMenuItem(
                          icon: Icons.repeat_rounded,
                          title: s('autoInvest'),
                          subtitle: 'No active SIPs',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.flag_outlined,
                          title: s('myGoals'),
                          subtitle: '${appState.activeGoals.length} ${s('activeGoals')}',
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(s('appSettings'), [
                        _buildMenuItem(
                          icon: Icons.language_rounded,
                          title: s('language'),
                          subtitle: lang.languageName,
                          onTap: () => _showLanguageSheet(),
                        ),
                        _buildMenuItem(
                          icon: Icons.volume_up_rounded,
                          title: s('voiceReadAloud'),
                          subtitle: lang.voiceEnabled ? s('enabled') : s('disabled'),
                          trailing: Switch(
                            value: lang.voiceEnabled,
                            onChanged: (val) => context.read<LanguageService>().setVoiceEnabled(val),
                            activeColor: AppColors.primary,
                          ),
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          title: s('notifications'),
                          subtitle: 'All enabled',
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection(s('support'), [
                        _buildMenuItem(
                          icon: Icons.help_outline_rounded,
                          title: s('helpFaq'),
                          subtitle: 'Common questions',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: s('contactUs'),
                          subtitle: 'WhatsApp, Email, Call',
                          onTap: () => _showContactSheet(),
                        ),
                        _buildMenuItem(
                          icon: Icons.share_outlined,
                          title: s('shareWithFriends'),
                          subtitle: 'Earn ₹50 bonus',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentGradient.colors.first.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '₹50',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          onTap: () => _showReferralSheet(phoneNumber),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('About', [
                        _buildMenuItem(
                          icon: Icons.info_outline_rounded,
                          title: 'App Version',
                          subtitle: 'v1.0.0',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.article_outlined,
                          title: 'Terms & Conditions',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildLogoutButton(appState),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(String userName, String phoneNumber, int currentLevel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'I',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
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
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phoneNumber.isNotEmpty ? '+91 $phoneNumber' : 'Phone not set',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Level $currentLevel: ${_getLevelName(currentLevel)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  Widget _buildQuickStats(double totalInvested, double currentValue, int totalXP, LanguageService lang) {
    final returns = currentValue - totalInvested;
    final s = (String key) => lang.str(AppStrings.profile, key);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.account_balance_wallet_rounded,
            label: s('invested'),
            value: '₹${totalInvested.toStringAsFixed(0)}',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up_rounded,
            label: s('returns'),
            value: '${returns >= 0 ? '+' : ''}₹${returns.toStringAsFixed(0)}',
            color: returns >= 0 ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.school_rounded,
            label: 'XP',
            value: '$totalXP',
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(AppState appState, LanguageService lang) {
    final badges = appState.getAllBadges();
    final earnedBadges = badges.where((b) => b.earned).toList();
    final s = (String key) => lang.str(AppStrings.profile, key);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s('achievements'), style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${earnedBadges.length}/${badges.length} badges',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: badges.take(6).map((badge) {
              final badgeName = lang.currentLanguage != AppLanguage.english ? badge.nameHindi : badge.name;
              return Container(
                width: 60,
                height: 70,
                decoration: BoxDecoration(
                  color: badge.earned ? AppColors.gold.withOpacity(0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: badge.earned ? AppColors.gold : AppColors.divider,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      badge.emoji,
                      style: TextStyle(
                        fontSize: 24,
                        color: badge.earned ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badgeName.split(' ').first,
                      style: TextStyle(
                        fontSize: 9,
                        color: badge.earned ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AppState appState) {
    return OutlinedButton(
      onPressed: () => _showLogoutConfirmation(appState),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded),
          SizedBox(width: 8),
          Text('Logout'),
        ],
      ),
    );
  }

  void _showSettings() {}

  void _showEditNameDialog(AppState appState) {
    final controller = TextEditingController(text: appState.user?.name ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'Enter your name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await appState.updateUserName(controller.text.trim());
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet() {
    final langService = context.read<LanguageService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Select Language', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildLanguageChip('English', AppLanguage.english, langService),
                _buildLanguageChip('हिंदी', AppLanguage.hindi, langService),
                _buildLanguageChip('मराठी', AppLanguage.marathi, langService),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String language, AppLanguage lang, LanguageService langService) {
    final isSelected = langService.currentLanguage == lang;
    return InkWell(
      onTap: () async {
        await langService.setLanguage(lang);
        if (mounted) Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          language,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _showContactSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Contact Us', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            _buildContactOption(
              icon: Icons.chat_rounded,
              title: 'WhatsApp',
              subtitle: 'Fastest response',
              color: const Color(0xFF25D366),
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: 'support@investsathi.com',
              color: AppColors.info,
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              icon: Icons.phone_outlined,
              title: 'Call',
              subtitle: '1800-XXX-XXXX (Toll-free)',
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: color),
          ],
        ),
      ),
    );
  }

  void _showReferralSheet(String phoneNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('🎁', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Invite Friends, Earn ₹50', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Both you and your friend get ₹50 bonus investment',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Your Code: ', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    'INV${phoneNumber.length >= 4 ? phoneNumber.substring(0, 4) : '0000'}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.share_rounded),
              label: const Text('Share Now'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await appState.logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
