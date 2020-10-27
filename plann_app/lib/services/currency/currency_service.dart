class CurrencyService {
  Future<void> start() async {
    print("[CurrencyService] starting");
  }

  double exchangeDollarsToRubles(double value) {
    return value * 75;
  }

  double exchangeEuroToRubles(double value) {
    return value * 90;
  }
}
