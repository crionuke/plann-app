import 'dart:async';

import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';

class MonthIncomeBloc {
  final _controller = StreamController<MonthIncomeViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final CurrencyType currency;
  final AnalyticsMonth month;

  MonthIncomeBloc(
      this.dbService, this.analyticsService, this.currency, this.month);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(MonthIncomeViewState.loading());
    if (!_controller.isClosed) {
      // Filter by currency
      Map<IncomeCategoryType, CurrencyValue> values = Map();
      month.actualIncomePerCategory.forEach((category, currencyMap) {
        if (currencyMap.containsKey(currency)) {
          values[category] = currencyMap[currency];
        }
      });
      // Sort categories by values
      List<IncomeCategoryType> sortedCategories = List();
      sortedCategories.addAll(values.keys);
      sortedCategories.sort((c1, c2) {
        return values[c2].value.compareTo(values[c1].value);
      });
      // Calc percents
      Map<IncomeCategoryType, double> percents = Map();
      double total = 0;
      values.values.forEach((currencyValue) => total += currencyValue.value);
      values.forEach((category, currencyValue) {
        percents[category] = currencyValue.value / total * 100;
      });

      _controller.sink
          .add(MonthIncomeViewState.loaded(sortedCategories, values, percents));
    }
  }
}

class MonthIncomeArguments {
  final CurrencyType currency;
  final AnalyticsMonth month;

  MonthIncomeArguments(this.currency, this.month);
}

class MonthIncomeViewState {
  final bool loaded;
  final List<IncomeCategoryType> sortedCategories;
  final Map<IncomeCategoryType, CurrencyValue> values;
  final Map<IncomeCategoryType, double> percents;

  MonthIncomeViewState.loading()
      : loaded = false,
        sortedCategories = null,
        values = null,
        percents = null;

  MonthIncomeViewState.loaded(this.sortedCategories, this.values, this.percents)
      : loaded = true;
}
