import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plann_app/components/main/main_screen.dart';
import 'package:plann_app/services/purchase/purchase_service.dart';

class BlockBloc {
  final _controller = StreamController<BlockScreenState>();

  Stream get stream => _controller.stream;

  final PurchaseService purchaseService;
  final GlobalKey<NavigatorState> navigatorKey;

  BlockBloc(this.purchaseService, this.navigatorKey);

  void dispose() {
    _controller.close();
  }

  void requestState() async {
    _controller.sink.add(BlockScreenState.loading());
    _fireState();
  }

  Future<void> purchase(BuildContext context, PurchaseItem purchaseItem) async {
    _controller.sink.add(BlockScreenState.loading());

    PurchaseResult purchaseResult =
        await purchaseService.makePurchase(purchaseItem);
    print("[BlockBloc] $purchaseResult");
    _firePurchaseResult(purchaseResult);
  }

  Future<void> restorePurchases() async {
    _controller.sink.add(BlockScreenState.loading());
    await purchaseService.restorePurchases();
    _fireState();
  }

  void navigate() {
    navigatorKey.currentState.pushReplacementNamed(MainScreen.routeName);
  }

  void _firePurchaseResult(PurchaseResult purchaseResult) async {
    print("[BlockBloc] firePurchaseResult");
    if (!_controller.isClosed) {
      _controller.sink.add(BlockScreenState.purchased(purchaseResult));
    }
  }

  void _fireState() async {
    print("[BlockBloc] fireState");
    if (!_controller.isClosed) {
      try {
        _controller.sink.add(BlockScreenState.loaded(
            await purchaseService.basePurchaseItem,
            await purchaseService.purchaseList));
      } on PlatformException catch (e) {
        print("[BlockBloc] " + e.toString());
        _controller.sink.add(BlockScreenState.failed());
      }
    }
  }
}

class BlockScreenState {
  final bool loaded;
  final bool purchased;
  final bool failed;
  final PurchaseResult purchaseResult;
  final PurchaseItem basePurchaseItem;
  final List<PurchaseItem> purchaseList;

  BlockScreenState.loading()
      : loaded = false,
        purchased = false,
        failed = false,
        purchaseResult = null,
        basePurchaseItem = null,
        purchaseList = null;

  BlockScreenState.purchased(this.purchaseResult)
      : loaded = false,
        purchased = true,
        failed = false,
        basePurchaseItem = null,
        purchaseList = null;

  BlockScreenState.loaded(this.basePurchaseItem, this.purchaseList)
      : loaded = true,
        purchased = false,
        failed = false,
        purchaseResult = null;

  BlockScreenState.failed()
      : loaded = false,
        purchased = false,
        failed = true,
        purchaseResult = null,
        basePurchaseItem = null,
        purchaseList = null;
}
