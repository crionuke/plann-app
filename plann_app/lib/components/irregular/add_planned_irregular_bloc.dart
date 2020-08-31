import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/components/irregular/planned_irregular_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:plann_app/services/tracking/tracking_service.dart';

class AddPlannedIrregularBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  PlannedIrregularItemBloc itemBloc = PlannedIrregularItemBloc();

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TrackingService trackingService;

  AddPlannedIrregularBloc(
      this.dbService, this.analyticsService, this.trackingService);

  void dispose() {
    _controller.close();
    itemBloc.dispose();
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      PlannedIrregularItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.addPlannedIrregular(PlannedIrregularModel(
          null,
          state.creationDate,
          num.parse(AppValues.prepareToParse(state.value)),
          state.currency,
          AppTexts.upFirstLetter(state.title),
          state.date));
      await analyticsService.analyze();
      trackingService.irregularPlanned();
      Navigator.pop(context, true);
    }
  }
}
