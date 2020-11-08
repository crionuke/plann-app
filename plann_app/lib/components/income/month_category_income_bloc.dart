import 'dart:async';

import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';

class MonthCategoryIncomeBloc {
  final _controller = StreamController<MonthCategoryIncomeViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final CurrencyType currency;
  final AnalyticsMonth month;
  final IncomeCategoryType category;

  MonthCategoryIncomeBloc(this.dbService, this.analyticsService, this.currency,
      this.month, this.category);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(MonthCategoryIncomeViewState.loading());
    if (!_controller.isClosed) {
      // Filter by currency
      List<AnalyticsItem<IncomeModel>> list = List();
      month.actualIncomeItemsPerCategory[category].forEach((item) {
        if (item.currencyValue.currency == currency) {
          list.add(item);
        }
      });
      _controller.sink.add(MonthCategoryIncomeViewState.loaded(list));
    }
  }

  DateTime getMonthDate() {
    return month.date;
  }

  IncomeCategoryType getCategory() {
    return category;
  }
}

class MonthCategoryIncomeArguments {
  final CurrencyType currency;
  final AnalyticsMonth month;
  final IncomeCategoryType category;

  MonthCategoryIncomeArguments(this.currency, this.month, this.category);
}

class MonthCategoryIncomeViewState {
  final bool loaded;
  final List<AnalyticsItem<IncomeModel>> list;

  MonthCategoryIncomeViewState.loading()
      : loaded = false,
        list = null;

  MonthCategoryIncomeViewState.loaded(this.list) : loaded = true;
}
