import 'dart:async';

import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';

class PlannedIrregularItemBloc {
  final _controller = StreamController();

  Stream get stream => _controller.stream;

  DateTime _creationDate;
  String _value;
  CurrencyType _currency;
  String _title;
  DateTime _date;

  PlannedIrregularItemBloc() {
    // Setup default values
    _creationDate = DateTime.now();
    _currency = CurrencyType.rubles;
  }

  PlannedIrregularItemBloc.from(PlannedIrregularModel model) {
    _creationDate = model.creationDate;
    _value = AppTexts.prepareToDisplay(model.value);
    _currency = model.currency;
    _title = model.title;
    _date = model.date;
  }

  void dispose() {
    _controller.close();
  }

  PlannedIrregularItemViewState get currentState {
    return PlannedIrregularItemViewState(
        _creationDate, _value, _currency, _title, _date);
  }

  void creationDateChanged(DateTime date) {
    _creationDate = date;
    if (_creationDate.compareTo(_date) > 0) {
      _creationDate = _date;
    }
    _controller.sink.add(currentState);
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

  void dateChanged(DateTime date) {
    _date = date;
    if (_date.compareTo(_creationDate) < 0) {
      _date = _creationDate;
    }
    _controller.sink.add(currentState);
  }

  bool done() {
    String creationErrorKey = _creationDate == null ? "texts.field_empty" : null;
    String valueErrorKey;
    if (_value == null || _value.trim() == "") {
      valueErrorKey = "texts.field_empty";
    } else if (num.tryParse(AppTexts.prepareToParse(_value)) == null) {
      valueErrorKey = "texts.field_invalid";
    }
    String titleErrorKey =
        _title == null || _title.trim() == "" ? "texts.field_empty" : null;
    String currencyErrorKey = _currency == null ? "texts.field_empty" : null;
    String dateErrorKey = _date == null ? "texts.field_empty" : null;

    PlannedIrregularItemViewState state = PlannedIrregularItemViewState(
        _creationDate, _value, _currency, _title, _date,
        creationErrorKey: creationErrorKey,
        valueErrorKey: valueErrorKey,
        currencyErrorKey: currencyErrorKey,
        titleErrorKey: titleErrorKey,
        dateErrorKey: dateErrorKey);

    if (state.hasErrors()) {
      _controller.sink.add(state);
      return false;
    } else {
      return true;
    }
  }
}

class PlannedIrregularItemViewState {
  final DateTime creationDate;
  final String value;
  final CurrencyType currency;
  final String title;
  final DateTime date;
  final String creationErrorKey;
  final String valueErrorKey;
  final String currencyErrorKey;
  final String titleErrorKey;
  final String dateErrorKey;

  PlannedIrregularItemViewState(
      this.creationDate, this.value, this.currency, this.title, this.date,
      {this.creationErrorKey,
      this.valueErrorKey,
      this.currencyErrorKey,
      this.titleErrorKey,
      this.dateErrorKey});

  bool hasErrors() {
    return creationErrorKey != null ||
        valueErrorKey != null ||
        currencyErrorKey != null ||
        titleErrorKey != null ||
        dateErrorKey != null;
  }
}
