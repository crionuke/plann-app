import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/income/income_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/income_to_tag_model.dart';

class EditIncomeBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  IncomeModel model;
  IncomeItemBloc itemBloc;

  EditIncomeBloc(this.dbService, this.analyticsService, this.model) {
    itemBloc = IncomeItemBloc.from(dbService, model);
  }

  @override
  void dispose() {
    _controller.close();
  }

  void delete(BuildContext context) async {
    _controller.sink.add(true);
    await dbService.deleteIncome(model.id);
    await analyticsService.analyze();
    Navigator.pop(context, true);
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      IncomeItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.editIncome(
          model.id,
          IncomeModel(
              null,
              num.parse(AppTexts.prepareToParse(state.value)),
              state.currency,
              state.dateTime,
              state.category,
              AppTexts.upFirstLetter(state.comment)));
      int incomeId = model.id;
      // Selected tags
      for (int tagId in itemBloc.tagsBloc.selectedTags.keys) {
        IncomeToTagModel incomeToTagModel = new IncomeToTagModel(
            null, incomeId, tagId);
        if (!(await dbService.hasIncomeTag(incomeToTagModel))) {
          await dbService.addTagToIncome(incomeToTagModel);
        }
      }
      // Removed tags
      for (int tagId in itemBloc.tagsBloc.originalTags.keys) {
        if (!itemBloc.tagsBloc.selectedTags.containsKey(tagId)) {
          await dbService.deleteTagFromIncome(model.id, tagId);
        }
      }
      await analyticsService.analyze();
      Navigator.pop(context, true);
    }
  }
}
