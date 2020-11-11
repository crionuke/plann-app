import 'dart:async';
import 'dart:math';

import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';

class TipsBloc {

  static const int TIPS_COUNT = 24;

  int offset;
  List<String> tips;
  String textKey;

  TipsBloc() {
    tips = List();
    for (int i = 1; i <= TIPS_COUNT; i++) {
      tips.add("tips.tip_" + (100 + i).toString());
    }
    // Simple shuffle
    Random random = Random();
    for (int i = tips.length - 1; i > 0 ; i--) {
      int k = random.nextInt(i + 1);
      String temp = tips[k];
      tips[k] = tips[i];
      tips[i] = temp;
    }
    offset = random.nextInt(TIPS_COUNT);
  }

  String getKey(int index) {
    return tips[(offset + index) % TIPS_COUNT];
  }
}