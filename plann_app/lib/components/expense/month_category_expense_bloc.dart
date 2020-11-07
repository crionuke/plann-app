import 'dart:async';

import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';

class MonthCategoryExpenseBloc {
  final _controller = StreamController<MonthCategoryExpenseViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final AnalyticsMonth month;
  final ExpenseCategoryType category;

  MonthCategoryExpenseBloc(
      this.dbService, this.analyticsService, this.month, this.category);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(MonthCategoryExpenseViewState.loading());
    if (!_controller.isClosed) {
      _controller.sink.add(MonthCategoryExpenseViewState.loaded(
          month.actualExpenseItemsPerCategory[category]));
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
  final AnalyticsMonth month;
  final ExpenseCategoryType category;

  MonthCategoryExpenseArguments(this.month, this.category);
}

class MonthCategoryExpenseViewState {
  final bool loaded;
  final List<AnalyticsItem<ExpenseModel>> list;

  MonthCategoryExpenseViewState.loading()
      : loaded = false,
        list = null;

  MonthCategoryExpenseViewState.loaded(this.list) : loaded = true;
}
