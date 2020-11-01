import 'dart:core';

import 'package:plann_app/services/analytics/analytics_utils.dart';
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';

class AnalyticsAccount<T> {
  Map<CurrencyType, CurrencyValue> debet;
  Map<CurrencyType, CurrencyValue> credit;
  Map<CurrencyType, CurrencyValue> balance;
  Map<T, CurrencyValue> values;

  AnalyticsAccount() {
    debet = Map();
    credit = Map();
    balance = Map();
    values = Map();
  }

  void addDebetValue(T item, CurrencyValue currencyValue) {
    AnalyticsUtils.addValueToCurrencyMap(debet, currencyValue);
    values[item] = currencyValue;
  }

  void addCreditValue(CurrencyValue currencyValue) {
    AnalyticsUtils.addValueToCurrencyMap(credit, currencyValue);
  }

  double debetInDefaultCurrency() {
    double total = 0;
    values.values
        .forEach((currencyValue) => total += currencyValue.valueInDefaultValue);
    return total;
  }

  Map<CurrencyType, CurrencyValue> calcBalance(
      Map<CurrencyType, CurrencyValue> prevMonthBalance) {
    balance = AnalyticsUtils.addCurrencyMap(prevMonthBalance, debet);
    balance = AnalyticsUtils.subCurrencyMap(balance, credit);
    return balance;
  }
}
