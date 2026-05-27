import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/subject.dart';
import 'quiz_screen.dart';

class LevelTreeScreen extends StatefulWidget {
  final Subject subject;
  const LevelTreeScreen({super.key, required this.subject});

  @override
  State<LevelTreeScreen> createState() => _LevelTreeScreenState();
}

class _LevelTreeScreenState extends State<LevelTreeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _treeController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _treeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200),
        () => _treeController.forward());
  }

  @override
  void dispose() {
    _headerController.dispose();
    _treeController.dispose();
    super.dispose();
  }

  // How many levels are done / total
  int get _completedCount =>
      widget.subject.levels.where((l) => l.isCompleted).length;
  int get _totalCount => widget.subject.levels.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: Column(
        children: [
          // ─── HEADER ───
          _TreeHeader(
            subject: widget.subject,
            controller: _headerController,
            completed: _completedCount,
            total: _totalCount,
          ),
          // ─── TREE ───
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: _LevelTree(
                subject: widget.subject,
                controller: _treeController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HEADER ──────────────────────────────────────────────────────────────────

class _TreeHeader extends StatelessWidget {
  final Subject subject;
  final AnimationController controller;
  final int completed;
  final int total;

  const _TreeHeader({
    required this.subject,
    required this.controller,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: controller,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [subject.color, subject.shadowColor],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Nav bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 5),
                              Text(
                                '$completed / $total',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Subject info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(subject.emoji,
                                style: const TextStyle(fontSize: 36)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: completed / total,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.25),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '$completed von $total Leveln abgeschlossen',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── LEVEL TREE ──────────────────────────────────────────────────────────────

class _LevelTree extends StatelessWidget {
  final Subject subject;
  final AnimationController controller;

  const _LevelTree({required this.subject, required this.controller});

  // Zigzag horizontal positions: alternate left/center/right
  static const List<double> _xOffsets = [
    -0.28, // left
    0.0,   // center
    0.28,  // right
    0.0,   // center
    -0.28,
    0.0,
    0.28,
    0.0,
  ];

  double _xFor(int i) => _xOffsets[i % _xOffsets.length];

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    const nodeH = 90.0;   // space per node
    const nodeSize = 76.0;
    final totalH = subject.levels.length * nodeH + 40;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          width: screenW,
          height: totalH,
          child: Stack(
            children: [
              // ── connector lines ──
              ...List.generate(subject.levels.length - 1, (i) {
                final level = subject.levels[i];
                final next = subject.levels[i + 1];

                final cx = screenW / 2;
                final x1 = cx + _xFor(i) * screenW;
                final y1 = 20 + i * nodeH + nodeSize / 2;
                final x2 = cx + _xFor(i + 1) * screenW;
                final y2 = 20 + (i + 1) * nodeH + nodeSize / 2;

                final lineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: controller,
                    curve: Interval(
                      (i / subject.levels.length) * 0.7,
                      ((i + 1) / subject.levels.length) * 0.7 + 0.1,
                      curve: Curves.easeOut,
                    ),
                  ),
                );

                return Positioned.fill(
                  child: CustomPaint(
                    painter: _ConnectorPainter(
                      x1: x1, y1: y1, x2: x2, y2: y2,
                      isDone: level.isCompleted && next.isUnlocked,
                      isUnlocked: next.isUnlocked,
                      progress: lineAnim.value,
                      color: subject.color,
                    ),
                  ),
                );
              }),

              // ── level nodes ──
              ...List.generate(subject.levels.length, (i) {
                final level = subject.levels[i];
                final cx = screenW / 2;
                final x = cx + _xFor(i) * screenW - nodeSize / 2;
                final y = 20.0 + i * nodeH;

                final nodeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: controller,
                    curve: Interval(
                      (i / subject.levels.length) * 0.75,
                      math.min(
                          (i / subject.levels.length) * 0.75 + 0.25, 1.0),
                      curve: Curves.elasticOut,
                    ),
                  ),
                );

                return Positioned(
                  left: x,
                  top: y,
                  width: nodeSize,
                  height: nodeSize,
                  child: Transform.scale(
                    scale: nodeAnim.value,
                    child: _LevelNode(
                      level: level,
                      subject: subject,
                      nodeSize: nodeSize,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ─── CONNECTOR PAINTER ───────────────────────────────────────────────────────

class _ConnectorPainter extends CustomPainter {
  final double x1, y1, x2, y2;
  final bool isDone;
  final bool isUnlocked;
  final double progress;
  final Color color;

  _ConnectorPainter({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.isDone,
    required this.isUnlocked,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    // Dashed background line
    final bgPaint = Paint()
      ..color = const Color(0xFFE8E8F0)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Active line
    final activePaint = Paint()
      ..color = isDone ? color : color.withOpacity(0.3)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(x1, y1);

    // Curved connector
    final midY = (y1 + y2) / 2;
    path.cubicTo(x1, midY, x2, midY, x2, y2);

    // Draw dashed bg
    _drawDashedPath(canvas, path, bgPaint);

    if (progress > 0) {
      // Animate the active line
      final metrics = path.computeMetrics().first;
      final extractPath =
          metrics.extractPath(0, metrics.length * progress);
      canvas.drawPath(extractPath, activePaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics().first;
    final length = metrics.length;
    double distance = 0;
    const dashLen = 8.0;
    const gapLen = 6.0;
    while (distance < length) {
      final end = math.min(distance + dashLen, length);
      canvas.drawPath(metrics.extractPath(distance, end), paint);
      distance += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.progress != progress || old.isDone != isDone;
}

// ─── LEVEL NODE ──────────────────────────────────────────────────────────────

class _LevelNode extends StatefulWidget {
  final LevelData level;
  final Subject subject;
  final double nodeSize;

  const _LevelNode({
    required this.level,
    required this.subject,
    required this.nodeSize,
  });

  @override
  State<_LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<_LevelNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    // Pulse only for the active (unlocked, not completed) node
    if (widget.level.isUnlocked && !widget.level.isCompleted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.level.isUnlocked) return;
    HapticFeedback.lightImpact();
    final dummyQuestions = [
      {
        'question_text': 'Was passt am besten zum Thema ${widget.subject.name}?',
        'options': ['Option A', 'Option B', 'Option C', 'Option D'],
        'correct_answer': 'Option B',
      },
      {
        'question_text': 'Wähle die richtige Antwort für Level ${widget.level.levelNumber}.',
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
        pageBuilder: (_, __, ___) =>
            QuizScreen(
              quizTitle: '${widget.subject.name} - ${widget.level.title}',
              questions: dummyQuestions,
              subjectColor: widget.subject.color,
              subjectShadowColor: widget.subject.shadowColor,
              subjectEmoji: widget.subject.emoji,
            ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(1.0, 0), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.level.isUnlocked && !widget.level.isCompleted;
    final isCompleted = widget.level.isCompleted;
    final isLocked = !widget.level.isUnlocked;

    final color = widget.subject.color;
    final shadowColor = widget.subject.shadowColor;

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseScale = isActive
              ? 1.0 + _pulseController.value * 0.06
              : 1.0;
          final glowOpacity = isActive ? _pulseController.value * 0.4 : 0.0;

          return Transform.scale(
            scale: pulseScale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow ring for active node
                if (isActive)
                  Container(
                    width: widget.nodeSize,
                    height: widget.nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(glowOpacity),
                          blurRadius: 20,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),

                // Main node circle
                Container(
                  width: widget.nodeSize - 6,
                  height: widget.nodeSize - 6,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? const Color(0xFFEEEFF5)
                        : isCompleted
                            ? color
                            : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLocked
                          ? const Color(0xFFD8D8E8)
                          : isCompleted
                              ? shadowColor
                              : color,
                      width: isActive ? 3.5 : 3,
                    ),
                    boxShadow: isLocked
                        ? null
                        : [
                            BoxShadow(
                              color: isCompleted
                                  ? shadowColor.withOpacity(0.5)
                                  : color.withOpacity(0.25),
                              offset: const Offset(0, 5),
                              blurRadius: 0,
                            ),
                          ],
                  ),
                  child: Center(child: _nodeContent(isActive, isCompleted, isLocked, color)),
                ),

                // Stars badge (top-right) for completed
                if (isCompleted && widget.level.stars > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.white, size: 9),
                          Text(
                            '${widget.level.stars}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _nodeContent(
      bool isActive, bool isCompleted, bool isLocked, Color color) {
    if (isLocked) {
      return const Icon(Icons.lock_rounded,
          color: Color(0xFFB8B8CC), size: 26);
    }
    if (isCompleted) {
      return const Icon(Icons.check_rounded, color: Colors.white, size: 30);
    }
    // Active / unlocked
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.subject.emoji,
          style: const TextStyle(fontSize: 22),
        ),
        Text(
          '${widget.level.levelNumber}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
