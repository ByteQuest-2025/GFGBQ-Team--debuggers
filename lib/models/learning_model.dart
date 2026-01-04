class LessonModel {
  final String id;
  final String title;
  final String titleHindi;
  final List<LessonContent> contentBlocks;
  final int durationMinutes;
  final String difficulty;
  final int xpReward;
  const LessonModel({required this.id, required this.title, required this.titleHindi, required this.contentBlocks, required this.durationMinutes, required this.difficulty, this.xpReward = 50});
  String get content => contentBlocks.where((b) => b.type == ContentType.text).map((b) => b.text).join('\n\n');
}

enum ContentType { text, checkpoint, tip, example, keyPoint }

class LessonContent {
  final ContentType type;
  final String text;
  final String? textHindi;
  final CheckpointQuestion? checkpoint;
  const LessonContent({required this.type, required this.text, this.textHindi, this.checkpoint});
  const LessonContent.text(this.text, {this.textHindi}) : type = ContentType.text, checkpoint = null;
  const LessonContent.tip(this.text, {this.textHindi}) : type = ContentType.tip, checkpoint = null;
  const LessonContent.example(this.text, {this.textHindi}) : type = ContentType.example, checkpoint = null;
  const LessonContent.keyPoint(this.text, {this.textHindi}) : type = ContentType.keyPoint, checkpoint = null;
  const LessonContent.checkpoint(this.checkpoint) : type = ContentType.checkpoint, text = '', textHindi = null;
}

class CheckpointQuestion {
  final String question;
  final String questionHindi;
  final List<String> options;
  final List<String> optionsHindi;
  final int correctIndex;
  final String explanation;
  final String explanationHindi;
  const CheckpointQuestion({required this.question, required this.questionHindi, required this.options, required this.optionsHindi, required this.correctIndex, required this.explanation, required this.explanationHindi});
}

class QuizQuestion {
  final String question;
  final String questionHindi;
  final List<String> options;
  final List<String> optionsHindi;
  final int correctIndex;
  final String? explanation;
  final String? explanationHindi;
  const QuizQuestion({required this.question, required this.questionHindi, required this.options, required this.optionsHindi, required this.correctIndex, this.explanation, this.explanationHindi});
}

class ModuleModel {
  final String id;
  final int number;
  final String title;
  final String titleHindi;
  final String description;
  final String descriptionHindi;
  final String icon;
  final String difficulty;
  final List<LessonModel> lessons;
  final List<QuizQuestion> quiz;
  final int xpReward;
  final String? badgeId;
  final bool isLocked;
  final int requiredModules;
  const ModuleModel({required this.id, required this.number, required this.title, required this.titleHindi, required this.description, required this.descriptionHindi, required this.icon, required this.lessons, required this.quiz, this.difficulty = 'beginner', this.xpReward = 100, this.badgeId, this.isLocked = false, this.requiredModules = 0});
  int get totalLessons => lessons.length;
}

class LearningProgress {
  final String moduleId;
  int completedLessons;
  bool quizPassed;
  int quizScore;
  DateTime? completedAt;
  LearningProgress({required this.moduleId, this.completedLessons = 0, this.quizPassed = false, this.quizScore = 0, this.completedAt});
  Map<String, dynamic> toJson() => {'moduleId': moduleId, 'completedLessons': completedLessons, 'quizPassed': quizPassed, 'quizScore': quizScore, 'completedAt': completedAt?.toIso8601String()};
  factory LearningProgress.fromJson(Map<String, dynamic> json) => LearningProgress(moduleId: json['moduleId'], completedLessons: json['completedLessons'] ?? 0, quizPassed: json['quizPassed'] ?? false, quizScore: json['quizScore'] ?? 0, completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null);
}

class LearningData {
  static ModuleModel? getModuleById(String id) {
    try { return modules.firstWhere((m) => m.id == id); } catch (_) { return null; }
  }
  static const List<ModuleModel> modules = [
    ModuleModel(
      id: 'module_1', number: 1, title: 'Investment Basics', titleHindi: 'Investment Basics', description: 'Learn money basics', descriptionHindi: 'Paisa basics', icon: '', difficulty: 'beginner', xpReward: 100, badgeId: 'basics_complete', requiredModules: 0,
      lessons: [
        LessonModel(id: 'l1_1', title: 'What is Money?', titleHindi: 'Paisa Kya?', durationMinutes: 3, difficulty: 'beginner', xpReward: 30, contentBlocks: [
          LessonContent.text('Money is a medium of exchange.'),
          LessonContent.keyPoint('Functions: Exchange, Store Value, Unit of Account'),
          LessonContent.checkpoint(CheckpointQuestion(question: 'Main purpose of money?', questionHindi: 'Paisa ka purpose?', options: ['Exchange easier', 'Look pretty', 'Collect', 'Throw'], optionsHindi: ['Exchange', 'Sundar', 'Collect', 'Phenkna'], correctIndex: 0, explanation: 'Money makes exchange easy!', explanationHindi: 'Paisa exchange easy karta hai!')),
        ]),
        LessonModel(id: 'l1_2', title: 'Why Save?', titleHindi: 'Kyun Bachayein?', durationMinutes: 4, difficulty: 'beginner', xpReward: 30, contentBlocks: [
          LessonContent.text('Saving is keeping money for future.'),
          LessonContent.keyPoint('Save for: Emergency, Goals, Peace'),
          LessonContent.checkpoint(CheckpointQuestion(question: 'Emergency fund for?', questionHindi: 'Emergency fund?', options: ['Unexpected expenses', 'Luxury', 'Gambling', 'Friends'], optionsHindi: ['Unexpected', 'Luxury', 'Gambling', 'Friends'], correctIndex: 0, explanation: 'For unexpected expenses.', explanationHindi: 'Unexpected ke liye.')),
        ]),
      ],
      quiz: [
        QuizQuestion(question: 'Saving vs Investing?', questionHindi: 'Bachat vs Investment?', options: ['Investing grows more', 'Same', 'Saving better', 'Rich only'], optionsHindi: ['Investment zyada', 'Same', 'Bachat better', 'Ameer'], correctIndex: 0),
      ],
    ),
    ModuleModel(
      id: 'module_2', number: 2, title: 'Mutual Funds', titleHindi: 'Mutual Funds', description: 'Learn mutual funds', descriptionHindi: 'MF seekho', icon: '', difficulty: 'beginner', xpReward: 120, badgeId: 'mf_expert', requiredModules: 1,
      lessons: [
        LessonModel(id: 'l2_1', title: 'What are MFs?', titleHindi: 'MF Kya?', durationMinutes: 4, difficulty: 'beginner', xpReward: 35, contentBlocks: [
          LessonContent.text('MF pools money from investors.'),
          LessonContent.keyPoint('Benefits: Professional, Diversified, Low min'),
          LessonContent.checkpoint(CheckpointQuestion(question: 'Who manages MF?', questionHindi: 'MF kaun manage?', options: ['Professional managers', 'Investor', 'Government', 'Bank'], optionsHindi: ['Managers', 'Investor', 'Govt', 'Bank'], correctIndex: 0, explanation: 'Professional managers.', explanationHindi: 'Professional managers.')),
        ]),
        LessonModel(id: 'l2_2', title: 'What is SIP?', titleHindi: 'SIP Kya?', durationMinutes: 4, difficulty: 'beginner', xpReward: 35, contentBlocks: [
          LessonContent.text('SIP is regular investing.'),
          LessonContent.keyPoint('Benefits: Averaging, Discipline, Compounding'),
          LessonContent.checkpoint(CheckpointQuestion(question: 'Min SIP amount?', questionHindi: 'Min SIP?', options: ['Rs100', 'Rs1000', 'Rs10000', 'Rs50000'], optionsHindi: ['Rs100', 'Rs1000', 'Rs10000', 'Rs50000'], correctIndex: 0, explanation: 'Start with Rs100!', explanationHindi: 'Rs100 se shuru!')),
        ]),
      ],
      quiz: [
        QuizQuestion(question: 'SIP full form?', questionHindi: 'SIP?', options: ['Systematic Investment Plan', 'Simple', 'Standard', 'Special'], optionsHindi: ['Systematic', 'Simple', 'Standard', 'Special'], correctIndex: 0),
      ],
    ),
    ModuleModel(
      id: 'module_3', number: 3, title: 'Understanding Risk', titleHindi: 'Risk Samjho', description: 'Learn about risk', descriptionHindi: 'Risk seekho', icon: '', difficulty: 'intermediate', xpReward: 150, badgeId: 'risk_aware', requiredModules: 2,
      lessons: [
        LessonModel(id: 'l3_1', title: 'What is Risk?', titleHindi: 'Risk Kya?', durationMinutes: 5, difficulty: 'intermediate', xpReward: 45, contentBlocks: [
          LessonContent.text('Risk is possibility of loss.'),
          LessonContent.keyPoint('Types: Market, Inflation, Liquidity, Credit'),
          LessonContent.checkpoint(CheckpointQuestion(question: 'What is market risk?', questionHindi: 'Market risk?', options: ['Market decline', 'Bank failure', 'Theft', 'Fraud'], optionsHindi: ['Market girna', 'Bank fail', 'Chori', 'Fraud'], correctIndex: 0, explanation: 'When market declines.', explanationHindi: 'Jab market gire.')),
        ]),
        LessonModel(id: 'l3_2', title: 'Diversification', titleHindi: 'Diversification', durationMinutes: 5, difficulty: 'intermediate', xpReward: 50, contentBlocks: [
          LessonContent.text('Spread investments to reduce risk.'),
          LessonContent.keyPoint('Diversify: Assets, Sectors, Caps, Time'),
          LessonContent.checkpoint(CheckpointQuestion(question: 'Diversification benefit?', questionHindi: 'Diversification fayda?', options: ['Reduces risk', 'Guarantees profit', 'No risk', 'More returns'], optionsHindi: ['Risk kam', 'Profit pakka', 'No risk', 'Zyada returns'], correctIndex: 0, explanation: 'Spreads risk.', explanationHindi: 'Risk spread hota hai.')),
        ]),
      ],
      quiz: [
        QuizQuestion(question: 'Risk-return relation?', questionHindi: 'Risk-return?', options: ['Higher risk = higher return', 'No relation', 'Opposite', 'Same'], optionsHindi: ['Zyada risk = zyada return', 'No relation', 'Opposite', 'Same'], correctIndex: 0),
      ],
    ),
    ModuleModel(
      id: 'module_4', number: 4, title: 'Advanced Strategies', titleHindi: 'Advanced', description: 'Portfolio and tax', descriptionHindi: 'Portfolio aur tax', icon: '', difficulty: 'advanced', xpReward: 200, badgeId: 'advanced_investor', requiredModules: 3,
      lessons: [
        LessonModel(id: 'l4_1', title: 'Building Portfolio', titleHindi: 'Portfolio', durationMinutes: 6, difficulty: 'advanced', xpReward: 60, contentBlocks: [
          LessonContent.text('Portfolio is your investment collection.'),
          LessonContent.keyPoint('Steps: Goals, Risk, Allocation, Select, Review'),
          LessonContent.checkpoint(CheckpointQuestion(question: 'First step in portfolio?', questionHindi: 'Portfolio pehla step?', options: ['Define goals', 'Buy stocks', 'Follow tips', 'Invest all'], optionsHindi: ['Goals', 'Stocks', 'Tips', 'Sab invest'], correctIndex: 0, explanation: 'Start with goals.', explanationHindi: 'Goals se shuru.')),
        ]),
        LessonModel(id: 'l4_2', title: 'Tax Planning', titleHindi: 'Tax', durationMinutes: 6, difficulty: 'advanced', xpReward: 60, contentBlocks: [
          LessonContent.text('Tax planning keeps more returns.'),
          LessonContent.keyPoint('LTCG 10% above 1L, STCG 15%, ELSS 80C'),
          LessonContent.checkpoint(CheckpointQuestion(question: '80C deduction fund?', questionHindi: '80C fund?', options: ['ELSS', 'Liquid', 'Debt', 'Index'], optionsHindi: ['ELSS', 'Liquid', 'Debt', 'Index'], correctIndex: 0, explanation: 'ELSS gives 80C benefit.', explanationHindi: 'ELSS 80C deta hai.')),
        ]),
      ],
      quiz: [
        QuizQuestion(question: '100-age rule?', questionHindi: '100-age?', options: ['Equity allocation', 'Returns', 'Tax', 'Manager'], optionsHindi: ['Equity', 'Returns', 'Tax', 'Manager'], correctIndex: 0),
      ],
    ),
  ];
}
