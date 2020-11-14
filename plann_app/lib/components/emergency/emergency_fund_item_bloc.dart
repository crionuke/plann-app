import 'dart:async';

import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/emergency_fund_model.dart';

class EmergencyFundItemBloc {
  final _controller = StreamController();

  Stream get stream => _controller.stream;

  CurrencyType _currency;
  String _currentValue;
  String _targetValue;
  DateTime _startDate;
  DateTime _finishDate;

  EmergencyFundItemBloc() {
    // Setup default values
    _currency = CurrencyType.rubles;
    _startDate = DateTime.now();
  }

  EmergencyFundItemBloc.from(EmergencyFundModel model) {
    _currency = model.currency;
    _currentValue = AppTexts.prepareToDisplay(model.currentValue);
    _targetValue = AppTexts.prepareToDisplay(model.targetValue);
    _startDate = model.startDate;
    _finishDate = model.finishDate;
  }

  @override
  void dispose() {
    _controller.close();
  }

  EmergencyFundItemViewState get currentState {
    return EmergencyFundItemViewState(
        _currency, _currentValue, _targetValue, _startDate, _finishDate);
  }

  void currencyChanged(CurrencyType currency) {
    _currency = currency;
    _controller.sink.add(currentState);
  }

  void currentValueChanged(String currentValue) {
    _currentValue = currentValue;
    _controller.sink.add(currentState);
  }

  void targetValueChanged(String targetValue) {
    _targetValue = targetValue;
    _controller.sink.add(currentState);
  }

  void startDateChanged(DateTime startDate) {
    _startDate = startDate;
    _controller.sink.add(currentState);
  }

  void finishDateChanged(DateTime finishDate) {
    _finishDate = finishDate;
    _controller.sink.add(currentState);
  }

  bool done() {
    String currencyErrorKey = _currency == null ? "texts.field_empty" : null;
    String currentValueErrorKey;
    if (_currentValue == null || _currentValue.trim() == "") {
      currentValueErrorKey = "texts.field_empty";
    } else if (num.tryParse(AppTexts.prepareToParse(_currentValue)) == null) {
      currentValueErrorKey = "texts.field_invalid";
    }
    String targetValueErrorKey;
    if (_targetValue == null || _targetValue.trim() == "") {
      targetValueErrorKey = "texts.field_empty";
    } else if (num.tryParse(AppTexts.prepareToParse(_targetValue)) == null) {
      targetValueErrorKey = "texts.field_invalid";
    }
    String startDateErrorKey = _startDate == null ? "texts.field_empty" : null;
    String finishDateErrorKey =
        _finishDate == null ? "texts.field_empty" : null;

    EmergencyFundItemViewState state = EmergencyFundItemViewState(
        _currency, _currentValue, _targetValue, _startDate, _finishDate,
        currencyErrorKey: currencyErrorKey,
        currentValueErrorKey: currentValueErrorKey,
        targetValueErrorKey: targetValueErrorKey,
        startDateErrorKey: startDateErrorKey,
        finishDateErrorKey: finishDateErrorKey);

    if (state.hasErrors()) {
      _controller.sink.add(state);
      return false;
    } else {
      return true;
    }
  }
}

class EmergencyFundItemViewState {
  final CurrencyType currency;
  final String currentValue;
  final String targetValue;
  final DateTime startDate;
  final DateTime finishDate;

  final String currencyErrorKey;
  final String currentValueErrorKey;
  final String targetValueErrorKey;
  final String startDateErrorKey;
  final String finishDateErrorKey;

  EmergencyFundItemViewState(this.currency, this.currentValue, this.targetValue,
      this.startDate, this.finishDate,
      {this.currencyErrorKey,
      this.currentValueErrorKey,
      this.targetValueErrorKey,
      this.startDateErrorKey,
      this.finishDateErrorKey});

  bool hasErrors() {
    return currencyErrorKey != null ||
        currentValueErrorKey != null ||
        targetValueErrorKey != null ||
        startDateErrorKey != null ||
        finishDateErrorKey != null;
  }
}
