import 'package:plann_app/services/analytics/analytics_utils.dart';
import 'package:plann_app/services/analytics/month_analytics.dart';
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

  List<MonthAnalytics> _monthList;
  int _currentMonthIndex;
  int _firstMonthIndex;
  int _lastMonthIndex;

  int get monthCount => _monthList.length;

  List<MonthAnalytics> get monthList => _monthList;

  int get currentMonthOffset => _currentMonthIndex - _firstMonthIndex;

  AnalyticsData(
      this.actualIncomeList,
      this.plannedIncomeList,
      this.actualExpenseList,
      this.plannedExpenseList,
      this.actualIrregularList,
      this.plannedIrregularList) {
    _monthList = List();
    DateTime now = DateTime.now();
    _currentMonthIndex = AnalyticsUtils.toAbs(now.year, now.month);
    _firstMonthIndex = _currentMonthIndex - 1;
    _lastMonthIndex = _currentMonthIndex + 1;
    _calcRange();
    _fillMonthList();
  }

  Future<void> analyze() async {
    await _analyzeActualIncomeList();
    await _analyzePlannedIncomeList();
    await _analyzeActualExpenseList();
    await _analyzePlannedExpenseList();
    await _analyzeActualIrregularList();
    await _analyzePlannedIrregularList();
    await _calcBalance();
    await _calcIncomePercentDiff();
    await _calcExpensePercentDiff();
    print("[AnalyticsData] firstMonth=" +
        _firstMonthIndex.toString() +
        ", lastMonth=" +
        _lastMonthIndex.toString() +
        ", currentMonth=" +
        _currentMonthIndex.toString());
  }

  void _calcRange() {
    List<DateTime> dateList = List();
    actualIncomeList.forEach((income) => dateList.add(income.date));
    plannedIncomeList.forEach((plannedIncome) {
      if (plannedIncome.mode == SubjectModeType.onetime) {
        dateList.add(plannedIncome.date);
      }
    });
    actualExpenseList.forEach((expense) => dateList.add(expense.date));
    actualIrregularList.forEach((irregular) => dateList.add(irregular.date));
    plannedIrregularList.forEach((plannedIrregular) {
      dateList.add(plannedIrregular.creationDate);
      dateList.add(plannedIrregular.date);
    });
    dateList.forEach((date) {
      int dateIndex = AnalyticsUtils.toAbs(date.year, date.month);

      if (dateIndex < _firstMonthIndex) {
        _firstMonthIndex = dateIndex;
      }

      if (dateIndex > _lastMonthIndex) {
        _lastMonthIndex = dateIndex;
      }
    });
  }

  void _fillMonthList() {
    for (int monthIndex = _firstMonthIndex;
        monthIndex <= _lastMonthIndex;
        monthIndex++) {
      List yearMonth = AnalyticsUtils.toHuman(monthIndex);
      _monthList.add(MonthAnalytics(monthIndex, yearMonth[0], yearMonth[1],
          monthIndex < _currentMonthIndex));
    }
  }

  MonthAnalytics _findMonthAnalyticsByDate(DateTime date) {
    int monthIndex = AnalyticsUtils.toAbs(date.year, date.month);
    return _monthList[monthIndex - _firstMonthIndex];
  }

  Future<void> _analyzeActualIncomeList() async {
    actualIncomeList.forEach((model) => _findMonthAnalyticsByDate(model.date)
        .addActualIncomeValue(model.currency, model.value));
  }

  Future<void> _analyzePlannedIncomeList() async {
    plannedIncomeList.forEach((model) {
      if (model.mode == SubjectModeType.monthly) {
        _monthList.forEach((monthAnalytics) =>
            monthAnalytics.addPlannedIncomeValue(model.currency, model.value));
      } else {
        _findMonthAnalyticsByDate(model.date)
            .addPlannedIncomeValue(model.currency, model.value);
      }
    });
  }

  Future<void> _analyzeActualExpenseList() async {
    actualExpenseList.forEach((model) => _findMonthAnalyticsByDate(model.date)
        .addActualExpenseValue(model.currency, model.value));
  }

  Future<void> _analyzePlannedExpenseList() async {
    plannedExpenseList.forEach((model) => _monthList.forEach((monthAnalytics) =>
        monthAnalytics.addPlannedExpenseValue(model.currency, model.value)));
  }

  Future<void> _analyzeActualIrregularList() async {
    actualIrregularList.forEach((model) {
      MonthAnalytics monthAnalytics = _findMonthAnalyticsByDate(model.date);
      monthAnalytics.addActualIrregularValue(model.currency, model.value);
    });
  }

  Future<void> _analyzePlannedIrregularList() async {
    plannedIrregularList.forEach((model) =>
        _findMonthAnalyticsByDate(model.date)
            .addPlannedIrregularValue(model.currency, model.value));

    plannedIrregularList.forEach((model) => _applyDebet(
        model.creationDate, model.date, model.currency, model.value));
  }

  void _applyDebet(DateTime fromDate, DateTime toDate,
      CurrencyType currencyType, double value) {
    int fromMonthIndex = AnalyticsUtils.toAbs(fromDate.year, fromDate.month);
    int toMonthIndex = AnalyticsUtils.toAbs(toDate.year, toDate.month);
    int monthCount = toMonthIndex - fromMonthIndex;
    if (monthCount == 0) {
      _monthList[fromMonthIndex - _firstMonthIndex]
          .addDebetValue(currencyType, value);
    } else {
      double valuePerMonth = value / monthCount;
      for (int monthIndex = fromMonthIndex;
          monthIndex < toMonthIndex;
          monthIndex++) {
        _monthList[monthIndex - _firstMonthIndex]
            .addDebetValue(currencyType, valuePerMonth);
      }
    }
  }

  Future<void> _calcBalance() async {
    Map<CurrencyType, double> prevMonthBalance = Map();
    _monthList.forEach((monthAnalytics) =>
        (prevMonthBalance = monthAnalytics.calcBalance(prevMonthBalance)));
  }

  Future<void> _calcIncomePercentDiff() async {
    Map<CurrencyType, double> prevMonthIncomeValues = Map();
    _monthList.forEach((monthAnalytics) {
      monthAnalytics.calcIncomePercentDiff(prevMonthIncomeValues);
      prevMonthIncomeValues = monthAnalytics.actualIncomeValues;
    });
  }

  Future<void> _calcExpensePercentDiff() async {
    Map<CurrencyType, double> prevMonthExpenseValue = Map();
    _monthList.forEach((monthAnalytics) {
      monthAnalytics.calcExpensePercentDiff(prevMonthExpenseValue);
      prevMonthExpenseValue = monthAnalytics.actualExpenseValues;
    });
  }
}
