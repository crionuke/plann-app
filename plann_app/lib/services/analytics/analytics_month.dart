import 'package:plann_app/services/analytics/analytics_account.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/analytics/analytics_utils.dart';
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';

class AnalyticsMonth {
  final int index;
  final int year;
  final int month;
  final DateTime date;

  Map<CurrencyType, CurrencyValue> actualIncomeValues;
  Map<IncomeCategoryType, Map<CurrencyType, CurrencyValue>>
      actualIncomePerCategory;
  Map<CurrencyType, CurrencyValue> plannedIncomeValues;
  Map<CurrencyType, CurrencyValue> actualExpenseValues;
  Map<ExpenseCategoryType, Map<CurrencyType, CurrencyValue>>
      actualExpensePerCategory;
  Map<CurrencyType, CurrencyValue> plannedExpenseValues;
  Map<CurrencyType, CurrencyValue> deltaValues;
  Map<CurrencyType, CurrencyValue> actualIrregularValues;
  Map<CurrencyType, CurrencyValue> plannedIrregularValues;
  Map<CurrencyType, int> incomePercentDiff;
  Map<CurrencyType, int> expensePercentDiff;
  Map<CurrencyType, int> deltaPercentDiff;
  Map<CurrencyType, CurrencyValue> balanceValues;

  AnalyticsAccount<AnalyticsItem<PlannedIrregularModel>>
      plannedIrregularAccount;

  AnalyticsMonth(this.index, this.year, this.month)
      : date = DateTime(year, month) {
    actualIncomeValues = Map();
    actualIncomePerCategory = Map();
    plannedIncomeValues = Map();
    actualExpenseValues = Map();
    actualExpensePerCategory = Map();
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

  void addActualIncomeValue(AnalyticsItem<IncomeModel> item) {
    IncomeCategoryType category = item.model.category;

    AnalyticsUtils.addValueToCurrencyMap(
        actualIncomeValues, item.currencyValue);
    if (actualIncomePerCategory[category] == null) {
      actualIncomePerCategory[category] =
          AnalyticsUtils.addValueToCurrencyMap(Map(), item.currencyValue);
    } else {
      AnalyticsUtils.addValueToCurrencyMap(
          actualIncomePerCategory[category], item.currencyValue);
    }
  }

  void addPlannedIncomeValue(AnalyticsItem<PlannedIncomeModel> item) {
    AnalyticsUtils.addValueToCurrencyMap(
        plannedIncomeValues, item.currencyValue);
  }

  void addActualExpenseValue(AnalyticsItem<ExpenseModel> item) {
    AnalyticsUtils.addValueToCurrencyMap(
        actualExpenseValues, item.currencyValue);
    ExpenseCategoryType category = item.model.category;
    if (actualExpensePerCategory[category] == null) {
      actualExpensePerCategory[category] =
          AnalyticsUtils.addValueToCurrencyMap(Map(), item.currencyValue);
    } else {
      AnalyticsUtils.addValueToCurrencyMap(
          actualExpensePerCategory[category], item.currencyValue);
    }
  }

  void addPlannedExpenseValue(AnalyticsItem<PlannedExpenseModel> item) {
    AnalyticsUtils.addValueToCurrencyMap(
        plannedExpenseValues, item.currencyValue);
  }

  void addActualIrregularValue(AnalyticsItem<IrregularModel> item) {
    AnalyticsUtils.addValueToCurrencyMap(
        actualIrregularValues, item.currencyValue);
  }

  void addPlannedIrregularValue(AnalyticsItem<PlannedIrregularModel> item) {
    AnalyticsUtils.addValueToCurrencyMap(
        plannedIrregularValues, item.currencyValue);
  }

  void calcDelta() {
    deltaValues =
        AnalyticsUtils.subCurrencyMap(actualIncomeValues, actualExpenseValues);
    deltaValues.forEach((key, currencyValue) {
      CurrencyValue expense = actualExpenseValues[key];
      CurrencyValue income = actualIncomeValues[key];
      if (expense != null && income != null) {
        deltaPercentDiff[key] =
            ((1 - expense.value / income.value) * 100).round();
      } else if (currencyValue.value > 0) {
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

  void calcIncomePercentDiff(
      Map<CurrencyType, CurrencyValue> prevMonthIncomeValues) {
    actualIncomeValues.forEach((key, currencyValue) {
      CurrencyValue prevIncome = prevMonthIncomeValues[key];
      if (prevIncome != null) {
        if (prevIncome.value > 0) {
          incomePercentDiff[key] =
              ((currencyValue.value / prevIncome.value - 1) * 100).round();
        } else {
          incomePercentDiff[key] = 100;
        }
      } else {
        incomePercentDiff[key] = 100;
      }
    });
  }

  void calcExpensePercentDiff(
      Map<CurrencyType, CurrencyValue> prevMonthExpenseValues) {
    actualExpenseValues.forEach((key, currencyValue) {
      CurrencyValue prevExpense = prevMonthExpenseValues[key];
      if (prevExpense != null) {
        if (prevExpense.value >= 0) {
          expensePercentDiff[key] =
              ((currencyValue.value / prevExpense.value - 1) * 100).round();
        } else {
          expensePercentDiff[key] = 100;
        }
      } else {
        expensePercentDiff[key] = 100;
      }
    });
  }
}
