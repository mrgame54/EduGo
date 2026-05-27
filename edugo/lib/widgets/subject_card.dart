import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subject.dart';
import '../screens/level_tree_screen.dart';

class SubjectCard extends StatefulWidget {
  final Subject subject;
  final int index;
  final VoidCallback onRefresh;
  const SubjectCard({
    super.key,
    required this.subject,
    required this.index,
    required this.onRefresh,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _pressAnim = Tween<double>(begin: 0.0, end: 4.0).animate(
        CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(_) {
    _pressController.reverse();
    _navigate();
  }

  void _onTapCancel() => _pressController.reverse();

  void _navigate() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            LevelTreeScreen(subject: widget.subject),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0, 0.06), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) {
      widget.onRefresh();
    });
  }

  // Completed levels count
  int get _completedCount =>
      widget.subject.levels.where((l) => l.isCompleted).length;
  int get _totalCount => widget.subject.levels.length;
  double get _progress => _completedCount / _totalCount;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + widget.index * 90),
      curve: Curves.elasticOut,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _pressController,
          builder: (context, child) {
            final offset = _pressAnim.value;
            return Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.subject.color.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.subject.shadowColor.withOpacity(0.18),
                      offset: Offset(0, 6 - offset),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: widget.subject.color.withOpacity(0.10),
                      offset: const Offset(0, 10),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji in colored circle
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: widget.subject.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            widget.subject.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.subject.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Level ${widget.subject.level}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.subject.color,
                        ),
                      ),
                      const Spacer(),
                      // Progress bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_completedCount/$_totalCount',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[400],
                                ),
                              ),
                              Text(
                                '${(_progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: widget.subject.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor:
                                  widget.subject.color.withOpacity(0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.subject.color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
