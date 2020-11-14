import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/income/income_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/tracking/tracking_service_appmetrica.dart';

class AddIncomeBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  IncomeItemBloc itemBloc = IncomeItemBloc();

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TrackingService trackingService;

  AddIncomeBloc(this.dbService, this.analyticsService, this.trackingService);

  @override
  void dispose() {
    _controller.close();
    itemBloc.dispose();
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      IncomeItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.addIncome(IncomeModel(
          null,
          num.parse(AppTexts.prepareToParse(state.value)),
          state.currency,
          state.dateTime,
          state.category,
          AppTexts.upFirstLetter(state.comment)));
      await analyticsService.analyze();
      trackingService.incomeAdded();
      Navigator.pop(context, true);
    }
  }
}
