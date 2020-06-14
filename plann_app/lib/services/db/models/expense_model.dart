import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';

class ExpenseModel {
  static const EXPENSE_TABLE = "expense";

  static const EXPENSE_ID_V1 = "expense_id";
  static const EXPENSE_VALUE_V1 = "expense_value";
  static const EXPENSE_CURRENCY_V1 = "expense_currency";
  static const EXPENSE_DATE_TS_V1 = "expense_date_ts";
  static const EXPENSE_CATEGORY_V1 = "expense_category";
  static const EXPENSE_COMMENT_V1 = "expense_comment";

  static const String createTableSql = "CREATE TABLE $EXPENSE_TABLE ("
      "$EXPENSE_ID_V1 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "$EXPENSE_VALUE_V1 REAL NOT NULL, "
      "$EXPENSE_CURRENCY_V1 TEXT NOT NULL, "
      "$EXPENSE_DATE_TS_V1 INTEGER NOT NULL,"
      "$EXPENSE_CATEGORY_V1 TEXT NOT NULL, "
      "$EXPENSE_COMMENT_V1 TEXT NOT NULL)";

  final int id;
  final num value;
  final CurrencyType currency;
  final DateTime date;
  final ExpenseCategoryType category;
  final String comment;

  ExpenseModel(this.id, this.value, this.currency, this.date, this.category,
      this.comment);

  factory ExpenseModel.fromMap(Map<String, dynamic> map) => ExpenseModel(
      map[EXPENSE_ID_V1],
      map[EXPENSE_VALUE_V1],
      CURRENCY_FROM_DB_MAPPING[map[EXPENSE_CURRENCY_V1]],
      DateTime.fromMillisecondsSinceEpoch(map[EXPENSE_DATE_TS_V1]),
      EXPENSE_CATEGORY_FROM_DB_MAPPING[map[EXPENSE_CATEGORY_V1]],
      map[EXPENSE_COMMENT_V1] != null ? map[EXPENSE_COMMENT_V1] : "");

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[EXPENSE_ID_V1] = id;
    }

    map[EXPENSE_VALUE_V1] = value;
    map[EXPENSE_CURRENCY_V1] = CURRENCY_TO_DB_MAPPING[currency];
    map[EXPENSE_DATE_TS_V1] = date.millisecondsSinceEpoch;
    map[EXPENSE_CATEGORY_V1] = EXPENSE_CATEGORY_TO_DB_MAPPING[category];

    if (comment != null) {
      map[EXPENSE_COMMENT_V1] = comment;
    } else {
      map[EXPENSE_COMMENT_V1] = "";
    }

    return map;
  }
}
