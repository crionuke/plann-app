import 'dart:math';

import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:plann_app/services/db/models/subject_mode_model.dart';
import 'package:plann_app/services/db/models/tag_model.dart';
import 'package:plann_app/services/db/models/tag_type_model.dart';

class DbTestDataSet {
  // Test dataset

  static Future<void> fill(database) async {
    var random = Random();

    List<String> tickers = [
      "ЛСР",
      "НЛМК",
      "МТС",
      "Московская биржа",
      "ФосАгро",
      "Юнипро"
    ];

    // Income
    for (int monthIndex = 1; monthIndex <= 11; monthIndex++) {
      // Prepaid
      await database.insert(
          IncomeModel.INCOME_TABLE,
          IncomeModel(
                  null,
                  45000,
                  CurrencyType.rubles,
                  DateTime(2020, monthIndex, 20),
                  IncomeCategoryType.prepaid,
                  "Работа")
              .toMap());
      // Salary
      await database.insert(
          IncomeModel.INCOME_TABLE,
          IncomeModel(
                  null,
                  100500 + random.nextInt(60000),
                  CurrencyType.rubles,
                  DateTime(2020, monthIndex, 5),
                  IncomeCategoryType.salary,
                  "Работа")
              .toMap());
      // Rent
      await database.insert(
          IncomeModel.INCOME_TABLE,
          IncomeModel(
                  null,
                  32500,
                  CurrencyType.rubles,
                  DateTime(2020, monthIndex, 11),
                  IncomeCategoryType.rent,
                  "Арнендная плата")
              .toMap());
      // Deposits
      for (int i = 0; i < random.nextInt(2); i++) {
        await database.insert(
            IncomeModel.INCOME_TABLE,
            IncomeModel(
                    null,
                    random.nextInt(4000),
                    CurrencyType.rubles,
                    DateTime(2020, monthIndex, 11),
                    IncomeCategoryType.deposits,
                    "Капитализация вклада, " +
                        (3 + random.nextInt(3)).toString() +
                        "% годовых")
                .toMap());
      }
      for (int i = 0; i < random.nextInt(2); i++) {
        await database.insert(
            IncomeModel.INCOME_TABLE,
            IncomeModel(
                    null,
                    random.nextInt(10000),
                    CurrencyType.rubles,
                    DateTime(2020, monthIndex, 11),
                    IncomeCategoryType.dividends,
                    tickers[random.nextInt(tickers.length)] +
                        ", " +
                        random.nextInt(200).toString() +
                        "р. на 1цб")
                .toMap());
      }
    }

    // Planned income
    await database.insert(
        PlannedIncomeModel.PLANNED_INCOME_TABLE,
        PlannedIncomeModel(
                null,
                45000,
                CurrencyType.rubles,
                SubjectModeType.monthly,
                DateTime.now(),
                IncomeCategoryType.prepaid,
                "Работа")
            .toMap());
    await database.insert(
        PlannedIncomeModel.PLANNED_INCOME_TABLE,
        PlannedIncomeModel(
                null,
                127500,
                CurrencyType.rubles,
                SubjectModeType.monthly,
                DateTime.now(),
                IncomeCategoryType.salary,
                "Работа")
            .toMap());

    // Planned expense
    await database.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 27000, CurrencyType.rubles,
                ExpenseCategoryType.house, "Аренда")
            .toMap());
    await database.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 4000, CurrencyType.rubles,
                ExpenseCategoryType.house, "Коммунальные платежи")
            .toMap());
    await database.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 1000, CurrencyType.rubles,
                ExpenseCategoryType.it, "Связь и интернет")
            .toMap());
    await database.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 10000, CurrencyType.rubles,
                ExpenseCategoryType.shops, "Еда")
            .toMap());
    await database.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 5000, CurrencyType.rubles,
                ExpenseCategoryType.clothes, "")
            .toMap());
    await database.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 5500, CurrencyType.rubles,
                ExpenseCategoryType.auto, "Бензин")
            .toMap());
    await database.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(
                null, 7000, CurrencyType.rubles, ExpenseCategoryType.fun, "")
            .toMap());

    // Expense
    for (int monthIndex = 1; monthIndex <= 11; monthIndex++) {
      await database.insert(
          ExpenseModel.EXPENSE_TABLE,
          ExpenseModel(
                  null,
                  27000,
                  CurrencyType.rubles,
                  DateTime(2020, monthIndex, 11),
                  ExpenseCategoryType.house,
                  "Аренда")
              .toMap());
      await database.insert(
          ExpenseModel.EXPENSE_TABLE,
          ExpenseModel(
                  null,
                  3000 + random.nextInt(2000),
                  CurrencyType.rubles,
                  DateTime(2020, monthIndex, 5 + random.nextInt(5)),
                  ExpenseCategoryType.house,
                  "Коммунальные платежи")
              .toMap());

      int count = 20 + random.nextInt(20);
      for (int randomIndex = 0;
          randomIndex <= count;
          randomIndex++) {
        ExpenseCategoryType category = ExpenseCategoryType
            .values[random.nextInt(ExpenseCategoryType.values.length)];

        String comment = "";
        if (category == ExpenseCategoryType.fun) {
          List<String> values = ["Кино", "Театр", "Концерт"];
          comment = values[random.nextInt(values.length)];
        }

        await database.insert(
            ExpenseModel.EXPENSE_TABLE,
            ExpenseModel(
                    null,
                    1000 + random.nextInt(10000),
                    CurrencyType.rubles,
                    DateTime(2020, monthIndex, random.nextInt(28)),
                    category,
                    comment)
                .toMap());
      }
    }

    await database.insert(TagModel.TABLE,
        TagModel(null, "Отпуск2020", DateTime.now(), TagType.expense).toMap());
    await database.insert(TagModel.TABLE,
        TagModel(null, "НГ2020", DateTime.now(), TagType.expense).toMap());

    await database.insert(TagModel.TABLE,
        TagModel(null, "Сайты", DateTime.now(), TagType.income).toMap());
    await database.insert(TagModel.TABLE,
        TagModel(null, "Телеграм-каналы", DateTime.now(), TagType.income)
            .toMap());

    // Planned irregular
    await database.insert(
        PlannedIrregularModel.PLANNED_IRREGULAR_TABLE,
        PlannedIrregularModel(null, DateTime(2020, 1, 13), 25000,
                CurrencyType.rubles, "Кофе-машина", DateTime(2020, 5, 7))
            .toMap());
    await database.insert(
        PlannedIrregularModel.PLANNED_IRREGULAR_TABLE,
        PlannedIrregularModel(null, DateTime(2020, 2, 27), 90000,
                CurrencyType.rubles, "Отпуск", DateTime(2020, 10, 10))
            .toMap());
    await database.insert(
        PlannedIrregularModel.PLANNED_IRREGULAR_TABLE,
        PlannedIrregularModel(null, DateTime(2020, 4, 14), 30000,
                CurrencyType.rubles, "Новый год", DateTime(2020, 12, 31))
            .toMap());
    await database.insert(
        PlannedIrregularModel.PLANNED_IRREGULAR_TABLE,
        PlannedIrregularModel(null, DateTime(2020, 4, 16), 80000,
                CurrencyType.rubles, "Компьютер", DateTime(2020, 9, 1))
            .toMap());

    // Actual Irregular
    await database.insert(
        IrregularModel.IRREGULAR_TABLE,
        IrregularModel(null, 24990, CurrencyType.rubles, "Кофе-машина",
                DateTime(2020, 5, 6))
            .toMap());
  }
}
