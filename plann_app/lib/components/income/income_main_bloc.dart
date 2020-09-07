import 'dart:async';

import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';

class IncomeMainBloc {
  final _controller = StreamController<IncomeMainViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  IncomeMainBloc(this.dbService, this.analyticsService);

  void dispose() {
    _controller.close();
  }

  void requestState() async {
    _controller.sink.add(IncomeMainViewState.loading());
    List<IncomeModel> fact = await dbService.getIncomeList();
    List<PlannedIncomeModel> planned = await dbService.getPlannedIncomeList();
    if (!_controller.isClosed) {
      CurrencyType defaultCurrency = CurrencyType.rubles;

      Map<int, double> perMonthIncomes = analyticsService
          .analytics.perMonthIncomes
          .map((monthIndex, currencyMap) => MapEntry<int, double>(
              monthIndex,
              currencyMap.containsKey(defaultCurrency)
                  ? currencyMap[defaultCurrency]
                  : 0));

      _controller.sink
          .add(IncomeMainViewState.loaded(fact, perMonthIncomes, planned));
    }
  }
}

class IncomeMainViewState {
  final bool loaded;
  final List<IncomeModel> fact;
  final Map<int, double> perMonthIncomes;
  final List<PlannedIncomeModel> planned;

  IncomeMainViewState.loading()
      : loaded = false,
        fact = null,
        perMonthIncomes = null,
        planned = null;

  IncomeMainViewState.loaded(this.fact, this.perMonthIncomes, this.planned)
      : loaded = true;
}
