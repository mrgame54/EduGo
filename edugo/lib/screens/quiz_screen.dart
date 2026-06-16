import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subject.dart';

class QuizScreen extends StatefulWidget {
  final Subject subject;
  final LevelData level;

  const QuizScreen({super.key, required this.subject, required this.level});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _isChecked = false;
  bool _isFinished = false;

  // Platzhalter-Daten: In einer echten App würden diese aus einer Datenbank kommen
  late final List<_QuizQuestion> _questions;

  @override
  void initState() {
    super.initState();
    // Generiere ein paar Dummy-Fragen basierend auf dem Fach
    _questions = [
      _QuizQuestion(
        question: 'Was passt am besten zum Thema ${widget.subject.name}?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctIndex: 1,
      ),
      _QuizQuestion(
        question: 'Wähle die richtige Antwort für Level ${widget.level.levelNumber}.',
        options: ['Falsch', 'Auch Falsch', 'Richtig', 'Ganz Falsch'],
        correctIndex: 2,
      ),
      _QuizQuestion(
        question: 'Letzte Frage! Bist du bereit?',
        options: ['Nein', 'Vielleicht', 'Ja, absolut!', 'Weiß nicht'],
        correctIndex: 2,
      ),
    ];
  }

  void _onOptionSelected(int index) {
    if (_isChecked) return; // Nach Überprüfung sperren
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCheckOrContinue() {
    if (_isFinished) {
      Navigator.pop(context); // Zurück zur Level-Übersicht
      return;
    }

    if (!_isChecked) {
      // Überprüfen-Logik
      if (_selectedIndex != null) {
        HapticFeedback.mediumImpact();
        setState(() {
          _isChecked = true;
        });
      }
    } else {
      // Weiter-Logik
      setState(() {
        _isChecked = false;
        _selectedIndex = null;
        if (_currentIndex < _questions.length - 1) {
          _currentIndex++;
        } else {
          _isFinished = true;
          HapticFeedback.heavyImpact(); // Erfolg!
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _isFinished 
        ? 1.0 
        : _currentIndex / _questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ─── TOP BAR ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        color: Color(0xFFAFAFAF), size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _AnimatedProgressBar(
                      progress: progress,
                      color: widget.subject.color,
                    ),
                  ),
                ],
              ),
            ),

            // ─── CONTENT ───
            Expanded(
              child: _isFinished
                  ? _buildSuccessScreen()
                  : _buildQuestionScreen(),
            ),

            // ─── BOTTOM BAR ───
            _BottomActionArea(
              isChecked: _isChecked,
              isFinished: _isFinished,
              isCorrect: _isChecked &&
                  _selectedIndex == _questions[_currentIndex].correctIndex,
              hasSelection: _selectedIndex != null,
              subjectColor: widget.subject.color,
              subjectShadowColor: widget.subject.shadowColor,
              onTap: _onCheckOrContinue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final currentQ = _questions[_currentIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            currentQ.question,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3C3C3C),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: currentQ.options.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                final isCorrectAns = currentQ.correctIndex == index;

                // Status für Farben bestimmen
                _OptionStatus status = _OptionStatus.normal;
                if (_isChecked) {
                  if (isSelected && isCorrectAns) {
                    status = _OptionStatus.correct;
                  } else if (isSelected && !isCorrectAns) {
                    status = _OptionStatus.incorrect;
                  } else if (isCorrectAns) {
                    status = _OptionStatus.missedCorrect; // Zeigt die richtige Antwort an
                  } else {
                    status = _OptionStatus.disabled;
                  }
                } else if (isSelected) {
                  status = _OptionStatus.selected;
                }

                return _QuizOptionCard(
                  text: currentQ.options[index],
                  status: status,
                  subjectColor: widget.subject.color,
                  onTap: () => _onOptionSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.subject.emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 20),
          const Text(
            'Lektion abgeschlossen!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3C3C3C),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '+10 XP verdient',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFF9600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HILFSKLASSEN & WIDGETS ───

class _QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

enum _OptionStatus { normal, selected, correct, incorrect, missedCorrect, disabled }

class _QuizOptionCard extends StatelessWidget {
  final String text;
  final _OptionStatus status;
  final Color subjectColor;
  final VoidCallback onTap;

  const _QuizOptionCard({
    required this.text,
    required this.status,
    required this.subjectColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color textColor;

    switch (status) {
      case _OptionStatus.selected:
        borderColor = subjectColor;
        bgColor = subjectColor.withOpacity(0.1);
        textColor = subjectColor;
        break;
      case _OptionStatus.correct:
      case _OptionStatus.missedCorrect:
        borderColor = const Color(0xFF58CC02);
        bgColor = const Color(0xFF58CC02).withOpacity(0.15);
        textColor = const Color(0xFF58CC02);
        break;
      case _OptionStatus.incorrect:
        borderColor = const Color(0xFFFF4B4B);
        bgColor = const Color(0xFFFF4B4B).withOpacity(0.15);
        textColor = const Color(0xFFFF4B4B);
        break;
      case _OptionStatus.disabled:
        borderColor = const Color(0xFFEEEEEE);
        bgColor = Colors.white;
        textColor = const Color(0xFFAFAFAF);
        break;
      case _OptionStatus.normal:
      default:
        borderColor = const Color(0xFFE5E5E5);
        bgColor = Colors.white;
        textColor = const Color(0xFF4B4B4B);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          // Leichter 3D Schatten für nicht ausgewählte Buttons
          boxShadow: status == _OptionStatus.normal
              ? [
                  BoxShadow(
                    color: const Color(0xFFE5E5E5),
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: status == _OptionStatus.normal
                ? FontWeight.w700
                : FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _AnimatedProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * progress,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    // Lichtreflexion (Glossy Effekt)
                    Container(
                      margin: const EdgeInsets.only(top: 3, left: 10, right: 10),
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomActionArea extends StatelessWidget {
  final bool isChecked;
  final bool isFinished;
  final bool isCorrect;
  final bool hasSelection;
  final Color subjectColor;
  final Color subjectShadowColor;
  final VoidCallback onTap;

  const _BottomActionArea({
    required this.isChecked,
    required this.isFinished,
    required this.isCorrect,
    required this.hasSelection,
    required this.subjectColor,
    required this.subjectShadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color btnColor = const Color(0xFFE5E5E5);
    Color shadowColor = const Color(0xFFCCCCCC);
    Color textColor = const Color(0xFFAFAFAF);
    String btnText = 'ÜBERPRÜFEN';
    Widget? icon;

    if (isFinished) {
      btnColor = subjectColor;
      shadowColor = subjectShadowColor;
      textColor = Colors.white;
      btnText = 'WEITER';
    } else if (isChecked) {
      if (isCorrect) {
        bgColor = const Color(0xFFD7FFB8);
        btnColor = const Color(0xFF58CC02);
        shadowColor = const Color(0xFF46A302);
        textColor = Colors.white;
        btnText = 'WEITER';
        icon = const Icon(Icons.check_circle_rounded, color: Color(0xFF58CC02), size: 30);
      } else {
        bgColor = const Color(0xFFFFDFE0);
        btnColor = const Color(0xFFFF4B4B);
        shadowColor = const Color(0xFFEA2B2B);
        textColor = Colors.white;
        btnText = 'VERSTANDEN';
        icon = const Icon(Icons.cancel_rounded, color: Color(0xFFFF4B4B), size: 30);
      }
    } else if (hasSelection) {
      btnColor = subjectColor;
      shadowColor = subjectShadowColor;
      textColor = Colors.white;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: isChecked ? Colors.transparent : const Color(0xFFE5E5E5),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isChecked && !isFinished) ...[
            Row(
              children: [
                icon!,
                const SizedBox(width: 12),
                Text(
                  isCorrect ? 'Richtig!' : 'Falsch!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isCorrect ? const Color(0xFF58CC02) : const Color(0xFFFF4B4B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          _DuolingoButton(
            text: btnText,
            color: btnColor,
            shadowColor: shadowColor,
            textColor: textColor,
            onTap: (!isChecked && !hasSelection) ? null : onTap,
          ),
        ],
      ),
    );
  }
}

// ─── CUSTOM 3D BUTTON ───
class _DuolingoButton extends StatefulWidget {
  final String text;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _DuolingoButton({
    required this.text,
    required this.color,
    required this.shadowColor,
    required this.textColor,
    this.onTap,
  });

  @override
  State<_DuolingoButton> createState() => _DuolingoButtonState();
}

class _DuolingoButtonState extends State<_DuolingoButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    widget.onTap!();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: _isPressed ? 4 : 0),
        height: 52,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: widget.shadowColor,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: widget.textColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}