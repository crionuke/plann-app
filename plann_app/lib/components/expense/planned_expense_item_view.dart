import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_fields.dart';
import 'package:plann_app/components/expense/planned_expense_item_bloc.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:provider/provider.dart';

class PlannedExpenseItemView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: CustomScrollView(slivers: <Widget>[
          SliverFillRemaining(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Form(
                    child: Column(children: <Widget>[
                      _buildForm(context),
                    ]),
                  )))
        ]));
  }

  Widget _buildForm(BuildContext context) {
    final PlannedExpenseItemBloc bloc =
        Provider.of<PlannedExpenseItemBloc>(context);
    final _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data;
          return Column(children: <Widget>[
            _buildValueTextField(context, bloc, state),
            _sizedBox,
            _buildCurrencyDropDownButton(context, bloc, state),
            _sizedBox,
            _buildCategoryDropDownButton(context, bloc, state),
            _sizedBox,
            _buildCommentTextField(context, bloc, state),
          ]);
        });
  }

  Widget _buildValueTextField(BuildContext context, PlannedExpenseItemBloc bloc,
      PlannedExpenseItemViewState state) {
    return TextFormField(
      initialValue: state.value,
      decoration: InputDecoration(
        icon: Icon(Icons.account_balance_wallet),
        border: OutlineInputBorder(),
        labelText: FlutterI18n.translate(context, 'texts.value') + '*',
        errorText: state.valueErrorKey != null
            ? FlutterI18n.translate(context, state.valueErrorKey)
            : null,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) => bloc.valueChanged(value),
    );
  }

  Widget _buildCurrencyDropDownButton(BuildContext context,
      PlannedExpenseItemBloc bloc, PlannedExpenseItemViewState state) {
    return AppFields.buildCurrencyDropDownButton(
        context,
        "texts.currency",
        state.currencyErrorKey,
        state.currency,
        (value) => bloc.currencyChanged(value));
  }

  Widget _buildCategoryDropDownButton(BuildContext context,
      PlannedExpenseItemBloc bloc, PlannedExpenseItemViewState state) {
    return AppFields.buildEnumTextField(
        context,
        ExpenseCategoryType.values,
        state.category,
        Icon(Icons.category),
        "texts.category",
        state.categoryErrorKey,
        (value) => bloc.categoryChanged(value),
        "expense_category_type_enum");
  }

  Widget _buildCommentTextField(BuildContext context,
      PlannedExpenseItemBloc bloc, PlannedExpenseItemViewState state) {
    return AppFields.buildCommentTextField(context, state.comment,
        "texts.comment", (value) => bloc.commentChanged(value));
  }
}
