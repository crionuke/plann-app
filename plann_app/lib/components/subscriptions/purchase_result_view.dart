import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/services/purchase/purchase_service.dart';

typedef ButtonTapCallback = void Function(BuildContext context);

class PurchaseResultView extends StatelessWidget {
  final PurchaseResult purchaseResult;
  final ButtonTapCallback buttonTapCallback;

  PurchaseResultView(this.purchaseResult, this.buttonTapCallback);

  @override
  Widget build(BuildContext context) {
    Text text;
    if (purchaseResult.completed) {
      text =
          Text(FlutterI18n.translate(context, "texts.subscription_completed"));
    } else if (purchaseResult.cancelled) {
      text = Text(FlutterI18n.translate(context, "texts.purchase_cancelled"));
    } else if (purchaseResult.failed) {
      text = Text(FlutterI18n.translate(context, "texts.error") +
          ": " +
          purchaseResult.platformException.message);
    } else {
      text = Text("UNKNOWN");
    }

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        text,
        RaisedButton(
          onPressed: () {
            buttonTapCallback(context);
          },
          child: Text(FlutterI18n.translate(context, "texts.continue")),
        )
      ],
    ));
  }
}
