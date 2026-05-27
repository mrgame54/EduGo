import 'package:flutter/material.dart';

class Subject {
  final String name;
  final int level;
  final Color color;
  final Color shadowColor;
  final IconData icon;
  final String emoji;
  final List<LevelData> levels;

  const Subject({
    required this.name,
    required this.level,
    required this.color,
    required this.shadowColor,
    required this.icon,
    required this.emoji,
    required this.levels,
  });
}

class LevelData {
  final int levelNumber;
  final String title;
  final bool isUnlocked;
  final bool isCompleted;
  final int stars;

  const LevelData({
    required this.levelNumber,
    required this.title,
    required this.isUnlocked,
    this.isCompleted = false,
    this.stars = 0,
  });
}

final List<Subject> subjects = [
  Subject(
    name: 'Sprache',
    level: 1,
    color: const Color(0xFF1CB0F6),
    shadowColor: const Color(0xFF1480B3),
    icon: Icons.auto_stories_rounded,
    emoji: '📖',
    levels: [
      const LevelData(levelNumber: 1, title: 'Buchstaben A-E', isUnlocked: true, isCompleted: true, stars: 3),
      const LevelData(levelNumber: 2, title: 'Buchstaben F-J', isUnlocked: true, isCompleted: true, stars: 2),
      const LevelData(levelNumber: 3, title: 'Buchstaben K-O', isUnlocked: true, isCompleted: false, stars: 0),
      const LevelData(levelNumber: 4, title: 'Buchstaben P-T', isUnlocked: false, isCompleted: false, stars: 0),
      const LevelData(levelNumber: 5, title: 'Buchstaben U-Z', isUnlocked: false, isCompleted: false, stars: 0),
    ],
  ),
  Subject(
    name: 'Mathe',
    level: 7,
    color: const Color(0xFFFF4B4B),
    shadowColor: const Color(0xFFC73A3A),
    icon: Icons.calculate_rounded,
    emoji: '🔢',
    levels: [
      const LevelData(levelNumber: 1, title: 'Zahlen 1-10', isUnlocked: true, isCompleted: true, stars: 3),
      const LevelData(levelNumber: 2, title: 'Addition', isUnlocked: true, isCompleted: true, stars: 3),
      const LevelData(levelNumber: 3, title: 'Subtraktion', isUnlocked: true, isCompleted: true, stars: 2),
      const LevelData(levelNumber: 4, title: 'Multiplikation', isUnlocked: true, isCompleted: true, stars: 3),
      const LevelData(levelNumber: 5, title: 'Division', isUnlocked: true, isCompleted: true, stars: 1),
      const LevelData(levelNumber: 6, title: 'Brüche', isUnlocked: true, isCompleted: true, stars: 2),
      const LevelData(levelNumber: 7, title: 'Geometrie', isUnlocked: true, isCompleted: false, stars: 0),
      const LevelData(levelNumber: 8, title: 'Algebra', isUnlocked: false, isCompleted: false, stars: 0),
    ],
  ),
  Subject(
    name: 'Natur',
    level: 3,
    color: const Color(0xFF58CC02),
    shadowColor: const Color(0xFF46A302),
    icon: Icons.eco_rounded,
    emoji: '🌿',
    levels: [
      const LevelData(levelNumber: 1, title: 'Pflanzen', isUnlocked: true, isCompleted: true, stars: 3),
      const LevelData(levelNumber: 2, title: 'Tiere', isUnlocked: true, isCompleted: true, stars: 3),
      const LevelData(levelNumber: 3, title: 'Wetter', isUnlocked: true, isCompleted: false, stars: 0),
      const LevelData(levelNumber: 4, title: 'Erde & Weltraum', isUnlocked: false, isCompleted: false, stars: 0),
      const LevelData(levelNumber: 5, title: 'Ökosysteme', isUnlocked: false, isCompleted: false, stars: 0),
    ],
  ),
  Subject(
    name: 'Kunst',
    level: 5,
    color: const Color(0xFFCE82FF),
    shadowColor: const Color(0xFFA366CC),
    icon: Icons.palette_rounded,
    emoji: '🎨',
    levels: [
      const LevelData(levelNumber: 1, title: 'Grundfarben', isUnlocked: true, isCompleted: true, stars: 3),
      const LevelData(levelNumber: 2, title: 'Formen zeichnen', isUnlocked: true, isCompleted: true, stars: 3),
      const LevelData(levelNumber: 3, title: 'Muster & Texturen', isUnlocked: true, isCompleted: true, stars: 2),
      const LevelData(levelNumber: 4, title: 'Landschaften', isUnlocked: true, isCompleted: true, stars: 3),
      const LevelData(levelNumber: 5, title: 'Porträts', isUnlocked: true, isCompleted: false, stars: 0),
      const LevelData(levelNumber: 6, title: 'Abstrakte Kunst', isUnlocked: false, isCompleted: false, stars: 0),
    ],
  ),
];
