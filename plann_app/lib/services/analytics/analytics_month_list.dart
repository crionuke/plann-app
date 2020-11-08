import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
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

class AnalyticsMonthList {
  final List<AnalyticsItem<IncomeModel>> analyticsActualIncomeList;
  final List<AnalyticsItem<PlannedIncomeModel>> analyticsPlannedIncomeList;
  final List<AnalyticsItem<ExpenseModel>> analyticsActualExpenseList;
  final List<AnalyticsItem<PlannedExpenseModel>> analyticsPlannedExpenseList;
  final List<AnalyticsItem<IrregularModel>> analyticsActualIrregularList;
  final List<AnalyticsItem<PlannedIrregularModel>>
      analyticsPlannedIrregularList;

  List<AnalyticsMonth> _monthList;
  int _currentMonthIndex;
  int _firstMonthIndex;
  int _lastMonthIndex;

  Map<int, double> _perMonthValues;

  AnalyticsMonthList(
      this.analyticsActualIncomeList,
      this.analyticsPlannedIncomeList,
      this.analyticsActualExpenseList,
      this.analyticsPlannedExpenseList,
      this.analyticsActualIrregularList,
      this.analyticsPlannedIrregularList) {
    _perMonthValues = Map();
    _monthList = List();
    DateTime now = DateTime.now();
    _currentMonthIndex = AnalyticsUtils.toAbs(now.year, now.month);
    _firstMonthIndex = _currentMonthIndex;
    _lastMonthIndex = _currentMonthIndex;
    List<DateTime> dateList = List();
    // Fill list by all dates
    analyticsActualIncomeList.forEach((item) => dateList.add(item.model.date));
    analyticsPlannedIncomeList.forEach((item) {
      if (item.model.mode == SubjectModeType.onetime) {
        dateList.add(item.model.date);
      }
    });
    analyticsActualExpenseList.forEach((item) => dateList.add(item.model.date));
    analyticsActualIrregularList
        .forEach((item) => dateList.add(item.model.date));
    analyticsPlannedIrregularList.forEach((item) {
      dateList.add(item.model.creationDate);
      dateList.add(item.model.date);
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
    List<AnalyticsItem<PlannedIrregularModel>> sorted = List();
    sorted.addAll(analyticsPlannedIrregularList);
    // Sort
    sorted.sort((item1, item2) {
      PlannedIrregularModel model1 = item1.model;
      PlannedIrregularModel model2 = item2.model;
      if (model1.creationDate.year == model2.creationDate.year) {
        if (model1.creationDate.month == model2.creationDate.month) {
          return model1.date.compareTo(model2.date);
        }
      }
      return model1.creationDate.compareTo(model2.creationDate);
    });
    // Sorted list with all end points
    List<DateTime> points = List();
    sorted.forEach((item) {
      points.add(item.model.date);
    });
    points.sort();
    // Calc plan
    sorted.forEach((item) {
      PlannedIrregularModel model = item.model;
      DateTime fromDate = model.creationDate;
      double metric = _calcMetricWith(
          fromDate,
          model.date,
          AnalyticsUtils.calcValuePerMonth(
              model.creationDate, model.date, item.currencyValue));
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
                AnalyticsUtils.calcValuePerMonth(
                    point, model.date, item.currencyValue));
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
            .addDebetValue(item, item.currencyValue);
        _perMonthValues[model.id] = model.value;
      } else {
        double valuePerMonth = model.value / monthCount;
        double valuePerMonthInDefaultCurrency =
            item.currencyValue.valueInDefaultValue / monthCount;
        for (int monthIndex = fromMonthIndex;
            monthIndex < toMonthIndex;
            monthIndex++) {
          _monthList[monthIndex - _firstMonthIndex]
              .plannedIrregularAccount
              .addDebetValue(
                  item,
                  CurrencyValue(item.currencyValue.currency, valuePerMonth,
                      valuePerMonthInDefaultCurrency));
          _perMonthValues[model.id] = valuePerMonth;
        }
      }
      // Add credit
      _monthList[toMonthIndex - _firstMonthIndex]
          .plannedIrregularAccount
          .addCreditValue(item.currencyValue);
    });
    // Calc month values
    Map<CurrencyType, CurrencyValue> prevMonthBalance = Map();
    Map<CurrencyType, CurrencyValue> prevMonthIncomeValues = Map();
    Map<CurrencyType, CurrencyValue> prevMonthExpenseValue = Map();
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
      // Delta map
      month.calcDelta();
      // Balance map
      month.calcBalance();
    });
  }

  double _calcMetricWith(DateTime fromDate, DateTime toDate,
      double valuePerMonthInDefaultCurrency) {
    int fromMonthIndex = AnalyticsUtils.toAbs(fromDate.year, fromDate.month);
    int toMonthIndex = AnalyticsUtils.toAbs(toDate.year, toDate.month);
    double max = 0;
    _monthList.forEach((month) {
      double total = month.plannedIrregularAccount.debetInDefaultCurrency();
      if (month.index >= fromMonthIndex && month.index <= toMonthIndex) {
        total += valuePerMonthInDefaultCurrency;
        if (total > max) {
          max = total;
        }
      }
    });
    return max;
  }
}
