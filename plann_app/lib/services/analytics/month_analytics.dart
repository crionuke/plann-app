import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';

class MonthAnalytics {
  final int index;
  final int year;
  final int month;
  final bool finished;
  final DateTime date;

  Map<CurrencyType, double> actualIncomeValues;
  Map<CurrencyType, double> plannedIncomeValues;
  Map<CurrencyType, double> actualExpenseValues;
  Map<CurrencyType, double> plannedExpenseValues;
  Map<CurrencyType, double> actualIrregularValues;
  Map<CurrencyType, double> plannedIrregularValues;
  Map<CurrencyType, int> incomePercentDiff;
  Map<CurrencyType, int> expensePercentDiff;

  Map<CurrencyType, double> accountDebet;
  Map<CurrencyType, double> accountBalance;
  Map<PlannedIrregularModel, double> accountParts;

  MonthAnalytics(this.index, this.year, this.month, this.finished)
      : date = DateTime(year, month) {
    actualIncomeValues = Map();
    plannedIncomeValues = Map();
    actualExpenseValues = Map();
    plannedExpenseValues = Map();
    actualIrregularValues = Map();
    plannedIrregularValues = Map();
    incomePercentDiff = Map();
    expensePercentDiff = Map();
    accountDebet = Map();
    accountBalance = Map();
    accountParts = Map();
  }

  void addActualIncomeValue(CurrencyType currencyType, double value) {
    _addValue(actualIncomeValues, currencyType, value);
  }

  void addPlannedIncomeValue(CurrencyType currencyType, double value) {
    _addValue(plannedIncomeValues, currencyType, value);
  }

  void addActualExpenseValue(CurrencyType currencyType, double value) {
    _addValue(actualExpenseValues, currencyType, value);
  }

  void addPlannedExpenseValue(CurrencyType currencyType, double value) {
    _addValue(plannedExpenseValues, currencyType, value);
  }

  void addActualIrregularValue(CurrencyType currencyType, double value) {
    _addValue(actualIrregularValues, currencyType, value);
  }

  void addPlannedIrregularValue(CurrencyType currencyType, double value) {
    _addValue(plannedIrregularValues, currencyType, value);
  }

  void addDebetValue(
      PlannedIrregularModel model, CurrencyType currencyType, double value) {
    _addValue(accountDebet, currencyType, value);

    accountParts[model] = value;
  }

  Map<CurrencyType, double> calcBalance(
      Map<CurrencyType, double> prevMonthBalance) {
    accountBalance = _addCurrencyMap(prevMonthBalance, accountDebet);
    accountBalance = _subCurrencyMap(accountBalance, plannedIrregularValues);
    return accountBalance;
  }

  void calcIncomePercentDiff(Map<CurrencyType, double> prevMonthIncomeValues) {
    actualIncomeValues.forEach((key, value) {
      double prevIncome = prevMonthIncomeValues[key];
      if (prevIncome != null) {
        if (prevIncome > 0) {
          incomePercentDiff[key] = ((value / prevIncome - 1) * 100).round();
        } else {
          incomePercentDiff[key] = 100;
        }
      } else {
        incomePercentDiff[key] = 100;
      }
    });
  }

  void calcExpensePercentDiff(
      Map<CurrencyType, double> prevMonthExpenseValues) {
    actualExpenseValues.forEach((key, value) {
      double prevExpense = prevMonthExpenseValues[key];
      if (prevExpense != null) {
        if (prevExpense >= 0) {
          expensePercentDiff[key] = ((value / prevExpense - 1) * 100).round();
        } else {
          expensePercentDiff[key] = 100;
        }
      } else {
        expensePercentDiff[key] = 100;
      }
    });
  }

  void _addValue(
      Map<CurrencyType, double> list, CurrencyType currencyType, double value) {
    double lastValue = list[currencyType];
    if (lastValue == null) {
      lastValue = 0;
    }
    list[currencyType] = lastValue += value;
  }

  Map<CurrencyType, double> _addCurrencyMap(
      Map<CurrencyType, double> map1, Map<CurrencyType, double> map2) {
    Map<CurrencyType, double> result = Map();
    map1.forEach((key, value) => result[key] = value);
    map2.forEach(
        (key, value) => result[key] == null ? result[key] = 0 : result[key]);
    map2.forEach((key, value) => result[key] = result[key] + value);
    return result;
  }

  Map<CurrencyType, double> _subCurrencyMap(
      Map<CurrencyType, double> map1, Map<CurrencyType, double> map2) {
    Map<CurrencyType, double> result = Map();
    map1.forEach((key, value) => result[key] = value);
    map2.forEach(
        (key, value) => result[key] == null ? result[key] = 0 : result[key]);
    map2.forEach((key, value) => result[key] = result[key] - value);
    return result;
  }
}
