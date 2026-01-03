import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final int moduleNumber;
  final int lessonNumber;

  const QuizScreen({
    super.key,
    required this.moduleNumber,
    required this.lessonNumber,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  int _correctAnswers = 0;
  bool _showResultsScreen = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is money?',
      'options': [
        'A medium of exchange',
        'Only coins and notes',
        'Something only rich people have',
      ],
      'correct': 0,
    },
    {
      'question': 'What happens when you save money?',
      'options': [
        'It stays the same amount',
        'It automatically grows',
        'It disappears',
      ],
      'correct': 0,
    },
    {
      'question': 'What happens when you invest money?',
      'options': [
        'It can grow over time',
        'It always stays the same',
        'You lose it immediately',
      ],
      'correct': 0,
    },
  ];

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
    });
  }

  void _nextQuestion() {
    if (_selectedAnswer == null) return;

    if (_selectedAnswer == _questions[_currentQuestionIndex]['correct']) {
      _correctAnswers++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      _showResults();
    }
  }

  Future<void> _showResults() async {
    setState(() {
      _showResultsScreen = true;
    });

    // Award XP based on score
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt('total_xp') ?? 0;
    final xpEarned = (_correctAnswers * 10) + 20; // Base 20 + 10 per correct
    await prefs.setInt('total_xp', xp + xpEarned);

    // Check level up
    final currentLevel = prefs.getInt('current_level') ?? 1;
    final newLevel = (xp + xpEarned) ~/ 1000 + 1;
    if (newLevel > currentLevel) {
      await prefs.setInt('current_level', newLevel);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showResultsScreen) {
      return _buildResults();
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.blackSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                minHeight: 4,
                backgroundColor: AppColors.dividerColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.pureBlack,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Question
            Text(
              question['question'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.pureBlack,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Options
            ...List.generate(
              question['options'].length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _selectAnswer(index),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedAnswer == index
                          ? AppColors.pureBlack
                          : AppColors.warmWhite,
                      border: Border.all(
                        color: _selectedAnswer == index
                            ? AppColors.pureBlack
                            : AppColors.dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedAnswer == index
                                  ? AppColors.warmWhite
                                  : AppColors.pureBlack,
                              width: 2,
                            ),
                            color: _selectedAnswer == index
                                ? AppColors.pureBlack
                                : Colors.transparent,
                          ),
                          child: _selectedAnswer == index
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: AppColors.warmWhite,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question['options'][index],
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: _selectedAnswer == index
                                      ? AppColors.warmWhite
                                      : AppColors.pureBlack,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Next button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAnswer == null ? null : _nextQuestion,
                child: Text(
                  _currentQuestionIndex < _questions.length - 1
                      ? 'Next'
                      : 'Submit',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final score = _correctAnswers;
    final total = _questions.length;
    final percentage = (score / total * 100).round();
    final xpEarned = (score * 10) + 20;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Quiz Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            // Score
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.pureBlack,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$score/$total',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.warmWhite,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              percentage >= 80
                  ? 'Excellent! 🎉'
                  : percentage >= 60
                      ? 'Good Job! 👍'
                      : 'Keep Learning! 📚',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.pureBlack,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You got $score out of $total correct',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.blackSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            
            // XP earned
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.warmWhite,
                border: Border.all(color: AppColors.dividerColor),
                borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppColors.pureBlack),
                  const SizedBox(width: 8),
                  Text(
                    '+$xpEarned XP',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Continue Learning'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
              setState(() {
                _currentQuestionIndex = 0;
                _selectedAnswer = null;
                _correctAnswers = 0;
                _showResultsScreen = false;
              });
              },
              child: const Text('Retake Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

