import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:plann_app/services/tracking/tracking_service.dart';

class AnalyticsService {
  final DbService dbService;
  final TrackingService trackingService;

  AnalyticsData _analytics;

  AnalyticsService(this.dbService, this.trackingService);

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
        plannedExpenseCount: expenseList.length,
        actualIrregularCount: irregularList.length,
        plannedIrregularCount: plannedIrregularList.length);

    AnalyticsData analytics = AnalyticsData(incomeList, plannedIncomeList,
        expenseList, plannedExpenseList, irregularList, plannedIrregularList);
    await analytics.analyze();

    _analytics = analytics;

    return _analytics;
  }
}
