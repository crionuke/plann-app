import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';

class IncomeModel {
  static const INCOME_TABLE = "income";

  static const INCOME_ID_V1 = "income_id";
  static const INCOME_VALUE_V1 = "income_value";
  static const INCOME_CURRENCY_V1 = "income_currency";
  static const INCOME_DATE_TS_V1 = "income_date_ts";
  static const INCOME_CATEGORY_V1 = "income_category";
  static const INCOME_COMMENT_V1 = "income_comment";

  static const String createTableSql = "CREATE TABLE $INCOME_TABLE ("
      "$INCOME_ID_V1 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "$INCOME_VALUE_V1 REAL NOT NULL, "
      "$INCOME_CURRENCY_V1 TEXT NOT NULL, "
      "$INCOME_DATE_TS_V1 INTEGER NOT NULL,"
      "$INCOME_CATEGORY_V1 TEXT NOT NULL, "
      "$INCOME_COMMENT_V1 TEXT NOT NULL)";

  final int id;
  final num value;
  final CurrencyType currency;
  final DateTime date;
  final IncomeCategoryType category;
  final String comment;

  IncomeModel(this.id, this.value, this.currency, this.date, this.category,
      this.comment);

  factory IncomeModel.fromMap(Map<String, dynamic> map) => IncomeModel(
      map[INCOME_ID_V1],
      map[INCOME_VALUE_V1],
      CURRENCY_FROM_DB_MAPPING[map[INCOME_CURRENCY_V1]],
      DateTime.fromMillisecondsSinceEpoch(map[INCOME_DATE_TS_V1]),
      INCOME_CATEGORY_FROM_DB_MAPPING[map[INCOME_CATEGORY_V1]],
      map[INCOME_COMMENT_V1] != null ? map[INCOME_COMMENT_V1] : "");

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[INCOME_ID_V1] = id;
    }

    map[INCOME_VALUE_V1] = value;
    map[INCOME_CURRENCY_V1] = CURRENCY_TO_DB_MAPPING[currency];
    map[INCOME_DATE_TS_V1] = date.millisecondsSinceEpoch;
    map[INCOME_CATEGORY_V1] = INCOME_CATEGORY_TO_DB_MAPPING[category];

    if (comment != null) {
      map[INCOME_COMMENT_V1] = comment;
    } else {
      map[INCOME_COMMENT_V1] = "";
    }

    return map;
  }
}
