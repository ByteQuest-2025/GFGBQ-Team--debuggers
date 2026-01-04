import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  double _totalInvested = 0.0;
  double _currentValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalInvested = prefs.getDouble('total_invested') ?? 0.0;
      _currentValue = prefs.getDouble('current_value') ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final returns = _currentValue - _totalInvested;
    final returnsPercentage =
        _totalInvested > 0 ? ((returns / _totalInvested) * 100) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Investment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Summary
            _buildPortfolioSummary(returns, returnsPercentage),
            const SizedBox(height: 24),
            
            // Investment Options
            Text(
              'Invest Now',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.pureBlack,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInvestmentOption(
              title: 'Nippon small cap fund',
              description: 'Very low risk, stable returns',
              returns: '4-6% per year',
              risk: 'Very Low',
              minAmount: 10,
              riskLevel: 1,
            ),
            const SizedBox(height: 12),
            _buildInvestmentOption(
              title: 'ICICI Prudential Small Cap Fund',
              description: 'Low risk, good growth potential',
              returns: '6-8% per year',
              risk: 'Low',
              minAmount: 10,
              riskLevel: 2,
            ),
            const SizedBox(height: 12),
            _buildInvestmentOption(
              title: 'Mirae Asset Small Cap Fund',
              description: 'Moderate risk, balanced returns',
              returns: '8-10% per year',
              risk: 'Medium',
              minAmount: 10,
              riskLevel: 3,
            ),
          ],
        ),
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
                        color: AppColors.pureBlack,
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

  Widget _buildInvestmentOption({
    required String title,
    required String description,
    required String returns,
    required String risk,
    required int minAmount,
    required int riskLevel,
  }) {
    return InkWell(
      onTap: () => _showInvestDialog(title, minAmount, riskLevel),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.pureBlack,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskLevel == 1
                        ? AppColors.pureBlack.withOpacity(0.1)
                        : riskLevel == 2
                            ? AppColors.pureBlack.withOpacity(0.2)
                            : AppColors.pureBlack.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
                  ),
                  child: Text(
                    risk,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.blackSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Returns: $returns',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.blackSecondary,
                      ),
                ),
                Text(
                  'Min: ₹$minAmount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.blackSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showInvestDialog(title, minAmount, riskLevel),
                child: const Text('Invest'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvestDialog(String fundName, int minAmount, int riskLevel) {
    final amountController = TextEditingController(text: minAmount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        title: Text(
          'Invest in $fundName',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.pureBlack,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter amount (minimum ₹$minAmount)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.blackSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '₹',
                hintText: 'Enter amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount < minAmount) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Minimum investment is ₹$minAmount'),
                    backgroundColor: AppColors.pureBlack,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              await _processInvestment(fundName, amount, riskLevel);
            },
            child: const Text('Invest'),
          ),
        ],
      ),
    );
  }

  Future<void> _processInvestment(
      String fundName, double amount, int riskLevel) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Calculate expected returns (simplified)
    double returnRate;
    if (riskLevel == 1) {
      returnRate = 0.05; // 5% per year
    } else if (riskLevel == 2) {
      returnRate = 0.07; // 7% per year
    } else {
      returnRate = 0.09; // 9% per year
    }

    // Save investment
    final prefs = await SharedPreferences.getInstance();
    final totalInvested = prefs.getDouble('total_invested') ?? 0.0;
    final currentValue = prefs.getDouble('current_value') ?? 0.0;
    final investmentCount = prefs.getInt('investment_count') ?? 0;

    // For simplicity, assume immediate small growth
    final newInvested = totalInvested + amount;
    final newValue = currentValue + amount + (amount * returnRate * 0.1); // 10% of annual return

    await prefs.setDouble('total_invested', newInvested);
    await prefs.setDouble('current_value', newValue);
    await prefs.setInt('investment_count', investmentCount + 1);

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    // Show success
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        title: const Text('Investment Successful!'),
        content: Text(
          'You invested ₹${amount.toStringAsFixed(0)} in $fundName',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _totalInvested = newInvested;
                _currentValue = newValue;
              });
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
