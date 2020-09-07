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

  Map<int, double> _perMonthValues;
  Map<DateTime, Map<CurrencyType, double>> _perDayExpenses;
  Map<int, Map<CurrencyType, double>> _perMonthIncomes;

  int _currentMonthIndex;
  int _firstMonthIndex;
  int _lastMonthIndex;

  int get monthCount => _monthList.length;

  List<MonthAnalytics> get monthList => _monthList;

  Map<int, double> get perMonthValues => _perMonthValues;

  Map<DateTime, Map<CurrencyType, double>> get perDayExpenses =>
      _perDayExpenses;

  Map<int, Map<CurrencyType, double>> get perMonthIncomes =>
      _perMonthIncomes;

  int get currentMonthOffset => _currentMonthIndex - _firstMonthIndex;

  int _actualIncomeCount;

  int get actualIncomeCount => _actualIncomeCount;

  int _plannedIncomeCount;

  int get plannedIncomeCount => _plannedIncomeCount;

  int _actualExpenseCount;

  int get actualExpenseCount => _actualExpenseCount;

  int _plannedExpenseCount;

  int get plannedExpenseCount => _plannedExpenseCount;

  int _actualIrregularCount;

  int get actualIrregularCount => _actualIrregularCount;

  int _plannedIrregularCount;

  int get plannedIrregularCount => _plannedIrregularCount;

  AnalyticsData(
      this.actualIncomeList,
      this.plannedIncomeList,
      this.actualExpenseList,
      this.plannedExpenseList,
      this.actualIrregularList,
      this.plannedIrregularList) {
    _actualIncomeCount = actualIncomeList.length;
    _plannedIncomeCount = plannedIncomeList.length;
    _actualExpenseCount = actualExpenseList.length;
    _plannedExpenseCount = plannedExpenseList.length;
    _actualIrregularCount = actualIrregularList.length;
    _plannedIrregularCount = plannedIrregularList.length;

    _monthList = List();
    _perMonthValues = Map();
    _perDayExpenses = Map();
    _perMonthIncomes = Map();

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
    await _calcDeltaPercentDiff();
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

    actualIncomeList.forEach((model) {
      int monthIndex = AnalyticsUtils.toAbs(model.date.year, model.date.month);

      if (_perMonthIncomes[monthIndex] == null) {
        _perMonthIncomes[monthIndex] = Map();
      }
      if (_perMonthIncomes[monthIndex][model.currency] == null) {
        _perMonthIncomes[monthIndex][model.currency] = 0;
      }
      _perMonthIncomes[monthIndex][model.currency] += model.value;
    });
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

    actualExpenseList.forEach((model) {
      if (_perDayExpenses[model.date] == null) {
        _perDayExpenses[model.date] = Map();
      }
      if (_perDayExpenses[model.date][model.currency] == null) {
        _perDayExpenses[model.date][model.currency] = 0;
      }
      _perDayExpenses[model.date][model.currency] += model.value;
    });
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
        model, model.creationDate, model.date, model.currency, model.value));
  }

  void _applyDebet(PlannedIrregularModel model, DateTime fromDate,
      DateTime toDate, CurrencyType currencyType, double value) {
    int fromMonthIndex = AnalyticsUtils.toAbs(fromDate.year, fromDate.month);
    int toMonthIndex = AnalyticsUtils.toAbs(toDate.year, toDate.month);
    int monthCount = toMonthIndex - fromMonthIndex;
    if (monthCount == 0) {
      _monthList[fromMonthIndex - _firstMonthIndex]
          .addDebetValue(model, currencyType, value);
      _perMonthValues[model.id] = value;
    } else {
      double valuePerMonth = value / monthCount;
      _perMonthValues[model.id] = valuePerMonth;
      for (int monthIndex = fromMonthIndex;
          monthIndex < toMonthIndex;
          monthIndex++) {
        _monthList[monthIndex - _firstMonthIndex]
            .addDebetValue(model, currencyType, valuePerMonth);
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

  Future<void> _calcDeltaPercentDiff() async {
    _monthList.forEach((monthAnalytics) {
      monthAnalytics.calcDeltaPercentDiff();
    });
  }
}
