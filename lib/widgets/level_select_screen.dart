import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/level_info.dart';
import '../models/game_progress.dart';
import '../services/theme_manager.dart';
import 'gameplay_screen.dart';
import 'particle_background.dart';

class LevelSelectScreen extends StatefulWidget {
  final GameProgress progress;
  final GameTheme theme;
  final VoidCallback onBack;

  const LevelSelectScreen({
    super.key,
    required this.progress,
    required this.theme,
    required this.onBack,
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {

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
                  _buildHeader(context),
                  Expanded(
                    child: _buildLevelGrid(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final int completedCount = widget.progress.bestTimes.keys.where((k) => k >= 1 && k <= 15).length;
    final double progressPercent = completedCount / 15.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                onPressed: widget.onBack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                'MAGIC SQUARE',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: widget.theme.glowColor.withOpacity(0.5),
                      offset: const Offset(0, 0),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Select a Matrix to Align',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: widget.theme.secondaryTextColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESS: $completedCount / 15 COMPLETED',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '${(progressPercent * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: widget.theme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 8,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    height: 8,
                    width: constraints.maxWidth * progressPercent,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.theme.accentColor,
                          widget.theme.glowColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: widget.theme.glowColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid(BuildContext context) {
    final levels = LevelInfo.allLevels;
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.74,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        return _buildLevelCard(context, level);
      },
    );
  }

  Widget _buildLevelCard(BuildContext context, LevelInfo level) {
    final int score = widget.progress.highScores[level.levelNumber] ?? 0;
    final int? time = widget.progress.bestTimes[level.levelNumber];
    final String medal = widget.progress.medals[level.levelNumber] ?? 'none';
    final bool isUnlocked = widget.progress.isUnlocked(level.levelNumber);
    final bool isCompleted = widget.progress.bestTimes.containsKey(level.levelNumber);

    final Color primaryGlowColor = isUnlocked ? _getDifficultyColor(level.levelNumber) : Colors.grey;

    return MouseRegion(
      cursor: isUnlocked ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () {
          if (isUnlocked) {
            _startLevel(context, level);
          } else {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xff121829),
                content: Text(
                  'Complete Level ${level.levelNumber - 1} to unlock Level ${level.levelNumber}!',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0x33ffffff)),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isUnlocked ? const Color(0x15ffffff) : const Color(0x08ffffff),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUnlocked ? primaryGlowColor.withOpacity(0.35) : Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: primaryGlowColor.withOpacity(0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: Opacity(
            opacity: isUnlocked ? 1.0 : 0.45,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LVL ${level.levelNumber}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryGlowColor,
                          letterSpacing: 1,
                        ),
                      ),
                      if (!isUnlocked)
                        const Icon(Icons.lock_rounded, color: Colors.grey, size: 18)
                      else if (medal != 'none')
                        _buildMedalIcon(medal)
                      else if (isCompleted)
                        const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    isUnlocked ? level.difficultyName : 'Locked',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Grid size
                  Text(
                    '${level.gridSize} x ${level.gridSize} Grid',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff8a9bb8),
                    ),
                  ),
                  const Spacer(),
                  // Details
                  if (isUnlocked) ...[
                    Text(
                      'Sum Target: ${level.magicConstant}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Divider(color: Colors.white.withOpacity(0.08), height: 1),
                    const SizedBox(height: 6),
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          score > 0 ? '$score pts' : 'Unplayed',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        if (time != null)
                          Text(
                            '${time}s',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.theme.accentColor,
                            ),
                          ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Locked',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Divider(color: Colors.white.withOpacity(0.08), height: 1),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.lock_clock_outlined, color: Colors.grey, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Beat Lvl ${level.levelNumber - 1}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(int level) {
    if (level <= 2) return const Color(0xff00d2ff); // Cyber Cyan
    if (level <= 4) return const Color(0xff39ff14); // Neon Green
    if (level <= 6) return const Color(0xffffe600); // Neon Yellow
    if (level <= 8) return const Color(0xffff5e00); // Neon Orange
    if (level <= 10) return const Color(0xffff0055); // Pink/Red Neon
    return const Color(0xffbd00ff); // Cosmic Purple (Levels 11-15)
  }

  Widget _buildMedalIcon(String medal) {
    Color color;
    IconData icon = Icons.emoji_events_rounded;
    switch (medal) {
      case 'gold':
        color = const Color(0xffffd700);
        break;
      case 'silver':
        color = const Color(0xffc0c0c0);
        break;
      case 'bronze':
        color = const Color(0xffcd7f32);
        break;
      default:
        return const SizedBox.shrink();
    }
    return Icon(icon, color: color, size: 18);
  }

  void _startLevel(BuildContext context, LevelInfo level) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GamePlayScreen(
          level: level,
          progress: widget.progress,
          theme: widget.theme,
        ),
      ),
    );
    // Refresh scores upon return
    setState(() {});
  }
}
