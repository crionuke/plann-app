import 'dart:async';

import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';

class MonthCaruselBloc {
  final AnalyticsService analyticsService;
  final DbService dbService;

  final _controller = StreamController<MonthCaruselViewState>();

  Stream get stream => _controller.stream;

  CurrencyType currencyType;

  MonthCaruselBloc(this.dbService, this.analyticsService) {
    currencyType = CurrencyType.rubles;
  }

  @override
  void dispose() {
    print("[MonthCaruselBloc] dispose");
    _controller.close();
  }

  MonthCaruselViewState get currentState {
    return MonthCaruselViewState(analyticsService.analytics, currencyType);
  }

  void requestState() {
    print("[MonthCaruselBloc] requestState");
    _controller.sink.add(currentState);
  }

  void switchToRubles() {
    currencyType = CurrencyType.rubles;
    requestState();
  }

  void switchToDollars() {
    currencyType = CurrencyType.dollars;
    requestState();
  }

  void switchToEuro() {
    currencyType = CurrencyType.euro;
    requestState();
  }
}

class MonthCaruselViewState {
  final AnalyticsData analytics;
  final CurrencyType currencyType;

  MonthCaruselViewState(this.analytics, this.currencyType);
}
