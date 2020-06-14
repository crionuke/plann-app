import 'dart:async';

import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';

class IncomeMainBloc {
  final _controller = StreamController<IncomeMainViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;

  IncomeMainBloc(this.dbService);

  void dispose() {
    _controller.close();
  }

  void requestState() async {
    _controller.sink.add(IncomeMainViewState.loading());
    List<IncomeModel> fact = await dbService.getIncomeList();
    List<PlannedIncomeModel> planned = await dbService.getPlannedIncomeList();
    if (!_controller.isClosed) {
      _controller.sink.add(IncomeMainViewState.loaded(fact, planned));
    }
  }
}

class IncomeMainViewState {
  final bool loaded;
  final List<IncomeModel> fact;
  final List<PlannedIncomeModel> planned;

  IncomeMainViewState.loading()
      : loaded = false,
        fact = null,
        planned = null;

  IncomeMainViewState.loaded(this.fact, this.planned) : loaded = true;
}
