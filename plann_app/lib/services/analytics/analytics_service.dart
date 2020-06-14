import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/db/db_service.dart';

class AnalyticsService {
  AnalyticsData _analytics;

  AnalyticsData get analytics => _analytics;

  Future<void> start(DbService dbService) async {
    print("[AnalyticsService] starting");
    return await analyze(dbService);
  }

  Future<AnalyticsData> analyze(DbService dbService) async {
    print("[AnalyticsService] analyze");

    AnalyticsData analytics = AnalyticsData(
        await dbService.getIncomeList(),
        await dbService.getPlannedIncomeList(),
        await dbService.getExpenseList(),
        await dbService.getPlannedExpenseList(),
        await dbService.getIrregularList(),
        await dbService.getPlannedIrregularList());
    await analytics.analyze();

    return (_analytics = analytics);
  }
}
