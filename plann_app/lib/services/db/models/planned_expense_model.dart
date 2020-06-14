import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';

class PlannedExpenseModel {
  static const PLANNED_EXPENSE_TABLE = "p_expense";

  static const PLANNED_EXPENSE_ID_V1 = "p_expense_id";
  static const PLANNED_EXPENSE_VALUE_V1 = "p_expense_value";
  static const PLANNED_EXPENSE_CURRENCY_V1 = "p_expense_currency";
  static const PLANNED_EXPENSE_CATEGORY_V1 = "p_expense_category";
  static const PLANNED_EXPENSE_COMMENT_V1 = "p_expense_comment";

  static const String createTableSql = "CREATE TABLE $PLANNED_EXPENSE_TABLE ("
      "$PLANNED_EXPENSE_ID_V1 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "$PLANNED_EXPENSE_VALUE_V1 REAL NOT NULL, "
      "$PLANNED_EXPENSE_CURRENCY_V1 TEXT NOT NULL, "
      "$PLANNED_EXPENSE_CATEGORY_V1 TEXT NOT NULL, "
      "$PLANNED_EXPENSE_COMMENT_V1 TEXT NOT NULL)";

  final int id;
  final num value;
  final CurrencyType currency;
  final ExpenseCategoryType category;
  final String comment;

  PlannedExpenseModel(
      this.id, this.value, this.currency, this.category, this.comment);

  factory PlannedExpenseModel.fromMap(Map<String, dynamic> map) =>
      PlannedExpenseModel(
          map[PLANNED_EXPENSE_ID_V1],
          map[PLANNED_EXPENSE_VALUE_V1],
          CURRENCY_FROM_DB_MAPPING[map[PLANNED_EXPENSE_CURRENCY_V1]],
          EXPENSE_CATEGORY_FROM_DB_MAPPING[map[PLANNED_EXPENSE_CATEGORY_V1]],
          map[PLANNED_EXPENSE_COMMENT_V1] != null
              ? map[PLANNED_EXPENSE_COMMENT_V1]
              : "");

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[PLANNED_EXPENSE_ID_V1] = id;
    }

    map[PLANNED_EXPENSE_VALUE_V1] = value;
    map[PLANNED_EXPENSE_CURRENCY_V1] = CURRENCY_TO_DB_MAPPING[currency];
    map[PLANNED_EXPENSE_CATEGORY_V1] = EXPENSE_CATEGORY_TO_DB_MAPPING[category];

    if (comment != null) {
      map[PLANNED_EXPENSE_COMMENT_V1] = comment;
    } else {
      map[PLANNED_EXPENSE_COMMENT_V1] = "";
    }

    return map;
  }
}
