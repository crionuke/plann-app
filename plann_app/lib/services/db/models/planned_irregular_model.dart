import 'package:plann_app/services/db/models/currency_model.dart';

class PlannedIrregularModel {
  static const PLANNED_IRREGULAR_TABLE = "p_irregular";

  static const PLANNED_IRREGULAR_ID_V1 = "p_irregular_id";
  static const PLANNED_IRREGULAR_CREATION_TS_V1 = "p_irregular_creation_ts";
  static const PLANNED_IRREGULAR_VALUE_V1 = "p_irregular_value";
  static const PLANNED_IRREGULAR_CURRENCY_V1 = "p_irregular_currency";
  static const PLANNED_IRREGULAR_TITLE_V1 = "p_irregular_title";
  static const PLANNED_IRREGULAR_DATE_TS_V1 = "p_irregular_date_ts";

  static const String createTableSql = "CREATE TABLE $PLANNED_IRREGULAR_TABLE ("
      "$PLANNED_IRREGULAR_ID_V1 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "$PLANNED_IRREGULAR_CREATION_TS_V1 INTEGER NOT NULL, "
      "$PLANNED_IRREGULAR_VALUE_V1 REAL NOT NULL, "
      "$PLANNED_IRREGULAR_CURRENCY_V1 TEXT NOT NULL, "
      "$PLANNED_IRREGULAR_TITLE_V1 TEXT NOT NULL, "
      "$PLANNED_IRREGULAR_DATE_TS_V1 INTEGER NOT NULL)";

  final int id;
  final DateTime creationDate;
  final num value;
  final CurrencyType currency;
  final String title;
  final DateTime date;

  PlannedIrregularModel(this.id, this.creationDate, this.value, this.currency,
      this.title, this.date);

  factory PlannedIrregularModel.fromMap(Map<String, dynamic> map) =>
      PlannedIrregularModel(
          map[PLANNED_IRREGULAR_ID_V1],
          DateTime.fromMillisecondsSinceEpoch(
              map[PLANNED_IRREGULAR_CREATION_TS_V1]),
          map[PLANNED_IRREGULAR_VALUE_V1],
          CURRENCY_FROM_DB_MAPPING[map[PLANNED_IRREGULAR_CURRENCY_V1]],
          map[PLANNED_IRREGULAR_TITLE_V1],
          DateTime.fromMillisecondsSinceEpoch(
              map[PLANNED_IRREGULAR_DATE_TS_V1]));

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[PLANNED_IRREGULAR_ID_V1] = id;
    }

    map[PLANNED_IRREGULAR_CREATION_TS_V1] = creationDate.millisecondsSinceEpoch;
    map[PLANNED_IRREGULAR_VALUE_V1] = value;
    map[PLANNED_IRREGULAR_CURRENCY_V1] = CURRENCY_TO_DB_MAPPING[currency];
    map[PLANNED_IRREGULAR_TITLE_V1] = title;
    map[PLANNED_IRREGULAR_DATE_TS_V1] = date.millisecondsSinceEpoch;

    return map;
  }
}
