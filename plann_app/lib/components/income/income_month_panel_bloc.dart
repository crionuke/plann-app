import 'dart:async';

import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';

class IncomeMonthPanelBloc {
  final _controller = StreamController.broadcast();

  Stream get stream => _controller.stream;

  final AnalyticsService analyticsService;

  AnalyticsMonth _month;

  IncomeMonthPanelBloc(this.analyticsService) {
    setCurrentMonth();
  }

  void dispose() {
    _controller.close();
  }

  IncomeMonthPanelViewState get currentState {
    return IncomeMonthPanelViewState(_month);
  }

  void setCurrentMonth() {
    AnalyticsData analytics = analyticsService.analytics;
    setMonthByIndex(analytics.monthList.currentMonthOffset);
  }

  void setMonthByIndex(int monthIndex) {
    _month = analyticsService.analytics.monthList.findMonthByIndex(monthIndex);
    if (!_controller.isClosed) {
      _controller.sink.add(currentState);
    }
  }
}

class IncomeMonthPanelViewState {
  final AnalyticsMonth month;

  IncomeMonthPanelViewState(this.month);
}
