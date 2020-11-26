import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plann_app/components/tags/tag_item_bloc.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/tag_model.dart';
import 'package:plann_app/services/db/models/tag_type_model.dart';

class AddTagBloc {
  final _controller = StreamController<bool>();

  Stream get stream => _controller.stream;

  TagItemBloc itemBloc = TagItemBloc();

  final DbService dbService;

  AddTagBloc(this.dbService);

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
          .addTag(TagModel(null, state.name, DateTime.now(), TagType.expense));
      return true;
    } else {
      return false;
    }
  }
}
