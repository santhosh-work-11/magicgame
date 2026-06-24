import 'package:flutter/material.dart';

class GameTheme {
  final String name;
  final Color accentColor;
  final Color glowColor;
  final Color secondaryTextColor;
  final List<Color> backgroundColors;

  const GameTheme({
    required this.name,
    required this.accentColor,
    required this.glowColor,
    required this.secondaryTextColor,
    required this.backgroundColors,
  });
}

class ThemeManager {
  static const GameTheme cyberCyan = GameTheme(
    name: 'Cyber Cyan',
    accentColor: Color(0xff00d2ff),
    glowColor: Color(0xff00d2ff),
    secondaryTextColor: Color(0xff8a9bb8),
    backgroundColors: [
      Color(0xff090c15),
      Color(0xff121829),
      Color(0xff1b223c),
    ],
  );

  static const GameTheme toxicGreen = GameTheme(
    name: 'Toxic Green',
    accentColor: Color(0xff39ff14),
    glowColor: Color(0xff39ff14),
    secondaryTextColor: Color(0xff8ba989),
    backgroundColors: [
      Color(0xff050c05),
      Color(0xff091a09),
      Color(0xff102e10),
    ],
  );

  static const GameTheme phaserPink = GameTheme(
    name: 'Phaser Pink',
    accentColor: Color(0xffff0055),
    glowColor: Color(0xffff0055),
    secondaryTextColor: Color(0xffbfa2b0),
    backgroundColors: [
      Color(0xff0e050c),
      Color(0xff1a0a16),
      Color(0xff290f23),
    ],
  );

  static const GameTheme solarOrange = GameTheme(
    name: 'Solar Orange',
    accentColor: Color(0xffff5e00),
    glowColor: Color(0xffff5e00),
    secondaryTextColor: Color(0xffbfae9e),
    backgroundColors: [
      Color(0xff0e0705),
      Color(0xff1a0e0a),
      Color(0xff29160f),
    ],
  );

  static const List<GameTheme> themes = [
    cyberCyan,
    toxicGreen,
    phaserPink,
    solarOrange,
  ];
}
