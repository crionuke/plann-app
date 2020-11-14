import 'package:flutter/material.dart';
import 'package:plann_app/components/widgets/gradient_overlay_widget.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
//        AppViews.buildAppGradientContainer(context),
        _buildIcon(context),
        _buildText(),
      ],
    ));
  }

  Widget _buildIcon(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.2;
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image(
            width: size,
            height: size,
            image: AssetImage('res/images/icon_inverse.png')),
      ],
    ));
  }

  Widget _buildText() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            padding: EdgeInsets.all(20),
            child: GradientOverlayWidget(Text(
              "PLANNing App",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ))));
  }
}
