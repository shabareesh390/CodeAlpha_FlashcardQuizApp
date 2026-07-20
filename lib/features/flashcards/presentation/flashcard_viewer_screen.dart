import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/flip_card.dart';
import 'package:confetti/confetti.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/flashcard.dart';
import 'providers/flashcards_provider.dart';
import '../../statistics/presentation/providers/stats_provider.dart';

class FlashcardViewerScreen extends ConsumerStatefulWidget {
  const FlashcardViewerScreen({super.key});

  @override
  ConsumerState<FlashcardViewerScreen> createState() => _FlashcardViewerScreenState();
}

class _FlashcardViewerScreenState extends ConsumerState<FlashcardViewerScreen> {
  final GlobalKey<FlipCardState> _flipCardKey = GlobalKey<FlipCardState>();
  late ConfettiController _confettiController;
  int _currentIndex = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _nextCard(int totalCards) {
    if (_currentIndex < totalCards - 1) {
      setState(() {
        _currentIndex++;
      });
      _flipCardKey.currentState?.reset();
    } else if (!_isFinished) {
      setState(() {
        _isFinished = true;
      });
      _confettiController.play();
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _flipCardKey.currentState?.reset();
    }
  }

  void _markLearned(int totalCards, dynamic currentCard) {
    ref.read(statsProvider.notifier).recordAnswer(isCorrect: true);
    _nextCard(totalCards);
  }

  void _markForgot(int totalCards, dynamic currentCard) {
    ref.read(statsProvider.notifier).recordAnswer(isCorrect: false);
    _nextCard(totalCards);
  }

  @override
  Widget build(BuildContext context) {
    final flashcardsState = ref.watch(flashcardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: flashcardsState.when(
          data: (cards) => Text('${_currentIndex + 1} / ${cards.length}'),
          loading: () => const Text('Loading...'),
          error: (err, stack) => const Text('Error'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddFlashcardDialog(context, ref),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                flashcardsState.whenData((cards) {
                  if (cards.isNotEmpty) {
                    final validIndex = _currentIndex < cards.length ? _currentIndex : cards.length - 1;
                    final currentCard = cards[validIndex];
                    ref.read(flashcardsProvider.notifier).deleteFlashcard(currentCard.id);
                    setState(() {
                      if (_currentIndex >= cards.length - 1 && _currentIndex > 0) {
                        _currentIndex--;
                      } else if (cards.length <= 1) {
                        _isFinished = false;
                        _currentIndex = 0;
                      }
                      _flipCardKey.currentState?.reset();
                    });
                  }
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Flashcard', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: flashcardsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(child: Text('No flashcards yet. Create some!'));
          }

          int validIndex = _currentIndex;
          if (validIndex >= cards.length) {
            validIndex = cards.length - 1;
          }
          final currentCard = cards[validIndex];
          
          bool showFinished = _isFinished;
          if (showFinished && validIndex < cards.length - 1) {
            showFinished = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _isFinished) setState(() => _isFinished = false);
            });
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Progress Bar
                      LinearProgressIndicator(
                        value: (_currentIndex + 1) / cards.length,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 8,
                      ).animate().fadeIn(duration: 400.ms),
                      
                      const SizedBox(height: 48),
                      
                      if (showFinished)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ConfettiWidget(
                                  confettiController: _confettiController,
                                  blastDirectionality: BlastDirectionality.explosive,
                                  shouldLoop: false,
                                  colors: const [AppColors.primary, AppColors.secondary, Colors.yellow, Colors.pink],
                                ),
                                Text(
                                  'Deck Completed!',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Back to Subjects'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: FlipCard(
                            key: ValueKey(_currentIndex), // Force rebuild of FlipCard on index change
                            front: _buildCardFace(context, currentCard.question, 'Question', AppColors.primary),
                            back: _buildCardFace(context, currentCard.answer, 'Answer', AppColors.secondary),
                          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                        ),
                      
                      const SizedBox(height: 48),
                      
                      if (!showFinished)
                        // Controls
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton.filledTonal(
                                onPressed: _prevCard,
                                icon: const Icon(Icons.arrow_back),
                                iconSize: 32,
                                padding: const EdgeInsets.all(16),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () => _markForgot(cards.length, currentCard),
                                icon: const Icon(Icons.close),
                                label: const Text('Forgot'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () => _markLearned(cards.length, currentCard),
                                icon: const Icon(Icons.check),
                                label: const Text('Learned'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton.filledTonal(
                                onPressed: () => _nextCard(cards.length),
                                icon: const Icon(Icons.arrow_forward),
                                iconSize: 32,
                                padding: const EdgeInsets.all(16),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5, end: 0),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFace(BuildContext context, String text, String label, Color accentColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: accentColor.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accentColor,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            text,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Text(
            'Tap to flip',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFlashcardDialog(BuildContext context, WidgetRef ref) {
    final qController = TextEditingController();
    final aController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qController,
              decoration: const InputDecoration(hintText: 'Question'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: aController,
              decoration: const InputDecoration(hintText: 'Answer'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final q = qController.text.trim();
              final a = aController.text.trim();
              if (q.isNotEmpty && a.isNotEmpty) {
                final subjectId = ref.read(selectedSubjectIdProvider);
                if (subjectId != null) {
                  final newCard = Flashcard(
                    id: const Uuid().v4(),
                    subjectId: subjectId,
                    question: q,
                    answer: a,
                    createdAt: DateTime.now(),
                  );
                  
                  ref.read(flashcardsProvider.notifier).addFlashcard(newCard);
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
