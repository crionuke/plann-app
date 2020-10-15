import 'dart:async';
import 'dart:math';

import 'package:path/path.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/emergency_fund_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:plann_app/services/db/models/subject_mode_model.dart';
import 'package:plann_app/services/db/models/value_model.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  Database database;

  Future<void> start() async {
    print("[DbService] starting");
    String path = join(await getDatabasesPath(), "plann_119.db");
//    String path = join(await getDatabasesPath(), "plann.db");
    database =
        await openDatabase(path, version: 2, onConfigure: (database) async {
      await database.execute("PRAGMA foreign_keys = ON");
    }, onOpen: (database) async {
      database = database;
      print("[DbService] opened");
    }, onCreate: (database, version) async {
      // Version 1
      if (version >= 1) {
        await database.execute(IncomeModel.createTableSql);
        await database.execute(PlannedIncomeModel.createTableSql);
        await database.execute(ExpenseModel.createTableSql);
        await database.execute(PlannedExpenseModel.createTableSql);
        await database.execute(IrregularModel.createTableSql);
        await database.execute(PlannedIrregularModel.createTableSql);
      }
      if (version >= 2) {
        await database.execute(ValueModel.createTableSql);
        await database.execute(EmergencyFundModel.createTableSql);
      }
//      await fill(txn);
      print("[DbService] version $version created");
    }, onUpgrade: (database, oldVersion, newVersion) async {
      if (oldVersion < 2 && newVersion >= 2) {
        print("[DbService] upgrade from 1 to 2");
        await database.execute(ValueModel.createTableSql);
        await database.execute(EmergencyFundModel.createTableSql);
      }
    });
  }

  // Income CRUD operations

  Future<int> addIncome(IncomeModel incomeModel) async {
    return await database.insert(IncomeModel.INCOME_TABLE, incomeModel.toMap());
  }

  Future<void> editIncome(int id, IncomeModel incomeModel) async {
    await database.update(IncomeModel.INCOME_TABLE, incomeModel.toMap(),
        where: '${IncomeModel.INCOME_ID_V1}=?', whereArgs: [id]);
  }

  Future<void> deleteIncome(int id) async {
    await database.delete(IncomeModel.INCOME_TABLE,
        where: '${IncomeModel.INCOME_ID_V1}=?', whereArgs: [id]);
  }

  Future<List<IncomeModel>> getIncomeList() async {
    List<Map<String, dynamic>> results = await database.query(
        IncomeModel.INCOME_TABLE,
        orderBy: "${IncomeModel.INCOME_DATE_TS_V1} DESC");
    return results.isNotEmpty
        ? results.map((map) => IncomeModel.fromMap(map)).toList()
        : [];
  }

  Future<int> addPlannedIncome(PlannedIncomeModel model) async {
    Map<String, dynamic> values = model.toMap();
    print("[DbService] insert " + values.toString());
    return database.insert(PlannedIncomeModel.PLANNED_INCOME_TABLE, values);
  }

  Future<void> editPlannedIncome(int id, PlannedIncomeModel model) async {
    database.update(PlannedIncomeModel.PLANNED_INCOME_TABLE, model.toMap(),
        where: '${PlannedIncomeModel.PLANNED_INCOME_ID_V1}=?', whereArgs: [id]);
  }

  Future<void> deletePlannedIncome(int id) async {
    database.delete(PlannedIncomeModel.PLANNED_INCOME_TABLE,
        where: '${PlannedIncomeModel.PLANNED_INCOME_ID_V1}=?', whereArgs: [id]);
  }

  Future<List<PlannedIncomeModel>> getPlannedIncomeList() async {
    List<Map<String, dynamic>> results = await database.query(
        PlannedIncomeModel.PLANNED_INCOME_TABLE,
        orderBy: "${PlannedIncomeModel.PLANNED_INCOME_DATE_TS_V1} ASC");
    return results.isNotEmpty
        ? results.map((map) => PlannedIncomeModel.fromMap(map)).toList()
        : [];
  }

  // Expense CRUD operations

  Future<int> addExpense(ExpenseModel model) async {
    return database.insert(ExpenseModel.EXPENSE_TABLE, model.toMap());
  }

  Future<void> editExpense(int id, ExpenseModel model) async {
    database.update(ExpenseModel.EXPENSE_TABLE, model.toMap(),
        where: '${ExpenseModel.EXPENSE_ID_V1}=?', whereArgs: [id]);
  }

  Future<void> deleteExpense(int id) async {
    database.delete(ExpenseModel.EXPENSE_TABLE,
        where: '${ExpenseModel.EXPENSE_ID_V1}=?', whereArgs: [id]);
  }

  Future<List<ExpenseModel>> getExpenseList() async {
    List<Map<String, dynamic>> results = await database.query(
        ExpenseModel.EXPENSE_TABLE,
        orderBy: "${ExpenseModel.EXPENSE_DATE_TS_V1} DESC");
    return results.isNotEmpty
        ? results.map((map) => ExpenseModel.fromMap(map)).toList()
        : [];
  }

  Future<int> addPlannedExpense(PlannedExpenseModel model) async {
    return database.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE, model.toMap());
  }

  Future<void> editPlannedExpense(int id, PlannedExpenseModel model) async {
    database.update(PlannedExpenseModel.PLANNED_EXPENSE_TABLE, model.toMap(),
        where: '${PlannedExpenseModel.PLANNED_EXPENSE_ID_V1}=?',
        whereArgs: [id]);
  }

  Future<void> deletePlannedExpense(int id) async {
    database.delete(PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        where: '${PlannedExpenseModel.PLANNED_EXPENSE_ID_V1}=?',
        whereArgs: [id]);
  }

  Future<List<PlannedExpenseModel>> getPlannedExpenseList() async {
    List<Map<String, dynamic>> results = await database.query(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        orderBy: "${PlannedExpenseModel.PLANNED_EXPENSE_VALUE_V1} ASC");
    return results.isNotEmpty
        ? results.map((map) => PlannedExpenseModel.fromMap(map)).toList()
        : [];
  }

  // Irregular CRUD operations

  Future<int> addIrregular(IrregularModel model) async {
    return database.insert(IrregularModel.IRREGULAR_TABLE, model.toMap());
  }

  Future<int> addPlannedIrregular(PlannedIrregularModel model) async {
    return database.insert(
        PlannedIrregularModel.PLANNED_IRREGULAR_TABLE, model.toMap());
  }

  Future<void> editIrregular(int id, IrregularModel model) async {
    database.update(IrregularModel.IRREGULAR_TABLE, model.toMap(),
        where: '${IrregularModel.IRREGULAR_ID_V1}=?', whereArgs: [id]);
  }

  Future<void> editPlannedIrregular(int id, PlannedIrregularModel model) async {
    database.update(
        PlannedIrregularModel.PLANNED_IRREGULAR_TABLE, model.toMap(),
        where: '${PlannedIrregularModel.PLANNED_IRREGULAR_ID_V1}=?',
        whereArgs: [id]);
  }

  Future<void> deleteIrregular(int id) async {
    database.delete(IrregularModel.IRREGULAR_TABLE,
        where: '${IrregularModel.IRREGULAR_ID_V1}=?', whereArgs: [id]);
  }

  Future<void> deletePlannedIrregular(int id) async {
    database.delete(PlannedIrregularModel.PLANNED_IRREGULAR_TABLE,
        where: '${PlannedIrregularModel.PLANNED_IRREGULAR_ID_V1}=?',
        whereArgs: [id]);
  }

  Future<List<IrregularModel>> getIrregularList() async {
    List<Map<String, dynamic>> results = await database.query(
        IrregularModel.IRREGULAR_TABLE,
        orderBy: "${IrregularModel.IRREGULAR_DATE_TS_V1} DESC");
    return results.isNotEmpty
        ? results.map((map) => IrregularModel.fromMap(map)).toList()
        : [];
  }

  Future<List<PlannedIrregularModel>> getPlannedIrregularList() async {
    List<Map<String, dynamic>> results = await database.query(
        PlannedIrregularModel.PLANNED_IRREGULAR_TABLE,
        orderBy: "${PlannedIrregularModel.PLANNED_IRREGULAR_DATE_TS_V1} ASC");
    return results.isNotEmpty
        ? results.map((map) => PlannedIrregularModel.fromMap(map)).toList()
        : [];
  }

  // Value CRUD operations

  Future<int> addValue(ValueModel model) async {
    return database.insert(ValueModel.VALUE_TABLE, model.toMap());
  }

  Future<void> editValue(String key, ValueModel model) async {
    database.update(ValueModel.VALUE_TABLE, model.toMap(),
        where: '${ValueModel.VALUE_KEY_V1}=?', whereArgs: [key]);
  }

  Future<void> deleteValue(String key) async {
    database.delete(ValueModel.VALUE_TABLE,
        where: '${ValueModel.VALUE_KEY_V1}=?', whereArgs: [key]);
  }

  Future<Map<String, String>> getAllValues() async {
    List<Map<String, dynamic>> results =
        await database.query(ValueModel.VALUE_TABLE);
    Map<String, String> map = {};
    results.forEach((value) =>
        map[value[ValueModel.VALUE_KEY_V1]] = value[ValueModel.VALUE_VALUE_V1]);
    return map;
  }

  // Emergency fund CRUD operations

  Future<int> addEmergencyFund(EmergencyFundModel model) async {
    return database.insert(
        EmergencyFundModel.EMERGENY_FUND_TABLE, model.toMap());
  }

  Future<void> editEmergencyFund(int id, EmergencyFundModel model) async {
    database.update(EmergencyFundModel.EMERGENY_FUND_TABLE, model.toMap(),
        where: '${EmergencyFundModel.EMERGENCY_FUND_ID_V1}=?', whereArgs: [id]);
  }

  Future<void> deleteEmergencyFund(int id) async {
    database.delete(EmergencyFundModel.EMERGENY_FUND_TABLE,
        where: '${EmergencyFundModel.EMERGENCY_FUND_ID_V1}=?', whereArgs: [id]);
  }

  Future<List<EmergencyFundModel>> getEmergencyFundList() async {
    List<Map<String, dynamic>> results = await database.query(
        EmergencyFundModel.EMERGENY_FUND_TABLE,
        orderBy: "${EmergencyFundModel.EMERGENCY_FUND_START_DATE_TS_V1} DESC");
    return results.isNotEmpty
        ? results.map((map) => EmergencyFundModel.fromMap(map)).toList()
        : [];
  }

  // Test dataset

  Future<void> fill(txn) async {
    var random = Random();

    for (int monthIndex = 1; monthIndex <= 9; monthIndex++) {
      // Авансы
      await txn.insert(
          IncomeModel.INCOME_TABLE,
          IncomeModel(
                  null,
                  45000,
                  CurrencyType.rubles,
                  DateTime(2020, monthIndex, 20),
                  IncomeCategoryType.prepaid,
                  "Работа")
              .toMap());
      // Зарплаты
      await txn.insert(
          IncomeModel.INCOME_TABLE,
          IncomeModel(
                  null,
                  127500,
                  CurrencyType.rubles,
                  DateTime(2020, monthIndex, 5),
                  IncomeCategoryType.salary,
                  "Работа")
              .toMap());
      // Рента
      await txn.insert(
          IncomeModel.INCOME_TABLE,
          IncomeModel(
                  null,
                  32500,
                  CurrencyType.rubles,
                  DateTime(2020, monthIndex, 11),
                  IncomeCategoryType.rent,
                  "Арнендная плата")
              .toMap());
      for (int i = 0; i < random.nextInt(2); i++) {
        await txn.insert(
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
    }

    // Плановые доходы
    await txn.insert(
        PlannedIncomeModel.PLANNED_INCOME_TABLE,
        PlannedIncomeModel(
                null,
                30000,
                CurrencyType.rubles,
                SubjectModeType.monthly,
                DateTime.now(),
                IncomeCategoryType.prepaid,
                "Работа")
            .toMap());
    await txn.insert(
        PlannedIncomeModel.PLANNED_INCOME_TABLE,
        PlannedIncomeModel(
                null,
                57000,
                CurrencyType.rubles,
                SubjectModeType.monthly,
                DateTime.now(),
                IncomeCategoryType.salary,
                "Работа")
            .toMap());

    // Плановые расходы
    await txn.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 27000, CurrencyType.rubles,
                ExpenseCategoryType.house, "Аренда")
            .toMap());
    await txn.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 4000, CurrencyType.rubles,
                ExpenseCategoryType.house, "Коммунальные платежи")
            .toMap());
    await txn.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 1000, CurrencyType.rubles,
                ExpenseCategoryType.it, "Связь и интернет")
            .toMap());
    await txn.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 10000, CurrencyType.rubles,
                ExpenseCategoryType.shops, "Еда")
            .toMap());
    await txn.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 5000, CurrencyType.rubles,
                ExpenseCategoryType.clothes, "")
            .toMap());
    await txn.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(null, 5500, CurrencyType.rubles,
                ExpenseCategoryType.auto, "Бензин")
            .toMap());
    await txn.insert(
        PlannedExpenseModel.PLANNED_EXPENSE_TABLE,
        PlannedExpenseModel(
                null, 7000, CurrencyType.rubles, ExpenseCategoryType.fun, "")
            .toMap());

    // Расходы
    for (int monthIndex = 1; monthIndex <= 9; monthIndex++) {
      await txn.insert(
          ExpenseModel.EXPENSE_TABLE,
          ExpenseModel(
                  null,
                  27000,
                  CurrencyType.rubles,
                  DateTime(2020, monthIndex, 11),
                  ExpenseCategoryType.house,
                  "Аренда")
              .toMap());
      await txn.insert(
          ExpenseModel.EXPENSE_TABLE,
          ExpenseModel(
                  null,
                  3000 + random.nextInt(2000),
                  CurrencyType.rubles,
                  DateTime(2020, monthIndex, 5 + random.nextInt(5)),
                  ExpenseCategoryType.house,
                  "Коммунальные платежи")
              .toMap());

      for (int randomIndex = 0; randomIndex <= 80; randomIndex++) {
        await txn.insert(
            ExpenseModel.EXPENSE_TABLE,
            ExpenseModel(
                    null,
                    1000 + random.nextInt(1000),
                    CurrencyType.rubles,
                    DateTime(2020, monthIndex, random.nextInt(28)),
                    ExpenseCategoryType.values[
                        random.nextInt(ExpenseCategoryType.values.length)],
                    "")
                .toMap());
      }
    }

    // Плановые нерегулярные расходы
    await txn.insert(
        PlannedIrregularModel.PLANNED_IRREGULAR_TABLE,
        PlannedIrregularModel(null, DateTime(2020, 1, 13), 25000,
                CurrencyType.rubles, "Кофе-машина", DateTime(2020, 5, 7))
            .toMap());
    await txn.insert(
        PlannedIrregularModel.PLANNED_IRREGULAR_TABLE,
        PlannedIrregularModel(null, DateTime(2020, 2, 27), 90000,
                CurrencyType.rubles, "Отпуск", DateTime(2020, 10, 10))
            .toMap());
    await txn.insert(
        PlannedIrregularModel.PLANNED_IRREGULAR_TABLE,
        PlannedIrregularModel(null, DateTime(2020, 4, 14), 30000,
                CurrencyType.rubles, "Новый год", DateTime(2020, 12, 31))
            .toMap());
    await txn.insert(
        PlannedIrregularModel.PLANNED_IRREGULAR_TABLE,
        PlannedIrregularModel(null, DateTime(2020, 4, 16), 80000,
                CurrencyType.rubles, "Новый компьютер", DateTime(2020, 9, 1))
            .toMap());

    // Нерегулярные расходы
    await txn.insert(
        IrregularModel.IRREGULAR_TABLE,
        IrregularModel(null, 24990, CurrencyType.rubles, "Кофе-машина",
                DateTime(2020, 5, 6))
            .toMap());
  }
}
