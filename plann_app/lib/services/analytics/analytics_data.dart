import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_month_list.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:plann_app/services/db/models/subject_mode_model.dart';

class AnalyticsData {
  final List<IncomeModel> actualIncomeList;
  final List<PlannedIncomeModel> plannedIncomeList;
  final List<ExpenseModel> actualExpenseList;
  final List<PlannedExpenseModel> plannedExpenseList;
  final List<IrregularModel> actualIrregularList;
  final List<PlannedIrregularModel> plannedIrregularList;

  AnalyticsMonthList _monthList;

  Map<DateTime, Map<CurrencyType, double>> _perDayExpenses;
  Map<DateTime, Map<CurrencyType, double>> _perMonthIncomes;

  AnalyticsData(
      this.actualIncomeList,
      this.plannedIncomeList,
      this.actualExpenseList,
      this.plannedExpenseList,
      this.actualIrregularList,
      this.plannedIrregularList) {
    _monthList = AnalyticsMonthList(
        actualIncomeList,
        plannedIncomeList,
        actualExpenseList,
        plannedExpenseList,
        actualIrregularList,
        plannedIrregularList);
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
    print("[AnalyticsData] calc irregular plan");
    await _monthList.calcIrregularPlan();
  }

  Future<void> _analyzeActualIncomeList() async {
    actualIncomeList.forEach((model) => monthList
        .findMonthByDate(model.date)
        .addActualIncomeValue(model.currency, model.value));
    actualIncomeList.forEach((model) {
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
    plannedIncomeList.forEach((model) {
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
    actualExpenseList.forEach((model) => monthList
        .findMonthByDate(model.date)
        .addActualExpenseValue(model.currency, model.value));

    actualExpenseList.forEach((model) {
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
    plannedExpenseList.forEach((model) => monthList.forEach(
        (month) => month.addPlannedExpenseValue(model.currency, model.value)));
  }

  Future<void> _analyzeActualIrregularList() async {
    actualIrregularList.forEach((model) {
      AnalyticsMonth month = monthList.findMonthByDate(model.date);
      month.addActualIrregularValue(model.currency, model.value);
    });
  }

  Future<void> _analyzePlannedIrregularList() async {
    plannedIrregularList.forEach((model) => monthList
        .findMonthByDate(model.date)
        .addPlannedIrregularValue(model.currency, model.value));
  }
}
