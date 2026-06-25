import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_progress.dart';
import '../services/theme_manager.dart';
import 'particle_background.dart';

class SettingsScreen extends StatefulWidget {
  final GameProgress progress;
  final GameTheme theme;
  final VoidCallback onBack;
  final ValueChanged<GameTheme> onThemeChanged;
  final VoidCallback onResetProgress;

  const SettingsScreen({
    super.key,
    required this.progress,
    required this.theme,
    required this.onBack,
    required this.onThemeChanged,
    required this.onResetProgress,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSettingsCard(),
                    const SizedBox(height: 24),
                    _buildAboutCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
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
              'SETTINGS',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Customize your matrix experience',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: widget.theme.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x15ffffff),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUDIO & GAMEPLAY',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: widget.theme.secondaryTextColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildAudioVibeRows(),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),
          Text(
            'INTERFACE COLOR SCHEME',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: widget.theme.secondaryTextColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildThemeSelector(),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildAudioVibeRows() {
    return Column(
      children: [
        _buildSettingToggle(
          title: 'Sound FX',
          value: widget.progress.soundEnabled,
          iconOn: Icons.volume_up_rounded,
          iconOff: Icons.volume_off_rounded,
          onChanged: (val) {
            setState(() {
              widget.progress.soundEnabled = val;
              widget.progress.save();
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSettingToggle(
          title: 'Background Music',
          value: widget.progress.musicEnabled,
          iconOn: Icons.music_note_rounded,
          iconOff: Icons.music_off_rounded,
          onChanged: (val) {
            setState(() {
              widget.progress.musicEnabled = val;
              widget.progress.save();
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSettingToggle(
          title: 'Haptic Vibration',
          value: widget.progress.vibrationEnabled,
          iconOn: Icons.vibration_rounded,
          iconOff: Icons.phone_android_rounded,
          onChanged: (val) {
            setState(() {
              widget.progress.vibrationEnabled = val;
              widget.progress.save();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSettingToggle({
    required String title,
    required bool value,
    required IconData iconOn,
    required IconData iconOff,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              value ? iconOn : iconOff,
              color: widget.theme.accentColor,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Switch.adaptive(
          activeColor: widget.theme.accentColor,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ThemeManager.themes.map((theme) {
        final isSelected = widget.theme.name == theme.name;
        return GestureDetector(
          onTap: () => widget.onThemeChanged(theme),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? theme.accentColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [theme.accentColor, theme.accentColor.withOpacity(0.6)],
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.accentColor.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2d171b),
          foregroundColor: const Color(0xffff3b30),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0x30ff3b30)),
          ),
        ),
        icon: const Icon(Icons.delete_outline_rounded),
        label: Text(
          'Delete Game Records',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        onPressed: () => _confirmReset(context),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x15ffffff),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ABOUT MAGIC SQUARES',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: widget.theme.secondaryTextColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A Magic Square is a mathematical arrangement of distinct integers in an n x n grid, where the numbers in each row, column, and primary/secondary diagonal add up to the same constant.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xffcfd8dc),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The Magic Constant (M) is defined by the algebraic formula:',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: widget.theme.secondaryTextColor,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'M = n * (n² + 1) / 2',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Our grid sizes start at 3x3 (constant sum 15) and scale up to a colossal 21x21 grid (constant sum 4,641). Unlocked cells can be swapped freely, while locked metallic nodes remain fixed to provide clues.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xffcfd8dc),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.theme.backgroundColors[0],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: widget.theme.accentColor.withOpacity(0.3), width: 1.5),
        ),
        title: Text(
          'Reset Progress?',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will delete all completed levels, high scores, best times, and medals. This action cannot be undone.',
          style: GoogleFonts.inter(color: widget.theme.secondaryTextColor),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffff3b30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Reset', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              widget.onResetProgress();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All game records have been cleared.', style: GoogleFonts.inter()),
                  backgroundColor: Colors.blueGrey[800],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
