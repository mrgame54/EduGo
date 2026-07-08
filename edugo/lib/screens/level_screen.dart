import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subject.dart';
import 'quiz_screen.dart';

class LevelScreen extends StatelessWidget {
  final Subject subject;
  const LevelScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HEADER ───
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: subject.color,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      subject.color,
                      subject.shadowColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        subject.emoji,
                        style: const TextStyle(fontSize: 56),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subject.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Level ${subject.level} erreicht!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── LEVELS LIST ───
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final level = subject.levels[index];
                  return _LevelTile(
                    level: level,
                    subject: subject,
                    index: index,
                  );
                },
                childCount: subject.levels.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final LevelData level;
  final Subject subject;
  final int index;

  const _LevelTile({
    required this.level,
    required this.subject,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: level.isUnlocked
            ? () {
                HapticFeedback.lightImpact();
                // Build dummy questions for offline subjects
                final dummyQuestions = [
                  {
                    'question_text': 'Was passt am besten zum Thema ${subject.name}?',
                    'options': ['Option A', 'Option B', 'Option C', 'Option D'],
                    'correct_answer': 'Option B',
                  },
                  {
                    'question_text': 'Wähle die richtige Antwort für Level ${level.levelNumber}.',
                    'options': ['Falsch', 'Auch Falsch', 'Richtig', 'Ganz Falsch'],
                    'correct_answer': 'Richtig',
                  },
                  {
                    'question_text': 'Letzte Frage! Bist du bereit?',
                    'options': ['Nein', 'Vielleicht', 'Ja, absolut!', 'Weiß nicht'],
                    'correct_answer': 'Ja, absolut!',
                  },
                ];
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        QuizScreen(
                          quizTitle: '${subject.name} - ${level.title}',
                          questions: dummyQuestions,
                          subjectColor: subject.color,
                          subjectShadowColor: subject.shadowColor,
                          subjectEmoji: subject.emoji,
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      );
                    },
                  ),
                );
              }
            : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: level.isUnlocked ? Colors.white : const Color(0xFFF0F2F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: level.isUnlocked
                  ? (level.isCompleted
                      ? subject.color.withOpacity(0.3)
                      : const Color(0xFFEEEEEE))
                  : const Color(0xFFE0E0E0),
              width: 2,
            ),
            boxShadow: level.isUnlocked
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Level number circle
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: level.isUnlocked
                      ? (level.isCompleted
                          ? subject.color
                          : subject.color.withOpacity(0.12))
                      : const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: level.isUnlocked
                      ? (level.isCompleted
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 28)
                          : Text(
                              '${level.levelNumber}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: subject.shadowColor,
                              ),
                            ))
                      : const Icon(Icons.lock_rounded,
                          color: Color(0xFFBBBBBB), size: 24),
                ),
              ),
              const SizedBox(width: 16),
              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${level.levelNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: level.isUnlocked
                            ? subject.color
                            : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: level.isUnlocked
                            ? const Color(0xFF3C3C3C)
                            : Colors.grey[400],
                      ),
                    ),
                    if (level.isCompleted && level.stars > 0) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: List.generate(3, (i) {
                          return Icon(
                            i < level.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: i < level.stars
                                ? const Color(0xFFFFD700)
                                : Colors.grey[300],
                            size: 18,
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow or lock
              if (level.isUnlocked && !level.isCompleted)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: subject.color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: subject.shadowColor,
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 22),
                ),
              if (level.isCompleted)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: subject.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.replay_rounded,
                      color: subject.color, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}