import 'package:flutter/material.dart';

class RobotAvatar extends StatefulWidget {
  const RobotAvatar({super.key});

  @override
  State<RobotAvatar> createState() => _RobotAvatarState();
}

class _RobotAvatarState extends State<RobotAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.05).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Blink every 3-4 seconds
    _scheduleBlink();
  }

  void _scheduleBlink() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      await _blinkController.forward();
      await _blinkController.reverse();
      _scheduleBlink();
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFD8D8DE),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFA8A8B0), width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFA8A8B0),
                offset: Offset(0, 5),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Left antenna
              Positioned(
                top: -22,
                left: 16,
                child: Transform.rotate(
                  angle: -0.26,
                  child: Container(
                    width: 8,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA8A8B0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              // Right antenna
              Positioned(
                top: -22,
                right: 16,
                child: Transform.rotate(
                  angle: 0.26,
                  child: Container(
                    width: 8,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA8A8B0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              // Left antenna tip
              Positioned(
                top: -34,
                left: 11,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA8A8B0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Right antenna tip
              Positioned(
                top: -34,
                right: 11,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA8A8B0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Face
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    // Eyes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildEye(),
                        const SizedBox(width: 16),
                        _buildEye(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Mouth
                    Container(
                      width: 32,
                      height: 14,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFA8A8B0),
                            width: 3,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEye() {
    return Transform.scale(
      scaleY: _blinkAnimation.value,
      child: Container(
        width: 18,
        height: 13,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFA8A8B0), width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(left: 2),
            decoration: const BoxDecoration(
              color: Color(0xFF3C3C3C),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}