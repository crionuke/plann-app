import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/expense/expense_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/expense_to_tag_model.dart';

class EditExpenseBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  ExpenseModel model;
  ExpenseItemBloc itemBloc;

  EditExpenseBloc(this.dbService, this.analyticsService, this.model) {
    itemBloc = ExpenseItemBloc.from(dbService, model);
  }

  void dispose() {
    _controller.close();
  }

  Future<void> delete() async {
    _controller.sink.add(true);
    await dbService.deleteExpense(model.id);
    await analyticsService.analyze();
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      _controller.sink.add(true);
      await dbService.editExpense(
          model.id,
          ExpenseModel(
              null,
              num.parse(AppTexts.prepareToParse(itemBloc.value)),
              itemBloc.currency,
              itemBloc.date,
              itemBloc.category,
              AppTexts.upFirstLetter(itemBloc.comment)));
      int expenseId = model.id;
      // Selected tags
      for (int tagId in itemBloc.tagsBloc.selectedTags.keys) {
        ExpenseToTagModel expenseToTagModel = new ExpenseToTagModel(
            null, expenseId, tagId);
        if (!(await dbService.hasExpenseTag(expenseToTagModel))) {
          await dbService.addTagToExpense(expenseToTagModel);
        }
      }
      // Removed tags
      for (int tagId in itemBloc.tagsBloc.originalTags.keys) {
        if (!itemBloc.tagsBloc.selectedTags.containsKey(tagId)) {
          await dbService.deleteTagFromExpense(model.id, tagId);
        }
      }
      await analyticsService.analyze();
      Navigator.pop(context, true);
    }
  }
}
