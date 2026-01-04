enum InvestmentType { oneTime, sip }
enum TransactionStatus { pending, completed, failed }

class FundModel {
  final String id;
  final String name;
  final String shortName;
  final String description;
  final String descriptionHindi;
  final double expectedReturns; // Annual percentage
  final String riskLevel; // very_low, low, moderate, high
  final int minInvestment;
  final int lockInDays;
  final double expenseRatio;
  final int totalInvestors;
  final String category; // liquid, debt, hybrid, gilt, gold

  const FundModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.descriptionHindi,
    required this.expectedReturns,
    required this.riskLevel,
    required this.minInvestment,
    this.lockInDays = 0,
    this.expenseRatio = 0.5,
    this.totalInvestors = 0,
    required this.category,
  });

  String get riskLabel {
    switch (riskLevel) {
      case 'very_low': return 'Very Safe';
      case 'low': return 'Safe';
      case 'moderate': return 'Moderate';
      case 'high': return 'High';
      default: return 'Unknown';
    }
  }

  // Simulate daily NAV change (-0.5% to +0.5%)
  double simulateDailyReturn() {
    final dailyReturn = expectedReturns / 365;
    final variance = (dailyReturn * 0.5); // 50% variance
    return dailyReturn + (variance * (DateTime.now().millisecond % 100 - 50) / 100);
  }
}

class InvestmentModel {
  final String id;
  final String oderId;
  final String fundId;
  final String fundName;
  final double investedAmount;
  double currentValue;
  final double units;
  final double navAtPurchase;
  final DateTime investedAt;
  final InvestmentType type;
  final TransactionStatus status;
  final String? goalId; // If linked to a goal

  InvestmentModel({
    required this.id,
    required this.fundId,
    required this.fundName,
    required this.investedAmount,
    required this.currentValue,
    required this.units,
    required this.navAtPurchase,
    required this.investedAt,
    this.type = InvestmentType.oneTime,
    this.status = TransactionStatus.completed,
    this.goalId,
  }) : oderId = 'INV${DateTime.now().millisecondsSinceEpoch}';

  double get returns => currentValue - investedAmount;
  double get returnsPercentage => investedAmount > 0 ? (returns / investedAmount) * 100 : 0;
  double get currentNav => units > 0 ? currentValue / units : navAtPurchase;

  void updateValue(double newNav) {
    currentValue = units * newNav;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fundId': fundId,
    'fundName': fundName,
    'investedAmount': investedAmount,
    'currentValue': currentValue,
    'units': units,
    'navAtPurchase': navAtPurchase,
    'investedAt': investedAt.toIso8601String(),
    'type': type.index,
    'status': status.index,
    'goalId': goalId,
  };

  factory InvestmentModel.fromJson(Map<String, dynamic> json) => InvestmentModel(
    id: json['id'],
    fundId: json['fundId'],
    fundName: json['fundName'],
    investedAmount: (json['investedAmount'] as num).toDouble(),
    currentValue: (json['currentValue'] as num).toDouble(),
    units: (json['units'] as num).toDouble(),
    navAtPurchase: (json['navAtPurchase'] as num).toDouble(),
    investedAt: DateTime.parse(json['investedAt']),
    type: InvestmentType.values[json['type'] ?? 0],
    status: TransactionStatus.values[json['status'] ?? 1],
    goalId: json['goalId'],
  );
}

class TransactionModel {
  final String id;
  final String type; // investment, withdrawal, dividend
  final double amount;
  final String fundName;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? failureReason;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.fundName,
    required this.timestamp,
    this.status = TransactionStatus.completed,
    this.failureReason,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'amount': amount,
    'fundName': fundName,
    'timestamp': timestamp.toIso8601String(),
    'status': status.index,
    'failureReason': failureReason,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
    id: json['id'],
    type: json['type'],
    amount: (json['amount'] as num).toDouble(),
    fundName: json['fundName'],
    timestamp: DateTime.parse(json['timestamp']),
    status: TransactionStatus.values[json['status'] ?? 1],
    failureReason: json['failureReason'],
  );
}

// Predefined funds
class FundData {
  static const List<FundModel> funds = [
    FundModel(
      id: 'hdfc_liquid',
      name: 'HDFC Liquid Fund',
      shortName: 'HDFC Liquid',
      description: 'Like bank FD, but better returns. Withdraw anytime.',
      descriptionHindi: 'Bank FD jaisa, lekin zyada returns. Kab bhi nikaal sakte hain.',
      expectedReturns: 6.2,
      riskLevel: 'very_low',
      minInvestment: 10,
      category: 'liquid',
      totalInvestors: 47892,
    ),
    FundModel(
      id: 'sbi_debt',
      name: 'SBI Debt Fund',
      shortName: 'SBI Debt',
      description: 'Slightly higher returns, safe investment.',
      descriptionHindi: 'Thoda zyada return, safe investment.',
      expectedReturns: 7.8,
      riskLevel: 'low',
      minInvestment: 100,
      category: 'debt',
      totalInvestors: 32156,
    ),
    FundModel(
      id: 'icici_hybrid',
      name: 'ICICI Hybrid Fund',
      shortName: 'ICICI Hybrid',
      description: 'Mix of debt and equity, balanced returns.',
      descriptionHindi: 'Debt aur equity ka mix, balanced returns.',
      expectedReturns: 10.5,
      riskLevel: 'moderate',
      minInvestment: 100,
      category: 'hybrid',
      totalInvestors: 28943,
    ),
    FundModel(
      id: 'gilt_fund',
      name: 'GILT Fund (Govt Bonds)',
      shortName: 'GILT Fund',
      description: 'Direct investment in government, 100% safe.',
      descriptionHindi: 'Seedha sarkar mein invest, 100% safe.',
      expectedReturns: 6.8,
      riskLevel: 'very_low',
      minInvestment: 500,
      category: 'gilt',
      totalInvestors: 15678,
    ),
    FundModel(
      id: 'gold_fund',
      name: 'Gold Savings Fund',
      shortName: 'Gold Fund',
      description: 'Digital gold, like physical gold.',
      descriptionHindi: 'Digital gold, physical gold jaisa.',
      expectedReturns: 8.0,
      riskLevel: 'low',
      minInvestment: 10,
      category: 'gold',
      totalInvestors: 41234,
    ),
    FundModel(
      id: 'axis_bluechip',
      name: 'Axis Bluechip Fund',
      shortName: 'Axis Bluechip',
      description: 'Large company stocks, good for long term.',
      descriptionHindi: 'Badi companies mein invest, long term ke liye.',
      expectedReturns: 12.5,
      riskLevel: 'moderate',
      minInvestment: 500,
      category: 'equity',
      totalInvestors: 52341,
    ),
  ];

  static FundModel? getFundById(String id) {
    try {
      return funds.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}
