import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/tag_type_model.dart';

class TagModel {
  static const TABLE = "tag";

  static const TAG_ID_V1 = "tag_id";
  static const TAG_NAME_V1 = "tag_name";
  static const TAG_TS_V1 = "tag_ts";
  static const TAG_TYPE_V1 = "tag_type";

  static const String createTableSql = "CREATE TABLE IF NOT EXISTS $TABLE ("
      "$TAG_ID_V1 INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
      "$TAG_NAME_V1 TEXT NOT NULL UNIQUE, "
      "$TAG_TS_V1 INTEGER NOT NULL,"
      "$TAG_TYPE_V1 TEXT NOT NULL)";

  final int id;
  final String name;
  final DateTime timestamp;
  final TagType type;

  TagModel(this.id, this.name, this.timestamp, this.type);

  factory TagModel.fromMap(Map<String, dynamic> map) => TagModel(
      map[TAG_ID_V1],
      map[TAG_NAME_V1],
      DateTime.fromMillisecondsSinceEpoch(map[TAG_TS_V1]),
      TAG_TYPE_FROM_DB_MAPPING[map[TAG_TYPE_V1]]);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (id != null) {
      map[TAG_ID_V1] = id;
    }

    map[TAG_NAME_V1] = name;
    map[TAG_TS_V1] = timestamp.millisecondsSinceEpoch;
    map[TAG_TYPE_V1] = TAG_TYPE_TO_DB_MAPPING[type];

    return map;
  }
}
