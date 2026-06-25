import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../models/game_progress.dart';
import '../services/theme_manager.dart';
import 'particle_background.dart';

class HomeScreen extends StatefulWidget {
  final GameProgress progress;
  final GameTheme theme;
  final Function(int) onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.progress,
    required this.theme,
    required this.onNavigateToTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.theme.accentColor;

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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Game Logo with Circular Shape and Dual Neon Glow
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withOpacity(0.35),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: widget.theme.glowColor.withOpacity(0.2),
                              blurRadius: 25,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ALIGN THE MATRICES',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.secondaryTextColor,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Action buttons
                      _buildMenuButton(
                        label: 'PLAY MATRIX',
                        icon: Icons.play_arrow_rounded,
                        isPrimary: true,
                        onPressed: () => widget.onNavigateToTab(0),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        label: 'CHRONICLE (RANKINGS)',
                        icon: Icons.emoji_events_rounded,
                        isPrimary: false,
                        onPressed: () => widget.onNavigateToTab(1),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        label: 'CONTROL (SETTINGS)',
                        icon: Icons.tune_rounded,
                        isPrimary: false,
                        onPressed: () => widget.onNavigateToTab(2),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        label: 'EXIT SYSTEM',
                        icon: Icons.power_settings_new_rounded,
                        isPrimary: false,
                        isDanger: true,
                        onPressed: () {
                          if (Platform.isAndroid || Platform.isIOS) {
                            SystemNavigator.pop();
                          } else {
                            exit(0);
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    bool isDanger = false,
    required VoidCallback onPressed,
  }) {
    final accentColor = widget.theme.accentColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 280),
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isPrimary
              ? LinearGradient(
                  colors: [accentColor, widget.theme.glowColor.withOpacity(0.8)],
                )
              : null,
          color: isPrimary ? null : const Color(0x10ffffff),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDanger
                      ? const Color(0xffff3b30).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: widget.theme.glowColor.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: isPrimary
                ? Colors.black
                : (isDanger ? const Color(0xffff3b30) : accentColor),
            size: 22,
          ),
          label: Text(
            label,
            style: GoogleFonts.inter(
              color: isPrimary
                  ? Colors.black
                  : (isDanger ? const Color(0xffff3b30) : Colors.white),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
