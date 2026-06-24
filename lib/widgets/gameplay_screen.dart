import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/level_info.dart';
import '../models/game_state.dart';
import '../models/game_progress.dart';
import '../services/magic_square_solver.dart';
import '../services/theme_manager.dart';
import 'particle_background.dart';
import 'level_unlocked_dialog.dart';

class GamePlayScreen extends StatefulWidget {
  final LevelInfo level;
  final GameProgress progress;
  final GameTheme theme;

  const GamePlayScreen({
    super.key,
    required this.level,
    required this.progress,
    required this.theme,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> with SingleTickerProviderStateMixin {
  late GameState _gameState;
  bool _isPaused = false;
  bool _showWinOverlay = false;
  Map<String, dynamic> _winData = {};
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _gameState = GameState(
      levelInfo: widget.level,
      onTick: () => setState(() {}),
      onWin: _handleWin,
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _gameState.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _handleWin() async {
    _gameState.pauseTimer();
    
    final nextLevel = widget.level.levelNumber + 1;
    final isNextLevelInitiallyLocked = nextLevel <= 15 && !widget.progress.isUnlocked(nextLevel);

    final winDetails = await widget.progress.completeLevel(
      widget.level,
      _gameState.secondsElapsed,
      _gameState.moveCount,
    );
    setState(() {
      _winData = winDetails;
      _winData['newLevelUnlocked'] = isNextLevelInitiallyLocked;
      _winData['unlockedLevelNumber'] = nextLevel;
      _showWinOverlay = true;
    });
    _celebrationController.forward(from: 0.0);

    if (isNextLevelInitiallyLocked) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => LevelUnlockedDialog(
              levelNumber: nextLevel,
              theme: widget.theme,
            ),
          );
        }
      });
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _gameState.pauseTimer();
      } else {
        _gameState.resumeTimer();
      }
    });
  }

  void _restartLevel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff121829),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xff1b223c)),
        ),
        title: Text(
          'Restart Level?',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will reset the grid and restart the timer. Your current progress on this run will be lost.',
          style: GoogleFonts.inter(color: const Color(0xff8a9bb8)),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.theme.accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Restart', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _gameState.reset();
                _isPaused = false;
                _showWinOverlay = false;
              });
            },
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.backgroundColors[0],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.theme.backgroundColors,
          ),
        ),
        child: Stack(
          children: [
            ParticleBackground(theme: widget.theme),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  _buildHUD(),
                  Expanded(
                    child: _isPaused
                        ? _buildPausedWidget()
                        : _buildGameBoard(),
                  ),
                  _buildFooterControls(),
                ],
              ),
            ),
            if (_showWinOverlay) _buildWinOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () {
              _gameState.pauseTimer();
              Navigator.of(context).pop();
            },
          ),
          Text(
            'LEVEL ${widget.level.levelNumber}',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: widget.theme.glowColor.withOpacity(0.35),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white, size: 28),
            onPressed: _togglePause,
          ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    final int currentSec = _gameState.secondsElapsed;
    Color timerColor = widget.theme.accentColor;
    String activeMedal = 'Gold';
    
    if (currentSec <= widget.level.goldTimeSec) {
      timerColor = const Color(0xffffd700);
      activeMedal = 'Gold';
    } else if (currentSec <= widget.level.silverTimeSec) {
      timerColor = const Color(0xffc0c0c0);
      activeMedal = 'Silver';
    } else if (currentSec <= widget.level.bronzeTimeSec) {
      timerColor = const Color(0xffcd7f32);
      activeMedal = 'Bronze';
    } else {
      timerColor = Colors.white70;
      activeMedal = 'None';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0x15ffffff),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  'TIMER',
                  style: GoogleFonts.inter(fontSize: 10, color: widget.theme.secondaryTextColor, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(currentSec),
                  style: GoogleFonts.outfit(fontSize: 20, color: timerColor, fontWeight: FontWeight.bold),
                ),
                Text(
                  activeMedal,
                  style: GoogleFonts.inter(fontSize: 9, color: timerColor.withOpacity(0.8), fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Container(height: 32, width: 1, color: Colors.white.withOpacity(0.1)),
            Column(
              children: [
                Text(
                  'MOVES',
                  style: GoogleFonts.inter(fontSize: 10, color: widget.theme.secondaryTextColor, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_gameState.moveCount}',
                  style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(height: 32, width: 1, color: Colors.white.withOpacity(0.1)),
            Column(
              children: [
                Text(
                  'TARGET SUM',
                  style: GoogleFonts.inter(fontSize: 10, color: widget.theme.secondaryTextColor, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.level.magicConstant}',
                  style: GoogleFonts.outfit(fontSize: 20, color: const Color(0xffffe600), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPausedWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pause_circle_filled_rounded, size: 80, color: widget.theme.accentColor.withOpacity(0.6)),
          const SizedBox(height: 16),
          Text(
            'Game Paused',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Grid is hidden to prevent cheating!',
            style: GoogleFonts.inter(fontSize: 14, color: widget.theme.secondaryTextColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.theme.accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
            label: Text(
              'Resume Game',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            onPressed: _togglePause,
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    final int n = widget.level.gridSize;
    double cellSize = n <= 3 ? 64.0 : (n <= 5 ? 54.0 : (n <= 7 ? 46.0 : 38.0));
    final double gridSpace = 6.0;

    final double totalGridWidth = (n + 1) * (cellSize + gridSpace);
    final double totalGridHeight = (n + 1) * (cellSize + gridSpace);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool fitsWidth = totalGridWidth <= constraints.maxWidth;
        final bool fitsHeight = totalGridHeight <= constraints.maxHeight;

        Widget board = Container(
          width: totalGridWidth,
          height: totalGridHeight,
          padding: const EdgeInsets.all(8.0),
          child: Table(
            defaultColumnWidth: FixedColumnWidth(cellSize + gridSpace),
            children: List.generate(n + 1, (r) {
              return TableRow(
                children: List.generate(n + 1, (c) {
                  return Padding(
                    padding: EdgeInsets.all(gridSpace / 2),
                    child: SizedBox(
                      width: cellSize,
                      height: cellSize,
                      child: _buildGridItem(r, c, n),
                    ),
                  );
                }),
              );
            }),
          ),
        );

        if (!fitsWidth || !fitsHeight) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pinch_rounded, color: Color(0xff8a9bb8), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Pinch to zoom / Drag to pan',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xff8a9bb8)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(120),
                    minScale: 0.3,
                    maxScale: 2.0,
                    constrained: false,
                    child: board,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Center(child: board);
        }
      },
    );
  }

  Widget _buildGridItem(int r, int c, int n) {
    if (r < n && c < n) {
      final value = _gameState.currentGrid[r][c];
      final isLocked = _gameState.lockedGrid[r][c];
      final isSelected = _gameState.selectedRow == r && _gameState.selectedCol == c;

      return GestureDetector(
        onTap: () {
          setState(() {
            _gameState.selectCell(r, c);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isLocked
                ? const Color(0x302a354c)
                : (isSelected ? widget.theme.accentColor.withOpacity(0.35) : const Color(0x15ffffff)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? widget.theme.accentColor
                  : (isLocked ? const Color(0xff8a9bb8).withOpacity(0.3) : Colors.white.withOpacity(0.12)),
              width: isSelected ? 2.5 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: widget.theme.accentColor.withOpacity(0.4),
                      offset: const Offset(0, 0),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$value',
                style: GoogleFonts.outfit(
                  fontSize: n <= 5 ? 18 : 14,
                  fontWeight: isLocked ? FontWeight.bold : FontWeight.w500,
                  color: isLocked ? const Color(0xffcfd8dc) : const Color(0xffe0f7fa),
                ),
              ),
              if (isLocked)
                const Positioned(
                  bottom: 2,
                  right: 2,
                  child: Icon(Icons.lock_rounded, size: 10, color: Color(0xff8a9bb8)),
                ),
            ],
          ),
        ),
      );
    }

    if (r < n && c == n) {
      final rowSum = MagicSquareSolver.getRowSum(_gameState.currentGrid, r);
      final isTarget = rowSum == widget.level.magicConstant;
      return _buildSumBadge(rowSum, isTarget);
    }

    if (r == n && c < n) {
      final colSum = MagicSquareSolver.getColSum(_gameState.currentGrid, c);
      final isTarget = colSum == widget.level.magicConstant;
      return _buildSumBadge(colSum, isTarget);
    }

    if (r == n && c == n) {
      final diag1 = MagicSquareSolver.getPrimaryDiagSum(_gameState.currentGrid);
      final diag2 = MagicSquareSolver.getSecondaryDiagSum(_gameState.currentGrid);
      final d1Target = diag1 == widget.level.magicConstant;
      final d2Target = diag2 == widget.level.magicConstant;

      return Container(
        decoration: BoxDecoration(
          color: const Color(0x05ffffff),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.north_west_rounded, size: 8, color: Color(0xff8a9bb8)),
                Text(
                  '$diag1',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: d1Target ? widget.theme.accentColor : const Color(0xff8a9bb8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.south_west_rounded, size: 8, color: Color(0xff8a9bb8)),
                Text(
                  '$diag2',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: d2Target ? widget.theme.accentColor : const Color(0xff8a9bb8),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSumBadge(int sum, bool isTarget) {
    return Container(
      decoration: BoxDecoration(
        color: isTarget ? widget.theme.accentColor.withOpacity(0.15) : const Color(0x10ff3b30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTarget ? widget.theme.accentColor.withOpacity(0.6) : const Color(0xffff3b30).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: isTarget
            ? [
                BoxShadow(
                  color: widget.theme.accentColor.withOpacity(0.15),
                  blurRadius: 4,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          '$sum',
          style: GoogleFonts.inter(
            fontSize: widget.level.gridSize <= 5 ? 13 : 10,
            fontWeight: FontWeight.w800,
            color: isTarget ? widget.theme.accentColor : const Color(0xffff8a80),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterControls() {
    final diag1 = MagicSquareSolver.getPrimaryDiagSum(_gameState.currentGrid);
    final diag2 = MagicSquareSolver.getSecondaryDiagSum(_gameState.currentGrid);
    final d1Correct = diag1 == widget.level.magicConstant;
    final d2Correct = diag2 == widget.level.magicConstant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.north_west_rounded, size: 14, color: d1Correct ? widget.theme.accentColor : const Color(0xff8a9bb8)),
                  const SizedBox(width: 4),
                  Text(
                    'Diag ↘: $diag1',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: d1Correct ? widget.theme.accentColor : Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.south_west_rounded, size: 14, color: d2Correct ? widget.theme.accentColor : const Color(0xff8a9bb8)),
                  const SizedBox(width: 4),
                  Text(
                    'Diag ↗: $diag2',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: d2Correct ? widget.theme.accentColor : Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.help_outline_rounded, color: widget.theme.accentColor, size: 28),
                onPressed: () => _showHelpBottomSheet(context),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 28),
                onPressed: _restartLevel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWinOverlay(BuildContext context) {
    final int score = _winData['score'] ?? 0;
    final bool isHighScore = _winData['isNewHighScore'] ?? false;
    final String medal = _winData['medal'] ?? 'none';
    final int totalTime = _winData['timeSec'] ?? 0;
    final int moves = _winData['moves'] ?? 0;

    Color medalColor;
    switch (medal) {
      case 'gold':
        medalColor = const Color(0xffffd700);
        break;
      case 'silver':
        medalColor = const Color(0xffc0c0c0);
        break;
      case 'bronze':
        medalColor = const Color(0xffcd7f32);
        break;
      default:
        medalColor = Colors.white54;
    }

    return FadeTransition(
      opacity: CurvedAnimation(parent: _celebrationController, curve: Curves.easeIn),
      child: Container(
        color: Colors.black.withOpacity(0.85),
        alignment: Alignment.center,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xff121829),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: widget.theme.accentColor.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: widget.theme.accentColor.withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LEVEL COMPLETE!',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: widget.theme.accentColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (medal != 'none') ...[
                    Icon(Icons.emoji_events_rounded, color: medalColor, size: 72),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final int starsCount = medal == 'gold' ? 3 : (medal == 'silver' ? 2 : 1);
                        final bool isLit = index < starsCount;
                        return Icon(
                          Icons.star_rounded,
                          color: isLit ? const Color(0xffffd700) : Colors.white12,
                          size: 32,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${medal.toUpperCase()} MEDAL',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: medalColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ] else ...[
                    Icon(Icons.check_circle_outline_rounded, color: widget.theme.accentColor, size: 72),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final bool isLit = index < 1;
                        return Icon(
                          Icons.star_rounded,
                          color: isLit ? const Color(0xffffd700) : Colors.white12,
                          size: 32,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'COMPLETED!',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.accentColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (isHighScore) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xffffd700).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'NEW HIGH SCORE!',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xffffd700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    '$score PTS',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.08)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Time Taken', style: GoogleFonts.inter(fontSize: 11, color: widget.theme.secondaryTextColor)),
                          const SizedBox(height: 4),
                          Text(_formatTime(totalTime), style: GoogleFonts.outfit(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Total Moves', style: GoogleFonts.inter(fontSize: 11, color: widget.theme.secondaryTextColor)),
                          const SizedBox(height: 4),
                          Text('$moves', style: GoogleFonts.outfit(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'Menu',
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.theme.accentColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          widget.level.levelNumber < 15 ? 'Next Level' : 'Replay',
                          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (widget.level.levelNumber < 15) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => GamePlayScreen(
                                  level: LevelInfo.forLevel(widget.level.levelNumber + 1),
                                  progress: widget.progress,
                                  theme: widget.theme,
                                ),
                              ),
                            );
                          } else {
                            setState(() {
                              _gameState.reset();
                              _showWinOverlay = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff121829),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: widget.theme.accentColor.withOpacity(0.2))),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HOW TO PLAY',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Goal of the Game',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: widget.theme.accentColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Arrange the numbers in the grid so that every ROW, COLUMN, and DIAGONAL sums up to the Target Sum: ${widget.level.magicConstant}.',
                style: GoogleFonts.inter(color: const Color(0xff8a9bb8), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Controls & Visuals',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: widget.theme.accentColor),
              ),
              const SizedBox(height: 6),
              _buildBulletPoint('Locked Cells', 'Dark cells with lock icons are frozen in their correct positions and cannot be moved.'),
              _buildBulletPoint('Unlocked Cells', 'Lighter translucent cells can be selected. Tap one cell, then tap another unlocked cell to swap their numbers.'),
              _buildBulletPoint('Sum Indicators', 'Badges on the right and bottom show current sums. They glow green when matching the target sum, and red when they do not.'),
              _buildBulletPoint('Diagonals', 'Diagonal sums are displayed in the bottom-right grid cell and in the bottom-left corner of the HUD.'),
              const SizedBox(height: 16),
              Text(
                'Medal Benchmarks',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xffffe600)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMedalBadge('Gold', '${widget.level.goldTimeSec}s', const Color(0xffffd700)),
                  _buildMedalBadge('Silver', '${widget.level.silverTimeSec}s', const Color(0xffc0c0c0)),
                  _buildMedalBadge('Bronze', '${widget.level.bronzeTimeSec}s', const Color(0xffcd7f32)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right_rounded, color: Color(0xff39ff14), size: 20),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(color: const Color(0xff8a9bb8), fontSize: 13, height: 1.4),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalBadge(String title, String limit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_rounded, color: color, size: 24),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.outfit(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          Text(limit, style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  String _formatTime(int sec) {
    final int minutes = sec ~/ 60;
    final int seconds = sec % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
