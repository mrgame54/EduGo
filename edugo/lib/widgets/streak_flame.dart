import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedStreakFlame extends StatefulWidget {
  final int streakCount;
  const AnimatedStreakFlame({super.key, required this.streakCount});

  @override
  State<AnimatedStreakFlame> createState() => _AnimatedStreakFlameState();
}

class _AnimatedStreakFlameState extends State<AnimatedStreakFlame>
    with TickerProviderStateMixin {
  late AnimationController _flickerController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _flickerAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Flicker animation - fast and irregular
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
    _flickerAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _flickerController, curve: Curves.easeInOut),
    );

    // Slow breathing scale
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flickerController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_flickerController, _scaleController, _glowController]),
      builder: (context, child) {
        return Column(
          children: [
            // Glow effect behind the flame
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9600)
                        .withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Streak number
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Text(
                          '${widget.streakCount}',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF9600),
                            letterSpacing: -1,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  // Animated flame
                  Transform.scale(
                    scale: _flickerAnimation.value * _scaleAnimation.value,
                    alignment: Alignment.bottomCenter,
                    child: _FlameIcon(glowIntensity: _glowAnimation.value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Spark particles
            _SparkParticles(glowAnimation: _glowAnimation),
          ],
        );
      },
    );
  }
}

class _FlameIcon extends StatelessWidget {
  final double glowIntensity;
  const _FlameIcon({required this.glowIntensity});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 48,
      child: CustomPaint(
        painter: _FlamePainter(glowIntensity: glowIntensity),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  final double glowIntensity;
  _FlamePainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final outerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFFFFE066),
          Color(0xFFFF9600),
          Color(0xFFFF4B4B),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Glow paint
    final glowPaint = Paint()
      ..color = const Color(0xFFFF9600).withOpacity(0.3 * glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    final cx = size.width / 2;

    // Outer flame shape
    path.moveTo(cx, size.height); // bottom center
    path.cubicTo(
      cx - size.width * 0.5, size.height * 0.7,
      cx - size.width * 0.55, size.height * 0.4,
      cx - size.width * 0.2, size.height * 0.25,
    );
    path.cubicTo(
      cx - size.width * 0.15, size.height * 0.05,
      cx, 0,
      cx, 0,
    );
    path.cubicTo(
      cx, 0,
      cx + size.width * 0.15, size.height * 0.05,
      cx + size.width * 0.2, size.height * 0.25,
    );
    path.cubicTo(
      cx + size.width * 0.55, size.height * 0.4,
      cx + size.width * 0.5, size.height * 0.7,
      cx, size.height,
    );
    path.close();

    // Inner highlight
    final innerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.6),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(cx * 0.4, size.height * 0.1, cx * 0.8, size.height * 0.4))
      ..style = PaintingStyle.fill;

    final innerPath = Path();
    innerPath.moveTo(cx, size.height * 0.18);
    innerPath.cubicTo(
      cx - size.width * 0.1, size.height * 0.25,
      cx - size.width * 0.12, size.height * 0.45,
      cx, size.height * 0.55,
    );
    innerPath.cubicTo(
      cx + size.width * 0.12, size.height * 0.45,
      cx + size.width * 0.1, size.height * 0.25,
      cx, size.height * 0.18,
    );

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, outerPaint);
    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(_FlamePainter oldDelegate) =>
      oldDelegate.glowIntensity != glowIntensity;
}

class _SparkParticles extends StatefulWidget {
  final Animation<double> glowAnimation;
  const _SparkParticles({required this.glowAnimation});

  @override
  State<_SparkParticles> createState() => _SparkParticlesState();
}

class _SparkParticlesState extends State<_SparkParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkController;

  @override
  void initState() {
    super.initState();
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sparkController,
      builder: (context, child) {
        return SizedBox(
          width: 100,
          height: 20,
          child: CustomPaint(
            painter: _SparkPainter(progress: _sparkController.value),
          ),
        );
      },
    );
  }
}

class _SparkPainter extends CustomPainter {
  final double progress;
  _SparkPainter({required this.progress});

  static final List<_Spark> _sparks = [
    _Spark(startX: 0.3, delay: 0.0, size: 3.5),
    _Spark(startX: 0.5, delay: 0.3, size: 2.5),
    _Spark(startX: 0.7, delay: 0.6, size: 3.0),
    _Spark(startX: 0.2, delay: 0.8, size: 2.0),
    _Spark(startX: 0.8, delay: 0.15, size: 2.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final spark in _sparks) {
      final t = ((progress - spark.delay) % 1.0 + 1.0) % 1.0;
      if (t < 0.7) {
        final opacity = t < 0.3 ? t / 0.3 : (0.7 - t) / 0.4;
        final y = size.height * (1.0 - t * 1.5);
        final wobble = math.sin(t * math.pi * 3) * 5;

        paint.color = const Color(0xFFFFD700).withOpacity(opacity.clamp(0, 1));
        canvas.drawCircle(
          Offset(size.width * spark.startX + wobble, y),
          spark.size * (1 - t),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SparkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Spark {
  final double startX;
  final double delay;
  final double size;
  const _Spark(
      {required this.startX, required this.delay, required this.size});
}