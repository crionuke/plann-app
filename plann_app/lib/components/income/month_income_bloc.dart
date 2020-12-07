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
  final CurrencyType currency;
  final AnalyticsMonth month;

  MonthIncomeBloc(
      this.dbService, this.analyticsService, this.currency, this.month);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(MonthIncomeViewState.loading());
    if (!_controller.isClosed) {
      // CATEGORIES
      // Filter by currency
      Map<IncomeCategoryType, CurrencyValue> values = Map();
      month.actualIncomePerCategory.forEach((category, currencyMap) {
        if (currencyMap.containsKey(currency)) {
          values[category] = currencyMap[currency];
        }
      });
      // Sort categories by values
      List<IncomeCategoryType> sortedCategories = List();
      sortedCategories.addAll(values.keys);
      sortedCategories.sort((c1, c2) {
        return values[c2].value.compareTo(values[c1].value);
      });
      // Calc percents
      Map<IncomeCategoryType, double> percents = Map();
      double total = 0;
      values.values.forEach((currencyValue) => total += currencyValue.value);
      values.forEach((category, currencyValue) {
        percents[category] = currencyValue.value / total * 100;
      });
      // TAGS
      // Filter by currency
      Map<int, CurrencyValue> tags = Map();
      month.actualIncomePerTag.forEach((tagId, currencyMap) {
        if (currencyMap.containsKey(currency)) {
          tags[tagId] = currencyMap[currency];
        }
      });
      // Sort tags
      List<int> sortedTags = List();
      sortedTags.addAll(tags.keys);
      sortedTags.sort((t1, t2) {
        return month.actualIncomeItemsPerTag[t2].length.compareTo(
            month.actualIncomeItemsPerTag[t1].length);
      });
      // Tag values
      Map<int, CurrencyValue> tagValues = Map();
      // Tag names
      Map<int, String> tagNames = Map();
      sortedTags.forEach((tagid) =>
      tagNames[tagid] = month.analyticsTags.getTagName(tagid));
      // Tag item count
      Map<int, int> tagItemCount = Map();
      sortedTags.forEach((tagId) =>
      tagItemCount[tagId] = month.actualIncomeItemsPerTag[tagId].length);

      _controller.sink
          .add(MonthIncomeViewState.loaded(
          sortedCategories,
          values,
          percents,
          sortedTags,
          tags,
          tagNames,
          tagItemCount));
    }
  }
}

class MonthIncomeArguments {
  final CurrencyType currency;
  final AnalyticsMonth month;

  MonthIncomeArguments(this.currency, this.month);
}

class MonthIncomeViewState {
  final bool loaded;
  final List<IncomeCategoryType> sortedCategories;
  final Map<IncomeCategoryType, CurrencyValue> values;
  final Map<IncomeCategoryType, double> percents;

  final List<int> sortedTags;
  final Map<int, CurrencyValue> tags;
  final Map<int, String> tagNames;
  final Map<int, int> tagItemCount;

  MonthIncomeViewState.loading()
      : loaded = false,
        sortedCategories = null,
        values = null,
        percents = null,
        sortedTags = null,
        tags = null,
        tagNames = null,
        tagItemCount = null;

  MonthIncomeViewState.loaded(this.sortedCategories, this.values, this.percents,
      this.sortedTags, this.tags, this.tagNames, this.tagItemCount)
      : loaded = true;
}
