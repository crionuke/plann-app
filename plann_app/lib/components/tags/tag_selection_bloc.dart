import 'dart:async';

import 'package:plann_app/components/widgets/tags/tags_bloc.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/tag_model.dart';
import 'package:plann_app/services/db/models/tag_type_model.dart';

class TagSelectionBloc {
  final _controller = StreamController.broadcast();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TagType tagsType;
  final Map<int, Tag> excludeTags;

  TagSelectionBloc(this.dbService, this.analyticsService, this.tagsType,
      this.excludeTags);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(TagSelectionViewState.loading());
    if (!_controller.isClosed) {
      List<TagModel> tags = (await dbService.getTagsByType(tagsType));
      tags.removeWhere((model) => excludeTags.containsKey(model.id));
      _controller.sink.add(TagSelectionViewState.loaded(tags));
    }
  }

  Future<void> deleteTag(int tagId) async {
    await dbService.deleteTag(tagId);
    await analyticsService.analyze();
    requestState();
  }
}

class TagSelectionArguments {
  final TagType tagsType;
  final Map<int, Tag> excludeTags;

  TagSelectionArguments(this.tagsType, this.excludeTags);
}

class TagSelectionViewState {
  final bool loaded;
  final List<TagModel> tags;

  TagSelectionViewState.loading()
      : loaded = false,
        tags = null;

  TagSelectionViewState.loaded(this.tags) : loaded = true;
}
