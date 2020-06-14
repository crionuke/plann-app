import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/services/purchase/purchase_service.dart';

class AccessEntitlementView extends StatelessWidget {
  final AccessEntitlement accessEntitlement;

  AccessEntitlementView(this.accessEntitlement);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
        slivers: <Widget>[SliverFillRemaining(child: _buildTiles(context))]);
  }

  Widget _buildTiles(BuildContext context) {
    return Column(children: <Widget>[
      ListTile(
        title: Text(accessEntitlement.buildTitle(context)),
        subtitle: Text(accessEntitlement.buildSubTitle(context)),
      ),
      ListTile(
        onTap: () {
        },
        subtitle: Text(FlutterI18n.translate(
            context, "texts.subscription_cancellation_instruction")),
//        trailing: Icon(Icons.navigate_next),
      ),
    ]);
  }
}
