import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/components/emergency/emergency_fund_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/emergency_fund_model.dart';
import 'package:plann_app/services/tracking/tracking_service_appmetrica.dart';

class AddEmergencyFundBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  EmergencyFundItemBloc itemBloc = EmergencyFundItemBloc();

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TrackingService trackingService;

  AddEmergencyFundBloc(
      this.dbService, this.analyticsService, this.trackingService);

  void dispose() {
    _controller.close();
    itemBloc.dispose();
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      EmergencyFundItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.addEmergencyFund(EmergencyFundModel(
        null,
        state.currency,
        num.parse(AppValues.prepareToParse(state.currentValue)),
        num.parse(AppValues.prepareToParse(state.targetValue)),
        state.startDate,
        state.finishDate,
      ));
      await analyticsService.analyze();
      trackingService.emergencyFundAdded();
      Navigator.pop(context, true);
    }
  }
}
