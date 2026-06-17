import 'package:flutter/material.dart';

class RobotAvatar extends StatefulWidget {
  /// Scales the whole avatar (antennas, body, face) proportionally.
  /// 1.0 = original full size.
  final double scale;

  const RobotAvatar({super.key, this.scale = 1.0});

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

  // Scales a raw design-size value by the widget's scale factor.
  double _s(double value) => value * widget.scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        return Container(
          width: _s(100),
          height: _s(90),
          decoration: BoxDecoration(
            color: const Color(0xFFD8D8DE),
            borderRadius: BorderRadius.circular(_s(28)),
            border: Border.all(color: const Color(0xFFA8A8B0), width: _s(3.5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA8A8B0),
                offset: Offset(0, _s(5)),
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
                top: _s(-22),
                left: _s(16),
                child: Transform.rotate(
                  angle: -0.26,
                  child: Container(
                    width: _s(8),
                    height: _s(26),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA8A8B0),
                      borderRadius: BorderRadius.circular(_s(4)),
                    ),
                  ),
                ),
              ),
              // Right antenna
              Positioned(
                top: _s(-22),
                right: _s(16),
                child: Transform.rotate(
                  angle: 0.26,
                  child: Container(
                    width: _s(8),
                    height: _s(26),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA8A8B0),
                      borderRadius: BorderRadius.circular(_s(4)),
                    ),
                  ),
                ),
              ),
              // Left antenna tip
              Positioned(
                top: _s(-34),
                left: _s(11),
                child: Container(
                  width: _s(14),
                  height: _s(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA8A8B0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Right antenna tip
              Positioned(
                top: _s(-34),
                right: _s(11),
                child: Container(
                  width: _s(14),
                  height: _s(14),
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
                    SizedBox(height: _s(10)),
                    // Eyes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildEye(),
                        SizedBox(width: _s(16)),
                        _buildEye(),
                      ],
                    ),
                    SizedBox(height: _s(8)),
                    // Mouth
                    Container(
                      width: _s(32),
                      height: _s(14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFA8A8B0),
                            width: _s(3),
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(_s(20)),
                          bottomRight: Radius.circular(_s(20)),
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
        width: _s(18),
        height: _s(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_s(10)),
          border: Border.all(color: const Color(0xFFA8A8B0), width: _s(2.5)),
        ),
        child: Center(
          child: Container(
            width: _s(6),
            height: _s(6),
            margin: EdgeInsets.only(left: _s(2)),
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
