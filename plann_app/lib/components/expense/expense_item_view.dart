import 'package:flutter/material.dart';
import 'package:plann_app/components/app_date_fields.dart';
import 'package:plann_app/components/expense/expense_item_bloc.dart';
import 'package:plann_app/components/widgets/comment_text_field_widget.dart';
import 'package:plann_app/components/widgets/currency_drop_down_widget.dart';
import 'package:plann_app/components/widgets/decimal_text_field_widget.dart';
import 'package:plann_app/components/widgets/enum_drop_down_widget.dart';
import 'package:plann_app/components/widgets/tags/tags_bloc.dart';
import 'package:plann_app/components/widgets/tags/tags_widget.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:provider/provider.dart';

class ExpenseItemView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: CustomScrollView(slivers: <Widget>[
          SliverFillRemaining(
              child: ExpenseItem())
        ]));
  }
}

class ExpenseItem extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final ExpenseItemBloc bloc = Provider.of<ExpenseItemBloc>(context);
    const _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            bloc.requestState();
          } else {
            var state = snapshot.data;
            if (state.loaded) {
              var state = snapshot.data as ExpenseItemViewState;
              return SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Form(
                    child: Form(child: Column(children: <Widget>[
                      DecimalTextFieldWidget(state.value, "texts.value",
                          state.valueErrorKey, (value) =>
                              bloc.valueChanged(value),
                          true),
                      _sizedBox,
                      CurrencyDropDownWidget(state.currencyErrorKey,
                          state.currency, (value) =>
                              bloc.currencyChanged(value)),
                      _sizedBox,
                      AppDateFields.buildPastDateTextField(
                          context, state.date, 'texts.date',
                          state.dateErrorKey, (value) =>
                          bloc.dateChanged(value)),
                      _sizedBox,
                      EnumDropDownWidget<ExpenseCategoryType>(
                          ExpenseCategoryType.values,
                          state.category,
                          Icon(Icons.category),
                          "texts.category",
                          state.categoryErrorKey,
                              (value) => bloc.categoryChanged(value),
                          "expense_category_type_enum"),
                      _sizedBox,
                      CommentTextFieldWidget(
                          state.comment, (value) =>
                          bloc.commentChanged(value)),
                        Provider<TagsBloc>(
                            create: (context) => bloc.tagsBloc,
                            dispose: (context, bloc) => bloc.dispose(),
                            child: TagsWidget())
                    ])),
                  ));
            }
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}