import 'dart:async';

import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';

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
      _controller.sink
          .add(MonthExpenseViewState.loaded(month.actualExpensePerCategory));
    }
  }

  DateTime getMonthDate() {
    return month.date;
  }
}

class MonthExpenseViewState {
  final bool loaded;
  final Map<ExpenseCategoryType, Map<CurrencyType, CurrencyValue>>
      actualExpensePerCategory;

  MonthExpenseViewState.loading()
      : loaded = false,
        actualExpensePerCategory = null;

  MonthExpenseViewState.loaded(this.actualExpensePerCategory) : loaded = true;
}
