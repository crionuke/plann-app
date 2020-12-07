import 'dart:async';

import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';

class MonthTagIncomeBloc {
  final _controller = StreamController<MonthTagIncomeViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final CurrencyType currency;
  final AnalyticsMonth month;
  final int tagId;

  MonthTagIncomeBloc(this.dbService, this.analyticsService, this.currency,
      this.month, this.tagId);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(MonthTagIncomeViewState.loading());
    if (!_controller.isClosed) {
      // Filter by currency
      List<AnalyticsItem<IncomeModel>> list = List();
      month.actualIncomeItemsPerTag[tagId].forEach((item) {
        if (item.currencyValue.currency == currency) {
          list.add(item);
        }
      });
      _controller.sink.add(MonthTagIncomeViewState.loaded(list));
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

class MonthTagIncomeArguments {
  final CurrencyType currency;
  final AnalyticsMonth month;
  final int tagId;

  MonthTagIncomeArguments(this.currency, this.month, this.tagId);
}

class MonthTagIncomeViewState {
  final bool loaded;
  final List<AnalyticsItem<IncomeModel>> list;

  MonthTagIncomeViewState.loading()
      : loaded = false,
        list = null;

  MonthTagIncomeViewState.loaded(this.list) : loaded = true;
}
