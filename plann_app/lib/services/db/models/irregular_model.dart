import 'package:plann_app/services/db/models/currency_model.dart';

class IrregularModel {
  static const IRREGULAR_TABLE = "irregular";

  static const IRREGULAR_ID_V1 = "irregular_id";
  static const IRREGULAR_VALUE_V1 = "irregular_value";
  static const IRREGULAR_CURRENCY_V1 = "irregular_currency";
  static const IRREGULAR_TITLE_V1 = "irregular_title";
  static const IRREGULAR_DATE_TS_V1 = "irregular_date_ts";

  static const String createTableSql = "CREATE TABLE $IRREGULAR_TABLE ("
      "$IRREGULAR_ID_V1 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "$IRREGULAR_VALUE_V1 REAL NOT NULL, "
      "$IRREGULAR_CURRENCY_V1 TEXT NOT NULL, "
      "$IRREGULAR_TITLE_V1 TEXT NOT NULL, "
      "$IRREGULAR_DATE_TS_V1 INTEGER NOT NULL)";

  final int id;
  final num value;
  final CurrencyType currency;
  final String title;
  final DateTime date;

  IrregularModel(this.id, this.value, this.currency, this.title, this.date);

  factory IrregularModel.fromMap(Map<String, dynamic> map) => IrregularModel(
      map[IRREGULAR_ID_V1],
      map[IRREGULAR_VALUE_V1],
      CURRENCY_FROM_DB_MAPPING[map[IRREGULAR_CURRENCY_V1]],
      map[IRREGULAR_TITLE_V1],
      DateTime.fromMillisecondsSinceEpoch(map[IRREGULAR_DATE_TS_V1]));

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[IRREGULAR_ID_V1] = id;
    }

    map[IRREGULAR_VALUE_V1] = value;
    map[IRREGULAR_CURRENCY_V1] = CURRENCY_TO_DB_MAPPING[currency];
    map[IRREGULAR_TITLE_V1] = title;
    map[IRREGULAR_DATE_TS_V1] = date.millisecondsSinceEpoch;

    return map;
  }
}
