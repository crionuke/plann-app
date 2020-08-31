import 'dart:async';

import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/analytics/month_analytics.dart';

class IrregularMonthPanelBloc {
  final _controller = StreamController.broadcast();

  Stream get stream => _controller.stream;

  final AnalyticsService analyticsService;

  MonthAnalytics _monthAnalytics;

  IrregularMonthPanelBloc(this.analyticsService) {
    setCurrentMonth();
  }

  void dispose() {
    _controller.close();
  }

  IrregularMonthPanelViewState get currentState {
    return IrregularMonthPanelViewState(_monthAnalytics);
  }

  void setCurrentMonth() {
    AnalyticsData analytics = analyticsService.analytics;
    setMonthByIndex(analytics.currentMonthOffset);
  }

  void setMonthByIndex(int monthIndex) {
    _monthAnalytics = analyticsService.analytics.monthList[monthIndex];
    if (!_controller.isClosed) {
      _controller.sink.add(currentState);
    }
  }
}

class IrregularMonthPanelViewState {
  final MonthAnalytics monthAnalytics;

  IrregularMonthPanelViewState(this.monthAnalytics);
}
