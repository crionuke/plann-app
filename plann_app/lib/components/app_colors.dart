import 'package:flutter/material.dart';

class AppColors {
  // 6C36FF
  static const Color APP_COLOR_1 = Color.fromRGBO(108, 54, 255, 1);

  // 00A6FF
  static const Color APP_COLOR_2 = Color.fromRGBO(0, 166, 255, 1);
}

class ColorsMap<K> {
  static const List COLORS = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.blueGrey,
    Colors.cyan,
    Colors.lime,
    Colors.indigo,
    Colors.pink,
    Colors.grey,
    Colors.purpleAccent,
    Colors.brown,
    Colors.greenAccent,
  ];

  Map<K, Color> _map;
  int _lastColor = 0;

  ColorsMap() {
    _map = Map();
    _lastColor = 0;
  }

  void assign(K key) {
    _map[key] = COLORS[_lastColor++];
    if (_lastColor >= COLORS.length) {
      _lastColor = 0;
    }
  }

  Color getColor(K key) {
    return _map[key];
  }
}
