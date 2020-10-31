import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/income/planned_income_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/tracking/tracking_service_appmetrica.dart';

import '../app_values.dart';

class AddPlannedIncomeBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  PlannedIncomeItemBloc itemBloc = PlannedIncomeItemBloc();

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TrackingService trackingService;

  AddPlannedIncomeBloc(
      this.dbService, this.analyticsService, this.trackingService);

  void dispose() {
    _controller.close();
    itemBloc.dispose();
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      PlannedIncomeItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.addPlannedIncome(PlannedIncomeModel(
          null,
          num.parse(AppValues.prepareToParse(state.value)),
          state.currency,
          state.mode,
          state.date,
          state.category,
          AppTexts.upFirstLetter(state.comment)));
      await analyticsService.analyze();
      trackingService.incomePlanned();
      Navigator.pop(context, true);
    }
  }
}
