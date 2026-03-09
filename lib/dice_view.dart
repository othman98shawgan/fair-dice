import 'package:flutter/material.dart';

import 'die_widget.dart';
import 'fair_dice_engine.dart';

class DiceView extends StatelessWidget {
  final List<int> currentRoll;
  final bool isRolling;
  final FairDiceEngine engine;
  final bool showTotal;
  final VoidCallback onRoll;

  const DiceView({
    super.key,
    required this.currentRoll,
    required this.isRolling,
    required this.engine,
    required this.showTotal,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    final int totalSum = currentRoll.fold(0, (sum, val) => sum + val);

    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown, // This prevents the "invisible half" clipping
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: currentRoll.map((value) => DieWidget(value: value)).toList(),
                  ),
                  if (showTotal) ...[
                    const SizedBox(height: 32),
                    AnimatedOpacity(
                      opacity: isRolling ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        'TOTAL: $totalSum',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Padding(
          // Pushed the bottom padding to 110 to clear the hovering dock
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 150.0),
          child: _buildRollButton(context),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'PERMUTATIONS LEFT: ${engine.remaining}/${engine.total}',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRollButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isRolling
              ? Theme.of(context).colorScheme.primary.withAlpha(100)
              : Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: isRolling ? 0 : 8,
        ),
        onPressed: isRolling ? null : onRoll,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.casino, size: 32, color: isRolling ? Colors.grey : Colors.white),
            const SizedBox(width: 12),
            Text(
              isRolling ? 'ROLLING...' : 'ROLL',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isRolling ? Colors.grey : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
