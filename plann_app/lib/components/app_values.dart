class AppValues {
  static String prepareToParse(String value) {
    if (value != null) {
      return value.trim().replaceAll(" ", "").replaceAll(",", ".");
    } else {
      return null;
    }
  }

  static String prepareToDisplay(num value, {num fixed = 2}) {
    // TODO detect what use "." or ","
    return value.toStringAsFixed(fixed)
        .replaceAll(".00", "")
        .replaceAll(".0", "")
        .replaceAll(".", ",");
  }
}
