import 'dart:async';

import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';

class MonthTagExpenseBloc {
  final _controller = StreamController<MonthTagExpenseViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final CurrencyType currency;
  final AnalyticsMonth month;
  final int tagId;

  MonthTagExpenseBloc(this.dbService, this.analyticsService, this.currency,
      this.month, this.tagId);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(MonthTagExpenseViewState.loading());
    if (!_controller.isClosed) {
      // Filter by currency
      List<AnalyticsItem<ExpenseModel>> list = List();
      month.actualExpenseItemsPerTag[tagId].forEach((item) {
        if (item.currencyValue.currency == currency) {
          list.add(item);
        }
      });
      _controller.sink.add(MonthTagExpenseViewState.loaded(list));
    }
  }

  DateTime getMonthDate() {
    return month.date;
  }

  int getTagId() {
    return tagId;
  }

  String getTagName() {
    return month.analyticsTags.getTagName(tagId);
  }
}

class MonthTagExpenseArguments {
  final CurrencyType currency;
  final AnalyticsMonth month;
  final int tagId;

  MonthTagExpenseArguments(this.currency, this.month, this.tagId);
}

class MonthTagExpenseViewState {
  final bool loaded;
  final List<AnalyticsItem<ExpenseModel>> list;

  MonthTagExpenseViewState.loading()
      : loaded = false,
        list = null;

  MonthTagExpenseViewState.loaded(this.list) : loaded = true;
}
