import 'dart:async';

import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';

class ExpenseMainBloc {
  final _controller = StreamController<ExpenseMainViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;

  ExpenseMainBloc(this.dbService, this.analyticsService);

  @override
  void dispose() {
    _controller.close();
  }

  void requestState() async {
    _controller.sink.add(ExpenseMainViewState.loading());
    List<ExpenseModel> fact = await dbService.getExpenseList();
    List<PlannedExpenseModel> planned = await dbService.getPlannedExpenseList();
    if (!_controller.isClosed) {
      CurrencyType defaultCurrency = CurrencyType.rubles;

      Map<DateTime, double> perDayExpenses = analyticsService
          .analytics.perDayExpenses
          .map((dateTime, currencyMap) => MapEntry<DateTime, double>(
              dateTime,
              currencyMap.containsKey(defaultCurrency)
                  ? currencyMap[defaultCurrency]
                  : 0));

      _controller.sink
          .add(ExpenseMainViewState.loaded(fact, perDayExpenses, planned));
    }
  }

  void delete(int id) async {
    await dbService.deletePlannedExpense(id);
    await analyticsService.analyze();
    requestState();
  }
}

class ExpenseMainViewState {
  final bool loaded;
  final List<ExpenseModel> fact;
  final Map<DateTime, double> perDayExpenses;
  final List<PlannedExpenseModel> planned;

  ExpenseMainViewState.loading()
      : loaded = false,
        fact = null,
        perDayExpenses = null,
        planned = null;

  ExpenseMainViewState.loaded(this.fact, this.perDayExpenses, this.planned)
      : loaded = true;
}
