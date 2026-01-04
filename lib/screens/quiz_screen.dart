import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../models/learning_model.dart';
import '../services/app_state.dart';
import '../services/language_service.dart';

class QuizScreen extends StatefulWidget {
  final ModuleModel module;
  const QuizScreen({super.key, required this.module});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  int _correctAnswers = 0;
  bool _showResultsScreen = false;
  bool _answerSubmitted = false;

  List<QuizQuestion> get _questions => widget.module.quiz;

  void _selectAnswer(int index) {
    if (_answerSubmitted) return;
    setState(() => _selectedAnswer = index);
  }

  void _submitAnswer() {
    if (_selectedAnswer == null || _answerSubmitted) return;
    setState(() => _answerSubmitted = true);
    if (_selectedAnswer == _questions[_currentQuestionIndex].correctIndex) _correctAnswers++;
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() { _currentQuestionIndex++; _selectedAnswer = null; _answerSubmitted = false; });
    } else {
      _showResults();
    }
  }

  Future<void> _showResults() async {
    final appState = context.read<AppState>();
    await appState.completeQuiz(widget.module.id, _correctAnswers, _questions.length);
    if (!mounted) return;
    setState(() => _showResultsScreen = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_showResultsScreen) return _buildResults();
    if (_questions.isEmpty) return _buildNoQuestions();
    final question = _questions[_currentQuestionIndex];
    final langService = context.watch<LanguageService>();
    final isHindi = langService.currentLanguage != AppLanguage.english;
    final questionText = isHindi ? question.questionHindi : question.question;
    final options = isHindi ? question.optionsHindi : question.options;
    final explanation = isHindi ? (question.explanationHindi ?? question.explanation) : question.explanation;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: Text(isHindi ? 'क्विज़: ${widget.module.titleHindi}' : 'Quiz: ${widget.module.title}'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => _showExitConfirmation()),
        actions: [
          IconButton(
            icon: Icon(
              langService.isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
              color: langService.isSpeaking ? AppColors.error : AppColors.textPrimary,
            ),
            onPressed: () async {
              final svc = LanguageService();
              if (svc.isSpeaking) {
                await svc.stop();
              } else {
                await svc.speak(questionText);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isHindi ? 'प्रश्न ${_currentQuestionIndex + 1} / ${_questions.length}' : 'Question ${_currentQuestionIndex + 1} of ${_questions.length}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (_currentQuestionIndex + 1) / _questions.length, minHeight: 6, backgroundColor: AppColors.divider, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary))),
            const SizedBox(height: 32),
            Text(questionText, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            ...List.generate(options.length, (index) {
              final isSelected = _selectedAnswer == index;
              final isCorrect = index == question.correctIndex;
              final showResult = _answerSubmitted;
              Color bgColor = AppColors.cardBg, borderColor = AppColors.divider, textColor = AppColors.textPrimary;
              if (showResult) {
                if (isCorrect) { bgColor = AppColors.successLight; borderColor = AppColors.success; textColor = AppColors.success; }
                else if (isSelected) { bgColor = AppColors.errorLight; borderColor = AppColors.error; textColor = AppColors.error; }
              } else if (isSelected) { bgColor = AppColors.primary; borderColor = AppColors.primary; textColor = Colors.white; }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: _answerSubmitted ? null : () => _selectAnswer(index),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: bgColor, border: Border.all(color: borderColor, width: showResult && (isCorrect || isSelected) ? 2 : 1), borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                    child: Row(children: [
                      Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected && !showResult ? Colors.white : borderColor, width: 2), color: isSelected && !showResult ? AppColors.primary : Colors.transparent),
                        child: showResult ? Icon(isCorrect ? Icons.check_rounded : (isSelected ? Icons.close_rounded : null), size: 18, color: isCorrect ? AppColors.success : AppColors.error) : isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : Center(child: Text(String.fromCharCode(65 + index), style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)))),
                      const SizedBox(width: 14),
                      Expanded(child: Text(options[index], style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor, fontWeight: showResult && isCorrect ? FontWeight.w600 : FontWeight.w400))),
                    ]),
                  ),
                ),
              );
            }),
            if (_answerSubmitted && explanation != null) ...[
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.lightbulb_outline_rounded, color: AppColors.info), const SizedBox(width: 12), Expanded(child: Text(explanation, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.info)))])),
            ],
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _selectedAnswer == null ? null : _answerSubmitted ? _nextQuestion : _submitAnswer, child: Text(_answerSubmitted ? (_currentQuestionIndex < _questions.length - 1 ? (isHindi ? 'अगला प्रश्न' : 'Next Question') : (isHindi ? 'परिणाम देखें' : 'See Results')) : (isHindi ? 'जवाब दें' : 'Submit Answer')))),
          ],
        ),
      ),
    );
  }


  Widget _buildNoQuestions() {
    return Scaffold(backgroundColor: AppColors.warmWhite, appBar: AppBar(title: const Text('Quiz')),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.quiz_outlined, size: 64, color: AppColors.textSecondary), const SizedBox(height: 16),
        Text('No quiz questions available', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 24),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
      ])));
  }

  Widget _buildResults() {
    final score = _correctAnswers, total = _questions.length;
    final percentage = total > 0 ? (score / total * 100).round() : 0;
    final passed = percentage >= 60;
    final xpEarned = passed ? 30 + (score * 10) : score * 5;
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(title: const Text('Quiz Results'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(children: [
          const SizedBox(height: 32),
          Container(width: 140, height: 140, decoration: BoxDecoration(gradient: passed ? AppColors.successGradient : AppColors.primaryGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: (passed ? AppColors.success : AppColors.primary).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('$score/$total', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)), Text('$percentage%', style: const TextStyle(color: Colors.white70, fontSize: 16))]))),
          const SizedBox(height: 32),
          Text(passed ? percentage >= 80 ? 'Excellent! 🎉' : 'Good Job! 👍' : 'Keep Learning! 📚', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(passed ? 'You passed the quiz!' : 'You need 60% to pass. Try again!', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: passed ? AppColors.successLight : AppColors.warningLight, borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.star_rounded, color: passed ? AppColors.success : AppColors.warning, size: 28), const SizedBox(width: 12), Text('+$xpEarned XP', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: passed ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w700))])),
          if (passed && widget.module.badgeId != null) ...[
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusMedium), border: Border.all(color: AppColors.gold)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('🏆', style: TextStyle(fontSize: 28)), const SizedBox(width: 12), Text('Badge Earned!', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gold, fontWeight: FontWeight.w600))])),
          ],
          const SizedBox(height: 40),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(passed ? 'Continue Learning' : 'Back to Lessons'))),
          const SizedBox(height: 12),
          if (!passed) SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => setState(() { _currentQuestionIndex = 0; _selectedAnswer = null; _correctAnswers = 0; _showResultsScreen = false; _answerSubmitted = false; }), child: const Text('Retake Quiz'))),
        ]),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Exit Quiz?'), content: const Text('Your progress will be lost if you exit now.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Exit'))]));
  }
}
