import 'package:plann_app/services/db/models/expense_to_tag_model.dart';
import 'package:plann_app/services/db/models/income_to_tag_model.dart';
import 'package:plann_app/services/db/models/tag_model.dart';

class AnalyticsTags {
  final List<TagModel> tagList;
  final List<ExpenseToTagModel> expenseTags;
  final List<IncomeToTagModel> incomeTags;

  Map<int, TagModel> tagById;
  Map<int, TagModel> tagByExpenseId;
  Map<int, TagModel> tagByIncomeId;

  AnalyticsTags(this.tagList, this.expenseTags, this.incomeTags) {
    tagById = Map();
    tagList.forEach((model) {
      tagById[model.id] = model;
    });
    tagByExpenseId = Map();
    tagByIncomeId = Map();
    expenseTags.forEach((model) {
      if (tagById.containsKey(model.tagId)) {
        tagByExpenseId[model.expenseId] = tagById[model.tagId];
      }
    });
    incomeTags.forEach((model) {
      if (tagById.containsKey(model.tagId)) {
        tagByIncomeId[model.incomeId] = tagById[model.tagId];
      }
    });
  }

  TagModel getExpenseTag(int expenseId) {
    return tagByExpenseId[expenseId];
  }

  TagModel getIncomeTag(int incomeId) {
    return tagByIncomeId[incomeId];
  }

  String getTagName(int tagId) {
    if (tagById.containsKey(tagId)) {
      return tagById[tagId].name;
    } else {
      return "";
    }
  }
}
