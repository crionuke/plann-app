import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/expense/expense_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/expense_model.dart';

class EditExpenseBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  ExpenseModel model;
  ExpenseItemBloc itemBloc;

  EditExpenseBloc(this.dbService, this.analyticsService, this.model) {
    itemBloc = ExpenseItemBloc.from(model);
  }

  @override
  void dispose() {
    _controller.close();
  }

  void delete(BuildContext context) async {
    _controller.sink.add(true);
    await dbService.deleteExpense(model.id);
    await analyticsService.analyze();
    Navigator.pop(context, true);
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      ExpenseItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.editExpense(
          model.id,
          ExpenseModel(
              null,
              num.parse(AppTexts.prepareToParse(state.value)),
              state.currency,
              state.date,
              state.category,
              AppTexts.upFirstLetter(state.comment)));
      await analyticsService.analyze();
      Navigator.pop(context, true);
    }
  }
}
