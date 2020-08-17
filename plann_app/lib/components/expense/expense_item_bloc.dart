import 'dart:async';

import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';

class ExpenseItemBloc {
  final _controller = StreamController();

  Stream get stream => _controller.stream;

  String _value;
  CurrencyType _currency;
  DateTime _date;
  ExpenseCategoryType _category;
  String _comment = "";

  ExpenseItemBloc() {
    // Setup default values
    _currency = CurrencyType.rubles;
    _date = DateTime.now();
  }

  ExpenseItemBloc.from(ExpenseModel model) {
    _value = AppValues.prepareToDisplay(model.value);
    _currency = model.currency;
    _date = model.date;
    _category = model.category;
    _comment = model.comment;
  }

  @override
  void dispose() {
    _controller.close();
  }

  ExpenseItemViewState get currentState {
    return ExpenseItemViewState(_value, _currency, _date, _category, _comment);
  }

  void valueChanged(String value) {
    _value = value;
    _controller.sink.add(currentState);
  }

  void currencyChanged(CurrencyType currency) {
    _currency = currency;
    _controller.sink.add(currentState);
  }

  void dateChanged(DateTime date) {
    _date = date;
    _controller.sink.add(currentState);
  }

  void categoryChanged(ExpenseCategoryType category) {
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
    String dateErrorKey = _date == null ? "texts.field_empty" : null;
    String categoryErrorKey = _category == null ? "texts.field_empty" : null;

    ExpenseItemViewState state = ExpenseItemViewState(
        _value, _currency, _date, _category, _comment,
        valueErrorKey: valueErrorKey,
        dateErrorKey: dateErrorKey,
        currencyErrorKey: currencyErrorKey,
        categoryErrorKey: categoryErrorKey);

    if (state.hasErrors()) {
      _controller.sink.add(state);
      return false;
    } else {
      return true;
    }
  }
}

class ExpenseItemViewState {
  final String value;
  final CurrencyType currency;
  final DateTime date;
  final ExpenseCategoryType category;
  final String comment;
  final String valueErrorKey;
  final String currencyErrorKey;
  final String dateErrorKey;
  final String categoryErrorKey;

  ExpenseItemViewState(
      this.value, this.currency, this.date, this.category, this.comment,
      {this.valueErrorKey,
      this.currencyErrorKey,
      this.dateErrorKey,
      this.categoryErrorKey});

  bool hasErrors() {
    return valueErrorKey != null ||
        dateErrorKey != null ||
        currencyErrorKey != null ||
        categoryErrorKey != null;
  }
}
