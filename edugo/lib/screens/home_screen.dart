import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subject.dart';
import '../widgets/subject_card.dart';
import '../widgets/streak_flame.dart';
import '../widgets/robot_avatar.dart';
import '../services/api_service.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _teacherQuizzes = [];
  bool _loadingQuizzes = true;

  List<Subject> _subjects = [];
  bool _loadingSubjects = true;

  @override
  void initState() {
    super.initState();
    _fetchTeacherQuizzes();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      final subjectsData = await ApiService.fetchSubjects();
      final List<Subject> parsed = subjectsData.map((s) => Subject.fromJson(s)).toList();
      if (mounted) {
        setState(() {
          _subjects = parsed;
          _loadingSubjects = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
      if (mounted) {
        setState(() {
          _loadingSubjects = false;
        });
      }
    }
  }

  Future<void> _fetchTeacherQuizzes() async {
    try {
      final quizzes = await ApiService.fetchQuizzes();
      // Only display general/global quizzes in the "Lehrer-Quizzes" section.
      // Quizzes targeted at specific subject levels are played directly inside those levels.
      final globalQuizzes = quizzes.where((q) => q['level_number'] == null).toList();
      if (mounted) {
        setState(() {
          _teacherQuizzes = globalQuizzes;
          _loadingQuizzes = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching quizzes: $e');
      if (mounted) {
        setState(() {
          _loadingQuizzes = false;
        });
      }
    }
  }

  void _openTeacherQuiz(Map<String, dynamic> quiz) {
    HapticFeedback.lightImpact();
    final tasks = quiz['tasks'] as List<dynamic>;
    // Build quiz questions from backend data
    final questions = tasks.map<Map<String, dynamic>>((t) {
      final task = t as Map<String, dynamic>;
      return {
        'question_text': task['question_text'] ?? '',
        'options': List<String>.from(task['options'] ?? []),
        'correct_answer': task['correct_answer'] ?? '',
      };
    }).toList();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => QuizScreen(
          quizId: quiz['id'] as int,
          quizTitle: quiz['title'] ?? 'Quiz',
          questions: questions,
          subjectColor: const Color(0xFF1CB0F6),
          subjectShadowColor: const Color(0xFF1480B3),
          subjectEmoji: '📝',
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _GreetingSection(),
                    const SizedBox(height: 8),
                    _DailyStreakBanner(),
                    const SizedBox(height: 28),
                    // ─── TEACHER QUIZZES ───
                    if (!_loadingQuizzes && _teacherQuizzes.isNotEmpty) ...[
                      const _SectionLabel(label: 'Lehrer-Quizzes 📝'),
                      const SizedBox(height: 12),
                      _TeacherQuizList(
                        quizzes: _teacherQuizzes,
                        onQuizTap: _openTeacherQuiz,
                      ),
                      const SizedBox(height: 28),
                    ],
                    if (_loadingQuizzes) ...[
                      const _SectionLabel(label: 'Lehrer-Quizzes 📝'),
                      const SizedBox(height: 16),
                      const Center(
                        child: SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    const _SectionLabel(label: 'Fächer wählen'),
                    const SizedBox(height: 16),
                    if (_loadingSubjects) ...[
                      const Center(
                        child: SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ] else if (_subjects.isEmpty) ...[
                      const Center(
                        child: Text(
                          'Keine Fächer geladen.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ] else ...[
                      _SubjectGrid(
                        subjects: _subjects,
                        onRefresh: () {
                          _fetchSubjects();
                          _fetchTeacherQuizzes();
                        },
                      ),
                    ],
                    const SizedBox(height: 36),
                    _ProgressFooter(),
                    const SizedBox(height: 28),
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

// ─── HEADER ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1.5)),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3DD6F5), Color(0xFF1CB0F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1CB0F6).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text('🎓', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'EduGo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C2C2C),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          _HeaderIconBtn(icon: Icons.chat_bubble_outline_rounded),
          const SizedBox(width: 6),
          _HeaderIconBtn(icon: Icons.calendar_today_rounded),
          const SizedBox(width: 6),
          _HeaderIconBtn(icon: Icons.person_rounded),
        ],
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  const _HeaderIconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: const Color(0xFFB8BDD8), size: 20),
    );
  }
}

// ─── GREETING ─────────────────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hallo, Lernstar! 🌟',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2C2C2C),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Was lernst du heute?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // XP badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⚡', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 4),
                  Text(
                    '240 XP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE67E00),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STREAK BANNER ────────────────────────────────────────────────────────────

class _DailyStreakBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8F0), Color(0xFFFFF3E0)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFE0B2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9600).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const AnimatedStreakFlame(streakCount: 67, compact: true),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '67 Tage in Folge! 🔥',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFCC6600),
                  ),
                ),
                Text(
                  'Weiter so, du bist super!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[300],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9600),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCC6600),
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Text(
                'TOP!',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION LABEL ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C2C2C),
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

// ─── SUBJECT GRID ─────────────────────────────────────────────────────────────

class _SubjectGrid extends StatelessWidget {
  final List<Subject> subjects;
  final VoidCallback onRefresh;
  const _SubjectGrid({required this.subjects, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.88,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: subjects.asMap().entries.map((e) {
          return SubjectCard(
            subject: e.value,
            index: e.key,
            onRefresh: onRefresh,
          );
        }).toList(),
      ),
    );
  }
}

// ─── PROGRESS FOOTER ──────────────────────────────────────────────────────────

class _ProgressFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Expanded(child: Container(height: 1.5, color: const Color(0xFFEEEEEE))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Dein Fortschritt',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[400],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(child: Container(height: 1.5, color: const Color(0xFFEEEEEE))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const RobotAvatar(),
        const SizedBox(height: 6),
        Text(
          'Ich bin Edu! 🤖',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Dein Lernbegleiter',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }
}

// ─── TEACHER QUIZ LIST ────────────────────────────────────────────────────────

class _TeacherQuizList extends StatelessWidget {
  final List<Map<String, dynamic>> quizzes;
  final void Function(Map<String, dynamic>) onQuizTap;

  const _TeacherQuizList({required this.quizzes, required this.onQuizTap});

  static const _quizColors = [
    Color(0xFF1CB0F6),
    Color(0xFFFF4B4B),
    Color(0xFF58CC02),
    Color(0xFFCE82FF),
    Color(0xFFFF9600),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: quizzes.asMap().entries.map((entry) {
          final index = entry.key;
          final quiz = entry.value;
          final color = _quizColors[index % _quizColors.length];
          final taskCount = (quiz['tasks'] as List<dynamic>?)?.length ?? 0;
          final subject = quiz['subject'] ?? '';
          final grade = quiz['grade'] ?? '';

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + index * 80),
            curve: Curves.easeOutCubic,
            builder: (context, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - v)),
                child: child,
              ),
            ),
            child: GestureDetector(
              onTap: () => onQuizTap(quiz),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withValues(alpha: 0.25), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon circle
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('📝', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Quiz info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz['title'] ?? 'Quiz',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2C2C2C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$subject · $grade · $taskCount Fragen',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Play button
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            offset: const Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

