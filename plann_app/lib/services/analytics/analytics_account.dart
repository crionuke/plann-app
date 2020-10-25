import 'dart:core';

import 'package:plann_app/services/analytics/analytics_utils.dart';
import 'package:plann_app/services/db/models/currency_model.dart';

class AnalyticsAccount<T> {
  Map<CurrencyType, double> debet;
  Map<CurrencyType, double> credit;
  Map<T, double> values;
  Map<CurrencyType, double> balance;

  AnalyticsAccount() {
    debet = Map();
    credit = Map();
    values = Map();
    balance = Map();
  }

  void addDebetValue(T item, CurrencyType currency, double value) {
    AnalyticsUtils.addValueToCurrencyMap(debet, currency, value);
    values[item] = value;
  }

  void addCreditValue(CurrencyType currency, double value) {
    AnalyticsUtils.addValueToCurrencyMap(credit, currency, value);
  }

  double debetPerCurrency(CurrencyType currency) {
    double total = 0;
    debet.forEach((key, value) {
      if (key == currency) {
        total += value;
      }
    });
    return total;
  }

  Map<CurrencyType, double> calcBalance(
      Map<CurrencyType, double> prevMonthBalance) {
    balance = AnalyticsUtils.addCurrencyMap(prevMonthBalance, debet);
    balance = AnalyticsUtils.subCurrencyMap(balance, credit);
    return balance;
  }
}
