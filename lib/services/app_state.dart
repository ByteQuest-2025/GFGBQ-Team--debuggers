import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/investment_model.dart';
import '../models/goal_model.dart';
import '../models/learning_model.dart';
import 'data_service.dart';

/// Global app state using ChangeNotifier for reactive updates
class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final DataService _dataService = DataService();
  
  // State variables
  UserModel? _user;
  List<InvestmentModel> _investments = [];
  List<TransactionModel> _transactions = [];
  List<GoalModel> _goals = [];
  Map<String, LearningProgress> _learningProgress = {};
  Set<String> _completedLessons = {};
  bool _isLoading = true;
  String? _error;

  // Getters
  UserModel? get user => _user;
  List<InvestmentModel> get investments => _investments;
  List<TransactionModel> get transactions => _transactions;
  List<GoalModel> get goals => _goals;
  Map<String, LearningProgress> get learningProgress => _learningProgress;
  Set<String> get completedLessons => _completedLessons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  double get totalInvested => _investments.fold(0, (sum, inv) => sum + inv.investedAmount);
  double get currentValue => _investments.fold(0, (sum, inv) => sum + inv.currentValue);
  double get totalReturns => currentValue - totalInvested;
  double get returnsPercentage => totalInvested > 0 ? (totalReturns / totalInvested) * 100 : 0;
  
  int get totalCompletedLessons => _completedLessons.length;
  int get totalLessons => LearningData.modules.fold(0, (sum, m) => sum + m.lessons.length);
  
  List<GoalModel> get activeGoals => _goals.where((g) => !g.isCompleted).toList();
  List<GoalModel> get completedGoals => _goals.where((g) => g.isCompleted).toList();

  /// Initialize app state - call this on app start
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dataService.init();
      await _loadAllData();
      await _dataService.updateStreak();
      await _dataService.updateInvestmentValues();
      await _loadAllData(); // Reload after updates
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAllData() async {
    _user = await _dataService.getUser();
    _investments = await _dataService.getInvestments();
    _transactions = await _dataService.getTransactions();
    _goals = await _dataService.getGoals();
    _learningProgress = await _dataService.getLearningProgress();
    _completedLessons = await _dataService.getCompletedLessons();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await _loadAllData();
    notifyListeners();
  }

  // ==================== USER ACTIONS ====================

  Future<void> createUser({required String name, required String phoneNumber}) async {
    _user = await _dataService.createUser(name: name, phoneNumber: phoneNumber);
    await _dataService.setLoggedIn(true);
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    if (_user == null) return;
    _user = UserModel(
      id: _user!.id,
      name: name,
      phoneNumber: _user!.phoneNumber,
      createdAt: _user!.createdAt,
      totalXP: _user!.totalXP,
      currentLevel: _user!.currentLevel,
      currentStreak: _user!.currentStreak,
      lastActiveDate: _user!.lastActiveDate,
      preferredLanguage: _user!.preferredLanguage,
      kycCompleted: _user!.kycCompleted,
      earnedBadges: _user!.earnedBadges,
    );
    await _dataService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_user == null) return;
    _user!.preferredLanguage = language;
    await _dataService.saveUser(_user!);
    notifyListeners();
  }

  // ==================== INVESTMENT ACTIONS ====================

  Future<InvestmentModel?> invest({
    required String fundId,
    required double amount,
    String? goalId,
  }) async {
    try {
      final investment = await _dataService.addInvestment(
        fundId: fundId,
        amount: amount,
        goalId: goalId,
      );
      await _loadAllData();
      notifyListeners();
      return investment;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  List<InvestmentModel> getInvestmentsByFund(String fundId) {
    return _investments.where((inv) => inv.fundId == fundId).toList();
  }

  List<InvestmentModel> getInvestmentsByGoal(String goalId) {
    return _investments.where((inv) => inv.goalId == goalId).toList();
  }

  // ==================== GOAL ACTIONS ====================

  Future<GoalModel?> createGoal({
    required String name,
    required String category,
    required double targetAmount,
    required DateTime targetDate,
    String? linkedFundId,
  }) async {
    try {
      final goal = await _dataService.createGoal(
        name: name,
        category: category,
        targetAmount: targetAmount,
        targetDate: targetDate,
        linkedFundId: linkedFundId,
      );
      await _loadAllData();
      notifyListeners();
      return goal;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> addMoneyToGoal(String goalId, double amount) async {
    await _dataService.addMoneyToGoal(goalId, amount);
    await _loadAllData();
    notifyListeners();
  }

  Future<void> deleteGoal(String goalId) async {
    await _dataService.deleteGoal(goalId);
    await _loadAllData();
    notifyListeners();
  }

  // ==================== LEARNING ACTIONS ====================

  Future<void> completeLesson(String moduleId, String lessonId) async {
    await _dataService.completeLesson(moduleId, lessonId);
    await _loadAllData();
    notifyListeners();
  }

  Future<void> completeQuiz(String moduleId, int score, int totalQuestions) async {
    await _dataService.completeQuiz(moduleId, score, totalQuestions);
    await _loadAllData();
    notifyListeners();
  }

  bool isLessonCompleted(String lessonId) {
    return _completedLessons.contains(lessonId);
  }

  bool isModuleUnlocked(String moduleId) {
    return _dataService.isModuleUnlocked(moduleId, _learningProgress);
  }

  int getModuleCompletedLessons(String moduleId) {
    return _learningProgress[moduleId]?.completedLessons ?? 0;
  }

  bool isModuleQuizPassed(String moduleId) {
    return _learningProgress[moduleId]?.quizPassed ?? false;
  }

  // ==================== BADGE HELPERS ====================

  bool hasBadge(String badgeId) {
    return _user?.earnedBadges.contains(badgeId) ?? false;
  }

  List<BadgeInfo> getAllBadges() {
    return [
      BadgeInfo(
        id: 'first_investment',
        name: 'First ₹10',
        nameHindi: 'Pehla ₹10',
        emoji: '🎯',
        description: 'Made your first investment',
        earned: hasBadge('first_investment'),
        tier: BadgeTier.bronze,
      ),
      BadgeInfo(
        id: 'first_lesson',
        name: 'First Lesson',
        nameHindi: 'Pehla Lesson',
        emoji: '📚',
        description: 'Completed your first lesson',
        earned: hasBadge('first_lesson'),
        tier: BadgeTier.bronze,
      ),
      BadgeInfo(
        id: 'first_goal',
        name: 'Goal Setter',
        nameHindi: 'Goal Setter',
        emoji: '🎯',
        description: 'Created your first goal',
        earned: hasBadge('first_goal'),
        tier: BadgeTier.bronze,
      ),
      BadgeInfo(
        id: 'knowledge_seeker',
        name: 'Knowledge Seeker',
        nameHindi: 'Gyaan Khoji',
        emoji: '🔍',
        description: 'Completed 5 lessons',
        earned: hasBadge('knowledge_seeker'),
        tier: BadgeTier.silver,
      ),
      BadgeInfo(
        id: 'quiz_master',
        name: 'Quiz Master',
        nameHindi: 'Quiz Master',
        emoji: '🏆',
        description: 'Passed 3 quizzes',
        earned: hasBadge('quiz_master'),
        tier: BadgeTier.gold,
      ),
      BadgeInfo(
        id: '1000_club',
        name: '₹1000 Club',
        nameHindi: '₹1000 Club',
        emoji: '💎',
        description: 'Invested ₹1000 total',
        earned: hasBadge('1000_club'),
        tier: BadgeTier.gold,
      ),
      BadgeInfo(
        id: 'goal_achieved',
        name: 'Goal Achiever',
        nameHindi: 'Goal Achiever',
        emoji: '🏅',
        description: 'Completed a savings goal',
        earned: hasBadge('goal_achieved'),
        tier: BadgeTier.gold,
      ),
      BadgeInfo(
        id: 'basics_complete',
        name: 'Basics Pro',
        nameHindi: 'Basics Pro',
        emoji: '📖',
        description: 'Completed Investment Basics module',
        earned: hasBadge('basics_complete'),
        tier: BadgeTier.silver,
      ),
      BadgeInfo(
        id: 'mf_expert',
        name: 'MF Expert',
        nameHindi: 'MF Expert',
        emoji: '🏦',
        description: 'Completed Mutual Funds module',
        earned: hasBadge('mf_expert'),
        tier: BadgeTier.silver,
      ),
      BadgeInfo(
        id: 'risk_aware',
        name: 'Risk Aware',
        nameHindi: 'Risk Aware',
        emoji: '📊',
        description: 'Completed Risk module',
        earned: hasBadge('risk_aware'),
        tier: BadgeTier.silver,
      ),
    ];
  }

  int get earnedBadgesCount => _user?.earnedBadges.length ?? 0;

  // ==================== LOGOUT ====================

  Future<void> logout() async {
    await _dataService.setLoggedIn(false);
    // Don't clear data, just mark as logged out
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _dataService.clearAllData();
    _user = null;
    _investments = [];
    _transactions = [];
    _goals = [];
    _learningProgress = {};
    _completedLessons = {};
    notifyListeners();
  }
}

// Badge info model
enum BadgeTier { bronze, silver, gold }

class BadgeInfo {
  final String id;
  final String name;
  final String nameHindi;
  final String emoji;
  final String description;
  final bool earned;
  final BadgeTier tier;

  const BadgeInfo({
    required this.id,
    required this.name,
    required this.nameHindi,
    required this.emoji,
    required this.description,
    required this.earned,
    required this.tier,
  });
}
