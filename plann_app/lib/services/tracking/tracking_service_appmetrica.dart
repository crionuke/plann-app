import 'package:appmetrica_sdk/appmetrica_sdk.dart';

class TrackingService {
  final String API_KEY = "b8aabff0-a1f6-4fcb-aae4-9c182300155b";

  Future<void> start() async {
    await AppmetricaSdk().activate(apiKey: API_KEY);
  }

  void setPaid() {
    AppmetricaSdk().reportUserProfileCustomBoolean(key: "paid", value: true);
  }

  void setStats(
      {int actualIncomeCount,
      int plannedIncomeCount,
      int actualExpenseCount,
      int plannedExpenseCount,
      int actualIrregularCount,
      int plannedIrregularCount}) {
    AppmetricaSdk().reportUserProfileCustomNumber(
        key: "actual_income_count", value: actualIncomeCount.toDouble());
    AppmetricaSdk().reportUserProfileCustomNumber(
        key: "planned_income_count", value: plannedIncomeCount.toDouble());
    AppmetricaSdk().reportUserProfileCustomNumber(
        key: "actual_expense_ccount", value: actualExpenseCount.toDouble());
    AppmetricaSdk().reportUserProfileCustomNumber(
        key: "planned_expense_count", value: plannedExpenseCount.toDouble());
    AppmetricaSdk().reportUserProfileCustomNumber(
        key: "actual_irregular_count", value: actualIrregularCount.toDouble());
    AppmetricaSdk().reportUserProfileCustomNumber(
        key: "planned_irregular_count",
        value: plannedIrregularCount.toDouble());
    print("[TrackingService] report user profile");
  }

  void trackPurchase(productId) {
    setPaid();
    AppmetricaSdk().reportEvent(name: "purchase", attributes: <String, dynamic>{
      "product_id": productId,
    });
    print("[TrackingService] report event purchase");
  }

  void aboutAppViewed() {
    AppmetricaSdk().reportEvent(name: "about_app_viewed");
    print("[TrackingService] report event about_app_viewed");
  }

  void incomeAdded() {
    AppmetricaSdk().reportEvent(name: "income_added");
    print("[TrackingService] report event income_added");
  }

  void incomePlanned() {
    AppmetricaSdk().reportEvent(name: "income_planned");
    print("[TrackingService] report event income_planned");
  }

  void expenseAdded() {
    AppmetricaSdk().reportEvent(name: "expense_added");
    print("[TrackingService] report event expense_added");
  }

  void expensePlanned() {
    AppmetricaSdk().reportEvent(name: "expense_planned");
    print("[TrackingService] report event expense_planned");
  }

  void emergencyFundAdded() {
    AppmetricaSdk().reportEvent(name: "e_fund_added");
    print("[TrackingService] report event e_fund_added");
  }

  void irregularAdded() {
    AppmetricaSdk().reportEvent(name: "irregular_added");
    print("[TrackingService] report event irregular_added");
  }

  void irregularPlanned() {
    AppmetricaSdk().reportEvent(name: "irregular_planned");
    print("[TrackingService] report event irregular_planned");
  }

  void telegramOpened() {
    AppmetricaSdk().reportEvent(name: "telegram_opened");
    print("[TrackingService] report event telegram_opened");
  }
}
