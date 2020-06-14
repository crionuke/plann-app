import 'dart:async';

import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';

class IrregularMainBloc {
  final _controller = StreamController<IrregularMainViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;

  IrregularMainBloc(this.dbService);

  @override
  void dispose() {
    _controller.close();
  }

  void requestState() async {
    _controller.sink.add(IrregularMainViewState.loading());
    List<IrregularModel> fact = await dbService.getIrregularList();
    List<PlannedIrregularModel> planned =
        await dbService.getPlannedIrregularList();
    if (!_controller.isClosed) {
      _controller.sink.add(IrregularMainViewState.loaded(fact, planned));
    }
  }
}

class IrregularMainViewState {
  final bool loaded;
  final List<IrregularModel> fact;
  final List<PlannedIrregularModel> planned;

  IrregularMainViewState.loading()
      : loaded = false,
        fact = null,
        planned = null;

  IrregularMainViewState.loaded(this.fact, this.planned) : loaded = true;
}
