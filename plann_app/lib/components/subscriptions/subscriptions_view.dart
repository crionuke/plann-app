import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/services/purchase/purchase_service.dart';

typedef SubscriptionTapCallback = void Function(
    BuildContext context, PurchaseItem item);

typedef RestorePurchasesTapCallback = void Function(BuildContext context);

class SubscriptionsView extends StatelessWidget {
  final List<PurchaseItem> purchaseList;
  final PurchaseItem basePurchaseItem;
  final SubscriptionTapCallback subscriptionTap;
  final RestorePurchasesTapCallback restorePurchasesTap;

  SubscriptionsView(this.purchaseList, this.basePurchaseItem,
      this.subscriptionTap, this.restorePurchasesTap);

  @override
  Widget build(BuildContext context) {
    final List<Widget> tiles = _buildTiles(context);
    final Divider divider1 = Divider(height: 1);

    return ListView.separated(
        itemBuilder: (BuildContext context, int index) => tiles[index],
        separatorBuilder: (BuildContext context, int index) => divider1,
        itemCount: tiles.length);
  }

  List<Widget> _buildTiles(BuildContext context) {
    if (purchaseList.length > 0) {
      List<Widget> tiles = List();
      tiles.add(
        ListTile(
            subtitle: Text(
                FlutterI18n.translate(context, "texts.subscriptions_offer"))),
      );
      tiles.addAll(purchaseList.map((item) {
        String subtitle = item.buildSubTitle(context, basePurchaseItem.price);
        return ListTile(
          onTap: () {
            subscriptionTap(context, item);
          },
          title: Text(item.buildTitle(context)),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: Icon(Icons.navigate_next),
        );
      }).toList());
      tiles.add(ListTile(
        onTap: () {
          restorePurchasesTap(context);
        },
        title: Text(FlutterI18n.translate(context, "texts.restore_purchases")),
        trailing: Icon(Icons.navigate_next),
      ));
      return tiles;
    } else {
      return [
        ListTile(
            title: Text(FlutterI18n.translate(
                context, "texts.subscriptions_not_available")))
      ];
    }
  }
}
