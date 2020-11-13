import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/main/about_app_bloc.dart';
import 'package:plann_app/components/main/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AboutAppScreen extends StatelessWidget {
  static const routeName = '/aboutApp';

  static const int MAX_PAGE = 3;

  final bool startup;

  AboutAppScreen(this.startup);

  @override
  Widget build(BuildContext context) {
    final AboutAppBloc bloc = Provider.of<AboutAppBloc>(context);
    final pageController = PageController(viewportFraction: 0.95);

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xff00),
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: <Widget>[
              AppViews.buildAppGradientOverlay(IconButton(
                color: Colors.white,
                icon: Icon(Icons.close),
                onPressed: () {
                  bloc.markAsViewed();
                  if (startup) {
                    Navigator.of(context)
                        .pushReplacementNamed(MainScreen.routeName);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              )),
            ]),
        body: Stack(
          children: [
            CustomScrollView(slivers: <Widget>[
              SliverFillRemaining(
                  child: PageView(
                controller: pageController,
                children: [
                  _buildPage(context, 1),
                  _buildPage(context, 2),
                  _buildPage(context, 3),
                ],
              ))
            ]),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(20),
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: MAX_PAGE,
                  effect: WormEffect(activeDotColor: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildPage(BuildContext context, int pageIndex) {
    return Container(
        padding: EdgeInsets.all(20),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppViews.buildAppGradientOverlay(Text(
              FlutterI18n.translate(
                  context, "about_app.page" + pageIndex.toString()),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ))
          ],
        )));
  }
}
