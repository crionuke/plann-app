import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_utils.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:plann_app/services/db/models/subject_mode_model.dart';

class AnalyticsMonthList {
  final List<IncomeModel> actualIncomeList;
  final List<PlannedIncomeModel> plannedIncomeList;
  final List<ExpenseModel> actualExpenseList;
  final List<PlannedExpenseModel> plannedExpenseList;
  final List<IrregularModel> actualIrregularList;
  final List<PlannedIrregularModel> plannedIrregularList;

  List<AnalyticsMonth> _monthList;
  int _currentMonthIndex;
  int _firstMonthIndex;
  int _lastMonthIndex;

  Map<int, double> _perMonthValues;

  AnalyticsMonthList(
      this.actualIncomeList,
      this.plannedIncomeList,
      this.actualExpenseList,
      this.plannedExpenseList,
      this.actualIrregularList,
      this.plannedIrregularList) {
    _perMonthValues = Map();
    _monthList = List();
    DateTime now = DateTime.now();
    _currentMonthIndex = AnalyticsUtils.toAbs(now.year, now.month);
    _firstMonthIndex = _currentMonthIndex;
    _lastMonthIndex = _currentMonthIndex;
    List<DateTime> dateList = List();
    // Fill list by all dates
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
    // Calc min and max dates
    dateList.forEach((date) {
      int monthIndex = AnalyticsUtils.toAbs(date.year, date.month);
      if (monthIndex < _firstMonthIndex) {
        _firstMonthIndex = monthIndex;
      }
      if (monthIndex > _lastMonthIndex) {
        _lastMonthIndex = monthIndex;
      }
    });
    // Fill month list
    for (int monthIndex = _firstMonthIndex;
    monthIndex <= _lastMonthIndex;
    monthIndex++) {
      List yearMonth = AnalyticsUtils.toHuman(monthIndex);
      _monthList.add(AnalyticsMonth(monthIndex, yearMonth[0], yearMonth[1]));
    }
  }

  int get currentMonthOffset => _currentMonthIndex - _firstMonthIndex;

  double perMonthValue(PlannedIrregularModel model) {
    return _perMonthValues[model.id];
  }

  AnalyticsMonth findMonthByIndex(int index) {
    return _monthList[index];
  }

  AnalyticsMonth findMonthByDate(DateTime date) {
    int monthIndex = AnalyticsUtils.toAbs(date.year, date.month);
    return _monthList[monthIndex - _firstMonthIndex];
  }

  void forEach(void f(AnalyticsMonth month)) {
    for (AnalyticsMonth month in _monthList) f(month);
  }

  Future<void> calcIrregularPlan() async {
    // Copy list
    List<PlannedIrregularModel> sorted = List();
    sorted.addAll(plannedIrregularList);
    // Sort
    sorted.sort((m1, m2) {
      if (m1.creationDate.year == m2.creationDate.year) {
        if (m1.creationDate.month == m2.creationDate.month) {
          return m1.date.compareTo(m2.date);
        }
      }
      return m1.creationDate.compareTo(m2.creationDate);
    });
    // Sorted list with all end points
    List<DateTime> points = List();
    sorted.forEach((model) {
      if (!points.contains(model.date)) {
        points.add(model.date);
      }
    });
    points.sort();
    // Calc plan
    sorted.forEach((model) {
      DateTime fromDate = model.creationDate;
      double metric = _calcMetricWith(
          fromDate,
          model.date,
          model.currency,
          AnalyticsUtils.calcValuePerMonth(
              model.creationDate, model.date, model.value));
      print("${model.title} $metric");
      for (DateTime point in points) {
        int pointMonthIndex = AnalyticsUtils.toAbs(point.year, point.month);
        int modelMonthIndex =
            AnalyticsUtils.toAbs(model.date.year, model.date.month);
        // point before end date
        if (pointMonthIndex < modelMonthIndex) {
          int modelCreationMonthIndex = AnalyticsUtils.toAbs(
              model.creationDate.year, model.creationDate.month);
          // point after creation date
          if (pointMonthIndex > modelCreationMonthIndex) {
            double currentMetric = _calcMetricWith(
                point,
                model.date,
                model.currency,
                AnalyticsUtils.calcValuePerMonth(
                    point, model.date, model.value));
            print("${model.title} $currentMetric");
            //  Update best result
            if (currentMetric < metric) {
              metric = currentMetric;
              fromDate = point;
            }
          }
        } else {
          // As list sorted
          break;
        }
      }
      // Use best result
      int fromMonthIndex = AnalyticsUtils.toAbs(fromDate.year, fromDate.month);
      int toMonthIndex =
          AnalyticsUtils.toAbs(model.date.year, model.date.month);
      int monthCount = toMonthIndex - fromMonthIndex;
      if (monthCount == 0) {
        _monthList[fromMonthIndex - _firstMonthIndex]
            .plannedIrregularAccount
            .addDebetValue(model.id, model.currency, model.value);
        _perMonthValues[model.id] = model.value;
      } else {
        double valuePerMonth = model.value / monthCount;
        for (int monthIndex = fromMonthIndex;
            monthIndex < toMonthIndex;
            monthIndex++) {
          _monthList[monthIndex - _firstMonthIndex]
              .plannedIrregularAccount
              .addDebetValue(model.id, model.currency, valuePerMonth);
          _perMonthValues[model.id] = valuePerMonth;
        }
      }
      // Add credit
      _monthList[toMonthIndex - _firstMonthIndex]
          .plannedIrregularAccount
          .addCreditValue(model.currency, model.value);
    });
    // Calc month values
    Map<CurrencyType, double> prevMonthBalance = Map();
    Map<CurrencyType, double> prevMonthIncomeValues = Map();
    Map<CurrencyType, double> prevMonthExpenseValue = Map();
    _monthList.forEach((month) {
      // Planned irregular account balance
      prevMonthBalance =
          month.plannedIrregularAccount.calcBalance(prevMonthBalance);
      // Income percent diff
      month.calcIncomePercentDiff(prevMonthIncomeValues);
      prevMonthIncomeValues = month.actualIncomeValues;
      // Expense percent diff
      month.calcExpensePercentDiff(prevMonthExpenseValue);
      prevMonthExpenseValue = month.actualExpenseValues;
      // Delta
      month.calcDelta();
      // Balance
      month.calcBalance();
    });
  }

  double _calcMetricWith(DateTime fromDate, DateTime toDate,
      CurrencyType currency, double valuePerMonth) {
    int fromMonthIndex = AnalyticsUtils.toAbs(fromDate.year, fromDate.month);
    int toMonthIndex = AnalyticsUtils.toAbs(toDate.year, toDate.month);
    double max = 0;
    _monthList.forEach((month) {
      double total = month.plannedIrregularAccount.debetPerCurrency(currency);
      if (month.index >= fromMonthIndex && month.index <= toMonthIndex) {
        total += valuePerMonth;
      }
      if (total > max) {
        max = total;
      }
    });
    return max;
  }
}
