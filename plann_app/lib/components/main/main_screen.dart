import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/main/finances_view.dart';
import 'package:plann_app/components/main/main_bloc.dart';
import 'package:plann_app/components/main/settings_bloc.dart';
import 'package:plann_app/components/main/settings_view.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  static const routeName = '/main';

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.selectedIndex,
        builder: (context, snapshot) {
          var selectedIndex = snapshot.data;
          if (selectedIndex != null) {
            if (selectedIndex == 0) {
              return _buildFinanceView(context, bloc, selectedIndex);
            } else if (selectedIndex == 1) {
              return Provider<SettingsBloc>(
                  create: (context) =>
                      SettingsBloc(bloc.purchaseService, bloc.trackingService),
                  dispose: (context, bloc) => bloc.dispose(),
                  child: _buildProfileView(context, bloc, selectedIndex));
            }
          }

          return ProgressIndicatorWidget();
        });
  }

  Widget _buildFinanceView(
      BuildContext context, MainBloc bloc, int selectedIndex) {
    return Scaffold(
        appBar: AppBar(
            title: Text(FlutterI18n.translate(context, "texts.finances")),
            elevation: 0,
            flexibleSpace: AppViews.buildAppGradientContainer(context)),
        body: FinancesView(),
        bottomNavigationBar:
            _buildBottomNavigationBar(context, bloc, selectedIndex));
  }

  Widget _buildProfileView(
      BuildContext context, MainBloc bloc, int selectedIndex) {
    return Scaffold(
        appBar: AppBar(
            title: Text(FlutterI18n.translate(context, "texts.settings")),
            elevation: 0,
            flexibleSpace: AppViews.buildAppGradientContainer(context)),
        body: SettingsView(),
        bottomNavigationBar:
            _buildBottomNavigationBar(context, bloc, selectedIndex));
  }

  BottomNavigationBar _buildBottomNavigationBar(
      BuildContext context, MainBloc bloc, int selectedIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      items: [
        BottomNavigationBarItem(
          icon: AppViews.buildAppGradientOverlay(
              Icon(Icons.account_balance_wallet)),
          title: AppViews.buildAppGradientOverlay(
              Text(FlutterI18n.translate(context, "texts.finances"))),
        ),
        BottomNavigationBarItem(
          icon: AppViews.buildAppGradientOverlay(Icon(Icons.settings)),
          title: AppViews.buildAppGradientOverlay(
              Text(FlutterI18n.translate(context, "texts.settings"))),
        ),
      ],
      currentIndex: selectedIndex,
      onTap: (int index) {
        bloc.selectBarItem(index);
      },
    );
  }
}
