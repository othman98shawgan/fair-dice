import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:vibration/vibration.dart';

import 'dice_view.dart';
import 'fair_dice_engine.dart';
import 'settings_view.dart';
import 'stats_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global Theme Notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  runApp(const FairRollApp());
}

class FairRollApp extends StatelessWidget {
  const FairRollApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. This listens for theme changes and instantly rebuilds the app
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        return MaterialApp(
          title: 'FairRoll',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, // Dynamically switches
          // --- THE LIGHT THEME ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF3F4F6), // Off-white
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF344E41), // Emerald Green stays consistent
              surface: Colors.white, // Pure white for floating components
            ),
            fontFamily: 'Inter',
          ),

          // --- THE DARK THEME ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF2C363F), // Deep Slate Grey
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF344E41), // Emerald Green
              surface: Color(0xFF1E252B),
            ),
            fontFamily: 'Inter',
          ),
          home: const AppShell(),
        );
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0; // Tracks bottom nav

  // Hoisted State
  int _selectedDiceCount = 2;
  bool _showTotal = false;
  bool _isDarkMode = true; // UI only, not implemented yet
  bool _hapticsEnabled = true;

  List<int> _currentRoll = [6, 6];
  bool _isRolling = false;
  late FairDiceEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = FairDiceEngine(_selectedDiceCount);
    _loadSettings(); // Fetch the saved data on boot
  }

  // THE BOOT SEQUENCE
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Read from disk, fallback to defaults if it's the first launch
      _selectedDiceCount = prefs.getInt('diceCount') ?? 2;
      _showTotal = prefs.getBool('showTotal') ?? true;
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;

      // Sync the global theme
      themeNotifier.value = _isDarkMode ? ThemeMode.dark : ThemeMode.light;

      // Sync the engine and UI state
      _engine.reset(_selectedDiceCount);
      _currentRoll = List.generate(_selectedDiceCount, (_) => 6);
    });
  }

  // THE WRITE SEQUENCES
  void _updateDiceCount(int count) async {
    if (_selectedDiceCount == count) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('diceCount', count); // Save to disk

    setState(() {
      _selectedDiceCount = count;
      _engine.reset(count);
      _currentRoll = List.generate(count, (_) => 6);
    });
  }

  // The physics animation from earlier
  Future<void> _executeRollAnimation() async {
    if (_isRolling) return;
    setState(() => _isRolling = true);

    final realResult = _engine.roll();
    final random = math.Random();
    final List<int> tumbleDelays = [40, 40, 40, 60, 60, 80, 100, 140, 200, 300];

    // 1. Check hardware ONCE before the loop to prevent crashes
    bool hasVibrator = false;
    bool hasCustomAmplitude = false;
    if (_hapticsEnabled) {
      hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        hasCustomAmplitude = await Vibration.hasCustomVibrationsSupport();
      }
    }

    for (final delay in tumbleDelays) {
      // 2. The Chatter
      if (hasVibrator) {
        if (hasCustomAmplitude) {
          Vibration.vibrate(duration: 50, amplitude: 50); // Your successful timing
        } else {
          Vibration.vibrate(duration: 50); // Fallback for cheap phones
        }
      }

      await Future.delayed(Duration(milliseconds: delay));
      if (!mounted) return;
      setState(() {
        _currentRoll = List.generate(_selectedDiceCount, (_) => random.nextInt(6) + 1);
      });
    }

    if (!mounted) return;

    // 3. The Slam
    if (hasVibrator) {
      if (hasCustomAmplitude) {
        Vibration.vibrate(duration: 100, amplitude: 128); // Your successful timing
      } else {
        Vibration.vibrate(duration: 100); // Fallback for cheap phones
      }
    }

    setState(() {
      _currentRoll = realResult;
      _isRolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Array of our screens
    final List<Widget> screens = [
      DiceView(
        currentRoll: _currentRoll,
        isRolling: _isRolling,
        engine: _engine,
        showTotal: _showTotal,
        onRoll: _executeRollAnimation,
      ),
      StatsView(frequencies: _engine.sessionFrequencies, diceCount: _selectedDiceCount),
      SettingsView(
        diceCount: _selectedDiceCount,
        showTotal: _showTotal,
        isDarkMode: _isDarkMode,
        onDiceCountChanged: _updateDiceCount,
        onShowTotalChanged: (val) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('showTotal', val);
          setState(() => _showTotal = val);
        },
        onThemeChanged: (val) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isDarkMode', val);
          setState(() => _isDarkMode = val);
          themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
        },
        hapticsEnabled: _hapticsEnabled,
        onHapticsChanged: (val) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('hapticsEnabled', val);
          setState(() => _hapticsEnabled = val);
        },
      ),
    ];

    return Scaffold(
      extendBody: true,
      // Wrap screens in SafeArea, but let the bottom bleed through
      body: SafeArea(bottom: false, child: screens[_currentIndex]),
      bottomNavigationBar: _buildFloatingGNav(),
    );
  }

  Widget _buildFloatingGNav() {
    return SafeArea(
      // Move SafeArea to the outside to protect the bottom edge
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0), // Removed the left/right constraints
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // THE FIX: Forces the container to shrink-wrap
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: GNav(
                rippleColor: Colors.grey[800]!,
                hoverColor: Colors.grey[700]!,
                haptic: true,
                tabBorderRadius: 100,
                tabActiveBorder: Border.all(color: Colors.transparent, width: 0),
                tabBorder: Border.all(color: Colors.transparent, width: 0),
                tabShadow: [BoxShadow(color: Colors.transparent)],
                curve: Curves.easeOutExpo,
                duration: const Duration(milliseconds: 150),
                gap: 8,
                color: Colors.grey.shade500,
                activeColor: Theme.of(context).colorScheme.primary,
                iconSize: 28,
                tabBackgroundColor: Theme.of(context).colorScheme.primary.withAlpha(40),

                // THE SECOND FIX: Tightened the horizontal padding slightly
                // so the buttons themselves don't force unnecessary width
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

                selectedIndex: _currentIndex,
                onTabChange: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                tabs: const [
                  GButton(icon: Icons.casino, text: 'Roll'),
                  GButton(icon: Icons.leaderboard, text: 'Stats'),
                  GButton(icon: Icons.settings, text: 'Settings'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
