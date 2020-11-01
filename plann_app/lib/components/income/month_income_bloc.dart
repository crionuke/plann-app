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
      _controller.sink
          .add(MonthIncomeViewState.loaded(month.actualIncomePerCategory));
    }
  }

  DateTime getMonthDate() {
    return month.date;
  }
}

class MonthIncomeViewState {
  final bool loaded;
  final Map<IncomeCategoryType, Map<CurrencyType, CurrencyValue>>
      actualIncomePerCategory;

  MonthIncomeViewState.loading()
      : loaded = false,
        actualIncomePerCategory = null;

  MonthIncomeViewState.loaded(this.actualIncomePerCategory) : loaded = true;
}
