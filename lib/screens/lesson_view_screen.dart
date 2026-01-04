import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../models/learning_model.dart';
import '../services/app_state.dart';
import '../services/language_service.dart';
import 'quiz_screen.dart';

class LessonViewScreen extends StatefulWidget {
  final ModuleModel module;
  final int startLessonIndex;

  const LessonViewScreen({
    super.key,
    required this.module,
    this.startLessonIndex = 0,
  });

  @override
  State<LessonViewScreen> createState() => _LessonViewScreenState();
}

class _LessonViewScreenState extends State<LessonViewScreen> {
  late int _currentLessonIndex;
  late ScrollController _scrollController;
  
  // Checkpoint state
  Map<int, int?> _checkpointAnswers = {};
  Map<int, bool> _checkpointSubmitted = {};

  @override
  void initState() {
    super.initState();
    _currentLessonIndex = widget.startLessonIndex;
    if (_currentLessonIndex >= widget.module.lessons.length) {
      _currentLessonIndex = widget.module.lessons.length - 1;
    }
    if (_currentLessonIndex < 0) _currentLessonIndex = 0;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    LanguageService().stop();
    super.dispose();
  }

  void _resetCheckpoints() {
    _checkpointAnswers = {};
    _checkpointSubmitted = {};
  }

  bool _allCheckpointsCompleted(LessonModel lesson) {
    int checkpointCount = 0;
    for (var block in lesson.contentBlocks) {
      if (block.type == ContentType.checkpoint) {
        if (_checkpointSubmitted[checkpointCount] != true) return false;
        checkpointCount++;
      }
    }
    return true;
  }

  Future<void> _completeLesson() async {
    final appState = context.read<AppState>();
    final currentLesson = widget.module.lessons[_currentLessonIndex];
    
    await appState.completeLesson(widget.module.id, currentLesson.id);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text('Lesson completed! +${currentLesson.xpReward} XP'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    if (_currentLessonIndex >= widget.module.lessons.length - 1) {
      _navigateToQuiz();
    } else {
      setState(() {
        _currentLessonIndex++;
        _resetCheckpoints();
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    }
  }

  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(module: widget.module)),
    ).then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessons = widget.module.lessons;
    final currentLesson = lessons[_currentLessonIndex];
    final appState = context.watch<AppState>();
    final isCompleted = appState.isLessonCompleted(currentLesson.id);
    final canComplete = _allCheckpointsCompleted(currentLesson) || isCompleted;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: Text(widget.module.title),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentLessonIndex + 1}/${lessons.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentLessonIndex + 1) / lessons.length,
            minHeight: 4,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          
          // Lesson content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lesson header
                  _buildLessonHeader(currentLesson, isCompleted),
                  const SizedBox(height: 24),
                  
                  // Content blocks
                  _buildContentBlocks(currentLesson),
                  
                  const SizedBox(height: 24),
                  
                  // XP reward card
                  if (!isCompleted) _buildXPCard(currentLesson),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Bottom navigation
          _buildBottomNav(lessons, isCompleted, canComplete),
        ],
      ),
    );
  }

  Widget _buildLessonHeader(LessonModel lesson, bool isCompleted) {
    final langService = context.watch<LanguageService>();
    final isHindi = langService.currentLanguage != AppLanguage.english;
    final title = isHindi ? lesson.titleHindi : lesson.title;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildDifficultyBadge(lesson.difficulty),
            const SizedBox(width: 8),
            Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('${lesson.durationMinutes} min', style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            // Voice button
            IconButton(
              icon: Icon(
                langService.isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                color: langService.isSpeaking ? AppColors.error : AppColors.primary,
              ),
              onPressed: () async {
                final svc = LanguageService();
                if (svc.isSpeaking) {
                  await svc.stop();
                } else {
                  final allText = lesson.contentBlocks
                      .where((b) => b.type != ContentType.checkpoint)
                      .map((b) => isHindi ? (b.textHindi ?? b.text) : b.text)
                      .join('. ');
                  await svc.speak('$title. $allText');
                }
              },
            ),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                    SizedBox(width: 4),
                    Text('Completed', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = AppColors.success;
        break;
      case 'intermediate':
        color = AppColors.warning;
        break;
      case 'advanced':
        color = AppColors.error;
        break;
      default:
        color = AppColors.primary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildContentBlocks(LessonModel lesson) {
    int checkpointIndex = 0;
    final langService = context.watch<LanguageService>();
    final isHindi = langService.currentLanguage != AppLanguage.english;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lesson.contentBlocks.map((block) {
        final text = isHindi ? (block.textHindi ?? block.text) : block.text;
        switch (block.type) {
          case ContentType.text:
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7)),
            );
          case ContentType.tip:
            return _buildTipCard(text);
          case ContentType.example:
            return _buildExampleCard(text);
          case ContentType.keyPoint:
            return _buildKeyPointCard(text);
          case ContentType.checkpoint:
            final idx = checkpointIndex++;
            return _buildCheckpointCard(block.checkpoint!, idx);
        }
      }).toList(),
    );
  }

  Widget _buildTipCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tip', style: TextStyle(color: AppColors.info, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.info)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📝', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Example', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPointCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔑', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Key Point', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckpointCard(CheckpointQuestion checkpoint, int index) {
    final selectedAnswer = _checkpointAnswers[index];
    final isSubmitted = _checkpointSubmitted[index] ?? false;
    final isCorrect = selectedAnswer == checkpoint.correctIndex;
    final langService = context.watch<LanguageService>();
    final isHindi = langService.currentLanguage != AppLanguage.english;
    final question = isHindi ? checkpoint.questionHindi : checkpoint.question;
    final options = isHindi ? checkpoint.optionsHindi : checkpoint.options;
    final explanation = isHindi ? checkpoint.explanationHindi : checkpoint.explanation;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSubmitted 
            ? (isCorrect ? AppColors.successLight : AppColors.errorLight)
            : AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: isSubmitted 
              ? (isCorrect ? AppColors.success : AppColors.error)
              : AppColors.accent.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✓ CHECKPOINT',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  langService.isSpeaking ? Icons.stop_circle : Icons.volume_up,
                  color: langService.isSpeaking ? AppColors.error : AppColors.accent,
                  size: 20,
                ),
                onPressed: () async {
                  final svc = LanguageService();
                  if (svc.isSpeaking) {
                    await svc.stop();
                  } else {
                    await svc.speak(question);
                  }
                },
              ),
              if (isSubmitted)
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isCorrect ? AppColors.success : AppColors.error,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          
          // Options
          ...List.generate(options.length, (optIndex) {
            final isSelected = selectedAnswer == optIndex;
            final showCorrect = isSubmitted && optIndex == checkpoint.correctIndex;
            final showWrong = isSubmitted && isSelected && !isCorrect;
            
            Color bgColor = AppColors.cardBg;
            Color borderColor = AppColors.divider;
            
            if (showCorrect) {
              bgColor = AppColors.successLight;
              borderColor = AppColors.success;
            } else if (showWrong) {
              bgColor = AppColors.errorLight;
              borderColor = AppColors.error;
            } else if (isSelected && !isSubmitted) {
              bgColor = AppColors.accent.withOpacity(0.1);
              borderColor = AppColors.accent;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: isSubmitted ? null : () => setState(() => _checkpointAnswers[index] = optIndex),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: isSelected || showCorrect ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected && !isSubmitted ? AppColors.accent : Colors.transparent,
                          border: Border.all(
                            color: isSelected && !isSubmitted ? AppColors.accent : AppColors.textSecondary,
                            width: 2,
                          ),
                        ),
                        child: isSelected && !isSubmitted
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : showCorrect
                                ? const Icon(Icons.check, size: 14, color: AppColors.success)
                                : showWrong
                                    ? const Icon(Icons.close, size: 14, color: AppColors.error)
                                    : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          options[optIndex],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          
          // Submit button or explanation
          if (!isSubmitted && selectedAnswer != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _checkpointSubmitted[index] = true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                child: Text(isHindi ? 'जवाब देखें' : 'Check Answer'),
              ),
            ),
          
          if (isSubmitted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isCorrect ? Icons.lightbulb_rounded : Icons.info_rounded,
                    color: isCorrect ? AppColors.success : AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      explanation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildXPCard(LessonModel lesson) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete this lesson to earn',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '+${lesson.xpReward} XP',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(List<LessonModel> lessons, bool isCompleted, bool canComplete) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentLessonIndex > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentLessonIndex--;
                      _resetCheckpoints();
                      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                    });
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Previous'),
                ),
              ),
            if (_currentLessonIndex > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: canComplete
                    ? () {
                        if (_currentLessonIndex < lessons.length - 1) {
                          if (!isCompleted) {
                            _completeLesson();
                          } else {
                            setState(() {
                              _currentLessonIndex++;
                              _resetCheckpoints();
                              _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                            });
                          }
                        } else {
                          if (!isCompleted) {
                            _completeLesson();
                          } else {
                            _navigateToQuiz();
                          }
                        }
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentLessonIndex < lessons.length - 1
                          ? (isCompleted ? 'Next Lesson' : 'Complete & Continue')
                          : (isCompleted ? 'Take Quiz' : 'Complete & Take Quiz'),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentLessonIndex < lessons.length - 1 
                          ? Icons.arrow_forward_rounded 
                          : Icons.quiz_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
