import 'package:amplitude_flutter/amplitude.dart';

class TrackingService {
  final String API_KEY = "9a707f04a0bfaea523bee9bf07a22bba";

  final Amplitude amplitude = Amplitude.getInstance(instanceName: "plann-app");

  Future<void> start() async {
    amplitude.init(API_KEY);
    amplitude.trackingSessionEvents(true);
  }

  void setPaying() {
    amplitude.setUserProperties({"paying": true});
  }

  void setStats(
      {int actualIncomeCount,
      int plannedIncomeCount,
      int actualExpenseCount,
      int plannedExpenseCount,
      int actualIrregularCount,
      int plannedIrregularCount}) {

    amplitude.setUserProperties({
      "actual_income_count": actualIncomeCount,
      "planned_income_count": plannedIncomeCount,
      "actual_expense_ccount": actualExpenseCount,
      "planned_expense_count": plannedExpenseCount,
      "actual_irregular_count": actualIrregularCount,
      "planned_irregular_count": plannedIrregularCount,
    });
  }

  void trackPurchase(productId) {
    setPaying();
    amplitude.logEvent("purchase", eventProperties: {"product_id": productId});
  }

  void incomeAdded() {
    amplitude.logEvent("income_added");
  }

  void incomePlanned() {
    amplitude.logEvent("income_planned");
  }

  void irregularAdded() {
    amplitude.logEvent("irregular_added");
  }

  void irregularPlanned() {
    amplitude.logEvent("irregular_planned");
  }

  void expenseAdded() {
    amplitude.logEvent("expense_added");
  }

  void expensePlanned() {
    amplitude.logEvent("expense_planned");
  }
}
