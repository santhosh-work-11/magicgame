import 'package:flutter_test/flutter_test.dart';
import 'package:magic_cube/services/magic_square_solver.dart';

void main() {
  group('MagicSquareSolver Tests', () {
    test('Calculate Magic Constants', () {
      expect(MagicSquareSolver.calculateMagicConstant(3), 15);
      expect(MagicSquareSolver.calculateMagicConstant(5), 65);
      expect(MagicSquareSolver.calculateMagicConstant(7), 175);
      expect(MagicSquareSolver.calculateMagicConstant(21), 4641);
    });

    test('Invalid Grid Size', () {
      expect(() => MagicSquareSolver.generate(2), throwsArgumentError);
      expect(() => MagicSquareSolver.generate(4), throwsArgumentError);
      expect(() => MagicSquareSolver.generate(0), throwsArgumentError);
    });

    test('Generate 3x3 Magic Square', () {
      final grid = MagicSquareSolver.generate(3);
      expect(grid.length, 3);
      expect(grid[0].length, 3);

      expect(MagicSquareSolver.getRowSum(grid, 0), 15);
      expect(MagicSquareSolver.getRowSum(grid, 1), 15);
      expect(MagicSquareSolver.getRowSum(grid, 2), 15);

      expect(MagicSquareSolver.getColSum(grid, 0), 15);
      expect(MagicSquareSolver.getColSum(grid, 1), 15);
      expect(MagicSquareSolver.getColSum(grid, 2), 15);

      expect(MagicSquareSolver.getPrimaryDiagSum(grid), 15);
      expect(MagicSquareSolver.getSecondaryDiagSum(grid), 15);

      expect(MagicSquareSolver.checkSolved(grid), isTrue);
    });

    test('Generate 5x5 Magic Square', () {
      final grid = MagicSquareSolver.generate(5);
      expect(grid.length, 5);
      expect(MagicSquareSolver.getRowSum(grid, 0), 65);
      expect(MagicSquareSolver.getColSum(grid, 2), 65);
      expect(MagicSquareSolver.getPrimaryDiagSum(grid), 65);
      expect(MagicSquareSolver.getSecondaryDiagSum(grid), 65);
      expect(MagicSquareSolver.checkSolved(grid), isTrue);
    });

    test('Generate 21x21 Magic Square', () {
      final grid = MagicSquareSolver.generate(21);
      expect(grid.length, 21);
      final magicConstant = MagicSquareSolver.calculateMagicConstant(21);
      
      expect(MagicSquareSolver.getRowSum(grid, 10), magicConstant);
      expect(MagicSquareSolver.getColSum(grid, 5), magicConstant);
      expect(MagicSquareSolver.getPrimaryDiagSum(grid), magicConstant);
      expect(MagicSquareSolver.getSecondaryDiagSum(grid), magicConstant);
      expect(MagicSquareSolver.checkSolved(grid), isTrue);
    });

    test('Check Solved with Invalid States', () {
      final grid = MagicSquareSolver.generate(3);
      
      // Mutate grid by swapping elements (making it unsolved)
      final value1 = grid[0][0];
      grid[0][0] = grid[0][1];
      grid[0][1] = value1;

      expect(MagicSquareSolver.checkSolved(grid), isFalse);
    });
  });
}
