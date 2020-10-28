import 'dart:core';

import 'package:plann_app/services/analytics/analytics_utils.dart';
import 'package:plann_app/services/db/models/currency_model.dart';

class AnalyticsAccount<T> {
  Map<CurrencyType, double> debet;
  Map<CurrencyType, double> credit;
  Map<CurrencyType, double> balance;
  Map<T, double> valuesInDefaultCurrency;

  AnalyticsAccount() {
    debet = Map();
    credit = Map();
    balance = Map();
    valuesInDefaultCurrency = Map();
  }

  void addDebetValue(T item, CurrencyType currency, double value,
      double valueInDefaultCurrency) {
    AnalyticsUtils.addValueToCurrencyMap(debet, currency, value);
    valuesInDefaultCurrency[item] = valueInDefaultCurrency;
  }

  void addCreditValue(CurrencyType currency, double value) {
    AnalyticsUtils.addValueToCurrencyMap(credit, currency, value);
  }

  double debetInDefaultCurrency() {
    double total = 0;
    valuesInDefaultCurrency.values.forEach((value) => total += value);
    return total;
  }

  Map<CurrencyType, double> calcBalance(
      Map<CurrencyType, double> prevMonthBalance) {
    balance = AnalyticsUtils.addCurrencyMap(prevMonthBalance, debet);
    balance = AnalyticsUtils.subCurrencyMap(balance, credit);
    return balance;
  }
}
