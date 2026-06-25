import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/storage_service.dart';
import 'services/theme_manager.dart';
import 'models/game_progress.dart';
import 'widgets/level_select_screen.dart';
import 'widgets/leaderboard_screen.dart';
import 'widgets/settings_screen.dart';
import 'widgets/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Square',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff000000),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const GameLauncher(),
    );
  }
}

class GameLauncher extends StatefulWidget {
  const GameLauncher({super.key});

  @override
  State<GameLauncher> createState() => _GameLauncherState();
}

class _GameLauncherState extends State<GameLauncher> {
  late AppStorage _storage;
  late GameProgress _progress;
  bool _isLoading = true;
  bool _showHome = true;
  int _currentIndex = 0;
  GameTheme _currentTheme = ThemeManager.cyberpunkNeon;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() async {
    try {
      _storage = createStorageInstance();
      await _storage.init();
    } catch (e) {
      _storage = MemoryStorage();
    }
    _progress = GameProgress(_storage);
    await _progress.load();
    setState(() {
      _isLoading = false;
    });
  }

  void _handleResetProgress() async {
    await _progress.resetAll();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xffff0055),
          ),
        ),
      );
    }

    if (_showHome) {
      return HomeScreen(
        progress: _progress,
        theme: _currentTheme,
        onNavigateToTab: (index) {
          setState(() {
            _currentIndex = index;
            _showHome = false;
          });
        },
      );
    }

    final List<Widget> screens = [
      LevelSelectScreen(
        progress: _progress,
        theme: _currentTheme,
        onBack: () {
          setState(() {
            _showHome = true;
          });
        },
      ),
      LeaderboardScreen(
        progress: _progress,
        theme: _currentTheme,
        onBack: () {
          setState(() {
            _showHome = true;
          });
        },
      ),
      SettingsScreen(
        progress: _progress,
        theme: _currentTheme,
        onBack: () {
          setState(() {
            _showHome = true;
          });
        },
        onThemeChanged: (theme) {
          setState(() {
            _currentTheme = theme;
          });
        },
        onResetProgress: _handleResetProgress,
      ),
    ];

    return Scaffold(
      backgroundColor: _currentTheme.backgroundColors[0],
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0x10ffffff),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: _currentTheme.accentColor,
          unselectedItemColor: const Color(0xff8a9bb8),
          selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'MATRIX',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_rounded),
              label: 'CHRONICLE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              label: 'CONTROL',
            ),
          ],
        ),
      ),
    );
  }
}
