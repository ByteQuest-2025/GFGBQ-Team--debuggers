class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final DateTime createdAt;
  int totalXP;
  int currentLevel;
  int currentStreak;
  DateTime? lastActiveDate;
  String preferredLanguage;
  bool kycCompleted;
  List<String> earnedBadges;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
    this.totalXP = 0,
    this.currentLevel = 1,
    this.currentStreak = 0,
    this.lastActiveDate,
    this.preferredLanguage = 'en',
    this.kycCompleted = false,
    List<String>? earnedBadges,
  }) : earnedBadges = earnedBadges ?? [];

  String get levelName {
    if (currentLevel >= 4) return 'Pro';
    if (currentLevel >= 3) return 'Investor';
    if (currentLevel >= 2) return 'Learner';
    return 'Beginner';
  }

  int get xpForNextLevel => currentLevel * 1000;
  int get xpProgress => totalXP % 1000;
  double get levelProgress => xpProgress / 1000;

  void addXP(int xp) {
    totalXP += xp;
    // Check level up
    final newLevel = (totalXP ~/ 1000) + 1;
    if (newLevel > currentLevel) {
      currentLevel = newLevel;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'createdAt': createdAt.toIso8601String(),
    'totalXP': totalXP,
    'currentLevel': currentLevel,
    'currentStreak': currentStreak,
    'lastActiveDate': lastActiveDate?.toIso8601String(),
    'preferredLanguage': preferredLanguage,
    'kycCompleted': kycCompleted,
    'earnedBadges': earnedBadges,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    name: json['name'] ?? 'Investor',
    phoneNumber: json['phoneNumber'] ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    totalXP: json['totalXP'] ?? 0,
    currentLevel: json['currentLevel'] ?? 1,
    currentStreak: json['currentStreak'] ?? 0,
    lastActiveDate: json['lastActiveDate'] != null ? DateTime.tryParse(json['lastActiveDate']) : null,
    preferredLanguage: json['preferredLanguage'] ?? 'en',
    kycCompleted: json['kycCompleted'] ?? false,
    earnedBadges: List<String>.from(json['earnedBadges'] ?? []),
  );
}
