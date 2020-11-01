import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';

class AnalyticsUtils {
  static int toAbs(int year, int month) {
    return year * 12 + (month - 1);
  }

  static List toHuman(int monthIndex) {
    return [
      // Year
      monthIndex ~/ 12,
      // Month
      monthIndex % 12 + 1,
    ];
  }

  static int calcMonthCount(DateTime fromDate, DateTime toDate) {
    int fromMonthIndex = AnalyticsUtils.toAbs(fromDate.year, fromDate.month);
    int toMonthIndex = AnalyticsUtils.toAbs(toDate.year, toDate.month);
    return toMonthIndex - fromMonthIndex;
  }

  static double calcValuePerMonth(
      DateTime fromDate, DateTime toDate, CurrencyValue currencyValue) {
    int monthCount = calcMonthCount(fromDate, toDate);
    if (monthCount == 0) {
      return currencyValue.valueInDefaultValue;
    } else {
      return currencyValue.valueInDefaultValue / monthCount;
    }
  }

  static Map<CurrencyType, CurrencyValue> addValueToCurrencyMap(
      Map<CurrencyType, CurrencyValue> map, CurrencyValue currencyValue) {
    CurrencyType currency = currencyValue.currency;

    if (map[currency] == null) {
      map[currency] = CurrencyValue(
          currency, currencyValue.value, currencyValue.valueInDefaultValue);
    } else {
      map[currency] = CurrencyValue(
          currency,
          map[currency].value + currencyValue.value,
          map[currency].valueInDefaultValue +
              currencyValue.valueInDefaultValue);
    }
    return map;
  }

  static Map<CurrencyType, CurrencyValue> addCurrencyMap(
      Map<CurrencyType, CurrencyValue> map1,
      Map<CurrencyType, CurrencyValue> map2) {
    Map<CurrencyType, CurrencyValue> result = Map();
    map1.forEach((key, value) => result[key] = value);
    map2.forEach((key, value) => result[key] == null
        ? result[key] = CurrencyValue.zero(key)
        : result[key]);
    map2.forEach((key, value) => result[key] = result[key].add(value));
    return result;
  }

  static Map<CurrencyType, CurrencyValue> subCurrencyMap(
      Map<CurrencyType, CurrencyValue> map1,
      Map<CurrencyType, CurrencyValue> map2) {
    Map<CurrencyType, CurrencyValue> result = Map();
    map1.forEach((key, value) => result[key] = value);
    map2.forEach((key, value) => result[key] == null
        ? result[key] = CurrencyValue.zero(key)
        : result[key]);
    map2.forEach((key, value) => result[key] = result[key].sub(value));
    return result;
  }
}
