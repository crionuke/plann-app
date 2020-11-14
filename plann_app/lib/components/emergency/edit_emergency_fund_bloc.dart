import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/emergency/emergency_fund_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/emergency_fund_model.dart';

class EditEmergencyFundBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  EmergencyFundModel model;
  EmergencyFundItemBloc itemBloc;

  EditEmergencyFundBloc(this.dbService, this.analyticsService, this.model) {
    itemBloc = EmergencyFundItemBloc.from(model);
  }

  void dispose() {
    _controller.close();
  }

  void delete(BuildContext context) async {
    _controller.sink.add(true);
    await dbService.deleteEmergencyFund(model.id);
    await analyticsService.analyze();
    Navigator.pop(context, true);
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      EmergencyFundItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.editEmergencyFund(
          model.id,
          EmergencyFundModel(
              null,
              state.currency,
              num.parse(AppTexts.prepareToParse(state.currentValue)),
              num.parse(AppTexts.prepareToParse(state.targetValue)),
              state.startDate,
              state.finishDate));
      await analyticsService.analyze();
      Navigator.pop(context, true);
    }
  }
}
