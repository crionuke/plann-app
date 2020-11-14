import 'package:flutter/cupertino.dart';
import 'package:plann_app/components/app_colors.dart';

class GradientOverlayWidget extends StatelessWidget {
  final Widget child;

  GradientOverlayWidget(this.child);

  @override
  Widget build(BuildContext context) {
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
