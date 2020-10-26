import 'package:plann_app/services/analytics/analytics_account.dart';
import 'package:plann_app/services/analytics/analytics_utils.dart';
import 'package:plann_app/services/db/models/currency_model.dart';

class AnalyticsMonth {
  final int index;
  final int year;
  final int month;
  final DateTime date;

  Map<CurrencyType, double> actualIncomeValues;
  Map<CurrencyType, double> plannedIncomeValues;
  Map<CurrencyType, double> actualExpenseValues;
  Map<CurrencyType, double> plannedExpenseValues;
  Map<CurrencyType, double> deltaValues;
  Map<CurrencyType, double> actualIrregularValues;
  Map<CurrencyType, double> plannedIrregularValues;
  Map<CurrencyType, int> incomePercentDiff;
  Map<CurrencyType, int> expensePercentDiff;
  Map<CurrencyType, int> deltaPercentDiff;
  Map<CurrencyType, double> balanceValues;

  AnalyticsAccount<int> plannedIrregularAccount;

  AnalyticsMonth(this.index, this.year, this.month)
      : date = DateTime(year, month) {
    actualIncomeValues = Map();
    plannedIncomeValues = Map();
    actualExpenseValues = Map();
    plannedExpenseValues = Map();
    actualIrregularValues = Map();
    plannedIrregularValues = Map();
    deltaValues = Map();
    incomePercentDiff = Map();
    expensePercentDiff = Map();
    deltaPercentDiff = Map();
    balanceValues = Map();
    plannedIrregularAccount = AnalyticsAccount();
  }

  void addActualIncomeValue(CurrencyType currencyType, double value) {
    AnalyticsUtils.addValueToCurrencyMap(
        actualIncomeValues, currencyType, value);
  }

  void addPlannedIncomeValue(CurrencyType currencyType, double value) {
    AnalyticsUtils.addValueToCurrencyMap(
        plannedIncomeValues, currencyType, value);
  }

  void addActualExpenseValue(CurrencyType currencyType, double value) {
    AnalyticsUtils.addValueToCurrencyMap(
        actualExpenseValues, currencyType, value);
  }

  void addPlannedExpenseValue(CurrencyType currencyType, double value) {
    AnalyticsUtils.addValueToCurrencyMap(
        plannedExpenseValues, currencyType, value);
  }

  void addActualIrregularValue(CurrencyType currencyType, double value) {
    AnalyticsUtils.addValueToCurrencyMap(
        actualIrregularValues, currencyType, value);
  }

  void addPlannedIrregularValue(CurrencyType currencyType, double value) {
    AnalyticsUtils.addValueToCurrencyMap(
        plannedIrregularValues, currencyType, value);
  }

  void calcDelta() {
    deltaValues =
        AnalyticsUtils.subCurrencyMap(actualIncomeValues, actualExpenseValues);
    deltaValues.forEach((key, value) {
      double expense = actualExpenseValues[key];
      double income = actualIncomeValues[key];
      if (expense != null && income != null) {
        deltaPercentDiff[key] = ((1 - expense / income) * 100).round();
      } else if (value > 0) {
        deltaPercentDiff[key] = 100;
      } else {
        deltaPercentDiff[key] = -100;
      }
    });
  }

  void calcBalance() {
    balanceValues = AnalyticsUtils.subCurrencyMap(
        deltaValues, plannedIrregularAccount.debet);
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
}
