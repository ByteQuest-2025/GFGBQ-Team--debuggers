import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../services/app_state.dart';
import '../../services/language_service.dart';
import '../../models/learning_model.dart';
import '../lesson_view_screen.dart';
import '../quiz_screen.dart';

class LearnTab extends StatefulWidget {
  const LearnTab({super.key});

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

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

  List<ModuleModel> _getModulesForLevel(String level) {
    return LearningData.modules.where((m) => m.difficulty.toLowerCase() == level.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Watch language service to rebuild when language changes
    context.watch<LanguageService>();
    
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final user = appState.user;
        final totalXP = user?.totalXP ?? 0;
        final currentLevel = user?.currentLevel ?? 1;
        final completedLessons = appState.totalCompletedLessons;
        final earnedBadges = appState.earnedBadgesCount;
        final currentStreak = user?.currentStreak ?? 0;

        return Scaffold(
          backgroundColor: AppColors.warmWhite,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: AppColors.warmWhite,
                title: const Text('Learn & Earn'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.emoji_events_rounded),
                    onPressed: () => _showBadgesSheet(appState),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(200),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildProgressHero(totalXP, currentLevel, completedLessons, earnedBadges, currentStreak),
                      ),
                      const SizedBox(height: 16),
                      _buildLevelTabs(),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: _levels.map((level) => _buildLevelContent(level, appState)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressHero(int totalXP, int currentLevel, int completedLessons, int earnedBadges, int currentStreak) {
    final progressToNextLevel = (totalXP % 1000) / 1000;
    final xpToNext = 1000 - (totalXP % 1000);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Level badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'L$currentLevel',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLevelTitle(currentLevel),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalXP XP • $xpToNext XP to next level',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressToNextLevel,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('📚', '$completedLessons', 'Lessons'),
              _buildStatItem('🏆', '$earnedBadges', 'Badges'),
              _buildStatItem('🔥', '$currentStreak', 'Day Streak'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _getLevelTitle(int level) {
    switch (level) {
      case 1: return 'Beginner Investor';
      case 2: return 'Learning Investor';
      case 3: return 'Smart Investor';
      case 4: return 'Pro Investor';
      default: return 'Expert Investor';
    }
  }

  Widget _buildLevelTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('🌱', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text('Beginner'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('📈', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text('Intermediate'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('🚀', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text('Advanced'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelContent(String level, AppState appState) {
    final modules = _getModulesForLevel(level);
    
    if (modules.isEmpty) {
      return _buildEmptyState(level);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: modules.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildLevelHeader(level, modules, appState);
        }
        
        final module = modules[index - 1];
        final completed = appState.getModuleCompletedLessons(module.id);
        final isLocked = !appState.isModuleUnlocked(module.id);
        final quizPassed = appState.isModuleQuizPassed(module.id);
        
        return _buildModuleCard(
          module: module,
          completed: completed,
          isLocked: isLocked,
          quizPassed: quizPassed,
          appState: appState,
        );
      },
    );
  }

  Widget _buildLevelHeader(String level, List<ModuleModel> modules, AppState appState) {
    int totalLessons = modules.fold(0, (sum, m) => sum + m.totalLessons);
    int completedLessons = modules.fold(0, (sum, m) => sum + appState.getModuleCompletedLessons(m.id));
    int passedQuizzes = modules.where((m) => appState.isModuleQuizPassed(m.id)).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getLevelColor(level).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: _getLevelColor(level).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getLevelEmoji(level),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$level Level',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _getLevelColor(level),
                      ),
                    ),
                    Text(
                      _getLevelDescription(level),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildProgressChip('$completedLessons/$totalLessons lessons', Icons.menu_book_rounded),
              const SizedBox(width: 8),
              _buildProgressChip('$passedQuizzes/${modules.length} quizzes', Icons.quiz_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner': return AppColors.success;
      case 'intermediate': return AppColors.warning;
      case 'advanced': return AppColors.error;
      default: return AppColors.primary;
    }
  }

  String _getLevelEmoji(String level) {
    switch (level.toLowerCase()) {
      case 'beginner': return '🌱';
      case 'intermediate': return '📈';
      case 'advanced': return '🚀';
      default: return '📚';
    }
  }

  String _getLevelDescription(String level) {
    switch (level.toLowerCase()) {
      case 'beginner': return 'Start your investment journey here';
      case 'intermediate': return 'Deepen your financial knowledge';
      case 'advanced': return 'Master advanced investment strategies';
      default: return 'Learn and grow';
    }
  }

  Widget _buildEmptyState(String level) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_getLevelEmoji(level), style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Coming Soon!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$level modules are being prepared.\nCheck back soon!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required ModuleModel module,
    required int completed,
    required bool isLocked,
    required bool quizPassed,
    required AppState appState,
  }) {
    final lessons = module.totalLessons;
    final progress = lessons > 0 ? completed / lessons : 0.0;
    final isCompleted = completed >= lessons && quizPassed;
    final allLessonsDone = completed >= lessons;
    final langService = context.watch<LanguageService>();
    final isHindi = langService.currentLanguage != AppLanguage.english;
    final title = isHindi ? module.titleHindi : module.title;
    final description = isHindi ? module.descriptionHindi : module.description;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isLocked ? AppColors.surface : AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isLocked 
              ? AppColors.divider 
              : isCompleted 
                  ? AppColors.success 
                  : AppColors.primary.withOpacity(0.3),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: isLocked ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Module header
          InkWell(
            onTap: isLocked ? null : () => _openModule(module, appState),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Module icon/number
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? AppColors.divider
                          : isCompleted
                              ? AppColors.success
                              : AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: isLocked
                          ? const Icon(Icons.lock_rounded, color: AppColors.textSecondary, size: 24)
                          : isCompleted
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                              : Text(
                                  module.icon,
                                  style: const TextStyle(fontSize: 26),
                                ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Module ${module.number}',
                              style: TextStyle(
                                color: isLocked ? AppColors.textSecondary : AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isCompleted) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'COMPLETED',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: isLocked ? AppColors.textSecondary : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!isLocked)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isCompleted ? AppColors.success : AppColors.primary,
                    ),
                ],
              ),
            ),
          ),
          
          // Progress section
          if (!isLocked) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted ? AppColors.success : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$completed/$lessons',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Lessons preview & Quiz button
                  Row(
                    children: [
                      // Lessons dots
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(lessons, (index) {
                            final lessonCompleted = index < completed;
                            return Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: lessonCompleted ? AppColors.success : AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: lessonCompleted ? AppColors.success : AppColors.divider,
                                ),
                              ),
                              child: Center(
                                child: lessonCompleted
                                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ),
                      ),
                      
                      // Quiz button
                      if (allLessonsDone)
                        TextButton.icon(
                          onPressed: () => _openQuiz(module),
                          icon: Icon(
                            quizPassed ? Icons.replay_rounded : Icons.quiz_rounded,
                            size: 18,
                          ),
                          label: Text(quizPassed ? 'Retake Quiz' : 'Take Quiz'),
                          style: TextButton.styleFrom(
                            foregroundColor: quizPassed ? AppColors.success : AppColors.accent,
                          ),
                        ),
                    ],
                  ),
                  
                  // XP reward
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        'Earn ${module.xpReward} XP',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (module.badgeId != null) ...[
                        const SizedBox(width: 12),
                        const Text('🏆', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          'Unlock Badge',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          // Locked message
          if (isLocked)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppTheme.radiusLarge)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Complete ${module.requiredModules} module(s) to unlock',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _openModule(ModuleModel module, AppState appState) {
    final completed = appState.getModuleCompletedLessons(module.id);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonViewScreen(
          module: module,
          startLessonIndex: completed < module.lessons.length ? completed : 0,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  void _openQuiz(ModuleModel module) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(module: module)),
    ).then((_) => setState(() {}));
  }

  void _showBadgesSheet(AppState appState) {
    final badges = appState.getAllBadges();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Badges',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${appState.earnedBadgesCount}/${badges.length} earned',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  final color = badge.tier == BadgeTier.gold
                      ? AppColors.gold
                      : badge.tier == BadgeTier.silver
                          ? AppColors.silver
                          : AppColors.bronze;
                  
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: badge.earned ? color.withOpacity(0.15) : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: badge.earned ? color : AppColors.divider,
                        width: badge.earned ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          badge.emoji,
                          style: TextStyle(
                            fontSize: 32,
                            color: badge.earned ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: badge.earned ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!badge.earned) ...[
                          const SizedBox(height: 4),
                          const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textSecondary),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
