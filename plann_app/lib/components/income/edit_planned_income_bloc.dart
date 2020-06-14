import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/components/income/planned_income_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';

class EditPlannedIncomeBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  PlannedIncomeModel model;
  PlannedIncomeItemBloc itemBloc;

  EditPlannedIncomeBloc(this.dbService, this.analyticsService, this.model) {
    itemBloc = PlannedIncomeItemBloc.from(model);
  }

  @override
  void dispose() {
    _controller.close();
  }

  void delete(BuildContext context) async {
    _controller.sink.add(true);
    await dbService.deletePlannedIncome(model.id);
    await analyticsService.analyze(dbService);
    Navigator.pop(context, true);
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      PlannedIncomeItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.editPlannedIncome(
          model.id,
          PlannedIncomeModel(
              null,
              num.parse(AppValues.prepareToParse(state.value)),
              state.currency,
              state.mode,
              state.date,
              state.category,
              AppTexts.upFirstLetter(state.comment)));
      await analyticsService.analyze(dbService);
      Navigator.pop(context, true);
    }
  }
}
