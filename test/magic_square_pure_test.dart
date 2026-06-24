import '../lib/services/magic_square_solver.dart';
import '../lib/models/level_info.dart';

void assertEqual(dynamic actual, dynamic expected, String message) {
  if (actual != expected) {
    throw Exception('FAILED: $message\nExpected: $expected\nActual: $actual');
  }
}

void assertTrue(bool condition, String message) {
  if (!condition) {
    throw Exception('FAILED: $message\nExpected condition to be true');
  }
}

void assertFalse(bool condition, String message) {
  if (condition) {
    throw Exception('FAILED: $message\nExpected condition to be false');
  }
}

void expectError(Function fn, String message) {
  try {
    fn();
    throw Exception('FAILED: $message\nExpected an argument error but none was thrown.');
  } catch (e) {
    if (e is! ArgumentError) {
      throw Exception('FAILED: $message\nExpected ArgumentError but got: $e');
    }
  }
}

void main() {
  print('--- Running Pure Dart MagicSquareSolver Tests ---');

  try {
    // 1. Calculate Magic Constants
    assertEqual(MagicSquareSolver.calculateMagicConstant(3), 15, 'Magic constant for 3x3');
    assertEqual(MagicSquareSolver.calculateMagicConstant(5), 65, 'Magic constant for 5x5');
    assertEqual(MagicSquareSolver.calculateMagicConstant(7), 175, 'Magic constant for 7x7');
    assertEqual(MagicSquareSolver.calculateMagicConstant(21), 4641, 'Magic constant for 21x21');
    print('✓ Magic constant calculations passed.');

    // 2. Invalid Grid Sizes
    expectError(() => MagicSquareSolver.generate(2), 'Should throw on even size 2');
    expectError(() => MagicSquareSolver.generate(4), 'Should throw on even size 4');
    expectError(() => MagicSquareSolver.generate(0), 'Should throw on invalid size 0');
    expectError(() => MagicSquareSolver.generate(-3), 'Should throw on negative size');
    print('✓ Invalid grid size validation passed.');

    // 3. Generate 3x3 Magic Square
    final grid3 = MagicSquareSolver.generate(3);
    assertEqual(grid3.length, 3, '3x3 grid row length');
    assertEqual(grid3[0].length, 3, '3x3 grid col length');
    assertEqual(MagicSquareSolver.getRowSum(grid3, 0), 15, 'Row 0 sum');
    assertEqual(MagicSquareSolver.getRowSum(grid3, 1), 15, 'Row 1 sum');
    assertEqual(MagicSquareSolver.getRowSum(grid3, 2), 15, 'Row 2 sum');
    assertEqual(MagicSquareSolver.getColSum(grid3, 0), 15, 'Col 0 sum');
    assertEqual(MagicSquareSolver.getColSum(grid3, 1), 15, 'Col 1 sum');
    assertEqual(MagicSquareSolver.getColSum(grid3, 2), 15, 'Col 2 sum');
    assertEqual(MagicSquareSolver.getPrimaryDiagSum(grid3), 15, 'Primary diagonal sum');
    assertEqual(MagicSquareSolver.getSecondaryDiagSum(grid3), 15, 'Secondary diagonal sum');
    assertTrue(MagicSquareSolver.checkSolved(grid3), 'Generated 3x3 should be solved');
    print('✓ 3x3 magic square generation & verification passed.');

    // 4. Generate 5x5 Magic Square
    final grid5 = MagicSquareSolver.generate(5);
    assertEqual(grid5.length, 5, '5x5 grid row length');
    assertEqual(MagicSquareSolver.getRowSum(grid5, 0), 65, '5x5 Row 0 sum');
    assertEqual(MagicSquareSolver.getColSum(grid5, 2), 65, '5x5 Col 2 sum');
    assertEqual(MagicSquareSolver.getPrimaryDiagSum(grid5), 65, '5x5 Primary diagonal sum');
    assertEqual(MagicSquareSolver.getSecondaryDiagSum(grid5), 65, '5x5 Secondary diagonal sum');
    assertTrue(MagicSquareSolver.checkSolved(grid5), 'Generated 5x5 should be solved');
    print('✓ 5x5 magic square generation & verification passed.');

    // 5. Generate 21x21 Magic Square
    final grid21 = MagicSquareSolver.generate(21);
    assertEqual(grid21.length, 21, '21x21 grid row length');
    final magicConstant21 = MagicSquareSolver.calculateMagicConstant(21);
    assertEqual(MagicSquareSolver.getRowSum(grid21, 10), magicConstant21, '21x21 Row 10 sum');
    assertEqual(MagicSquareSolver.getColSum(grid21, 5), magicConstant21, '21x21 Col 5 sum');
    assertEqual(MagicSquareSolver.getPrimaryDiagSum(grid21), magicConstant21, '21x21 Primary diagonal sum');
    assertEqual(MagicSquareSolver.getSecondaryDiagSum(grid21), magicConstant21, '21x21 Secondary diagonal sum');
    assertTrue(MagicSquareSolver.checkSolved(grid21), 'Generated 21x21 should be solved');
    print('✓ 21x21 magic square generation & verification passed.');

    // 6. Mutated State Check
    final grid3Mutated = MagicSquareSolver.generate(3);
    final tmp = grid3Mutated[0][0];
    grid3Mutated[0][0] = grid3Mutated[0][1];
    grid3Mutated[0][1] = tmp;
    assertFalse(MagicSquareSolver.checkSolved(grid3Mutated), 'Mutated 3x3 should not be solved');
    print('✓ Mutated grid detection passed.');

    // 7. Verify Levels 11 to 15 info
    final lvl11 = LevelInfo.forLevel(11);
    assertEqual(lvl11.gridSize, 23, 'Lvl 11 size should be 23');
    assertEqual(lvl11.magicConstant, 6095, 'Lvl 11 magicConstant should be 6095');
    assertEqual(lvl11.difficultyName, 'Immortal', 'Lvl 11 difficultyName should be Immortal');

    final lvl12 = LevelInfo.forLevel(12);
    assertEqual(lvl12.gridSize, 25, 'Lvl 12 size should be 25');
    assertEqual(lvl12.magicConstant, 7825, 'Lvl 12 magicConstant should be 7825');
    assertEqual(lvl12.difficultyName, 'Celestial', 'Lvl 12 difficultyName should be Celestial');

    final lvl13 = LevelInfo.forLevel(13);
    assertEqual(lvl13.gridSize, 27, 'Lvl 13 size should be 27');
    assertEqual(lvl13.magicConstant, 9855, 'Lvl 13 magicConstant should be 9855');
    assertEqual(lvl13.difficultyName, 'Astral', 'Lvl 13 difficultyName should be Astral');

    final lvl14 = LevelInfo.forLevel(14);
    assertEqual(lvl14.gridSize, 29, 'Lvl 14 size should be 29');
    assertEqual(lvl14.magicConstant, 12209, 'Lvl 14 magicConstant should be 12209');
    assertEqual(lvl14.difficultyName, 'Eternal', 'Lvl 14 difficultyName should be Eternal');

    final lvl15 = LevelInfo.forLevel(15);
    assertEqual(lvl15.gridSize, 31, 'Lvl 15 size should be 31');
    assertEqual(lvl15.magicConstant, 14911, 'Lvl 15 magicConstant should be 14911');
    assertEqual(lvl15.difficultyName, 'Infinite', 'Lvl 15 difficultyName should be Infinite');

    assertEqual(LevelInfo.allLevels.length, 15, 'Total levels count should be 15');
    print('✓ Levels 11-15 configurations and calculations passed.');

    print('\nALL TESTS PASSED SUCCESSFULLY! 🎉');
  } catch (e) {
    print('\n❌ TEST RUN FAILED!');
    print(e.toString());
  }
}
