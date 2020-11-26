import 'dart:async';

import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/widgets/tags/tags_bloc.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/tag_type_model.dart';

class ExpenseItemBloc {
  final _controller = StreamController();

  Stream get stream => _controller.stream;

  final DbService dbService;

  TagsBloc tagsBloc;

  String _value;
  bool _valueAutoFocus;
  CurrencyType _currency;
  DateTime _date;
  ExpenseCategoryType _category;
  String _comment = "";

  String valueErrorKey;
  String currencyErrorKey;
  String dateErrorKey;
  String categoryErrorKey;

  ExpenseItemBloc(this.dbService) {
    _valueAutoFocus = true;
    // Setup default values
    _currency = CurrencyType.rubles;
    _date = DateTime.now();
    tagsBloc = TagsBloc(dbService, TagType.expense);
  }

  ExpenseItemBloc.from(this.dbService, ExpenseModel model) {
    _valueAutoFocus = false;
    _value = AppTexts.prepareToDisplay(model.value);
    _currency = model.currency;
    _date = model.date;
    _category = model.category;
    _comment = model.comment;
    tagsBloc = TagsBloc.from(dbService, TagType.expense, model.id);
  }

  String get value => _value;

  bool get valueAutoFocus => _valueAutoFocus;

  CurrencyType get currency => _currency;

  DateTime get date => _date;

  ExpenseCategoryType get category => _category;

  String get comment => _comment;

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(ExpenseItemViewState.loading());
    // Detect tags
    if (!_controller.isClosed) {
      _controller.sink.add(ExpenseItemViewState.loaded(
          _value,
          _valueAutoFocus,
          _currency,
          _date,
          _category,
          _comment,
          valueErrorKey: valueErrorKey,
          dateErrorKey: dateErrorKey,
          currencyErrorKey: currencyErrorKey,
          categoryErrorKey: categoryErrorKey));
    }
  }

  void valueChanged(String value) {
    _value = value;
    requestState();
  }

  void currencyChanged(CurrencyType currency) {
    _currency = currency;
    requestState();
  }

  void dateChanged(DateTime date) {
    _date = date;
    requestState();
  }

  void categoryChanged(ExpenseCategoryType category) {
    _category = category;
    requestState();
  }

  void commentChanged(String comment) {
    _comment = comment;
    requestState();
  }

  bool done() {
    _resetErrors();

    if (_value == null || _value.trim() == "") {
      valueErrorKey = "texts.field_empty";
    } else if (num.tryParse(AppTexts.prepareToParse(_value)) == null) {
      valueErrorKey = "texts.field_invalid";
    }
    currencyErrorKey = _currency == null ? "texts.field_empty" : null;
    dateErrorKey = _date == null ? "texts.field_empty" : null;
    categoryErrorKey = _category == null ? "texts.field_empty" : null;

    if (_hasErrors()) {
      requestState();
      return false;
    } else {
      return true;
    }
  }

  void _resetErrors() {
    valueErrorKey = null;
    currencyErrorKey = null;
    dateErrorKey = null;
    categoryErrorKey = null;
  }

  bool _hasErrors() {
    return valueErrorKey != null ||
        dateErrorKey != null ||
        currencyErrorKey != null ||
        categoryErrorKey != null;
  }
}

class ExpenseItemViewState {
  final bool loaded;

  final String value;
  final bool valueAutofocus;
  final CurrencyType currency;
  final DateTime date;
  final ExpenseCategoryType category;
  final String comment;
  final String valueErrorKey;
  final String currencyErrorKey;
  final String dateErrorKey;
  final String categoryErrorKey;

  ExpenseItemViewState.loading()
      : loaded = false,
        value = null,
        valueAutofocus = null,
        currency = null,
        date = null,
        category = null,
        comment = null,
        valueErrorKey = null,
        currencyErrorKey = null,
        dateErrorKey = null,
        categoryErrorKey = null;

  ExpenseItemViewState.loaded(this.value, this.valueAutofocus, this.currency,
      this.date, this.category, this.comment,
      {this.valueErrorKey,
        this.currencyErrorKey,
        this.dateErrorKey,
        this.categoryErrorKey}) : loaded = true;
}