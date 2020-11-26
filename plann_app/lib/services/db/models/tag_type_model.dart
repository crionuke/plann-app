enum TagType {
  expense,
  income,
  irregular,
}

const TAG_TYPE_FROM_DB_MAPPING = {
  "expense": TagType.expense,
  "income": TagType.income,
  "irregular": TagType.irregular,
};

const TAG_TYPE_TO_DB_MAPPING = {
  TagType.expense: "expense",
  TagType.income: "income",
  TagType.irregular: "irregular",
};
