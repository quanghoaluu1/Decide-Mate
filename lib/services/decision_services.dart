
import 'dart:math';

class DecisionService {
  static String makeYesNoDecision() {
    final random = Random();
    return random.nextBool() ? 'YES' : 'NO';
  }

  static String makeMultipleChoice(List<String> options) {
    if(options.isEmpty) return '';
    final random = Random();
    return options[random.nextInt(options.length)];
  }

  static int rollDice() {
    final random = Random();
    return random.nextInt(6) + 1;
  }
}