import 'dart:async';

import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';

class IrregularMonthPanelBloc {
  final _controller = StreamController.broadcast();

  Stream get stream => _controller.stream;

  final AnalyticsService analyticsService;

  AnalyticsMonth _month;

  IrregularMonthPanelBloc(this.analyticsService) {
    setCurrentMonth();
  }

  void dispose() {
    _controller.close();
  }

  IrregularMonthPanelViewState get currentState {
    return IrregularMonthPanelViewState(_month);
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

class IrregularMonthPanelViewState {
  final AnalyticsMonth month;

  IrregularMonthPanelViewState(this.month);
}
