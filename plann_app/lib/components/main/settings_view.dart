import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/main/settings_bloc.dart';
import 'package:plann_app/components/subscriptions/subscriptions_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SettingsBloc bloc = Provider.of<SettingsBloc>(context);
    return StreamBuilder<SettingsViewState>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            bloc.requestState();
          } else {
            var state = snapshot.data;
            if (state.loaded) {
              return _buildSettings(context, bloc, state);
            }
          }

          return AppViews.buildProgressIndicator(context);
        });
  }

  Widget _buildSettings(
      BuildContext context, SettingsBloc bloc, SettingsViewState state) {
    final Divider divider1 = Divider(height: 1);

    final List<Widget> children = [];
    children.add(_buildSubscriptionsTile(context, bloc, state));
    if (state.blockingDate != null) {
      children.add(divider1);
      children.add(_buildBlockingDate(context, state));
    }

    children.add(divider1);
    children.add(_buildTermsAndConditions(context, bloc));
    children.add(divider1);
    children.add(_buildPrivacyPolicy(context, bloc));

//    children.add(divider1);
//    children.add(ListTile(onTap: () async {
//      bool result = await bloc.purchaseService.restorePurchases();
//      print(result);
//    },title: Text("Restore")));

    children.add(divider1);
    children.add(_buildVerstionTile(context, state));

    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(child: Column(children: children))
    ]);
  }

  Widget _buildSubscriptionsTile(
      BuildContext context, SettingsBloc bloc, SettingsViewState state) {
    return ListTile(
      onTap: () async {
        await Navigator.pushNamed(context, SubscriptionsScreen.routeName);
        bloc.requestState();
      },
      title: Text(FlutterI18n.translate(context, "texts.subscriptions")),
      trailing: Icon(Icons.navigate_next),
    );
  }

  Widget _buildBlockingDate(BuildContext context, SettingsViewState state) {
    return ListTile(
        title:
            Text(FlutterI18n.translate(context, "texts.blocking_date") + ":"),
        subtitle: Text(AppTexts.formatDate(context, state.blockingDate)));
  }

  Widget _buildTermsAndConditions(BuildContext context, SettingsBloc bloc) {
    return ListTile(
      onTap: () {
        bloc.openTermsAndConditions();
      },
      title: Text(FlutterI18n.translate(context, "texts.terms_and_conditions")),
      trailing: Icon(Icons.navigate_next),
    );
  }

  Widget _buildPrivacyPolicy(BuildContext context, SettingsBloc bloc) {
    return ListTile(
      onTap: () {
        bloc.openPrivacyPolicy();
      },
      title: Text(FlutterI18n.translate(context, "texts.privacy_policy")),
      trailing: Icon(Icons.navigate_next),
    );
  }

  Widget _buildVerstionTile(BuildContext context, SettingsViewState state) {
    return ListTile(
      title: Text(FlutterI18n.translate(context, "texts.version") + ":"),
      subtitle: Text("${state.version}-${state.buildNumber}"),
    );
  }
}
