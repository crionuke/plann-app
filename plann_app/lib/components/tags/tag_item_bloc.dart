import 'dart:async';

import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/tag_model.dart';

class TagItemBloc {
  final _controller = StreamController();

  Stream get stream => _controller.stream;

  String _name;
  String _nameErrorKey;

  TagItemBloc();

  TagItemBloc.from(TagModel model) {
    _name = model.name;
  }

  String get name => _name;

  void dispose() {
    _controller.close();
  }

  TagItemViewState get currentState {
    return TagItemViewState(_name, nameErrorKey: _nameErrorKey);
  }

  void nameChanged(String name) {
    _name = name;
    _controller.sink.add(currentState);
  }

  bool done() {
    if (_name == null || _name.trim() == "") {
      _nameErrorKey = "texts.field_empty";
    }

    if (_hasErrors()) {
      _controller.sink.add(currentState);
      return false;
    } else {
      return true;
    }
  }

  bool _hasErrors() {
    return _nameErrorKey != null;
  }
}

class TagItemViewState {
  final String name;
  final String nameErrorKey;

  TagItemViewState(this.name, {this.nameErrorKey});
}
