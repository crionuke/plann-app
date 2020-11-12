import 'dart:async';

import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/income/income_month_panel_bloc.dart';
import 'package:plann_app/services/analytics/analytics_month_list.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/tracking/tracking_service_appmetrica.dart';

class IncomeMainBloc {
  final _controller = StreamController<IncomeMainViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TrackingService trackingService;

  IncomeMonthPanelBloc incomeMonthPanelBloc;

  IncomeMainBloc(this.dbService, this.analyticsService, this.trackingService) {
    incomeMonthPanelBloc = IncomeMonthPanelBloc(analyticsService);
  }

  void dispose() {
    _controller.close();
    incomeMonthPanelBloc.dispose();
  }

  Future<void> requestState() async {
    _controller.sink.add(IncomeMainViewState.loading());
    List<IncomeModel> fact = await dbService.getIncomeList();
    List<PlannedIncomeModel> planned = await dbService.getPlannedIncomeList();
    if (!_controller.isClosed) {
      _controller.sink.add(IncomeMainViewState.loaded(
          fact, analyticsService.analytics.monthList, planned));
    }
  }

  void deleteIncome(int id) async {
    await dbService.deleteIncome(id);
    await analyticsService.analyze();
    requestState();
  }

  void deletePlannedIncome(int id) async {
    await dbService.deletePlannedIncome(id);
    await analyticsService.analyze();
    requestState();
  }

  Future<int> instantiateIncome(num value, CurrencyType currency,
      IncomeCategoryType category, String comment) async {
    int id = await dbService.addIncome(IncomeModel(null, value, currency,
        DateTime.now(), category, AppTexts.upFirstLetter(comment)));
    await analyticsService.analyze();
    trackingService.incomeAdded();
    requestState();
    return id;
  }
}

class IncomeMainViewState {
  final bool loaded;
  final List<IncomeModel> incomeList;
  final AnalyticsMonthList monthList;
  final List<PlannedIncomeModel> planned;

  IncomeMainViewState.loading()
      : loaded = false,
        incomeList = null,
        monthList = null,
        planned = null;

  IncomeMainViewState.loaded(this.incomeList, this.monthList, this.planned)
      : loaded = true;
}
