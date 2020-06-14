import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/subject_mode_model.dart';

class PlannedIncomeModel {
  static const PLANNED_INCOME_TABLE = "p_income";

  static const PLANNED_INCOME_ID_V1 = "p_income_id";
  static const PLANNED_INCOME_VALUE_V1 = "p_income_value";
  static const PLANNED_INCOME_CURRENCY_V1 = "p_income_currency";
  static const PLANNED_INCOME_MODE_V1 = "p_income_mode";
  static const PLANNED_INCOME_DATE_TS_V1 = "p_income_date_ts";
  static const PLANNED_INCOME_CATEGORY_V1 = "p_income_category";
  static const PLANNED_INCOME_COMMENT_V1 = "p_income_comment";

  static const String createTableSql = "CREATE TABLE $PLANNED_INCOME_TABLE ("
      "$PLANNED_INCOME_ID_V1 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "$PLANNED_INCOME_VALUE_V1 REAL NOT NULL, "
      "$PLANNED_INCOME_CURRENCY_V1 TEXT NOT NULL, "
      "$PLANNED_INCOME_MODE_V1 TEXT NOT NULL,"
      "$PLANNED_INCOME_DATE_TS_V1 INTEGER NOT NULL,"
      "$PLANNED_INCOME_CATEGORY_V1 TEXT NOT NULL, "
      "$PLANNED_INCOME_COMMENT_V1 TEXT NOT NULL)";

  final int id;
  final num value;
  final CurrencyType currency;
  final DateTime date;
  final SubjectModeType mode;
  final IncomeCategoryType category;
  final String comment;

  PlannedIncomeModel(this.id, this.value, this.currency, this.mode, this.date,
      this.category, this.comment);

  factory PlannedIncomeModel.fromMap(Map<String, dynamic> map) =>
      PlannedIncomeModel(
          map[PLANNED_INCOME_ID_V1],
          map[PLANNED_INCOME_VALUE_V1],
          CURRENCY_FROM_DB_MAPPING[map[PLANNED_INCOME_CURRENCY_V1]],
          SUBJECT_MODE_FROM_DB_MAPPING[map[PLANNED_INCOME_MODE_V1]],
          DateTime.fromMillisecondsSinceEpoch(map[PLANNED_INCOME_DATE_TS_V1]),
          INCOME_CATEGORY_FROM_DB_MAPPING[map[PLANNED_INCOME_CATEGORY_V1]],
          map[PLANNED_INCOME_COMMENT_V1] != null
              ? map[PLANNED_INCOME_COMMENT_V1]
              : "");

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[PLANNED_INCOME_ID_V1] = id;
    }

    map[PLANNED_INCOME_VALUE_V1] = value;
    map[PLANNED_INCOME_CURRENCY_V1] = CURRENCY_TO_DB_MAPPING[currency];
    map[PLANNED_INCOME_MODE_V1] = SUBJECT_MODE_TO_DB_MAPPING[mode];
    map[PLANNED_INCOME_DATE_TS_V1] = date.millisecondsSinceEpoch;
    map[PLANNED_INCOME_CATEGORY_V1] = INCOME_CATEGORY_TO_DB_MAPPING[category];

    if (comment != null) {
      map[PLANNED_INCOME_COMMENT_V1] = comment;
    } else {
      map[PLANNED_INCOME_COMMENT_V1] = "";
    }

    return map;
  }
}
