import 'package:plann_app/services/db/models/currency_model.dart';

class CurrencyService {
  Future<void> start() async {
    print("[CurrencyService] starting");
  }

  CurrencyValue exchange(CurrencyType currency, double value) {
    if (currency == CurrencyType.dollars) {
      return CurrencyValue(currency, value, value * 75);
    } else if (currency == CurrencyType.euro) {
      return CurrencyValue(currency, value, value * 90);
    } else {
      return CurrencyValue(currency, value, value);
    }
  }
}

class CurrencyValue {
  final CurrencyType currency;
  final double value;
  final double valueInDefaultValue;

  CurrencyValue(this.currency, this.value, this.valueInDefaultValue);
}