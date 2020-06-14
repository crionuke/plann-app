class AnalyticsUtils {
  static int toAbs(int year, int month) {
    return year * 12 + (month - 1);
  }

  static List toHuman(int monthIndex) {
    return [
      // Year
      monthIndex ~/ 12,
      // Month
      monthIndex % 12 + 1,
    ];
  }

  static int delta(int fromYear, int fromMonth, int toYear, int toMonth) {
    int deltaYears = toYear - fromYear;
    if (deltaYears > 0) {
      return (deltaYears - 1) * 12 + (toMonth - 1) + (12 - fromMonth + 1);
    } else {
      return toMonth - fromMonth;
    }
  }
}
