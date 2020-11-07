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
  final AnalyticsMonth month;

  MonthExpenseBloc(this.dbService, this.analyticsService, this.month);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(MonthExpenseViewState.loading());
    if (!_controller.isClosed) {
      // Sort all categories
      Map<ExpenseCategoryType, double> totalPerCategory =
          month.actualExpenseTotalPerCategory;
      List<ExpenseCategoryType> sortedCategories = List();
      sortedCategories.addAll(totalPerCategory.keys);
      sortedCategories.sort((c1, c2) {
        return totalPerCategory[c2].compareTo(totalPerCategory[c1]);
      });

      _controller.sink.add(MonthExpenseViewState.loaded(
          sortedCategories,
          month.actualExpensePerCategory,
          month.actualExpensePercentsPerCategory));
    }
  }

  AnalyticsMonth getMonth() {
    return month;
  }

  DateTime getMonthDate() {
    return month.date;
  }
}

class MonthExpenseViewState {
  final bool loaded;
  final List<ExpenseCategoryType> sortedCategories;
  final Map<ExpenseCategoryType, Map<CurrencyType, CurrencyValue>>
      actualExpensePerCategory;
  final Map<ExpenseCategoryType, double> actualExpensePercentsPerCategory;

  MonthExpenseViewState.loading()
      : loaded = false,
        sortedCategories = null,
        actualExpensePerCategory = null,
        actualExpensePercentsPerCategory = null;

  MonthExpenseViewState.loaded(this.sortedCategories,
      this.actualExpensePerCategory, this.actualExpensePercentsPerCategory)
      : loaded = true;
}
