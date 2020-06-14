import 'dart:async';

import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';

class MonthCaruselBloc {
  final AnalyticsService analyticsService;
  final DbService dbService;

  final _controller = StreamController<MonthCaruselViewState>();

  Stream get stream => _controller.stream;

  MonthCaruselBloc(this.dbService, this.analyticsService);

  @override
  void dispose() {
    print("[MonthCaruselBloc] dispose");
    _controller.close();
  }

  MonthCaruselViewState get currentState {
    return MonthCaruselViewState(analyticsService.analytics);
  }

  void requestState() {
    print("[MonthCaruselBloc] requestState");
    _controller.sink.add(currentState);
  }
}

class MonthCaruselViewState {
  final AnalyticsData analytics;

  MonthCaruselViewState(this.analytics);
}
