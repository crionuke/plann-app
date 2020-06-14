import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/components/expense/planned_expense_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';

class AddPlannedExpenseBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final PlannedExpenseItemBloc itemBloc = PlannedExpenseItemBloc();

  final DbService dbService;
  final AnalyticsService analyticsService;

  AddPlannedExpenseBloc(this.dbService, this.analyticsService);

  @override
  void dispose() {
    _controller.close();
    itemBloc.dispose();
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      PlannedExpenseItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.addPlannedExpense(PlannedExpenseModel(
          null,
          num.parse(AppValues.prepareToParse(state.value)),
          state.currency,
          state.category,
          AppTexts.upFirstLetter(state.comment)));
      await analyticsService.analyze(dbService);
      Navigator.pop(context, true);
    }
  }
}
