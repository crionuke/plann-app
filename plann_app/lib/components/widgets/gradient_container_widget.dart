import 'package:flutter/material.dart';
import 'package:plann_app/components/app_colors.dart';

class GradientContainerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
