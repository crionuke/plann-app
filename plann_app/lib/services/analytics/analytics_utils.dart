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
      DateTime fromDate, DateTime toDate, double value) {
    int monthCount = calcMonthCount(fromDate, toDate);
    if (monthCount == 0) {
      return value;
    } else {
      return value / monthCount;
    }
  }

  static void addValueToCurrencyMap(
      Map<CurrencyType, double> list, CurrencyType currency, double value) {
    if (list[currency] == null) {
      list[currency] = value;
    } else {
      list[currency] += value;
    }
  }

  static Map<CurrencyType, double> addCurrencyMap(
      Map<CurrencyType, double> map1, Map<CurrencyType, double> map2) {
    Map<CurrencyType, double> result = Map();
    map1.forEach((key, value) => result[key] = value);
    map2.forEach(
        (key, value) => result[key] == null ? result[key] = 0 : result[key]);
    map2.forEach((key, value) => result[key] = result[key] + value);
    return result;
  }

  static Map<CurrencyType, double> subCurrencyMap(
      Map<CurrencyType, double> map1, Map<CurrencyType, double> map2) {
    Map<CurrencyType, double> result = Map();
    map1.forEach((key, value) => result[key] = value);
    map2.forEach(
        (key, value) => result[key] == null ? result[key] = 0 : result[key]);
    map2.forEach((key, value) => result[key] = result[key] - value);
    return result;
  }
}
