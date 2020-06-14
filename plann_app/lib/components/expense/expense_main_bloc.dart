import 'dart:async';

import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';

class ExpenseMainBloc {
  final _controller = StreamController<ExpenseMainViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;

  ExpenseMainBloc(this.dbService);

  @override
  void dispose() {
    _controller.close();
  }

  void requestState() async {
    _controller.sink.add(ExpenseMainViewState.loading());
    List<ExpenseModel> fact = await dbService.getExpenseList();
    List<PlannedExpenseModel> planned = await dbService.getPlannedExpenseList();
    if (!_controller.isClosed) {
      _controller.sink.add(ExpenseMainViewState.loaded(fact, planned));
    }
  }
}

class ExpenseMainViewState {
  final bool loaded;
  final List<ExpenseModel> fact;
  final List<PlannedExpenseModel> planned;

  ExpenseMainViewState.loading()
      : loaded = false,
        fact = null,
        planned = null;

  ExpenseMainViewState.loaded(this.fact, this.planned) : loaded = true;
}
