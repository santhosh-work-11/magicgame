import 'dart:convert';
import '../services/storage_service.dart';
import 'level_info.dart';

class GameProgress {
  final AppStorage _storage;
  
  // Cache of state
  Map<int, int> highScores = {};
  Map<int, int> bestTimes = {};
  Map<int, String> medals = {}; // 'gold', 'silver', 'bronze', 'none'

  // Settings
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;

  GameProgress(this._storage);

  Future<void> load() async {
    try {
      final dataStr = await _storage.getString('game_progress');
      if (dataStr != null) {
        final Map<String, dynamic> json = jsonDecode(dataStr);
        
        final Map<String, dynamic>? scoresMap = json['highScores'];
        if (scoresMap != null) {
          highScores = scoresMap.map((key, value) => MapEntry(int.parse(key), value as int));
        }

        final Map<String, dynamic>? timesMap = json['bestTimes'];
        if (timesMap != null) {
          bestTimes = timesMap.map((key, value) => MapEntry(int.parse(key), value as int));
        }

        final Map<String, dynamic>? medalsMap = json['medals'];
        if (medalsMap != null) {
          medals = medalsMap.map((key, value) => MapEntry(int.parse(key), value as String));
        }

        soundEnabled = json['soundEnabled'] as bool? ?? true;
        musicEnabled = json['musicEnabled'] as bool? ?? true;
        vibrationEnabled = json['vibrationEnabled'] as bool? ?? true;
      }
    } catch (e) {
      // Ignore load error
    }
  }

  Future<void> save() async {
    final Map<String, dynamic> json = {
      'highScores': highScores.map((key, value) => MapEntry(key.toString(), value)),
      'bestTimes': bestTimes.map((key, value) => MapEntry(key.toString(), value)),
      'medals': medals.map((key, value) => MapEntry(key.toString(), value)),
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
    await _storage.saveString('game_progress', jsonEncode(json));
  }

  bool isUnlocked(int levelNumber) {
    if (levelNumber <= 1) return true;
    return bestTimes.containsKey(levelNumber - 1);
  }

  /// Registers a completion of a level. Calculates score, updates best times.
  /// Returns a map with completion details.
  Future<Map<String, dynamic>> completeLevel(LevelInfo level, int timeSec, int moves) async {
    // 1. Calculate medal
    String medal = 'none';
    if (timeSec <= level.goldTimeSec) {
      medal = 'gold';
    } else if (timeSec <= level.silverTimeSec) {
      medal = 'silver';
    } else if (timeSec <= level.bronzeTimeSec) {
      medal = 'bronze';
    }

    // 2. Calculate score
    final int timeBonus = (level.goldTimeSec * 2 - timeSec).clamp(0, level.goldTimeSec * 2) * 5;
    final int movePenalty = moves * 5;
    final int score = (level.baseScore + timeBonus - movePenalty).clamp(100, 1000000);

    // Update level records
    final prevHighScore = highScores[level.levelNumber] ?? 0;
    final isNewHighScore = score > prevHighScore;
    if (isNewHighScore) {
      highScores[level.levelNumber] = score;
    }

    final prevBestTime = bestTimes[level.levelNumber] ?? 9999999;
    if (timeSec < prevBestTime) {
      bestTimes[level.levelNumber] = timeSec;
    }

    // Update medal if it's better than previous
    final prevMedal = medals[level.levelNumber] ?? 'none';
    if (_medalRank(medal) > _medalRank(prevMedal)) {
      medals[level.levelNumber] = medal;
    }

    await save();

    return {
      'score': score,
      'isNewHighScore': isNewHighScore,
      'medal': medal,
      'timeSec': timeSec,
      'moves': moves,
    };
  }

  int _medalRank(String medal) {
    switch (medal) {
      case 'gold': return 3;
      case 'silver': return 2;
      case 'bronze': return 1;
      default: return 0;
    }
  }

  Future<void> resetAll() async {
    highScores = {};
    bestTimes = {};
    medals = {};
    await save();
  }
}
