

class MagicSquareSolver {
  /// Calculates the Magic Constant for a grid of size [n].
  /// Formula: M = n * (n^2 + 1) / 2
  static int calculateMagicConstant(int n) {
    return n * (n * n + 1) ~/ 2;
  }

  /// Generates a Magic Square of size [n] using the Siamese (De la Loubère) method.
  /// Works for any odd number [n] >= 3.
  static List<List<int>> generate(int n) {
    if (n % 2 == 0 || n < 3) {
      throw ArgumentError('Grid size n must be an odd integer >= 3.');
    }

    // Initialize n x n grid with zeros
    List<List<int>> grid = List.generate(n, (_) => List.filled(n, 0));

    // Starting position is the middle of the first row
    int r = 0;
    int c = n ~/ 2;

    for (int k = 1; k <= n * n; k++) {
      grid[r][c] = k;

      // Try moving up and right
      int nextR = (r - 1 + n) % n;
      int nextC = (c + 1) % n;

      if (grid[nextR][nextC] != 0) {
        // If occupied, move down from the previous position
        r = (r + 1) % n;
      } else {
        r = nextR;
        c = nextC;
      }
    }

    return grid;
  }

  /// Calculates the sum of a specific row in the [grid].
  static int getRowSum(List<List<int>> grid, int rowIndex) {
    int sum = 0;
    for (int col = 0; col < grid.length; col++) {
      sum += grid[rowIndex][col];
    }
    return sum;
  }

  /// Calculates the sum of a specific column in the [grid].
  static int getColSum(List<List<int>> grid, int colIndex) {
    int sum = 0;
    for (int row = 0; row < grid.length; row++) {
      sum += grid[row][colIndex];
    }
    return sum;
  }

  /// Calculates the sum of the primary diagonal (top-left to bottom-right).
  static int getPrimaryDiagSum(List<List<int>> grid) {
    int sum = 0;
    for (int i = 0; i < grid.length; i++) {
      sum += grid[i][i];
    }
    return sum;
  }

  /// Calculates the sum of the secondary diagonal (bottom-left to top-right).
  static int getSecondaryDiagSum(List<List<int>> grid) {
    int sum = 0;
    int n = grid.length;
    for (int i = 0; i < n; i++) {
      sum += grid[n - 1 - i][i];
    }
    return sum;
  }

  /// Checks if the current [grid] is a fully solved magic square.
  static bool checkSolved(List<List<int>> grid) {
    int n = grid.length;
    int target = calculateMagicConstant(n);

    // Verify all row sums
    for (int r = 0; r < n; r++) {
      if (getRowSum(grid, r) != target) return false;
    }

    // Verify all column sums
    for (int c = 0; c < n; c++) {
      if (getColSum(grid, c) != target) return false;
    }

    // Verify diagonal sums
    if (getPrimaryDiagSum(grid) != target) return false;
    if (getSecondaryDiagSum(grid) != target) return false;

    // Verify that the grid contains all numbers from 1 to n^2
    Set<int> expectedValues = List.generate(n * n, (i) => i + 1).toSet();
    Set<int> actualValues = {};
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        actualValues.add(grid[r][c]);
      }
    }

    return expectedValues.length == actualValues.length &&
        expectedValues.difference(actualValues).isEmpty;
  }
}
