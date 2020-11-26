import 'dart:async';

import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/tag_model.dart';
import 'package:plann_app/services/db/models/tag_type_model.dart';

class TagsBloc {
  final _controller = StreamController<TagsViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final int expenseId;

  Map<int, Tag> _originalTags;
  Map<int, Tag> _selectedTags;

  TagsBloc(this.dbService) : expenseId = null;

  TagsBloc.from(this.dbService, this.expenseId);

  Map<int, Tag> get originalTags => _originalTags;
  Map<int, Tag> get selectedTags => _selectedTags;

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(TagsViewState.loading());
    if (!_controller.isClosed) {
      _originalTags = Map();
      _selectedTags = Map();

      if (expenseId != null) {
        Map<int, TagModel> tags = Map();
        (await dbService.getTagList(TagType.expense)).forEach((model) {
          tags[model.id] = model;
        });

        (await dbService.getExpenseTags(expenseId)).forEach((expenseToTag) {
          if (tags.containsKey(expenseToTag.tagId)) {
            TagModel tagModel = tags[expenseToTag.tagId];
            Tag tag = Tag(tagModel.id, tagModel.name);
            _originalTags[tagModel.id] = tag;
            _selectedTags[tagModel.id] = tag;
          }
        });
      }

      _controller.sink.add(TagsViewState.loaded(_selectedTags));
    }
  }

  Future<void> updateState() async {
    _controller.sink.add(TagsViewState.loaded(_selectedTags));
  }

  void tagSelected(int tagId) async {
    List<TagModel> tags = await dbService.getTagList(TagType.expense);
    tags.where((model) => model.id == tagId).forEach((model) {
      _selectedTags[model.id] = Tag(model.id, model.name);
    });
    updateState();
  }

  void tagRemoved(int tagId) async {
    _selectedTags.removeWhere((id, tag) => id == tagId);
    updateState();
  }
}

class TagsViewState {
  final bool loaded;
  final Map<int, Tag> tags;

  TagsViewState.loading()
      : loaded = false,
        tags = null;

  TagsViewState.loaded(this.tags) : loaded = true;
}

class Tag {
  final int id;
  final String name;

  Tag(this.id, this.name);
}
