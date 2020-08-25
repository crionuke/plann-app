import 'dart:async';

import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';

class IrregularMainBloc {
  final _controller = StreamController<IrregularMainViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  int _selectedMonth = 0;

  IrregularMainBloc(this.dbService, this.analyticsService);

  @override
  void dispose() {
    _controller.close();
  }

  void requestState() async {
    _controller.sink.add(IrregularMainViewState.loading());
    List<IrregularModel> fact = await dbService.getIrregularList();
    List<PlannedIrregularModel> planned =
        await dbService.getPlannedIrregularList();
    if (!_controller.isClosed) {
      _controller.sink.add(IrregularMainViewState.loaded(
          fact, planned, analyticsService.analytics, _selectedMonth));
    }
  }

  void monthSelected(int monthIndex) {
    _selectedMonth = monthIndex;
    requestState();
  }
}

class IrregularMainViewState {
  final bool loaded;
  final List<IrregularModel> fact;
  final List<PlannedIrregularModel> planned;
  final AnalyticsData analytics;
  final int selectedMonth;

  IrregularMainViewState.loading()
      : loaded = false,
        fact = null,
        planned = null,
        analytics = null,
        selectedMonth = null;

  IrregularMainViewState.loaded(
      this.fact, this.planned, this.analytics, this.selectedMonth)
      : loaded = true;
}
