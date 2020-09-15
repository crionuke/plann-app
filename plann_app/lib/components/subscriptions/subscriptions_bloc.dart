import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plann_app/services/purchase/purchase_service.dart';

class SubscriptionsBloc {
  final _controller = StreamController<SubscriptionsViewState>();

  Stream get stream => _controller.stream;

  PurchaseService purchaseService;

  SubscriptionsBloc(this.purchaseService);

  void dispose() {
    _controller.close();
  }

  void requestState() async {
    _controller.sink.add(SubscriptionsViewState.loading());
    _fireState();
  }

  void purchase(BuildContext context, PurchaseItem purchaseItem) async {
    _controller.sink.add(SubscriptionsViewState.loading());
    PurchaseResult purchaseResult =
        await purchaseService.makePurchase(purchaseItem);
    print("[SubscriptionsBloc] $purchaseResult");
    _firePurchaseResult(purchaseResult);
  }

  Future<void> restorePurchases() async {
    _controller.sink.add(SubscriptionsViewState.loading());
    await purchaseService.restorePurchases();
    _fireState();
  }

  void _firePurchaseResult(PurchaseResult purchaseResult) async {
    print("[SubscriptionsBloc] firePurchaseResult");
    if (!_controller.isClosed) {
      _controller.sink.add(SubscriptionsViewState.purchased(purchaseResult));
    }
  }

  void _fireState() async {
    print("[SubscriptionsBloc] fireState");
    if (!_controller.isClosed) {
      try {
      _controller.sink.add(SubscriptionsViewState.loaded(
          await purchaseService.basePurchaseItem,
          await purchaseService.getAccessEntitlement(),
          await purchaseService.purchaseList));
      } on PlatformException catch (e) {
        print("[SubscriptionsBloc] " + e.toString());
        _controller.sink.add(SubscriptionsViewState.failed());
      }
    }
  }
}

class SubscriptionsViewState {
  final bool loaded;
  final bool purchased;
  final bool failed;
  final PurchaseResult purchaseResult;
  final PurchaseItem basePurchaseItem;
  final AccessEntitlement accessEntitlement;
  final List<PurchaseItem> purchaseList;

  SubscriptionsViewState.loading()
      : loaded = false,
        purchased = false,
        failed = false,
        purchaseResult = null,
        basePurchaseItem = null,
        accessEntitlement = null,
        purchaseList = null;

  SubscriptionsViewState.purchased(this.purchaseResult)
      : loaded = false,
        purchased = true,
        failed = false,
        basePurchaseItem = null,
        accessEntitlement = null,
        purchaseList = null;

  SubscriptionsViewState.loaded(
      this.basePurchaseItem, this.accessEntitlement, this.purchaseList)
      : loaded = true,
        purchased = false,
        failed = false,
        purchaseResult = null;

  SubscriptionsViewState.failed()
      : loaded = false,
        purchased = false,
        failed = true,
        basePurchaseItem = null,
        purchaseResult = null,
        accessEntitlement = null,
        purchaseList = null;
}
