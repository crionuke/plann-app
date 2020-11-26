class ValueModel {
  static const VALUE_TABLE = "value";

  static const VALUE_ID_V1 = "value_id";
  static const VALUE_KEY_V1 = "value_key";
  static const VALUE_VALUE_V1 = "value_value";

  static const String createTableSql = "CREATE TABLE IF NOT EXISTS $VALUE_TABLE ("
      "$VALUE_ID_V1 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "$VALUE_KEY_V1 TEXT NOT NULL, "
      "$VALUE_VALUE_V1 TEXT NOT NULL)";

  final int id;
  final String key;
  final String value;

  ValueModel(this.id, this.key, this.value);

  factory ValueModel.fromMap(Map<String, dynamic> map) => ValueModel(
      map[VALUE_ID_V1],
      map[VALUE_KEY_V1],
      map[VALUE_VALUE_V1]);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[VALUE_ID_V1] = id;
    }

    map[VALUE_KEY_V1] = key;
    map[VALUE_VALUE_V1] = value;

    return map;
  }
}
