import 'package:plann_app/services/db/models/currency_model.dart';

class EmergencyFundModel {
  static const EMERGENY_FUND_TABLE = "e_fund";

  static const EMERGENCY_FUND_ID_V1 = "e_fund_id";
  static const EMERGENCY_FUND_START_DATE_TS_V1 = "e_fund_start_date_ts";
  static const EMERGENCY_FUND_CURRENCY_V1 = "e_fund_currency";
  static const EMERGENCY_FUND_CURRENT_VALUE_V1 = "e_fund_current_value";
  static const EMERGENCY_FUND_TARGET_VALUE_V1 = "e_fund_target_value";
  static const EMERGENCY_FUND_FINISH_DATE_TS_V1 = "e_fund_date_ts";

  static const String createTableSql = "CREATE TABLE $EMERGENY_FUND_TABLE ("
      "$EMERGENCY_FUND_ID_V1 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "$EMERGENCY_FUND_CURRENCY_V1 TEXT NOT NULL, "
      "$EMERGENCY_FUND_CURRENT_VALUE_V1 REAL NOT NULL,"
      "$EMERGENCY_FUND_TARGET_VALUE_V1 REAL NOT NULL, "
      "$EMERGENCY_FUND_START_DATE_TS_V1 INTEGER NOT NULL, "
      "$EMERGENCY_FUND_FINISH_DATE_TS_V1 INTEGER NOT NULL)";

  final int id;
  final CurrencyType currency;
  final num currentValue;
  final num targetValue;
  final DateTime startDate;
  final DateTime finishDate;

  EmergencyFundModel(this.id, this.currency, this.currentValue,
      this.targetValue, this.startDate, this.finishDate);

  factory EmergencyFundModel.fromMap(Map<String, dynamic> map) =>
      EmergencyFundModel(
          map[EMERGENCY_FUND_ID_V1],
          CURRENCY_FROM_DB_MAPPING[map[EMERGENCY_FUND_CURRENCY_V1]],
          map[EMERGENCY_FUND_CURRENT_VALUE_V1],
          map[EMERGENCY_FUND_TARGET_VALUE_V1],
          DateTime.fromMillisecondsSinceEpoch(
              map[EMERGENCY_FUND_START_DATE_TS_V1]),
          DateTime.fromMillisecondsSinceEpoch(
              map[EMERGENCY_FUND_FINISH_DATE_TS_V1]));

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[EMERGENCY_FUND_ID_V1] = id;
    }

    map[EMERGENCY_FUND_CURRENCY_V1] = CURRENCY_TO_DB_MAPPING[currency];
    map[EMERGENCY_FUND_CURRENT_VALUE_V1] = currentValue;
    map[EMERGENCY_FUND_TARGET_VALUE_V1] = targetValue;
    map[EMERGENCY_FUND_START_DATE_TS_V1] = startDate.millisecondsSinceEpoch;
    map[EMERGENCY_FUND_FINISH_DATE_TS_V1] = finishDate.millisecondsSinceEpoch;

    return map;
  }
}
