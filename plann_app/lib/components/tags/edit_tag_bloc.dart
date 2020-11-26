import 'dart:async';

import 'package:plann_app/components/tags/tag_item_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/tag_model.dart';
import 'package:plann_app/services/db/models/tag_type_model.dart';

class EditTagBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  TagModel model;
  TagItemBloc itemBloc;

  EditTagBloc(this.dbService, this.analyticsService, this.model) {
    itemBloc = TagItemBloc.from(model);
  }

  void dispose() {
    _controller.close();
    itemBloc.dispose();
  }

  Future<void> delete() async {
    _controller.sink.add(true);
    await dbService.deleteTag(model.id);
    await analyticsService.analyze();
  }

  Future<bool> done() async {
    if (itemBloc.done()) {
      _controller.sink.add(true);
      TagItemViewState state = itemBloc.currentState;
      await dbService.editTag(model.id,
          TagModel(null, state.name, DateTime.now(), TagType.expense));
      return true;
    } else {
      return false;
    }
  }
}
