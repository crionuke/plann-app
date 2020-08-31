import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/components/irregular/planned_irregular_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';

class EditPlannedIrregularBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  PlannedIrregularModel model;
  PlannedIrregularItemBloc itemBloc;

  EditPlannedIrregularBloc(this.dbService, this.analyticsService, this.model) {
    itemBloc = PlannedIrregularItemBloc.from(model);
  }

  @override
  void dispose() {
    _controller.close();
  }

  void delete(BuildContext context) async {
    _controller.sink.add(true);
    await dbService.deletePlannedIrregular(model.id);
    await analyticsService.analyze();
    Navigator.pop(context, true);
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      PlannedIrregularItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.editPlannedIrregular(
          model.id,
          PlannedIrregularModel(
              null,
              state.creationDate,
              num.parse(AppValues.prepareToParse(state.value)),
              state.currency,
              AppTexts.upFirstLetter(state.title),
              state.date));
      await analyticsService.analyze();
      Navigator.pop(context, true);
    }
  }
}
