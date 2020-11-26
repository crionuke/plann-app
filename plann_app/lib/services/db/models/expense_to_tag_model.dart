class ExpenseToTagModel {
  static const TABLE = "expense_to_tag";

  static const EXPENSE_TO_TAG_ID_V1 = "expense_to_tag_id";
  static const EXPENSE_ID_V1 = "expense_id";
  static const TAG_ID_V1 = "tag_id";

  static const String createTableSql = "CREATE TABLE IF NOT EXISTS $TABLE ("
      "$EXPENSE_TO_TAG_ID_V1 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "$EXPENSE_ID_V1 INTEGER NOT NULL,"
      "$TAG_ID_V1 INTEGER NOT NULL)";

  final int id;
  final int expenseId;
  final int tagId;

  ExpenseToTagModel(this.id, this.expenseId, this.tagId);

  factory ExpenseToTagModel.fromMap(Map<String, dynamic> map) =>
      ExpenseToTagModel(
          map[EXPENSE_TO_TAG_ID_V1], map[EXPENSE_ID_V1], map[TAG_ID_V1]);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[EXPENSE_TO_TAG_ID_V1] = id;
    }

    map[EXPENSE_ID_V1] = expenseId;
    map[TAG_ID_V1] = tagId;

    return map;
  }
}
