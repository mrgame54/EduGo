import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../widgets/subject_card.dart';
import '../widgets/streak_flame.dart';
import '../widgets/robot_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ─── HEADER ───
            _Header(),
            // ─── SCROLLABLE CONTENT ───
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    // Greeting text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, v, child) => Opacity(
                                opacity: v,
                                child: Transform.translate(
                                  offset: Offset(0, 12 * (1 - v)),
                                  child: child,
                                ),
                              ),
                              child: const Text(
                                'Hallo, Lernstar! 🌟',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF3C3C3C),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, v, child) => Opacity(
                                opacity: v,
                                child: child,
                              ),
                              child: Text(
                                'Was lernst du heute?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Subject grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 28,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.82,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: subjects.asMap().entries.map((e) {
                          return SubjectCard(
                            subject: e.value,
                            index: e.key,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Robot + streak
                    _Footer(),
                    const SizedBox(height: 24),
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

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 2),
        ),
      ),
      child: Row(
        children: [
          // App logo / title
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1CB0F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('L', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'EduGo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3C3C3C),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Action icons
          _HeaderIcon(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _HeaderIcon(
            icon: Icons.calendar_month_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _HeaderIcon(
            icon: Icons.account_circle_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFBBBBBB), size: 22),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Decorative divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              Expanded(
                child: Container(height: 2, color: const Color(0xFFEEEEEE)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'Dein Fortschritt',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[400],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 2, color: const Color(0xFFEEEEEE)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const RobotAvatar(),
        const SizedBox(height: 20),
        // Streak
        const AnimatedStreakFlame(streakCount: 67),
        const SizedBox(height: 8),
        Text(
          'Tage in Folge',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}