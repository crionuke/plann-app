import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/components/irregular/irregular_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/tracking/tracking_service.dart';

class AddIrregularBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  IrregularItemBloc itemBloc = IrregularItemBloc();

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TrackingService trackingService;

  AddIrregularBloc(this.dbService, this.analyticsService, this.trackingService);

  @override
  void dispose() {
    _controller.close();
    itemBloc.dispose();
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      IrregularItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.addIrregular(IrregularModel(
          null,
          num.parse(AppValues.prepareToParse(state.value)),
          state.currency,
          AppTexts.upFirstLetter(state.title),
          state.date));
      await analyticsService.analyze();
      trackingService.irregularAdded();
      Navigator.pop(context, true);
    }
  }
}
