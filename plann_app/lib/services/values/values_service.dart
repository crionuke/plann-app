import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/value_model.dart';

class ValuesService {
  static const VALUE_ABOUT_APP_VIEWED = "about_app_viewed";

  final DbService dbService;

  Map<String, String> values;

  ValuesService(this.dbService);

  Future<void> start() async {
    print("[OptionsService] starting");
    await _refresh();
    print("[OptionsService] values=$values");
  }

  bool isExist(String key) {
    return values.containsKey(key);
  }

  String getValue(String key) {
    return values[key];
  }

  Future<void> addValue(String key, String value) async {
    await dbService.addValue(ValueModel(null, key, value));
    await _refresh();
    print("[OptionsService] add $key=$value");
  }

  Future<void> editValue(String key, String newValue) async {
    await dbService.editValue(key, ValueModel(null, key, newValue));
    await _refresh();
    print("[OptionsService] $key=$newValue now");
  }

  Future<void> deleteValue(String key) async {
    await dbService.deleteValue(key);
    await _refresh();
    print("[OptionsService] $key deleted");
  }

  Future<void> _refresh() async {
    values = await dbService.getAllValues();
  }
}