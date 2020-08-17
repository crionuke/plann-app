import 'dart:async';

import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/subject_mode_model.dart';

class PlannedIncomeItemBloc {
  final _controller = StreamController();

  Stream get stream => _controller.stream;

  String _value;
  CurrencyType _currency;
  SubjectModeType _mode;
  DateTime _date;
  IncomeCategoryType _category;
  String _comment = "";

  PlannedIncomeItemBloc();

  PlannedIncomeItemBloc.from(PlannedIncomeModel model) {
    _value = AppValues.prepareToDisplay(model.value);
    _currency = model.currency;
    _mode = model.mode;
    if (_mode == SubjectModeType.onetime) {
      _date = model.date;
    }
    _category = model.category;
    _comment = model.comment;
  }

  @override
  void dispose() {
    _controller.close();
  }

  PlannedIncomeItemViewState get currentState {
    return PlannedIncomeItemViewState(
        _value, _currency, _mode, _date, _category, _comment);
  }

  void valueChanged(String value) {
    _value = value;
    _controller.sink.add(currentState);
  }

  void currencyChanged(CurrencyType currency) {
    _currency = currency;
    _controller.sink.add(currentState);
  }

  void modeChanged(SubjectModeType mode) {
    _mode = mode;
    _controller.sink.add(currentState);
  }

  void dateChanged(DateTime date) {
    _date = date;
    _controller.sink.add(currentState);
  }

  void categoryChanged(IncomeCategoryType category) {
    _category = category;
    _controller.sink.add(currentState);
  }

  void commentChanged(String comment) {
    _comment = comment;
    _controller.sink.add(currentState);
  }

  bool done() {
    String valueErrorKey;
    if (_value == null || _value.trim() == "") {
      valueErrorKey = "texts.field_empty";
    } else if (num.tryParse(AppValues.prepareToParse(_value)) == null) {
      valueErrorKey = "texts.field_invalid";
    }
    String currencyErrorKey = _currency == null ? "texts.field_empty" : null;
    String modeErrorKey = _mode == null ? "texts.field_empty" : null;
    String dateTimeErrorKey;
    if (_mode == SubjectModeType.onetime) {
      dateTimeErrorKey = _date == null ? "texts.field_empty" : null;
    } else if (_mode == SubjectModeType.monthly) {
      _date = DateTime.now();
    }
    String categoryErrorKey = _category == null ? "texts.field_empty" : null;

    PlannedIncomeItemViewState state = PlannedIncomeItemViewState(
        _value, _currency, _mode, _date, _category, _comment,
        valueErrorKey: valueErrorKey,
        currencyErrorKey: currencyErrorKey,
        dateErrorKey: dateTimeErrorKey,
        modeErrorKey: modeErrorKey,
        categoryErrorKey: categoryErrorKey);

    if (state.hasErrors()) {
      _controller.sink.add(state);
      return false;
    } else {
      return true;
    }
  }
}

class PlannedIncomeItemViewState {
  final String value;
  final CurrencyType currency;
  final SubjectModeType mode;
  final DateTime date;
  final IncomeCategoryType category;
  final String comment;
  final String valueErrorKey;
  final String currencyErrorKey;
  final String dateErrorKey;
  final String modeErrorKey;
  final String categoryErrorKey;

  PlannedIncomeItemViewState(this.value, this.currency, this.mode, this.date,
      this.category, this.comment,
      {this.valueErrorKey,
      this.currencyErrorKey,
      this.dateErrorKey,
      this.modeErrorKey,
      this.categoryErrorKey});

  bool hasErrors() {
    return valueErrorKey != null ||
        currencyErrorKey != null ||
        modeErrorKey != null ||
        dateErrorKey != null ||
        categoryErrorKey != null;
  }
}
