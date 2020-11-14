import 'package:flutter/material.dart';
import 'package:plann_app/components/app_colors.dart';

class AppViews {

  static Widget buildAppGradientOverlay(Widget child) {
    return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.APP_COLOR_1, AppColors.APP_COLOR_2],
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
                tileMode: TileMode.clamp)
            .createShader(bounds),
        child: child);
  }

  static Widget buildRoundedBox(Color color) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 32,
          height: 32,
          color: color,
        ));
  }
}
