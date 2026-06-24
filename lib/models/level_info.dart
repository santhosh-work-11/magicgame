import '../services/magic_square_solver.dart';

class LevelInfo {
  final int levelNumber;
  final int gridSize;
  final double shufflePercentage; // Ratio of cells that are unlocked and shuffled
  final int magicConstant;
  final int goldTimeSec;
  final int silverTimeSec;
  final int bronzeTimeSec;
  final int baseScore;

  LevelInfo({
    required this.levelNumber,
    required this.gridSize,
    required this.shufflePercentage,
    required this.magicConstant,
    required this.goldTimeSec,
    required this.silverTimeSec,
    required this.bronzeTimeSec,
    required this.baseScore,
  });

  /// Factory to generate standard LevelInfo for a level from 1 to 15
  factory LevelInfo.forLevel(int level) {
    if (level < 1 || level > 15) {
      throw ArgumentError('Level must be between 1 and 15.');
    }

    final int size = 2 * level + 1; // 3, 5, 7, ... 31
    final int constant = MagicSquareSolver.calculateMagicConstant(size);

    // Shuffle percentage starts high for small grids, and goes lower for huge grids
    // Level 1: 3x3 (9 cells) -> shuffle 50% (approx 4-5 cells)
    // Level 2: 5x5 (25 cells) -> shuffle 45% (approx 11 cells)
    // Level 10: 21x21 (441 cells) -> shuffle 10% (approx 44 cells)
    // Formula: 0.50 - (level - 1) * 0.044
    double shuffleRatio = 0.50 - (level - 1) * 0.044;
    if (shuffleRatio < 0.10) shuffleRatio = 0.10; // Floor at 10%

    // Target times scaled exponentially
    final int gold = (45 * (level * level * 0.6 + 0.4)).toInt();
    final int silver = (gold * 2.0).toInt();
    final int bronze = (gold * 4.0).toInt();

    final int score = level * 1000;

    return LevelInfo(
      levelNumber: level,
      gridSize: size,
      shufflePercentage: shuffleRatio,
      magicConstant: constant,
      goldTimeSec: gold,
      silverTimeSec: silver,
      bronzeTimeSec: bronze,
      baseScore: score,
    );
  }

  String get difficultyName {
    const List<String> names = [
      'Novice',
      'Apprentice',
      'Adept',
      'Scholar',
      'Master',
      'Grandmaster',
      'Sage',
      'Magus',
      'Archmage',
      'Demigod',
      'Immortal',
      'Celestial',
      'Astral',
      'Eternal',
      'Infinite',
    ];
    if (levelNumber >= 1 && levelNumber <= 15) {
      return names[levelNumber - 1];
    }
    return 'Unknown';
  }

  /// Retrieves configurations for all 15 levels
  static List<LevelInfo> get allLevels {
    return List.generate(15, (index) => LevelInfo.forLevel(index + 1));
  }
}
