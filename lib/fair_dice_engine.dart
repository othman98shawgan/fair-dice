import 'dart:math';

class FairDiceEngine {
  final Random _secureRandom = Random.secure();
  List<List<int>> _bag = [];
  int _totalPermutations = 0;
  int _currentDiceCount = 2;
  // Maps the Sum of the roll -> How many times it has been rolled
  Map<int, int> sessionFrequencies = {};

  // Getters for the UI to display the "Fairness" indicator
  int get remaining => _bag.length;
  int get total => _totalPermutations;

  FairDiceEngine(int initialDiceCount) {
    reset(initialDiceCount);
  }

  /// Forces a complete wipe and regeneration of the bag.
  /// Call this when the user changes the number of dice.
  void reset(int diceCount) {
    _currentDiceCount = diceCount;
    sessionFrequencies.clear(); // WIPE THE LEDGER
    _generateAndShuffle();
  }

  void _generateAndShuffle() {
    _bag = _generateCombinations(_currentDiceCount);
    _totalPermutations = _bag.length;
    _bag.shuffle(_secureRandom);
  }

  /// Recursively generates all permutations for N dice.
  /// 1 die = 6 outcomes. 2 dice = 36. 3 dice = 216.
  List<List<int>> _generateCombinations(int count) {
    if (count == 0) return [[]];

    final subPermutations = _generateCombinations(count - 1);
    final List<List<int>> result = [];

    for (final perm in subPermutations) {
      for (int i = 1; i <= 6; i++) {
        result.add([...perm, i]);
      }
    }
    return result;
  }

  /// Pops the next roll from the bag. Auto-refills if empty.
  List<int> roll() {
    if (_bag.isEmpty) {
      _generateAndShuffle();
    }

    final result = _bag.removeLast();

    // Calculate the sum of the current roll
    final sum = result.fold(0, (a, b) => a + b);

    // Log it in the ledger (increment by 1, or set to 1 if it doesn't exist)
    sessionFrequencies[sum] = (sessionFrequencies[sum] ?? 0) + 1;

    return result;
  }
}
