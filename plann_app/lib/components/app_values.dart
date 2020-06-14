class AppValues {
  static String prepareToParse(String value) {
    if (value != null) {
      return value.trim().replaceAll(" ", "").replaceAll(",", ".");
    } else {
      return null;
    }
  }
}
