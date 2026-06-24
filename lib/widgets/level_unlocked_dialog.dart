import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/level_info.dart';
import '../services/theme_manager.dart';

class LevelUnlockedDialog extends StatefulWidget {
  final int levelNumber;
  final GameTheme theme;

  const LevelUnlockedDialog({
    super.key,
    required this.levelNumber,
    required this.theme,
  });

  @override
  State<LevelUnlockedDialog> createState() => _LevelUnlockedDialogState();
}

class _LevelUnlockedDialogState extends State<LevelUnlockedDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _lockOpenAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.25, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
      ),
    );

    _lockOpenAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOutBack),
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
    );

    _buttonScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = LevelInfo.forLevel(widget.levelNumber);
    final accentColor = widget.theme.accentColor;

    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: const Color(0xff121829),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.25),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sparkles & Lock Icon
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // Determine lock icon state
                    final bool isUnlocked = _lockOpenAnimation.value >= 0.5;
                    
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow behind lock
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.3 * _lockOpenAnimation.value),
                                  blurRadius: 30 * _lockOpenAnimation.value + 5,
                                  spreadRadius: 5 * _lockOpenAnimation.value,
                                ),
                              ],
                            ),
                          ),
                          // Unlocking lock icon
                          Icon(
                            isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                            color: isUnlocked ? accentColor : const Color(0xff8a9bb8),
                            size: 72,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Level Unlocked Title
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'LEVEL UNLOCKED!',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: accentColor.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Level ${widget.levelNumber}: ${level.difficultyName}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${level.gridSize}x${level.gridSize} Matrix • Target Sum: ${level.magicConstant}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xff8a9bb8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Action Button
                ScaleTransition(
                  scale: _buttonScaleAnimation,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      shadowColor: accentColor.withOpacity(0.4),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'AWESOME!',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
