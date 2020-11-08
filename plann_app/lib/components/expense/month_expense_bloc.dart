import 'dart:async';

import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';

class MonthExpenseBloc {
  final _controller = StreamController<MonthExpenseViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final CurrencyType currency;
  final AnalyticsMonth month;

  MonthExpenseBloc(
      this.dbService, this.analyticsService, this.currency, this.month);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(MonthExpenseViewState.loading());
    if (!_controller.isClosed) {
      // Filter by currency
      Map<ExpenseCategoryType, CurrencyValue> values = Map();
      month.actualExpensePerCategory.forEach((category, currencyMap) {
        if (currencyMap.containsKey(currency)) {
          values[category] = currencyMap[currency];
        }
      });
      // Sort categories by values
      List<ExpenseCategoryType> sortedCategories = List();
      sortedCategories.addAll(values.keys);
      sortedCategories.sort((c1, c2) {
        return values[c2].value.compareTo(values[c1].value);
      });
      // Calc percents
      Map<ExpenseCategoryType, double> percents = Map();
      double total = 0;
      values.values.forEach((currencyValue) => total += currencyValue.value);
      values.forEach((category, currencyValue) {
        percents[category] = currencyValue.value / total * 100;
      });

      _controller.sink.add(
          MonthExpenseViewState.loaded(sortedCategories, values, percents));
    }
  }
}

class MonthExpenseArguments {
  final CurrencyType currency;
  final AnalyticsMonth month;

  MonthExpenseArguments(this.currency, this.month);
}

class MonthExpenseViewState {
  final bool loaded;
  final List<ExpenseCategoryType> sortedCategories;
  final Map<ExpenseCategoryType, CurrencyValue> values;
  final Map<ExpenseCategoryType, double> percents;

  MonthExpenseViewState.loading()
      : loaded = false,
        sortedCategories = null,
        values = null,
        percents = null;

  MonthExpenseViewState.loaded(
      this.sortedCategories, this.values, this.percents)
      : loaded = true;
}
