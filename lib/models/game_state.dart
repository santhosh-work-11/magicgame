import 'dart:async';
import 'dart:math';
import '../services/magic_square_solver.dart';
import 'level_info.dart';

class GameState {
  final LevelInfo levelInfo;
  late List<List<int>> currentGrid;
  late List<List<bool>> lockedGrid;
  late List<List<int>> targetGrid;

  int? selectedRow;
  int? selectedCol;
  int moveCount = 0;
  int secondsElapsed = 0;
  bool isSolved = false;

  Timer? _timer;
  final void Function() onTick;
  final void Function() onWin;

  GameState({
    required this.levelInfo,
    required this.onTick,
    required this.onWin,
  }) {
    _initialize();
  }

  void _initialize() {
    final n = levelInfo.gridSize;
    targetGrid = MagicSquareSolver.generate(n);

    // Create locked map
    lockedGrid = List.generate(n, (_) => List.filled(n, true));
    currentGrid = List.generate(n, (r) => List.generate(n, (c) => targetGrid[r][c]));

    // Determine how many cells to unlock
    final int totalCells = n * n;
    final int unlockCount = (totalCells * levelInfo.shufflePercentage).round().clamp(2, totalCells - 1);

    // Get random cell indices to unlock
    final random = Random();
    final List<int> indices = List.generate(totalCells, (i) => i);
    indices.shuffle(random);

    final List<int> unlockedIndices = indices.sublist(0, unlockCount);
    for (final index in unlockedIndices) {
      final r = index ~/ n;
      final c = index % n;
      lockedGrid[r][c] = false;
    }

    // Collect values from targetGrid at unlocked positions
    final List<int> unlockedValues = [];
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (!lockedGrid[r][c]) {
          unlockedValues.add(targetGrid[r][c]);
        }
      }
    }

    // Shuffle those values until the grid is NOT solved
    do {
      unlockedValues.shuffle(random);

      // Distribute back
      int valIndex = 0;
      for (int r = 0; r < n; r++) {
        for (int c = 0; c < n; c++) {
          if (!lockedGrid[r][c]) {
            currentGrid[r][c] = unlockedValues[valIndex++];
          }
        }
      }
    } while (MagicSquareSolver.checkSolved(currentGrid) && unlockedValues.length > 1);

    moveCount = 0;
    secondsElapsed = 0;
    isSolved = false;
    selectedRow = null;
    selectedCol = null;

    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isSolved) {
        secondsElapsed++;
        onTick();
      } else {
        _timer?.cancel();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
  }

  void resumeTimer() {
    if (!isSolved) {
      startTimer();
    }
  }

  void dispose() {
    _timer?.cancel();
  }

  /// Tries to select or swap a cell at [row], [col]
  /// Returns true if selection changed or swap succeeded
  bool selectCell(int row, int col) {
    if (isSolved) return false;
    if (lockedGrid[row][col]) return false; // Can't select locked cells

    if (selectedRow == null || selectedCol == null) {
      // First selection
      selectedRow = row;
      selectedCol = col;
      return true;
    } else {
      // Second selection
      if (selectedRow == row && selectedCol == col) {
        // Deselect
        selectedRow = null;
        selectedCol = null;
        return true;
      }

      // Swap values
      final r1 = selectedRow!;
      final c1 = selectedCol!;

      final temp = currentGrid[r1][c1];
      currentGrid[r1][c1] = currentGrid[row][col];
      currentGrid[row][col] = temp;

      moveCount++;
      selectedRow = null;
      selectedCol = null;

      // Check if solved
      if (MagicSquareSolver.checkSolved(currentGrid)) {
        isSolved = true;
        _timer?.cancel();
        onWin();
      }

      return true;
    }
  }

  void reset() {
    _initialize();
  }
}
