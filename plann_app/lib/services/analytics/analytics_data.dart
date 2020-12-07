import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_month_list.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/analytics/analytics_tags.dart';
import 'package:plann_app/services/analytics/analytics_utils.dart';
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:plann_app/services/db/models/subject_mode_model.dart';
import 'package:plann_app/services/db/models/tag_model.dart';

class AnalyticsData {
  final List<AnalyticsItem<IncomeModel>> analyticsActualIncomeList;
  final List<AnalyticsItem<PlannedIncomeModel>> analyticsPlannedIncomeList;
  final List<AnalyticsItem<ExpenseModel>> analyticsActualExpenseList;
  final List<AnalyticsItem<PlannedExpenseModel>> analyticsPlannedExpenseList;
  final List<AnalyticsItem<IrregularModel>> analyticsActualIrregularList;
  final List<AnalyticsItem<PlannedIrregularModel>>
      analyticsPlannedIrregularList;
  final AnalyticsTags analyticsTags;

  AnalyticsMonthList _monthList;

  Map<DateTime, Map<CurrencyType, CurrencyValue>> _perDayExpenses;

  AnalyticsData(
      this.analyticsActualIncomeList,
      this.analyticsPlannedIncomeList,
      this.analyticsActualExpenseList,
      this.analyticsPlannedExpenseList,
      this.analyticsActualIrregularList,
      this.analyticsPlannedIrregularList,
      this.analyticsTags) {
    _monthList = AnalyticsMonthList(
        analyticsActualIncomeList,
        analyticsPlannedIncomeList,
        analyticsActualExpenseList,
        analyticsPlannedExpenseList,
        analyticsActualIrregularList,
        analyticsPlannedIrregularList,
        analyticsTags);
    _perDayExpenses = Map();
  }

  AnalyticsMonthList get monthList => _monthList;

  Map<DateTime, Map<CurrencyType, CurrencyValue>> get perDayExpenses =>
      _perDayExpenses;

  Future<void> analyze() async {
    await _analyzeActualIncomeList();
    await _analyzePlannedIncomeList();
    await _analyzeActualExpenseList();
    await _analyzePlannedExpenseList();
    await _analyzeActualIrregularList();
    await _analyzePlannedIrregularList();
    await _monthList.calcIrregularPlan();
  }

  Future<void> _analyzeActualIncomeList() async {
    analyticsActualIncomeList.forEach((item) =>
        monthList.findMonthByDate(item.model.date).addActualIncomeValue(item));
  }

  Future<void> _analyzePlannedIncomeList() async {
    analyticsPlannedIncomeList.forEach((item) {
      PlannedIncomeModel model = item.model;
      if (model.mode == SubjectModeType.monthly) {
        monthList.forEach((month) => month.addPlannedIncomeValue(item));
      } else {
        monthList.findMonthByDate(model.date).addPlannedIncomeValue(item);
      }
    });
  }

  Future<void> _analyzeActualExpenseList() async {
    analyticsActualExpenseList.forEach((item) =>
        monthList.findMonthByDate(item.model.date).addActualExpenseValue(item));

    analyticsActualExpenseList.forEach((item) {
      ExpenseModel model = item.model;
      DateTime rounded =
          DateTime(model.date.year, model.date.month, model.date.day);
      if (_perDayExpenses[rounded] == null) {
        _perDayExpenses[rounded] =
            AnalyticsUtils.addValueToCurrencyMap(Map(), item.currencyValue);
      } else {
        AnalyticsUtils.addValueToCurrencyMap(
            _perDayExpenses[rounded], item.currencyValue);
      }
    });
  }

  Future<void> _analyzePlannedExpenseList() async {
    analyticsPlannedExpenseList.forEach((item) =>
        monthList.forEach((month) => month.addPlannedExpenseValue(item)));
  }

  Future<void> _analyzeActualIrregularList() async {
    analyticsActualIrregularList.forEach((item) {
      AnalyticsMonth month = monthList.findMonthByDate(item.model.date);
      month.addActualIrregularValue(item);
    });
  }

  Future<void> _analyzePlannedIrregularList() async {
    analyticsPlannedIrregularList.forEach((item) => monthList
        .findMonthByDate(item.model.date)
        .addPlannedIrregularValue(item));
  }
}
