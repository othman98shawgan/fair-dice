import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class StatsView extends StatelessWidget {
  final Map<int, int> frequencies;
  final int diceCount;

  const StatsView({super.key, required this.frequencies, required this.diceCount});

  @override
  Widget build(BuildContext context) {
    // 1. Calculate the dynamic ranges
    final int minOutcome = diceCount; // e.g., 2 dice = minimum roll of 2
    final int maxOutcome = diceCount * 6; // e.g., 2 dice = maximum roll of 12

    // Find the highest frequency to scale the Y-axis gracefully.
    // Default to 5 if empty so the chart doesn't collapse.
    final int maxY = frequencies.isEmpty ? 5 : frequencies.values.reduce(max);
    // Add 20% padding to the top of the chart so the highest bar doesn't touch the ceiling
    final double upperLimit = (maxY * 1.2).ceilToDouble();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            "ROLL DISTRIBUTION",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            "Total Rolls: ${frequencies.values.fold(0, (sum, val) => sum + val)}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 32),

          // 2. The Chart Canvas
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 32, 24, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withAlpha(15)),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: upperLimit,
                  barTouchData: BarTouchData(enabled: false), // Disable touch tooltips for a cleaner MVP
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32, // Space for the numbers
                        getTitlesWidget: (value, meta) {
                          // Only show whole numbers on the Y-axis
                          if (value % 1 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withAlpha(10), strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false), // Kills the ugly default border
                  // 3. Generate the Bars
                  barGroups: List.generate(maxOutcome - minOutcome + 1, (index) {
                    final outcome = minOutcome + index;
                    final frequency = frequencies[outcome] ?? 0;

                    return BarChartGroupData(
                      x: outcome,
                      barRods: [
                        BarChartRodData(
                          toY: frequency.toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                          width: 16, // Thickness of the bars
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: upperLimit,
                            color: Colors.black.withAlpha(20), // Subtle track behind the bar
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 140), // Clears the floating dock
        ],
      ),
    );
  }
}
