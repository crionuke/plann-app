import 'dart:async';

import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';

class MonthCategoryExpenseBloc {
  final _controller = StreamController<MonthCategoryExpenseViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final CurrencyType currency;
  final AnalyticsMonth month;
  final ExpenseCategoryType category;

  MonthCategoryExpenseBloc(this.dbService, this.analyticsService, this.currency,
      this.month, this.category);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(MonthCategoryExpenseViewState.loading());
    if (!_controller.isClosed) {
      // Filter by currency
      List<AnalyticsItem<ExpenseModel>> list = List();
      month.actualExpenseItemsPerCategory[category].forEach((item) {
        if (item.currencyValue.currency == currency) {
          list.add(item);
        }
      });
      _controller.sink.add(MonthCategoryExpenseViewState.loaded(list));
    }
  }

  DateTime getMonthDate() {
    return month.date;
  }

  ExpenseCategoryType getCategory() {
    return category;
  }
}

class MonthCategoryExpenseArguments {
  final CurrencyType currency;
  final AnalyticsMonth month;
  final ExpenseCategoryType category;

  MonthCategoryExpenseArguments(this.currency, this.month, this.category);
}

class MonthCategoryExpenseViewState {
  final bool loaded;
  final List<AnalyticsItem<ExpenseModel>> list;

  MonthCategoryExpenseViewState.loading()
      : loaded = false,
        list = null;

  MonthCategoryExpenseViewState.loaded(this.list) : loaded = true;
}
