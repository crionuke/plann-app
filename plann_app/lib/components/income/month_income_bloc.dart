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
  final AnalyticsMonth month;

  MonthIncomeBloc(this.dbService, this.analyticsService, this.month);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(MonthIncomeViewState.loading());
    if (!_controller.isClosed) {
      // Sort all categories
      Map<IncomeCategoryType, double> totalPerCategory =
          month.actualIncomePercentsPerCategory;
      List<IncomeCategoryType> sortedCategories = List();
      sortedCategories.addAll(totalPerCategory.keys);
      sortedCategories.sort((c1, c2) {
        return totalPerCategory[c2].compareTo(totalPerCategory[c1]);
      });

      _controller.sink.add(MonthIncomeViewState.loaded(
          sortedCategories,
          month.actualIncomePerCategory,
          month.actualIncomePercentsPerCategory));
    }
  }

  AnalyticsMonth getMonth() {
    return month;
  }

  DateTime getMonthDate() {
    return month.date;
  }
}

class MonthIncomeViewState {
  final bool loaded;
  final List<IncomeCategoryType> sortedCategories;
  final Map<IncomeCategoryType, Map<CurrencyType, CurrencyValue>>
      actualIncomePerCategory;
  final Map<IncomeCategoryType, double> actualIncomePercentsPerCategory;

  MonthIncomeViewState.loading()
      : loaded = false,
        sortedCategories = null,
        actualIncomePerCategory = null,
        actualIncomePercentsPerCategory = null;

  MonthIncomeViewState.loaded(this.sortedCategories,
      this.actualIncomePerCategory, this.actualIncomePercentsPerCategory)
      : loaded = true;
}
