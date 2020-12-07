import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/tags/tag_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/tag_model.dart';
import 'package:plann_app/services/db/models/tag_type_model.dart';
import 'package:plann_app/services/tracking/tracking_service_appmetrica.dart';

class AddTagBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  TagItemBloc itemBloc = TagItemBloc();

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TrackingService trackingService;
  final TagType tagType;

  AddTagBloc(this.dbService, this.analyticsService, this.trackingService,
      this.tagType);

  @override
  void dispose() {
    _controller.close();
    itemBloc.dispose();
  }

  Future<bool> done() async {
    if (itemBloc.done()) {
      TagItemViewState state = itemBloc.currentState;
      _controller.sink.add(true);
      await dbService
          .addTag(TagModel(null, state.name, DateTime.now(), tagType));
      await analyticsService.analyze();
      trackingService.tagAdded();
      return true;
    } else {
      return false;
    }
  }
}
