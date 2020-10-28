import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_month_list.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:plann_app/services/db/models/subject_mode_model.dart';

class AnalyticsData {
  final List<AnalyticsItem<IncomeModel>> analyticsActualIncomeList;
  final List<AnalyticsItem<PlannedIncomeModel>> analyticsPlannedIncomeList;
  final List<AnalyticsItem<ExpenseModel>> analyticsActualExpenseList;
  final List<AnalyticsItem<PlannedExpenseModel>> analyticsPlannedExpenseList;
  final List<AnalyticsItem<IrregularModel>> analyticsActualIrregularList;
  final List<AnalyticsItem<PlannedIrregularModel>>
      analyticsPlannedIrregularList;

  AnalyticsMonthList _monthList;

  Map<DateTime, Map<CurrencyType, double>> _perDayExpenses;
  Map<DateTime, Map<CurrencyType, double>> _perMonthIncomes;

  AnalyticsData(
      this.analyticsActualIncomeList,
      this.analyticsPlannedIncomeList,
      this.analyticsActualExpenseList,
      this.analyticsPlannedExpenseList,
      this.analyticsActualIrregularList,
      this.analyticsPlannedIrregularList) {
    _monthList = AnalyticsMonthList(
        analyticsActualIncomeList,
        analyticsPlannedIncomeList,
        analyticsActualExpenseList,
        analyticsPlannedExpenseList,
        analyticsActualIrregularList,
        analyticsPlannedIrregularList);
    _perDayExpenses = Map();
    _perMonthIncomes = Map();
  }

  AnalyticsMonthList get monthList => _monthList;

  Map<DateTime, Map<CurrencyType, double>> get perDayExpenses =>
      _perDayExpenses;

  Map<DateTime, Map<CurrencyType, double>> get perMonthIncomes =>
      _perMonthIncomes;

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
    analyticsActualIncomeList.forEach((item) => monthList
        .findMonthByDate(item.model.date)
        .addActualIncomeValue(item.model.currency, item.model.value));
    analyticsActualIncomeList.forEach((item) {
      IncomeModel model = item.model;
      DateTime rounded = DateTime(model.date.year, model.date.month);
      if (_perMonthIncomes[rounded] == null) {
        _perMonthIncomes[rounded] = Map();
      }
      if (_perMonthIncomes[rounded][model.currency] == null) {
        _perMonthIncomes[rounded][model.currency] = 0;
      }
      _perMonthIncomes[rounded][model.currency] += model.value;
    });
  }

  Future<void> _analyzePlannedIncomeList() async {
    analyticsPlannedIncomeList.forEach((item) {
      PlannedIncomeModel model = item.model;
      if (model.mode == SubjectModeType.monthly) {
        monthList.forEach((month) =>
            month.addPlannedIncomeValue(model.currency, model.value));
      } else {
        monthList
            .findMonthByDate(model.date)
            .addPlannedIncomeValue(model.currency, model.value);
      }
    });
  }

  Future<void> _analyzeActualExpenseList() async {
    analyticsActualExpenseList.forEach((item) => monthList
        .findMonthByDate(item.model.date)
        .addActualExpenseValue(item.model.currency, item.model.value));

    analyticsActualExpenseList.forEach((item) {
      ExpenseModel model = item.model;
      DateTime rounded =
          DateTime(model.date.year, model.date.month, model.date.day);

      if (_perDayExpenses[rounded] == null) {
        _perDayExpenses[rounded] = Map();
      }
      if (_perDayExpenses[rounded][model.currency] == null) {
        _perDayExpenses[rounded][model.currency] = 0;
      }
      _perDayExpenses[rounded][model.currency] += model.value;
    });
  }

  Future<void> _analyzePlannedExpenseList() async {
    analyticsPlannedExpenseList.forEach((item) => monthList.forEach((month) =>
        month.addPlannedExpenseValue(item.model.currency, item.model.value)));
  }

  Future<void> _analyzeActualIrregularList() async {
    analyticsActualIrregularList.forEach((item) {
      AnalyticsMonth month = monthList.findMonthByDate(item.model.date);
      month.addActualIrregularValue(item.model.currency, item.model.value);
    });
  }

  Future<void> _analyzePlannedIrregularList() async {
    analyticsPlannedIrregularList.forEach((item) => monthList
        .findMonthByDate(item.model.date)
        .addPlannedIrregularValue(item.model.currency, item.model.value));
  }
}
