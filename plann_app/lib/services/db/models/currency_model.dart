enum CurrencyType { rubles, euro, dollars }

const CURRENCY_FROM_DB_MAPPING = {
  "rubles": CurrencyType.rubles,
  "euro": CurrencyType.euro,
  "dollars": CurrencyType.dollars,
};

const CURRENCY_TO_DB_MAPPING = {
  CurrencyType.rubles: "rubles",
  CurrencyType.euro: "euro",
  CurrencyType.dollars: "dollars",
};
