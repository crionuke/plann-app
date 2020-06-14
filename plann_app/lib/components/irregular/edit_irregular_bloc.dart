import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/components/irregular/irregular_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';

class EditIrregularBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  IrregularModel model;
  IrregularItemBloc itemBloc;

  EditIrregularBloc(this.dbService, this.analyticsService, this.model) {
    itemBloc = IrregularItemBloc.from(model);
  }

  @override
  void dispose() {
    _controller.close();
  }

  void delete(BuildContext context) async {
    _controller.sink.add(true);
    await dbService.deleteIrregular(model.id);
    await analyticsService.analyze(dbService);
    Navigator.pop(context, true);
  }

  void done(BuildContext context) async {
    if (itemBloc.done()) {
      IrregularItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService.editIrregular(
          model.id,
          IrregularModel(null, num.parse(AppValues.prepareToParse(state.value)),
              state.currency, AppTexts.upFirstLetter(state.title), state.date));
      await analyticsService.analyze(dbService);
      Navigator.pop(context, true);
    }
  }
}
