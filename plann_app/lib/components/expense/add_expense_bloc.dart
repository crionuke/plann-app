import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/expense/expense_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/expense_to_tag_model.dart';
import 'package:plann_app/services/tracking/tracking_service_appmetrica.dart';

class AddExpenseBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TrackingService trackingService;

  ExpenseItemBloc itemBloc;

  AddExpenseBloc(this.dbService, this.analyticsService, this.trackingService) {
    itemBloc = ExpenseItemBloc(dbService);
  }

  void dispose() {
    _controller.close();
    itemBloc.dispose();
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      _controller.sink.add(true);
      int expenseId = await dbService.addExpense(ExpenseModel(
          null,
          num.parse(AppTexts.prepareToParse(itemBloc.value)),
          itemBloc.currency,
          itemBloc.date,
          itemBloc.category,
          AppTexts.upFirstLetter(itemBloc.comment)));
      // Selected tags
      for (int tagId in itemBloc.tagsBloc.selectedTags.keys) {
        ExpenseToTagModel expenseToTagModel = new ExpenseToTagModel(
            null, expenseId, tagId);
        if (!(await dbService.hasExpenseTag(expenseToTagModel))) {
          await dbService.addTagToExpense(expenseToTagModel);
        }
      }
      await analyticsService.analyze();
      trackingService.expenseAdded();
      Navigator.pop(context, true);
    }
  }
}
