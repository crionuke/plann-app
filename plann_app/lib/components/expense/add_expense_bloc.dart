import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/components/expense/expense_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/tracking/tracking_service.dart';

class AddExpenseBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final ExpenseItemBloc itemBloc = ExpenseItemBloc();

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TrackingService trackingService;

  AddExpenseBloc(this.dbService, this.analyticsService, this.trackingService);

  @override
  void dispose() {
    _controller.close();
    itemBloc.dispose();
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      ExpenseItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.addExpense(ExpenseModel(
          null,
          num.parse(AppValues.prepareToParse(state.value)),
          state.currency,
          state.date,
          state.category,
          AppTexts.upFirstLetter(state.comment)));
      await analyticsService.analyze();
      trackingService.expenseAdded();
      Navigator.pop(context, true);
    }
  }
}
