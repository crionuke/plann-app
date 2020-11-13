import 'dart:async';

import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/expense/expense_month_panel_bloc.dart';
import 'package:plann_app/services/analytics/analytics_month_list.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/currency/currency_service.dart';
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

  ExpenseMonthPanelBloc expenseMonthPanelBloc;

  ExpenseMainBloc(this.dbService, this.analyticsService, this.trackingService) {
    expenseMonthPanelBloc = ExpenseMonthPanelBloc(analyticsService);
  }

  void dispose() {
    _controller.close();
    expenseMonthPanelBloc.dispose();
  }

  void requestState() async {
    _controller.sink.add(ExpenseMainViewState.loading());
    List<ExpenseModel> expenseList = await dbService.getExpenseList();
    List<PlannedExpenseModel> plannedExpenseList =
        await dbService.getPlannedExpenseList();
    if (!_controller.isClosed) {
      _controller.sink.add(ExpenseMainViewState.loaded(
          analyticsService.analytics.monthList,
          expenseList,
          analyticsService.analytics.perDayExpenses,
          plannedExpenseList));
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
  final AnalyticsMonthList monthList;
  final List<ExpenseModel> expenseList;
  final Map<DateTime, Map<CurrencyType, CurrencyValue>> perDayExpenses;
  final List<PlannedExpenseModel> plannedExpenseList;

  ExpenseMainViewState.loading()
      : loaded = false,
        monthList = null,
        expenseList = null,
        perDayExpenses = null,
        plannedExpenseList = null;

  ExpenseMainViewState.loaded(this.monthList, this.expenseList,
      this.perDayExpenses, this.plannedExpenseList)
      : loaded = true;
}
