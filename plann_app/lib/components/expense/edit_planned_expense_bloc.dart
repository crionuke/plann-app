import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/expense/planned_expense_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';

class EditPlannedExpenseBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  PlannedExpenseModel model;
  PlannedExpenseItemBloc itemBloc;

  EditPlannedExpenseBloc(this.dbService, this.analyticsService, this.model) {
    itemBloc = PlannedExpenseItemBloc.from(model);
  }

  @override
  void dispose() {
    _controller.close();
  }

  void delete(BuildContext context) async {
    _controller.sink.add(true);
    await dbService.deletePlannedExpense(model.id);
    await analyticsService.analyze();
    Navigator.pop(context, true);
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      PlannedExpenseItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.editPlannedExpense(
          model.id,
          PlannedExpenseModel(
              null,
              num.parse(AppTexts.prepareToParse(state.value)),
              state.currency,
              state.category,
              AppTexts.upFirstLetter(state.comment)));
      await analyticsService.analyze();
      Navigator.pop(context, true);
    }
  }
}
