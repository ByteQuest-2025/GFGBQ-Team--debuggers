import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/investment_model.dart';
import '../models/goal_model.dart';
import '../models/learning_model.dart';
import 'market_service.dart';

/// Central data service for all app data persistence
/// Handles offline-first storage using SharedPreferences
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  SharedPreferences? _prefs;
  
  // Keys for SharedPreferences
  static const String _keyUser = 'user_data';
  static const String _keyInvestments = 'investments';
  static const String _keyTransactions = 'transactions';
  static const String _keyGoals = 'goals';
  static const String _keyLearningProgress = 'learning_progress';
  static const String _keyCompletedLessons = 'completed_lessons_list';
  static const String _keyLastLoginDate = 'last_login_date';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyOnboardingComplete = 'onboarding_complete';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('DataService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ==================== USER DATA ====================
  
  Future<UserModel?> getUser() async {
    final json = prefs.getString(_keyUser);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }

  Future<void> saveUser(UserModel user) async {
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    // Also save individual fields for backward compatibility
    await prefs.setString('user_name', user.name);
    await prefs.setString('phone_number', user.phoneNumber);
    await prefs.setInt('total_xp', user.totalXP);
    await prefs.setInt('current_level', user.currentLevel);
    await prefs.setInt('current_streak', user.currentStreak);
    await prefs.setString('preferred_language', user.preferredLanguage);
  }

  Future<UserModel> createUser({
    required String name,
    required String phoneNumber,
  }) async {
    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
    );
    await saveUser(user);
    return user;
  }

  Future<void> addXP(int xp, {String? reason}) async {
    final user = await getUser();
    if (user == null) return;
    
    user.addXP(xp);
    await saveUser(user);
  }

  Future<void> updateStreak() async {
    final user = await getUser();
    if (user == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (user.lastActiveDate != null) {
      final lastActive = DateTime(
        user.lastActiveDate!.year,
        user.lastActiveDate!.month,
        user.lastActiveDate!.day,
      );
      final diff = today.difference(lastActive).inDays;
      
      if (diff == 1) {
        // Consecutive day - increase streak
        user.currentStreak++;
      } else if (diff > 1) {
        // Streak broken
        user.currentStreak = 1;
      }
      // diff == 0 means same day, don't change streak
    } else {
      user.currentStreak = 1;
    }
    
    user.lastActiveDate = now;
    await saveUser(user);
  }

  Future<void> addBadge(String badgeId) async {
    final user = await getUser();
    if (user == null) return;
    
    if (!user.earnedBadges.contains(badgeId)) {
      user.earnedBadges.add(badgeId);
      await saveUser(user);
    }
  }

  // ==================== INVESTMENTS ====================

  Future<List<InvestmentModel>> getInvestments() async {
    final json = prefs.getString(_keyInvestments);
    if (json == null) return [];
    
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => InvestmentModel.fromJson(e)).toList();
  }

  Future<void> saveInvestments(List<InvestmentModel> investments) async {
    await prefs.setString(
      _keyInvestments,
      jsonEncode(investments.map((e) => e.toJson()).toList()),
    );
    
    // Update totals
    double totalInvested = 0;
    double currentValue = 0;
    for (final inv in investments) {
      totalInvested += inv.investedAmount;
      currentValue += inv.currentValue;
    }
    await prefs.setDouble('total_invested', totalInvested);
    await prefs.setDouble('current_value', currentValue);
  }

  Future<InvestmentModel> addInvestment({
    required String fundId,
    required double amount,
    String? goalId,
  }) async {
    final fund = FundData.getFundById(fundId);
    if (fund == null) throw Exception('Fund not found');
    
    // Try to get real NAV from API, fallback to simulated
    double nav = 10.0 + (fund.expectedReturns / 100);
    try {
      final navData = await MarketService().fetchNav(fundId);
      if (navData != null && navData.currentNav > 0) {
        nav = navData.currentNav;
      }
    } catch (_) {
      // Use simulated NAV if API fails
    }
    
    final units = amount / nav;
    
    final investment = InvestmentModel(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      fundId: fundId,
      fundName: fund.name,
      investedAmount: amount,
      currentValue: amount, // Initially same as invested
      units: units,
      navAtPurchase: nav,
      investedAt: DateTime.now(),
      goalId: goalId,
    );
    
    final investments = await getInvestments();
    investments.add(investment);
    await saveInvestments(investments);
    
    // Add transaction
    await addTransaction(TransactionModel(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      type: 'investment',
      amount: amount,
      fundName: fund.name,
      timestamp: DateTime.now(),
    ));
    
    // Award XP for investing
    await addXP(25, reason: 'Investment made');
    
    // Check for first investment badge
    if (investments.length == 1) {
      await addBadge('first_investment');
      await addXP(100, reason: 'First investment bonus');
    }
    
    // Check for ₹1000 club badge
    final totalInvested = investments.fold<double>(0, (sum, inv) => sum + inv.investedAmount);
    if (totalInvested >= 1000) {
      await addBadge('1000_club');
    }
    
    return investment;
  }

  Future<void> updateInvestmentValues() async {
    final investments = await getInvestments();
    final marketService = MarketService();
    
    // Get unique fund IDs
    final fundIds = investments.map((i) => i.fundId).toSet().toList();
    
    // Fetch real NAV data for all funds
    final navDataMap = await marketService.fetchMultipleNavs(fundIds);
    
    for (final inv in investments) {
      // Try to use real NAV data
      final navData = navDataMap[inv.fundId];
      if (navData != null && navData.currentNav > 0) {
        inv.currentValue = inv.units * navData.currentNav;
      } else {
        // Fallback to simulated growth
        final fund = FundData.getFundById(inv.fundId);
        if (fund != null) {
          final daysSinceInvestment = DateTime.now().difference(inv.investedAt).inDays;
          final dailyReturn = fund.expectedReturns / 365 / 100;
          final growth = 1 + (dailyReturn * daysSinceInvestment);
          inv.currentValue = inv.investedAmount * growth;
        }
      }
    }
    
    await saveInvestments(investments);
  }

  // ==================== TRANSACTIONS ====================

  Future<List<TransactionModel>> getTransactions() async {
    final json = prefs.getString(_keyTransactions);
    if (json == null) return [];
    
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final transactions = await getTransactions();
    transactions.insert(0, transaction); // Add to beginning
    await prefs.setString(
      _keyTransactions,
      jsonEncode(transactions.map((e) => e.toJson()).toList()),
    );
  }

  // ==================== GOALS ====================

  Future<List<GoalModel>> getGoals() async {
    final json = prefs.getString(_keyGoals);
    if (json == null) return [];
    
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => GoalModel.fromJson(e)).toList();
  }

  Future<void> saveGoals(List<GoalModel> goals) async {
    await prefs.setString(
      _keyGoals,
      jsonEncode(goals.map((e) => e.toJson()).toList()),
    );
  }

  Future<GoalModel> createGoal({
    required String name,
    required String category,
    required double targetAmount,
    required DateTime targetDate,
    String? linkedFundId,
  }) async {
    final categoryData = GoalCategory.getById(category);
    
    final goal = GoalModel(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: categoryData?.icon ?? '🎯',
      category: category,
      targetAmount: targetAmount,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      linkedFundId: linkedFundId ?? 'hdfc_liquid', // Default to safest fund
    );
    
    final goals = await getGoals();
    goals.add(goal);
    await saveGoals(goals);
    
    // Award XP for creating goal
    await addXP(20, reason: 'Goal created');
    
    // Check for first goal badge
    if (goals.length == 1) {
      await addBadge('first_goal');
    }
    
    return goal;
  }

  Future<void> addMoneyToGoal(String goalId, double amount) async {
    final goals = await getGoals();
    final goalIndex = goals.indexWhere((g) => g.id == goalId);
    
    if (goalIndex == -1) return;
    
    final goal = goals[goalIndex];
    goal.addAmount(amount);
    
    // Also create an investment linked to this goal
    await addInvestment(
      fundId: goal.linkedFundId ?? 'hdfc_liquid',
      amount: amount,
      goalId: goalId,
    );
    
    await saveGoals(goals);
    
    // Check if goal completed
    if (goal.isCompleted) {
      await addBadge('goal_achieved');
      await addXP(200, reason: 'Goal completed!');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    final goals = await getGoals();
    goals.removeWhere((g) => g.id == goalId);
    await saveGoals(goals);
  }

  // ==================== LEARNING ====================

  Future<Map<String, LearningProgress>> getLearningProgress() async {
    final json = prefs.getString(_keyLearningProgress);
    if (json == null) return {};
    
    final Map<String, dynamic> map = jsonDecode(json);
    return map.map((key, value) => MapEntry(key, LearningProgress.fromJson(value)));
  }

  Future<void> saveLearningProgress(Map<String, LearningProgress> progress) async {
    await prefs.setString(
      _keyLearningProgress,
      jsonEncode(progress.map((key, value) => MapEntry(key, value.toJson()))),
    );
    
    // Update completed lessons count
    int totalCompleted = 0;
    for (final p in progress.values) {
      totalCompleted += p.completedLessons;
    }
    await prefs.setInt('completed_lessons', totalCompleted);
  }

  Future<Set<String>> getCompletedLessons() async {
    final list = prefs.getStringList(_keyCompletedLessons);
    return list?.toSet() ?? {};
  }

  Future<void> completeLesson(String moduleId, String lessonId) async {
    // Mark lesson as completed
    final completedLessons = await getCompletedLessons();
    if (completedLessons.contains(lessonId)) return; // Already completed
    
    completedLessons.add(lessonId);
    await prefs.setStringList(_keyCompletedLessons, completedLessons.toList());
    
    // Update module progress
    final progress = await getLearningProgress();
    final moduleProgress = progress[moduleId] ?? LearningProgress(moduleId: moduleId);
    moduleProgress.completedLessons++;
    progress[moduleId] = moduleProgress;
    await saveLearningProgress(progress);
    
    // Award XP
    await addXP(50, reason: 'Lesson completed');
    
    // Check for first lesson badge
    if (completedLessons.length == 1) {
      await addBadge('first_lesson');
    }
    
    // Check for 5 lessons badge
    if (completedLessons.length == 5) {
      await addBadge('knowledge_seeker');
    }
    
    // Check if module completed
    final module = LearningData.getModuleById(moduleId);
    if (module != null && moduleProgress.completedLessons >= module.lessons.length) {
      await addXP(module.xpReward, reason: 'Module completed');
      if (module.badgeId != null) {
        await addBadge(module.badgeId!);
      }
    }
  }

  Future<void> completeQuiz(String moduleId, int score, int totalQuestions) async {
    final progress = await getLearningProgress();
    final moduleProgress = progress[moduleId] ?? LearningProgress(moduleId: moduleId);
    
    moduleProgress.quizScore = score;
    moduleProgress.quizPassed = score >= (totalQuestions * 0.6); // 60% to pass
    
    if (moduleProgress.quizPassed) {
      moduleProgress.completedAt = DateTime.now();
      await addXP(30, reason: 'Quiz passed');
      
      // Check for quiz master badge (passed 3 quizzes)
      int passedQuizzes = 0;
      for (final p in progress.values) {
        if (p.quizPassed) passedQuizzes++;
      }
      if (passedQuizzes >= 3) {
        await addBadge('quiz_master');
      }
    }
    
    progress[moduleId] = moduleProgress;
    await saveLearningProgress(progress);
  }

  bool isModuleUnlocked(String moduleId, Map<String, LearningProgress> progress) {
    final module = LearningData.getModuleById(moduleId);
    if (module == null) return false;
    
    // First module is always unlocked
    if (module.number == 1) return true;
    
    // Check if previous module is completed
    final prevModuleId = 'module_${module.number - 1}';
    final prevProgress = progress[prevModuleId];
    
    if (prevProgress == null) return false;
    
    final prevModule = LearningData.getModuleById(prevModuleId);
    if (prevModule == null) return false;
    
    return prevProgress.completedLessons >= prevModule.lessons.length && 
           prevProgress.quizPassed;
  }

  // ==================== APP STATE ====================

  Future<bool> isLoggedIn() async {
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  Future<bool> isOnboardingComplete() async {
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await prefs.setBool(_keyOnboardingComplete, value);
  }

  // ==================== PORTFOLIO SUMMARY ====================

  Future<Map<String, double>> getPortfolioSummary() async {
    final investments = await getInvestments();
    
    double totalInvested = 0;
    double currentValue = 0;
    double todaysChange = 0;
    
    for (final inv in investments) {
      totalInvested += inv.investedAmount;
      currentValue += inv.currentValue;
      
      // Simulate today's change
      final fund = FundData.getFundById(inv.fundId);
      if (fund != null) {
        final dailyReturn = fund.expectedReturns / 365 / 100;
        todaysChange += inv.currentValue * dailyReturn;
      }
    }
    
    return {
      'totalInvested': totalInvested,
      'currentValue': currentValue,
      'returns': currentValue - totalInvested,
      'todaysChange': todaysChange,
    };
  }

  // ==================== CLEAR DATA ====================

  Future<void> clearAllData() async {
    await prefs.clear();
  }
}
