import 'dart:async';

import 'package:plann_app/services/purchase/purchase_service.dart';

class MainBloc {
  final _controller = StreamController();

  Stream get stream => _controller.stream;

  final PurchaseService purchaseService;

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  MainBloc(this.purchaseService);

  void selectBarItem(int index) {
    _selectedIndex = index;
    _controller.sink.add(index);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
