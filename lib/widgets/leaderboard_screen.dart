import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../services/theme_manager.dart';
import 'particle_background.dart';

class LeaderboardScreen extends StatelessWidget {
  final GameProgress progress;
  final GameTheme theme;
  final VoidCallback onBack;

  const LeaderboardScreen({
    super.key,
    required this.progress,
    required this.theme,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate player's total stats
    final int playerTotalScore = progress.highScores.values.fold(0, (sum, val) => sum + val);
    
    int goldCount = 0;
    int silverCount = 0;
    int bronzeCount = 0;
    for (final medal in progress.medals.values) {
      if (medal == 'gold') goldCount++;
      if (medal == 'silver') silverCount++;
      if (medal == 'bronze') bronzeCount++;
    }

    // 2. Generate list of global rankings
    final List<_LeaderboardEntry> list = [
      _LeaderboardEntry(name: 'NeuralMage', score: 54200, avatarInit: 'NM', color: const Color(0xffff0055), isPlayer: false),
      _LeaderboardEntry(name: 'CyberGhost', score: 46800, avatarInit: 'CG', color: const Color(0xffffe600), isPlayer: false),
      _LeaderboardEntry(name: 'PixelGlitch', score: 38500, avatarInit: 'PG', color: const Color(0xff00d2ff), isPlayer: false),
      _LeaderboardEntry(name: 'TechnoSage', score: 29400, avatarInit: 'TS', color: const Color(0xff39ff14), isPlayer: false),
      _LeaderboardEntry(name: 'MatrixPulse', score: 18500, avatarInit: 'MP', color: const Color(0xffe040fb), isPlayer: false),
      _LeaderboardEntry(name: 'CrypticCode', score: 8200, avatarInit: 'CC', color: const Color(0xffff5e00), isPlayer: false),
    ];

    // Insert player into rankings based on score
    final playerEntry = _LeaderboardEntry(
      name: 'YOU (Arithmancer)',
      score: playerTotalScore,
      avatarInit: 'U',
      color: theme.accentColor,
      isPlayer: true,
    );

    int insertIndex = 0;
    while (insertIndex < list.length && list[insertIndex].score > playerTotalScore) {
      insertIndex++;
    }
    list.insert(insertIndex, playerEntry);

    return Scaffold(
      backgroundColor: theme.backgroundColors[0],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.backgroundColors,
          ),
        ),
        child: Stack(
          children: [
            ParticleBackground(theme: theme),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  _buildPlayerStatsCard(playerTotalScore, goldCount, silverCount, bronzeCount),
                  Expanded(
                    child: _buildRanksList(list),
                  ),
                ],
              ),
            ),
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
            onPressed: onBack,
          ),
          Text(
            'LEADERBOARDS',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance back button
        ],
      ),
    );
  }

  Widget _buildPlayerStatsCard(int score, int gold, int silver, int bronze) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0x15ffffff),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.accentColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: theme.glowColor.withOpacity(0.05),
              blurRadius: 15,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'YOUR TOTAL SCORE',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: theme.secondaryTextColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$score PTS',
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: theme.glowColor.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMedalColumn('GOLD', gold, const Color(0xffffd700)),
                _buildMedalColumn('SILVER', silver, const Color(0xffc0c0c0)),
                _buildMedalColumn('BRONZE', bronze, const Color(0xffcd7f32)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedalColumn(String title, int count, Color color) {
    return Column(
      children: [
        Icon(Icons.emoji_events_rounded, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.8),
            letterSpacing: 1,
          ),
        ),
        Text(
          '$count',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRanksList(List<_LeaderboardEntry> list) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final entry = list[index];
        final rank = index + 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: entry.isPlayer ? theme.accentColor.withOpacity(0.12) : const Color(0x0affffff),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: entry.isPlayer
                    ? theme.accentColor.withOpacity(0.4)
                    : Colors.white.withOpacity(0.05),
                width: entry.isPlayer ? 1.5 : 1,
              ),
              boxShadow: entry.isPlayer
                  ? [
                      BoxShadow(
                        color: theme.glowColor.withOpacity(0.08),
                        blurRadius: 10,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Rank number
                SizedBox(
                  width: 32,
                  child: Text(
                    '#$rank',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rank <= 3 ? _getRankColor(rank) : const Color(0xff8a9bb8),
                    ),
                  ),
                ),
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: entry.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: entry.color.withOpacity(0.6), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.avatarInit,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: entry.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Competitor Name
                Expanded(
                  child: Text(
                    entry.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: entry.isPlayer ? FontWeight.w800 : FontWeight.w500,
                      color: entry.isPlayer ? Colors.white : const Color(0xffcfd8dc),
                    ),
                  ),
                ),
                // Score
                Text(
                  '${entry.score} pts',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: entry.isPlayer ? theme.accentColor : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xffffd700);
    if (rank == 2) return const Color(0xffc0c0c0);
    return const Color(0xffcd7f32);
  }
}

class _LeaderboardEntry {
  final String name;
  final int score;
  final String avatarInit;
  final Color color;
  final bool isPlayer;

  _LeaderboardEntry({
    required this.name,
    required this.score,
    required this.avatarInit,
    required this.color,
    required this.isPlayer,
  });
}
