import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'quiz_screen.dart';

class LessonViewScreen extends StatefulWidget {
  final int moduleNumber;
  final String moduleTitle;
  final int totalLessons;
  final int completedLessons;

  const LessonViewScreen({
    super.key,
    required this.moduleNumber,
    required this.moduleTitle,
    required this.totalLessons,
    required this.completedLessons,
  });

  @override
  State<LessonViewScreen> createState() => _LessonViewScreenState();
}

class _LessonViewScreenState extends State<LessonViewScreen> {
  late int _currentLessonIndex;

  final List<List<Map<String, String>>> _lessons = [
    // Module 1: What is Money?
    [
      {
        'title': 'What is Money?',
        'content':
            'Money is a medium of exchange that people use to buy goods and services. It makes trading easier than bartering (trading goods directly).\n\nThink of money as a tool that helps people exchange things. Instead of trading a cow for rice, you can use money to buy what you need.',
      },
      {
        'title': 'Why Do We Need Money?',
        'content':
            'Money helps us in many ways:\n\n• Buy things we need - food, clothes, shelter\n• Save for the future - keep money for later use\n• Measure value - know how much things cost\n• Make trading simple - no need to find someone who wants what you have',
      },
      {
        'title': 'How Money Works',
        'content':
            'When you work, you earn money. You can then use that money to buy things you need or want.\n\nThe money you don\'t spend right away can be:\n• Saved - kept safe for future use\n• Invested - put somewhere to grow over time',
      },
      {
        'title': 'Saving Money',
        'content':
            'Saving means keeping money aside for future use. It\'s safe but doesn\'t grow much.\n\nExample: If you save ₹100 today, it will still be ₹100 tomorrow (or maybe ₹101 with bank interest).\n\nSaving is good for:\n• Emergency needs\n• Short-term goals\n• Safety',
      },
      {
        'title': 'Investing Money',
        'content':
            'Investing means putting money in places where it can grow over time.\n\nExample: If you invest ₹100 today, it could become ₹110 or more in the future.\n\nInvesting is good for:\n• Long-term goals\n• Making your money grow\n• Building wealth over time',
      },
    ],
  ];

  @override
  void initState() {
    super.initState();
    // Start from the first incomplete lesson
    _currentLessonIndex = widget.completedLessons;
    // Make sure we don't go beyond available lessons
    if (_currentLessonIndex >= _lessons[widget.moduleNumber - 1].length) {
      _currentLessonIndex = _lessons[widget.moduleNumber - 1].length - 1;
    }
  }

  Future<void> _completeLesson() async {
    if (_currentLessonIndex < widget.completedLessons) {
      // Already completed, just move to quiz
      _navigateToQuiz();
      return;
    }

    // Mark lesson as completed
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getInt('completed_lessons') ?? 0;
    await prefs.setInt('completed_lessons', completed + 1);

    // Award XP
    final xp = prefs.getInt('total_xp') ?? 0;
    await prefs.setInt('total_xp', xp + 50);

    // Check level up
    final currentLevel = prefs.getInt('current_level') ?? 1;
    final newLevel = (xp + 50) ~/ 1000 + 1;
    if (newLevel > currentLevel) {
      await prefs.setInt('current_level', newLevel);
    }

    if (!mounted) return;
    _navigateToQuiz();
  }

  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          moduleNumber: widget.moduleNumber,
          lessonNumber: _currentLessonIndex + 1,
        ),
      ),
    ).then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _lessons[widget.moduleNumber - 1];
    
    // Safety check
    if (_currentLessonIndex >= lessons.length) {
      _currentLessonIndex = 0;
    }
    if (_currentLessonIndex < 0) {
      _currentLessonIndex = 0;
    }
    
    final currentLesson = lessons[_currentLessonIndex];

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: Text(widget.moduleTitle),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Lesson ${_currentLessonIndex + 1} of ${lessons.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.blackSecondary,
                      ),
                ),
                const Spacer(),
                Text(
                  '${((_currentLessonIndex + 1) / lessons.length * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.blackSecondary,
                      ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.dividerColor),
          
          // Lesson content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentLesson['title']!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    currentLesson['content']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.pureBlack,
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.dividerColor),
              ),
            ),
            child: Row(
              children: [
                if (_currentLessonIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentLessonIndex--;
                        });
                      },
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentLessonIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentLessonIndex < lessons.length - 1) {
                        setState(() {
                          _currentLessonIndex++;
                        });
                      } else {
                        _completeLesson();
                      }
                    },
                    child: Text(
                      _currentLessonIndex < lessons.length - 1
                          ? 'Next'
                          : 'Complete & Take Quiz',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

