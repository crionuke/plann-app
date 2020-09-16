import 'dart:async';

import 'package:plann_app/components/irregular/irregular_month_panel_bloc.dart';
import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/analytics/month_analytics.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';

class IrregularMainBloc {
  final _controller = StreamController<IrregularMainViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  IrregularMonthPanelBloc monthPanelBloc;

  IrregularMainBloc(this.dbService, this.analyticsService) {
    monthPanelBloc = IrregularMonthPanelBloc(analyticsService);
  }

  void dispose() {
    _controller.close();
    monthPanelBloc.dispose();
  }

  void requestState() async {
    _controller.sink.add(IrregularMainViewState.loading());
    List<IrregularModel> fact = await dbService.getIrregularList();
    List<PlannedIrregularModel> planned =
        await dbService.getPlannedIrregularList();
    if (!_controller.isClosed) {
      monthPanelBloc.setCurrentMonth();
      _controller.sink.add(IrregularMainViewState.loaded(
          fact, planned, analyticsService.analytics));
    }
  }

  void deleteIrregular(int id) async {
    await dbService.deleteIrregular(id);
    await analyticsService.analyze();
    requestState();
  }

  void deletePlannedIrregular(int id) async {
    await dbService.deletePlannedIrregular(id);
    await analyticsService.analyze();
    requestState();
  }
}

class IrregularMainViewState {
  final bool loaded;
  final List<IrregularModel> fact;
  final List<PlannedIrregularModel> planned;
  final AnalyticsData analytics;

  IrregularMainViewState.loading()
      : loaded = false,
        fact = null,
        planned = null,
        analytics = null;

  IrregularMainViewState.loaded(this.fact, this.planned, this.analytics)
      : loaded = true;
}
