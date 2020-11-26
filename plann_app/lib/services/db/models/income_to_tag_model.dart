class IncomeToTagModel {
  static const TABLE = "income_to_tag";

  static const INCOME_TO_TAG_ID_V1 = "income_to_tag_id";
  static const INCOME_ID_V1 = "income_id";
  static const TAG_ID_V1 = "tag_id";

  static const String createTableSql = "CREATE TABLE IF NOT EXISTS $TABLE ("
      "$INCOME_TO_TAG_ID_V1 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "$INCOME_ID_V1 INTEGER NOT NULL,"
      "$TAG_ID_V1 INTEGER NOT NULL)";

  final int id;
  final int incomeId;
  final int tagId;

  IncomeToTagModel(this.id, this.incomeId, this.tagId);

  factory IncomeToTagModel.fromMap(Map<String, dynamic> map) =>
      IncomeToTagModel(
          map[INCOME_TO_TAG_ID_V1], map[INCOME_ID_V1], map[TAG_ID_V1]);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[INCOME_TO_TAG_ID_V1] = id;
    }

    map[INCOME_ID_V1] = incomeId;
    map[TAG_ID_V1] = tagId;

    return map;
  }
}
