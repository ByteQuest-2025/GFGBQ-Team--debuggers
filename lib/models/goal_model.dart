class GoalModel {
  final String id;
  final String name;
  final String icon;
  final String category; // home, vehicle, gadget, wedding, education, medical, vacation, emergency, festival, custom
  final double targetAmount;
  double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  bool isCompleted;
  final bool autoInvest;
  final double? monthlyAmount;
  final String? linkedFundId;

  GoalModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.targetDate,
    required this.createdAt,
    this.isCompleted = false,
    this.autoInvest = false,
    this.monthlyAmount,
    this.linkedFundId,
  });

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0;
  int get progressPercentage => (progress * 100).round();
  
  int get daysRemaining {
    final diff = targetDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  int get monthsRemaining => (daysRemaining / 30).ceil();

  double get requiredMonthlyAmount {
    if (monthsRemaining <= 0) return targetAmount - currentAmount;
    return (targetAmount - currentAmount) / monthsRemaining;
  }

  void addAmount(double amount) {
    currentAmount += amount;
    if (currentAmount >= targetAmount) {
      isCompleted = true;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'category': category,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted,
    'autoInvest': autoInvest,
    'monthlyAmount': monthlyAmount,
    'linkedFundId': linkedFundId,
  };

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
    id: json['id'],
    name: json['name'],
    icon: json['icon'],
    category: json['category'],
    targetAmount: (json['targetAmount'] as num).toDouble(),
    currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
    targetDate: DateTime.parse(json['targetDate']),
    createdAt: DateTime.parse(json['createdAt']),
    isCompleted: json['isCompleted'] ?? false,
    autoInvest: json['autoInvest'] ?? false,
    monthlyAmount: (json['monthlyAmount'] as num?)?.toDouble(),
    linkedFundId: json['linkedFundId'],
  );
}

class GoalCategory {
  final String id;
  final String name;
  final String nameHindi;
  final String icon;
  final double suggestedAmount;

  const GoalCategory({
    required this.id,
    required this.name,
    required this.nameHindi,
    required this.icon,
    required this.suggestedAmount,
  });

  static const List<GoalCategory> categories = [
    GoalCategory(id: 'emergency', name: 'Emergency Fund', nameHindi: 'Emergency Fund', icon: '💰', suggestedAmount: 50000),
    GoalCategory(id: 'festival', name: 'Festival Shopping', nameHindi: 'Tyohaar Shopping', icon: '🎉', suggestedAmount: 20000),
    GoalCategory(id: 'gadget', name: 'New Gadget', nameHindi: 'Naya Phone/Gadget', icon: '📱', suggestedAmount: 15000),
    GoalCategory(id: 'vacation', name: 'Vacation', nameHindi: 'Chutti Trip', icon: '✈️', suggestedAmount: 30000),
    GoalCategory(id: 'education', name: 'Education', nameHindi: 'Padhai', icon: '🎓', suggestedAmount: 100000),
    GoalCategory(id: 'wedding', name: 'Wedding', nameHindi: 'Shaadi', icon: '💍', suggestedAmount: 200000),
    GoalCategory(id: 'vehicle', name: 'Vehicle', nameHindi: 'Gaadi', icon: '🚗', suggestedAmount: 100000),
    GoalCategory(id: 'home', name: 'Home', nameHindi: 'Ghar', icon: '🏠', suggestedAmount: 500000),
    GoalCategory(id: 'medical', name: 'Medical', nameHindi: 'Medical', icon: '🏥', suggestedAmount: 50000),
    GoalCategory(id: 'custom', name: 'Custom Goal', nameHindi: 'Apna Goal', icon: '🎯', suggestedAmount: 10000),
  ];

  static GoalCategory? getById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
