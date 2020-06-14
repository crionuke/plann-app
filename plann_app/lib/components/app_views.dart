import 'package:flutter/material.dart';
import 'package:plann_app/components/app_colors.dart';

class AppViews {
  static Widget buildProgressIndicator(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: CircularProgressIndicator(),
      ))
    ]);
  }

  static Widget buildAppGradientContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppColors.APP_COLOR_1, AppColors.APP_COLOR_2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            tileMode: TileMode.clamp),
      ),
    );
  }

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
}
