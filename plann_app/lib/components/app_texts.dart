import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/subject_mode_model.dart';

class AppTexts {
  static String upFirstLetter(String string) {
    if (string.length == 0) {
      return string;
    } else if (string.length == 1) {
      return "${string[0].toUpperCase()}";
    } else {
      return "${string[0].toUpperCase()}${string.substring(1)}";
    }
  }

  static String formatCurrencyMap(
      BuildContext context, Map<CurrencyType, double> currencyMap,
      {String prefix = ""}) {
    if (currencyMap.isNotEmpty) {
      return currencyMap
          .map((key, value) => MapEntry<CurrencyType, String>(
              key, AppTexts.formatCurrencyValue(context, key, value)))
          .values
          .map((value) => prefix + value)
          .join(", ");
    } else {
      return "0";
    }
  }

  static String formatPercentMap(
      BuildContext context, Map<CurrencyType, int> percentMap) {
    if (percentMap.isNotEmpty) {
      return percentMap
          .map((key, value) => MapEntry<CurrencyType, String>(key, "${value}%"))
          .values
          .join(", ");
    } else {
      return "0";
    }
  }

  static String mergeCurrencyAndPercentMap(BuildContext context,
      Map<CurrencyType, double> currencyMap, Map<CurrencyType, int> percentMap,
      {String prefix = ""}) {
    if (currencyMap.isNotEmpty) {
      return currencyMap
          .map((key, value) => MapEntry<CurrencyType, String>(
              key,
              AppTexts.formatCurrencyValue(context, key, value) +
                  " (" +
                  (percentMap[key] > 0
                      ? "+" + percentMap[key].toString()
                      : percentMap[key].toString()) +
                  "%)"))
          .values
          .map((value) => prefix + value)
          .join(", ");
    } else {
      return "0";
    }
  }

  static String formatDate(BuildContext context, DateTime dateTime) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat format = DateFormat.yMMMMd(locale.toString());
    return format.format(dateTime.toLocal()).toString();
  }

  static String formatMonth(BuildContext context, DateTime dateTime) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat format = DateFormat.MMMM(locale.toString());
    return format.format(dateTime.toLocal()).toString();
  }

  static String formatDateTime(BuildContext context, DateTime dateTime) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat format = DateFormat("yMMMMd", locale.toString()).add_jms();
    return format.format(dateTime.toLocal()).toString();
  }

  static String formatCurrencyType(CurrencyType type) {
    switch (type) {
      case (CurrencyType.rubles):
        return "₽";
      case (CurrencyType.euro):
        return "€";
      case (CurrencyType.dollars):
        return "\$";
      default:
        return "UNKNOWN";
    }
  }

  static String formatCurrencyValue(
      BuildContext context, CurrencyType currencyType, num value) {
    return FlutterI18n.translate(
        context, "texts." + currencyType.toString().split(".")[1] + "_value",
        translationParams: {
          "value": AppValues.prepareToDisplay(value)
        });
  }

  static String formatIncomeCategoryType(
      BuildContext context, IncomeCategoryType incomeCategoryType) {
    return FlutterI18n.translate(
        context,
        "income_category_type_enum." +
            incomeCategoryType.toString().split(".")[1]);
  }

  static String formatExpenseCategoryType(
      BuildContext context, ExpenseCategoryType expenseCategoryType) {
    return FlutterI18n.translate(
        context,
        "expense_category_type_enum." +
            expenseCategoryType.toString().split(".")[1]);
  }

  static String formatSubjectModeType(
      BuildContext context, SubjectModeType subjectModeType) {
    return FlutterI18n.translate(context,
        "subject_mode_type_enum." + subjectModeType.toString().split(".")[1]);
  }
}
