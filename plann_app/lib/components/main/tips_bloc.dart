import 'dart:math';

class TipsBloc {
  static const int TIPS_COUNT = 24;

  List<String> tips;
  String textKey;

  TipsBloc() {
    tips = List();
    for (int i = 1; i <= TIPS_COUNT; i++) {
      tips.add("tips.tip_" + (100 + i).toString());
    }
    // Simple shuffle
    Random random = Random();
    for (int i = tips.length - 1; i > 0; i--) {
      int k = random.nextInt(i + 1);
      String temp = tips[k];
      tips[k] = tips[i];
      tips[i] = temp;
    }
  }

  String getKey(int index) {
    return tips[index % TIPS_COUNT];
  }
}
