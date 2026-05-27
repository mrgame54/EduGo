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

  factory Subject.fromJson(Map<String, dynamic> json) {
    final colorStr = json['color'] as String? ?? '#1CB0F6';
    final shadowColorStr = json['shadow_color'] as String? ?? '#1480B3';
    
    // Parse hex colors safely
    final color = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    final shadowColor = Color(int.parse(shadowColorStr.replaceFirst('#', '0xFF')));

    final emoji = json['emoji'] as String? ?? '📝';

    // Map emoji to IconData
    IconData icon;
    if (emoji == '📖') {
      icon = Icons.auto_stories_rounded;
    } else if (emoji == '🔢') {
      icon = Icons.calculate_rounded;
    } else if (emoji == '🌿') {
      icon = Icons.eco_rounded;
    } else if (emoji == '🎨') {
      icon = Icons.palette_rounded;
    } else {
      icon = Icons.school_rounded;
    }

    final levelsList = (json['levels'] as List<dynamic>? ?? [])
        .map((l) => LevelData.fromJson(l as Map<String, dynamic>))
        .toList();

    return Subject(
      name: json['name'] as String? ?? 'Quiz',
      level: json['level'] as int? ?? 1,
      color: color,
      shadowColor: shadowColor,
      emoji: emoji,
      icon: icon,
      levels: levelsList,
    );
  }
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

  factory LevelData.fromJson(Map<String, dynamic> json) {
    return LevelData(
      levelNumber: json['level_number'] as int? ?? 1,
      title: json['title'] as String? ?? 'Level',
      isUnlocked: json['is_unlocked'] as bool? ?? true,
      isCompleted: json['is_completed'] as bool? ?? false,
      stars: json['stars'] as int? ?? 0,
    );
  }
}
