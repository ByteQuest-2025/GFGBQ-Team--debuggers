import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';
import '../../services/language_service.dart';
import '../../models/goal_model.dart';
import '../../models/learning_model.dart';
import '../widgets/portfolio_card.dart';
import '../widgets/investment_pack_card.dart';
import '../widgets/goal_card.dart';
import '../widgets/daily_nudge_card.dart';
import '../lesson_view_screen.dart';
import '../chatbot_screen.dart';
import 'create_goal_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _getGreeting(bool isHindi) {
    final hour = DateTime.now().hour;
    if (isHindi) {
      if (hour < 12) return 'सुप्रभात';
      if (hour < 17) return 'नमस्ते';
      if (hour < 21) return 'शुभ संध्या';
      return 'नमस्कार';
    }
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '👋';
    if (hour < 21) return '🌅';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    // Watch language service to rebuild when language changes
    context.watch<LanguageService>();
    
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.user;
        final userName = user?.name ?? 'Investor';
        final currentStreak = user?.currentStreak ?? 0;
        
        return Scaffold(
          backgroundColor: AppColors.warmWhite,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => appState.refresh(),
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    backgroundColor: AppColors.warmWhite,
                    elevation: 0,
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('InvestSathi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
                        ),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
                      ),
                      IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => _showNotifications()),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildGreetingSection(userName, currentStreak),
                        const SizedBox(height: 20),
                        PortfolioCard(
                          totalInvested: appState.totalInvested,
                          currentValue: appState.currentValue,
                          onAddMoney: () {},
                          onWithdraw: () => _showWithdrawSheet(appState),
                        ),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        _buildInvestmentPacks(),
                        const SizedBox(height: 24),
                        _buildGoalsSection(appState),
                        const SizedBox(height: 24),
                        DailyNudgeCard(
                          completedLessons: appState.totalCompletedLessons,
                          totalLessons: appState.totalLessons,
                          onStartLearning: () => _navigateToLearn(appState),
                        ),
                        const SizedBox(height: 24),
                        _buildTrustIndicators(),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingSection(String userName, int currentStreak) {
    final langService = context.watch<LanguageService>();
    final isHindi = langService.currentLanguage != AppLanguage.english;
    final messages = isHindi 
        ? ['आज के ₹10 कल के ₹100', 'हर दिन एक नई शुरुआत', 'छोटी बचत, बड़ा सपना']
        : ['Today\'s ₹10 is tomorrow\'s ₹100', 'Every day is a new beginning', 'Small savings, big dreams'];
    final message = messages[DateTime.now().day % messages.length];
    final streakText = isHindi ? '$currentStreak दिन की स्ट्रीक!' : '$currentStreak day streak!';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_getGreeting(isHindi)}, $userName! ${_getGreetingEmoji()}', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        if (currentStreak > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(streakText, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionCard(Icons.account_balance_wallet_rounded, 'Invest Now', 'Start with ₹10', AppColors.primaryGradient, () {})),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard(Icons.flag_rounded, 'Start a Goal', 'Save for dreams', AppColors.accentGradient, () => _showCreateGoalSheet())),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, LinearGradient gradient, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(AppTheme.radiusMedium), boxShadow: [BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentPacks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Popular Investment Packs', style: Theme.of(context).textTheme.titleMedium),
            TextButton(onPressed: () {}, child: const Text('See All')),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              InvestmentPackCard(icon: '☕', amount: 10, title: 'Chai Pack', description: 'Roz ki chai ki kimat', socialProof: '98,347 invested today', backgroundColor: AppColors.chaiPack, onInvest: () => _quickInvest(10, 'Chai Pack')),
              const SizedBox(width: 12),
              InvestmentPackCard(icon: '🍽️', amount: 50, title: 'Thali Pack', description: 'Hafta bhar ki bachat', badge: 'Good for beginners', backgroundColor: AppColors.thaliPack, onInvest: () => _quickInvest(50, 'Thali Pack')),
              const SizedBox(width: 12),
              InvestmentPackCard(icon: '🎬', amount: 100, title: 'Movie Pack', description: 'Mahine ki smart bachat', badge: 'Most Popular', backgroundColor: AppColors.moviePack, onInvest: () => _quickInvest(100, 'Movie Pack')),
              const SizedBox(width: 12),
              InvestmentPackCard(icon: '🪔', amount: 500, title: 'Festival Pack', description: 'Tyohaar ki taiyari', backgroundColor: AppColors.festivalPack, onInvest: () => _quickInvest(500, 'Festival Pack')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsSection(AppState appState) {
    final goals = appState.activeGoals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your Goals', style: Theme.of(context).textTheme.titleMedium),
            TextButton(onPressed: () => _showCreateGoalSheet(), child: Text(goals.isEmpty ? 'Create' : 'Manage')),
          ],
        ),
        const SizedBox(height: 12),
        if (goals.isEmpty)
          EmptyGoalCard(onCreateGoal: () => _showCreateGoalSheet())
        else
          Column(children: goals.take(2).map((goal) => Padding(padding: const EdgeInsets.only(bottom: 12), child: GoalCard(icon: goal.icon, name: goal.name, currentAmount: goal.currentAmount, targetAmount: goal.targetAmount, daysRemaining: goal.daysRemaining, onAddMoney: () => _showAddMoneyToGoalSheet(goal)))).toList()),
      ],
    );
  }

  Widget _buildTrustIndicators() {
    final indicators = ['✓ 5 Lakh+ users trust us', '✓ ₹100 Crore+ invested safely', '✓ SEBI registered platform'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(indicators[DateTime.now().second % indicators.length], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.success, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text('No new notifications', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showWithdrawSheet(AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Withdraw Funds', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Available: ₹${appState.currentValue.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Withdrawal feature coming soon!', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.info))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _quickInvest(int amount, String packName) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => QuickInvestSheet(amount: amount, packName: packName));
  }

  void _showCreateGoalSheet() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateGoalScreen()));
  }

  void _showAddMoneyToGoalSheet(GoalModel goal) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => AddMoneyToGoalSheet(goal: goal));
  }

  void _navigateToLearn(AppState appState) {
    // Find the next incomplete module
    for (final module in LearningData.modules) {
      if (!appState.isModuleUnlocked(module.id)) continue;
      final completed = appState.getModuleCompletedLessons(module.id);
      if (completed < module.lessons.length) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonViewScreen(
              module: module,
              startLessonIndex: completed,
            ),
          ),
        );
        return;
      }
    }
    // If all completed, go to first module
    if (LearningData.modules.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonViewScreen(
            module: LearningData.modules.first,
            startLessonIndex: 0,
          ),
        ),
      );
    }
  }
}


class QuickInvestSheet extends StatefulWidget {
  final int amount;
  final String packName;

  const QuickInvestSheet({super.key, required this.amount, required this.packName});

  @override
  State<QuickInvestSheet> createState() => _QuickInvestSheetState();
}

class _QuickInvestSheetState extends State<QuickInvestSheet> {
  bool _isProcessing = false;
  String _selectedFund = 'hdfc_liquid';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Invest ₹${widget.amount}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(widget.packName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Text('Select Fund', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          _buildFundOption('hdfc_liquid', 'HDFC Liquid Fund', '6.2%', 'Very Safe'),
          const SizedBox(height: 8),
          _buildFundOption('gold_fund', 'Gold Savings Fund', '8.0%', 'Safe'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.trending_up_rounded, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(child: Text('₹${widget.amount} could become ₹${(widget.amount * 1.062).toStringAsFixed(0)} in 1 year', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.success, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isProcessing ? null : _processInvestment,
            child: _isProcessing ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Invest ₹${widget.amount}'),
          ),
          const SizedBox(height: 12),
          Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
        ],
      ),
    );
  }

  Widget _buildFundOption(String fundId, String name, String returns, String risk) {
    final isSelected = _selectedFund == fundId;
    return InkWell(
      onTap: () => setState(() => _selectedFund = fundId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: isSelected ? 2 : 1)),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: Theme.of(context).textTheme.titleSmall), Text('$returns/year • $risk', style: Theme.of(context).textTheme.bodySmall)])),
          ],
        ),
      ),
    );
  }

  Future<void> _processInvestment() async {
    setState(() => _isProcessing = true);
    final appState = context.read<AppState>();
    final investment = await appState.invest(fundId: _selectedFund, amount: widget.amount.toDouble());
    if (!mounted) return;
    Navigator.pop(context);
    if (investment != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(children: [Icon(Icons.check_circle_rounded, color: AppColors.success), SizedBox(width: 8), Text('Success! 🎉')]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You invested ₹${widget.amount} successfully!'),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(8)), child: const Row(children: [Text('🪙', style: TextStyle(fontSize: 20)), SizedBox(width: 8), Text('+25 XP earned!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600))])),
            ],
          ),
          actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Great!'))],
        ),
      );
    }
  }
}

class AddMoneyToGoalSheet extends StatefulWidget {
  final GoalModel goal;

  const AddMoneyToGoalSheet({super.key, required this.goal});

  @override
  State<AddMoneyToGoalSheet> createState() => _AddMoneyToGoalSheetState();
}

class _AddMoneyToGoalSheetState extends State<AddMoneyToGoalSheet> {
  int _selectedAmount = 50;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final remaining = widget.goal.targetAmount - widget.goal.currentAmount;
    return Container(
      decoration: const BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(children: [Text(widget.goal.icon, style: const TextStyle(fontSize: 32)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.goal.name, style: Theme.of(context).textTheme.headlineSmall), Text('₹${remaining.toStringAsFixed(0)} remaining', style: Theme.of(context).textTheme.bodySmall)]))]),
          const SizedBox(height: 24),
          Text('Select Amount', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [10, 50, 100, 500].map((amount) {
              final isSelected = _selectedAmount == amount;
              return InkWell(
                onTap: () => setState(() => _selectedAmount = amount),
                borderRadius: BorderRadius.circular(12),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: isSelected ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider)), child: Text('₹$amount', style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600))),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _isProcessing ? null : _addMoney, child: _isProcessing ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Add ₹$_selectedAmount to Goal')),
          const SizedBox(height: 12),
          Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
        ],
      ),
    );
  }

  Future<void> _addMoney() async {
    setState(() => _isProcessing = true);
    final appState = context.read<AppState>();
    await appState.addMoneyToGoal(widget.goal.id, _selectedAmount.toDouble());
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ₹$_selectedAmount to ${widget.goal.name}! 🎉'), backgroundColor: AppColors.success));
  }
}
