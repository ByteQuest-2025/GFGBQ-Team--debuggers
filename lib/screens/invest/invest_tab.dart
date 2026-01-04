import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';
import '../../models/investment_model.dart';

class InvestTab extends StatefulWidget {
  const InvestTab({super.key});

  @override
  State<InvestTab> createState() => _InvestTabState();
}

class _InvestTabState extends State<InvestTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedAmount = 100;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Invest'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [Tab(text: 'Invest Now'), Tab(text: 'Portfolio'), Tab(text: 'History')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildInvestNowTab(), _buildPortfolioTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildInvestNowTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountSection(),
          const SizedBox(height: 24),
          Text('Choose Investment Product', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Humne sabse safe options choose kiye hain', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Very Safe 🟢', 'Safe 🟢', 'Moderate 🟠'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (value) => setState(() => _selectedFilter = filter),
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          ...FundData.funds.where((fund) {
            if (_selectedFilter == 'All') return true;
            if (_selectedFilter.contains('Very Safe')) return fund.riskLevel == 'very_low';
            if (_selectedFilter.contains('Safe')) return fund.riskLevel == 'low';
            if (_selectedFilter.contains('Moderate')) return fund.riskLevel == 'moderate';
            return true;
          }).map((fund) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildProductCard(fund),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    final amountInWords = _getAmountInWords(_selectedAmount);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppTheme.radiusLarge), border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aaj kitna invest karna chahte hain?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Minimum ₹10, Maximum ₹50,000', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          Center(child: Text('₹$_selectedAmount', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700))),
          const SizedBox(height: 8),
          Center(child: Text(amountInWords, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAmountChip(10, 'Chai'),
              _buildAmountChip(50, 'Thali'),
              _buildAmountChip(100, 'Movie'),
              _buildAmountChip(500, 'Festival'),
            ],
          ),
          const SizedBox(height: 16),
          Center(child: TextButton.icon(onPressed: () => _showCustomAmountSheet(), icon: const Icon(Icons.edit_rounded, size: 18), label: const Text('Enter custom amount'))),
        ],
      ),
    );
  }

  String _getAmountInWords(int amount) {
    if (amount < 100) return 'Das se kam';
    if (amount == 100) return 'Ek sau rupaye';
    if (amount == 500) return 'Paanch sau rupaye';
    if (amount == 1000) return 'Ek hazaar rupaye';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)} hazaar rupaye';
    return '$amount rupaye';
  }

  Widget _buildAmountChip(int amount, String label) {
    final isSelected = _selectedAmount == amount;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedAmount = amount);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider)),
        child: Column(
          children: [
            Text('₹$amount', style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(FundModel fund) {
    final riskColor = fund.riskLevel == 'very_low' ? AppColors.riskVeryLow : fund.riskLevel == 'low' ? AppColors.riskLow : fund.riskLevel == 'moderate' ? AppColors.riskModerate : AppColors.riskHigh;
    return InkWell(
      onTap: () => _showInvestmentDetails(fund),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppTheme.radiusMedium), border: Border.all(color: AppColors.divider)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(fund.name, style: Theme.of(context).textTheme.titleMedium)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: riskColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(fund.riskLabel, style: TextStyle(color: riskColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(fund.description, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetric('Returns', '${fund.expectedReturns}%/year'),
                const SizedBox(width: 24),
                _buildMetric('Min', '₹${fund.minInvestment}'),
                const SizedBox(width: 24),
                _buildMetric('Lock-in', fund.lockInDays > 0 ? '${fund.lockInDays} days' : 'None'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [const Icon(Icons.people_outline_rounded, size: 16, color: AppColors.textSecondary), const SizedBox(width: 4), Text('${_formatNumber(fund.totalInvestors)} invested', style: Theme.of(context).textTheme.bodySmall)]),
                ElevatedButton(
                  onPressed: _selectedAmount >= fund.minInvestment ? () => _showInvestmentDetails(fund) : null,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40), padding: const EdgeInsets.symmetric(horizontal: 20)),
                  child: Text(_selectedAmount >= fund.minInvestment ? 'Invest ₹$_selectedAmount' : 'Min ₹${fund.minInvestment}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPortfolioTab() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final investments = appState.investments;
        final totalInvested = appState.totalInvested;
        final currentValue = appState.currentValue;
        final returns = currentValue - totalInvested;
        final returnsPercentage = totalInvested > 0 ? (returns / totalInvested) * 100 : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Value', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('₹${currentValue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text('${returns >= 0 ? '+' : ''}${returnsPercentage.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPortfolioStat('Invested', '₹${totalInvested.toStringAsFixed(0)}'),
                        _buildPortfolioStat('Returns', '${returns >= 0 ? '+' : ''}₹${returns.toStringAsFixed(0)}'),
                        _buildPortfolioStat("Today's", '+₹${(currentValue * 0.0002).toStringAsFixed(0)}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (investments.isEmpty)
                _buildEmptyPortfolio()
              else
                _buildInvestmentsList(investments),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortfolioStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildEmptyPortfolio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(40)), child: const Icon(Icons.account_balance_wallet_outlined, size: 40, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Text('Abhi tak koi investment nahi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Apna pehla investment karein', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => _tabController.animateTo(0), child: const Text('Start Investing')),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentsList(List<InvestmentModel> investments) {
    // Group investments by fund
    final Map<String, List<InvestmentModel>> grouped = {};
    for (final inv in investments) {
      grouped.putIfAbsent(inv.fundId, () => []).add(inv);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Investments', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ...grouped.entries.map((entry) {
          final fundInvestments = entry.value;
          final totalInvested = fundInvestments.fold<double>(0, (sum, inv) => sum + inv.investedAmount);
          final totalValue = fundInvestments.fold<double>(0, (sum, inv) => sum + inv.currentValue);
          final totalUnits = fundInvestments.fold<double>(0, (sum, inv) => sum + inv.units);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInvestmentItem(name: fundInvestments.first.fundName, invested: totalInvested, currentValue: totalValue, units: totalUnits),
          );
        }),
      ],
    );
  }

  Widget _buildInvestmentItem({required String name, required double invested, required double currentValue, required double units}) {
    final returns = currentValue - invested;
    final returnsPercentage = invested > 0 ? (returns / invested) * 100 : 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppTheme.radiusMedium), border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: returns >= 0 ? AppColors.successLight : AppColors.errorLight, borderRadius: BorderRadius.circular(6)),
                child: Text('${returns >= 0 ? '+' : ''}${returnsPercentage.toStringAsFixed(1)}%', style: TextStyle(color: returns >= 0 ? AppColors.success : AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInvestmentMetric('Current', '₹${currentValue.toStringAsFixed(0)}'),
              _buildInvestmentMetric('Invested', '₹${invested.toStringAsFixed(0)}'),
              _buildInvestmentMetric('Returns', '${returns >= 0 ? '+' : ''}₹${returns.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 8),
          Text('${units.toStringAsFixed(2)} units', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildInvestmentMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final transactions = appState.transactions;
        if (transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(40)), child: const Icon(Icons.history_rounded, size: 40, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Text('Koi transaction nahi hai', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Jab aap invest karenge, yahan dikhega', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final txn = transactions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppTheme.radiusMedium), border: Border.all(color: AppColors.divider)),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: txn.type == 'investment' ? AppColors.successLight : AppColors.warningLight, borderRadius: BorderRadius.circular(12)),
                    child: Icon(txn.type == 'investment' ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: txn.type == 'investment' ? AppColors.success : AppColors.warning),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(txn.fundName, style: Theme.of(context).textTheme.titleSmall),
                        Text('${txn.timestamp.day}/${txn.timestamp.month}/${txn.timestamp.year}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text('${txn.type == 'investment' ? '+' : '-'}₹${txn.amount.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: txn.type == 'investment' ? AppColors.success : AppColors.warning)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomAmountSheet() {
    final controller = TextEditingController(text: _selectedAmount.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Enter Amount', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextField(autofocus: true, controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '₹ ', hintText: 'Enter amount (min ₹10)'), style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final amount = int.tryParse(controller.text) ?? 100;
                  if (amount >= 10 && amount <= 50000) {
                    setState(() => _selectedAmount = amount);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Set Amount'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showInvestmentDetails(FundModel fund) {
    final projectedValue1Y = _selectedAmount * (1 + fund.expectedReturns / 100);
    final projectedValue5Y = _selectedAmount * (1 + fund.expectedReturns / 100 * 5);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(fund.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Returns: ${fund.expectedReturns}%/year • Risk: ${fund.riskLabel}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Text(fund.description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Agar aap ₹$_selectedAmount invest karein:', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text('1 year mein: ₹${projectedValue1Y.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('5 years mein: ₹${projectedValue5Y.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(onPressed: () => _processInvestment(fund), child: Text('Invest ₹$_selectedAmount')),
            const SizedBox(height: 12),
            Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
          ],
        ),
      ),
    );
  }

  Future<void> _processInvestment(FundModel fund) async {
    Navigator.pop(context); // Close bottom sheet
    
    // Open PhonePe directly with amount - user will enter recipient
    final amount = _selectedAmount.toStringAsFixed(2);
    final transactionNote = Uri.encodeComponent('Investment in ${fund.name}');
    
    // PhonePe deep link with amount only
    final phonepeUrl = Uri.parse(
      'phonepe://pay?am=$amount&cu=INR&tn=$transactionNote'
    );
    
    try {
      final launched = await launchUrl(phonepeUrl, mode: LaunchMode.externalApplication);
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PhonePe not installed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PhonePe')),
        );
      }
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}
