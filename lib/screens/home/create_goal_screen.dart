import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';
import '../../models/goal_model.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  int _currentStep = 0;
  GoalCategory? _selectedCategory;
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 180));
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Create Goal'),
        backgroundColor: AppColors.warmWhite,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: List.generate(3, (index) {
                final isActive = index <= _currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: _currentStep == 0
                ? _buildCategoryStep()
                : _currentStep == 1
                    ? _buildDetailsStep()
                    : _buildConfirmStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apna sapna chunein', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Kis cheez ke liye bachat karna chahte hain?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: GoalCategory.categories.length,
            itemBuilder: (context, index) {
              final category = GoalCategory.categories[index];
              final isSelected = _selectedCategory?.id == category.id;
              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedCategory = category;
                    _nameController.text = category.name;
                    _amountController.text = category.suggestedAmount.toStringAsFixed(0);
                  });
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: isSelected ? 2 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 32)),
                      const Spacer(),
                      Text(category.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                      Text(category.nameHindi, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selectedCategory != null ? () => setState(() => _currentStep = 1) : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_selectedCategory?.icon ?? '🎯', style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Goal Details', style: Theme.of(context).textTheme.headlineSmall),
                    Text('Apne goal ki details bharein', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Goal Name', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'e.g., New Phone, Vacation'),
          ),
          const SizedBox(height: 24),
          Text('Target Amount (₹)', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: '₹ ', hintText: 'Enter amount'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [5000, 10000, 25000, 50000].map((amount) {
              return ActionChip(
                label: Text('₹$amount'),
                onPressed: () => _amountController.text = amount.toString(),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Target Date', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text('${_targetDate.day}/${_targetDate.month}/${_targetDate.year}', style: Theme.of(context).textTheme.bodyLarge),
                  const Spacer(),
                  Text('${_targetDate.difference(DateTime.now()).inDays} days', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentStep = 0), child: const Text('Back'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: _canProceed() ? () => setState(() => _currentStep = 2) : null, child: const Text('Continue'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final days = _targetDate.difference(DateTime.now()).inDays;
    final monthlyRequired = days > 0 ? (amount / (days / 30)).round() : amount.round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirm Your Goal', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Apna goal check karein', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Column(
              children: [
                Text(_selectedCategory?.icon ?? '🎯', style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(_nameController.text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('in $days days', style: TextStyle(color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Monthly Savings Needed', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.info)),
                      Text('₹$monthlyRequired per month', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentStep = 1), child: const Text('Back'))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createGoal,
                  child: _isCreating ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Goal'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    return _nameController.text.isNotEmpty && (double.tryParse(_amountController.text) ?? 0) >= 100;
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().add(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _targetDate = date);
  }

  Future<void> _createGoal() async {
    setState(() => _isCreating = true);
    final appState = context.read<AppState>();
    final goal = await appState.createGoal(
      name: _nameController.text,
      category: _selectedCategory?.id ?? 'custom',
      targetAmount: double.parse(_amountController.text),
      targetDate: _targetDate,
    );
    if (!mounted) return;
    if (goal != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Goal "${goal.name}" created! 🎯'), backgroundColor: AppColors.success));
    }
  }
}
