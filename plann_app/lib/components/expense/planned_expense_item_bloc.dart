import 'dart:async';

import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';

class PlannedExpenseItemBloc {
  final _controller = StreamController();

  Stream get stream => _controller.stream;

  String _value;
  CurrencyType _currency;
  ExpenseCategoryType _category;
  String _comment = "";

  PlannedExpenseItemBloc();

  PlannedExpenseItemBloc.from(PlannedExpenseModel model) {
    _value = AppTexts.prepareToDisplay(model.value);
    _currency = model.currency;
    _category = model.category;
    _comment = model.comment;
  }

  @override
  void dispose() {
    _controller.close();
  }

  PlannedExpenseItemViewState get currentState {
    return PlannedExpenseItemViewState(_value, _currency, _category, _comment);
  }

  void valueChanged(String value) {
    _value = value;
    _controller.sink.add(currentState);
  }

  void currencyChanged(CurrencyType currency) {
    _currency = currency;
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
    } else if (num.tryParse(AppTexts.prepareToParse(_value)) == null) {
      valueErrorKey = "texts.field_invalid";
    }
    String currencyErrorKey = _currency == null ? "texts.field_empty" : null;
    String categoryErrorKey = _category == null ? "texts.field_empty" : null;

    PlannedExpenseItemViewState state = PlannedExpenseItemViewState(
        _value, _currency, _category, _comment,
        valueErrorKey: valueErrorKey,
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

class PlannedExpenseItemViewState {
  final String value;
  final CurrencyType currency;
  final ExpenseCategoryType category;
  final String comment;
  final String valueErrorKey;
  final String currencyErrorKey;
  final String categoryErrorKey;

  PlannedExpenseItemViewState(
      this.value, this.currency, this.category, this.comment,
      {this.valueErrorKey, this.currencyErrorKey, this.categoryErrorKey});

  bool hasErrors() {
    return valueErrorKey != null ||
        currencyErrorKey != null ||
        categoryErrorKey != null;
  }
}
