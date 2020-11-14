import 'package:flutter/material.dart';

class ColorRoundedBoxWidget extends StatelessWidget {
  final Color color;

  ColorRoundedBoxWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 32,
          height: 32,
          color: color,
        ));
  }
}
