import 'package:flutter/material.dart';
import 'package:plann_app/components/app_date_fields.dart';
import 'package:plann_app/components/income/income_item_bloc.dart';
import 'package:plann_app/components/widgets/comment_text_field_widget.dart';
import 'package:plann_app/components/widgets/currency_drop_down_widget.dart';
import 'package:plann_app/components/widgets/decimal_text_field_widget.dart';
import 'package:plann_app/components/widgets/enum_drop_down_widget.dart';
import 'package:plann_app/components/widgets/tags/tags_bloc.dart';
import 'package:plann_app/components/widgets/tags/tags_widget.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:provider/provider.dart';

class IncomeItemView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final IncomeItemBloc bloc = Provider.of<IncomeItemBloc>(context);

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: CustomScrollView(slivers: <Widget>[
          SliverFillRemaining(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Form(
                    child: IncomeItemForm(bloc),
                  )))
        ]));
  }
}

class IncomeItemForm extends StatelessWidget {

  final IncomeItemBloc bloc;

  IncomeItemForm(this.bloc);

  @override
  Widget build(BuildContext context) {
    const _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data as IncomeItemViewState;
          return Column(children: <Widget>[
            DecimalTextFieldWidget(state.value, "texts.value",
                state.valueErrorKey, (value) => bloc.valueChanged(value),
                false),
            _sizedBox,
            CurrencyDropDownWidget(state.currencyErrorKey,
                state.currency, (value) => bloc.currencyChanged(value)),
            _sizedBox,
            AppDateFields.buildPastDateTextField(
                context,
                state.dateTime,
                'texts.date',
                state.dateTimeErrorKey,
                    (value) => bloc.dateTimeChanged(value)),
            _sizedBox,
            EnumDropDownWidget<IncomeCategoryType>(
                IncomeCategoryType.values,
                state.category,
                Icon(Icons.category),
                "texts.category",
                state.categoryErrorKey,
                    (value) => bloc.categoryChanged(value),
                "income_category_type_enum"),
            _sizedBox,
            CommentTextFieldWidget(
                state.comment, (value) => bloc.commentChanged(value)),
            Provider<TagsBloc>(
                create: (context) => bloc.tagsBloc,
                dispose: (context, bloc) => bloc.dispose(),
                child: TagsWidget())
          ]);
        });
  }
}
