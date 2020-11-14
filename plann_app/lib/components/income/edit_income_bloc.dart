import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/income/income_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/income_model.dart';

class EditIncomeBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  IncomeModel model;
  IncomeItemBloc itemBloc;

  EditIncomeBloc(this.dbService, this.analyticsService, this.model) {
    itemBloc = IncomeItemBloc.from(model);
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
      await analyticsService.analyze();
      Navigator.pop(context, true);
    }
  }
}
