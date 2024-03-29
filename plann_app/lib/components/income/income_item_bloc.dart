import 'dart:async';

import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/widgets/tags/tags_bloc.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/tag_type_model.dart';

class IncomeItemBloc {
  final _controller = StreamController();

  Stream get stream => _controller.stream;

  final DbService dbService;

  TagsBloc tagsBloc;

  String _value;
  CurrencyType _currency;
  DateTime _dateTime;
  IncomeCategoryType _category;
  String _comment = "";

  IncomeItemBloc(this.dbService) {
    // Setup default values
    _currency = CurrencyType.rubles;
    _dateTime = DateTime.now();
    tagsBloc = TagsBloc(dbService, TagType.income);
  }

  IncomeItemBloc.from(this.dbService, IncomeModel model) {
    _value = AppTexts.prepareToDisplay(model.value);
    _currency = model.currency;
    _dateTime = model.date;
    _category = model.category;
    _comment = model.comment;
    tagsBloc = TagsBloc.from(dbService, TagType.income, model.id);
  }

  @override
  void dispose() {
    _controller.close();
  }

  IncomeItemViewState get currentState {
    return IncomeItemViewState(
        _value, _currency, _dateTime, _category, _comment);
  }

  void valueChanged(String value) {
    _value = value;
    _controller.sink.add(currentState);
  }

  void currencyChanged(CurrencyType currency) {
    _currency = currency;
    _controller.sink.add(currentState);
  }

  void dateTimeChanged(DateTime dateTime) {
    _dateTime = dateTime;
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
    } else if (num.tryParse(AppTexts.prepareToParse(_value)) == null) {
      valueErrorKey = "texts.field_invalid";
    }
    String currencyErrorKey = _currency == null ? "texts.field_empty" : null;
    String dateTimeErrorKey = _dateTime == null ? "texts.field_empty" : null;
    String categoryErrorKey = _category == null ? "texts.field_empty" : null;

    IncomeItemViewState state = IncomeItemViewState(
        _value, _currency, _dateTime, _category, _comment,
        valueErrorKey: valueErrorKey,
        currencyErrorKey: currencyErrorKey,
        dateTimeErrorKey: dateTimeErrorKey,
        categoryErrorKey: categoryErrorKey);

    if (state.hasErrors()) {
      _controller.sink.add(state);
      return false;
    } else {
      return true;
    }
  }
}

class IncomeItemViewState {
  final String value;
  final CurrencyType currency;
  final DateTime dateTime;
  final IncomeCategoryType category;
  final String comment;
  final String valueErrorKey;
  final String currencyErrorKey;
  final String dateTimeErrorKey;
  final String categoryErrorKey;

  IncomeItemViewState(
      this.value, this.currency, this.dateTime, this.category, this.comment,
      {this.valueErrorKey,
      this.currencyErrorKey,
      this.dateTimeErrorKey,
      this.categoryErrorKey});

  bool hasErrors() {
    return valueErrorKey != null ||
        currencyErrorKey != null ||
        dateTimeErrorKey != null ||
        categoryErrorKey != null;
  }
}
