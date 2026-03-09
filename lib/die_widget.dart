import 'package:flutter/material.dart';

class DieWidget extends StatelessWidget {
  final int value;

  const DieWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    // 3x3 Grid mappings for dice dots (true = dot, false = empty)
    final dotPatterns = {
      1: [false, false, false, false, true, false, false, false, false],
      2: [true, false, false, false, false, false, false, false, true],
      3: [true, false, false, false, true, false, false, false, true],
      4: [true, false, true, false, false, false, true, false, true],
      5: [true, false, true, false, true, false, true, false, true],
      6: [true, false, true, true, false, true, true, false, true],
    };

    final pattern = dotPatterns[value] ?? dotPatterns[1]!;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(15)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return pattern[index]
              ? Container(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
