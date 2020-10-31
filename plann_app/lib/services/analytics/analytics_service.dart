import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:plann_app/services/tracking/tracking_service_appmetrica.dart';

class AnalyticsService {
  final DbService dbService;
  final TrackingService trackingService;
  final CurrencyService currencyService;

  AnalyticsData _analytics;

  AnalyticsService(this.dbService, this.trackingService, this.currencyService);

  AnalyticsData get analytics => _analytics;

  Future<void> start() async {
    print("[AnalyticsService] starting");
    return await analyze();
  }

  Future<AnalyticsData> analyze() async {
    print("[AnalyticsService] analyze started");

    List<IncomeModel> incomeList = await dbService.getIncomeList();
    List<PlannedIncomeModel> plannedIncomeList =
        await dbService.getPlannedIncomeList();
    List<ExpenseModel> expenseList = await dbService.getExpenseList();
    List<PlannedExpenseModel> plannedExpenseList =
        await dbService.getPlannedExpenseList();
    List<IrregularModel> irregularList = await dbService.getIrregularList();
    List<PlannedIrregularModel> plannedIrregularList =
        await dbService.getPlannedIrregularList();

    trackingService.setStats(
        actualIncomeCount: incomeList.length,
        plannedIncomeCount: plannedIncomeList.length,
        actualExpenseCount: expenseList.length,
        plannedExpenseCount: plannedExpenseList.length,
        actualIrregularCount: irregularList.length,
        plannedIrregularCount: plannedIrregularList.length);

    List<AnalyticsItem<IncomeModel>> analyticsActualIncomeList = List();
    List<AnalyticsItem<PlannedIncomeModel>> analyticsPlannedIncomeList = List();
    List<AnalyticsItem<ExpenseModel>> analyticsActualExpenseList = List();
    List<AnalyticsItem<PlannedExpenseModel>> analyticsPlannedExpenseList =
        List();
    List<AnalyticsItem<IrregularModel>> analyticsActualIrregularList = List();
    List<AnalyticsItem<PlannedIrregularModel>> analyticsPlannedIrregularList =
        List();

    analyticsActualIncomeList = incomeList
        .map((model) => AnalyticsItem<IncomeModel>(
            model, currencyService.exchange(model.currency, model.value)))
        .toList();

    analyticsPlannedIncomeList = plannedIncomeList
        .map((model) => AnalyticsItem<PlannedIncomeModel>(
            model, currencyService.exchange(model.currency, model.value)))
        .toList();

    analyticsActualExpenseList = expenseList
        .map((model) => AnalyticsItem<ExpenseModel>(
            model, currencyService.exchange(model.currency, model.value)))
        .toList();

    analyticsPlannedExpenseList = plannedExpenseList
        .map((model) => AnalyticsItem<PlannedExpenseModel>(
            model, currencyService.exchange(model.currency, model.value)))
        .toList();

    analyticsActualIrregularList = irregularList
        .map((model) => AnalyticsItem<IrregularModel>(
            model, currencyService.exchange(model.currency, model.value)))
        .toList();

    analyticsPlannedIrregularList = plannedIrregularList
        .map((model) => AnalyticsItem<PlannedIrregularModel>(
            model, currencyService.exchange(model.currency, model.value)))
        .toList();

    AnalyticsData analytics = AnalyticsData(
        analyticsActualIncomeList,
        analyticsPlannedIncomeList,
        analyticsActualExpenseList,
        analyticsPlannedExpenseList,
        analyticsActualIrregularList,
        analyticsPlannedIrregularList);
    await analytics.analyze();

    _analytics = analytics;

    return _analytics;
  }
}

class AnalyticsItem<T> {
  final T model;
  final CurrencyValue currencyValue;

  AnalyticsItem(this.model, this.currencyValue);
}
