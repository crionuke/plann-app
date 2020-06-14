import 'dart:async';

import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';

class IrregularItemBloc {
  final _controller = StreamController();

  Stream get stream => _controller.stream;

  String _value;
  CurrencyType _currency;
  String _title;
  DateTime _date;

  IrregularItemBloc();

  IrregularItemBloc.from(IrregularModel model) {
    _value = model.value.toString().replaceAll(".0", "");
    _currency = model.currency;
    _title = model.title;
    _date = model.date;
  }

  @override
  void dispose() {
    _controller.close();
  }

  IrregularItemViewState get currentState {
    return IrregularItemViewState(_value, _currency, _title, _date);
  }

  void valueChanged(String value) {
    _value = value;
    _controller.sink.add(currentState);
  }

  void currencyChanged(CurrencyType currency) {
    _currency = currency;
    _controller.sink.add(currentState);
  }

  void titleChanged(String title) {
    _title = title;
    _controller.sink.add(currentState);
  }

  void dateTimeChanged(DateTime dateTime) {
    _date = dateTime;
    _controller.sink.add(currentState);
  }

  bool done() {
    String valueErrorKey;
    if (_value == null || _value.trim() == "") {
      valueErrorKey = "texts.field_empty";
    } else if (num.tryParse(AppValues.prepareToParse(_value)) == null) {
      valueErrorKey = "texts.field_invalid";
    }
    String titleErrorKey =
        _title == null || _title.trim() == "" ? "texts.field_empty" : null;
    String currencyErrorKey = _currency == null ? "texts.field_empty" : null;
    String dateTimeErrorKey = _date == null ? "texts.field_empty" : null;

    IrregularItemViewState state = IrregularItemViewState(
        _value, _currency, _title, _date,
        valueErrorKey: valueErrorKey,
        currencyErrorKey: currencyErrorKey,
        titleErrorKey: titleErrorKey,
        dateTimeErrorKey: dateTimeErrorKey);

    if (state.hasErrors()) {
      _controller.sink.add(state);
      return false;
    } else {
      return true;
    }
  }
}

class IrregularItemViewState {
  final String value;
  final CurrencyType currency;
  final String title;
  final DateTime date;
  final String valueErrorKey;
  final String currencyErrorKey;
  final String titleErrorKey;
  final String dateTimeErrorKey;

  IrregularItemViewState(this.value, this.currency, this.title, this.date,
      {this.valueErrorKey,
      this.currencyErrorKey,
      this.titleErrorKey,
      this.dateTimeErrorKey});

  bool hasErrors() {
    return valueErrorKey != null ||
        currencyErrorKey != null ||
        titleErrorKey != null ||
        dateTimeErrorKey != null;
  }
}
