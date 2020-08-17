class AppValues {
  static String prepareToParse(String value) {
    if (value != null) {
      return value.trim().replaceAll(" ", "").replaceAll(",", ".");
    } else {
      return null;
    }
  }

  static String prepareToDisplay(num value) {
    // TODO detect what use "." or ","
    return value.toStringAsFixed(2).replaceAll(".00", "").replaceAll(".", ",");
  }
}
