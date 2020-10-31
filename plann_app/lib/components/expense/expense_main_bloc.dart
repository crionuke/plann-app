import 'dart:async';

import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/tracking/tracking_service_appmetrica.dart';

class ExpenseMainBloc {
  final _controller = StreamController<ExpenseMainViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TrackingService trackingService;

  ExpenseMainBloc(this.dbService, this.analyticsService, this.trackingService);

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

  void deleteExpense(int id) async {
    await dbService.deleteExpense(id);
    await analyticsService.analyze();
    requestState();
  }

  void deletePlannedExpense(int id) async {
    await dbService.deletePlannedExpense(id);
    await analyticsService.analyze();
    requestState();
  }

  Future<int> instantiateExpense(num value, CurrencyType currency,
      ExpenseCategoryType category, String comment) async {
    int id = await dbService.addExpense(ExpenseModel(null, value, currency,
        DateTime.now(), category, AppTexts.upFirstLetter(comment)));
    await analyticsService.analyze();
    trackingService.expenseAdded();
    return id;
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
