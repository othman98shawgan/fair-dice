import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  final int diceCount;
  final bool showTotal;
  final bool isDarkMode;
  final Function(int) onDiceCountChanged;
  final Function(bool) onShowTotalChanged;
  final Function(bool) onThemeChanged;
  final bool hapticsEnabled;
  final Function(bool) onHapticsChanged;

  const SettingsView({
    super.key,
    required this.diceCount,
    required this.showTotal,
    required this.isDarkMode,
    required this.onDiceCountChanged,
    required this.onShowTotalChanged,
    required this.onThemeChanged,
    required this.hapticsEnabled,
    required this.onHapticsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const Text(
          "PREFERENCES",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // The relocated Dice Toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Active Dice", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSegmentedToggle(context),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Settings Toggles
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text("Show Total Sum", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text(
                  "Display the combined value of all dice",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                value: showTotal,
                activeThumbColor: Theme.of(context).colorScheme.primary,
                onChanged: onShowTotalChanged,
              ),
              const Divider(height: 1, color: Colors.white10),
              SwitchListTile(
                title: const Text("Dark Theme", style: TextStyle(fontWeight: FontWeight.bold)),
                value: isDarkMode,
                activeThumbColor: Theme.of(context).colorScheme.primary,
                onChanged: onThemeChanged,
              ),
              const Divider(height: 1, color: Colors.white10),
              SwitchListTile(
                title: const Text("Haptic Feedback", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text(
                  "Physical vibrations during rolls",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                value: hapticsEnabled,
                activeThumbColor: Theme.of(context).colorScheme.primary,
                onChanged: onHapticsChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedToggle(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(color: const Color(0xFF2C363F), borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [1, 2, 3].map((count) {
          final isSelected = diceCount == count;
          return Expanded(
            child: GestureDetector(
              onTap: () => onDiceCountChanged(count),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
