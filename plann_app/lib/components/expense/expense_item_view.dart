import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_fields.dart';
import 'package:plann_app/components/expense/expense_item_bloc.dart';
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
    final ExpenseItemBloc bloc = Provider.of<ExpenseItemBloc>(context);
    final _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data as ExpenseItemViewState;
          return Column(children: <Widget>[
            _buildValueTextField(context, bloc, state),
            _sizedBox,
            _buildCurrencyDropDownButton(context, bloc, state),
            _sizedBox,
            _buildDateTextField(context, bloc, state),
            _sizedBox,
            _buildCategoryDropDownButton(context, bloc, state),
            _sizedBox,
            _buildCommentTextField(context, bloc, state),
          ]);
        });
  }

  Widget _buildValueTextField(
      BuildContext context, ExpenseItemBloc bloc, ExpenseItemViewState state) {
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

  Widget _buildCurrencyDropDownButton(
      BuildContext context, ExpenseItemBloc bloc, ExpenseItemViewState state) {
    return AppFields.buildCurrencyDropDownButton(
        context,
        "texts.currency",
        state.currencyErrorKey,
        state.currency,
        (value) => bloc.currencyChanged(value));
  }

  Widget _buildDateTextField(
      BuildContext context, ExpenseItemBloc bloc, ExpenseItemViewState state) {
    return AppFields.buildDateTextFieldPast(context, state.date, 'texts.date',
        state.dateErrorKey, (value) => bloc.dateChanged(value));
  }

  Widget _buildCategoryDropDownButton(
      BuildContext context, ExpenseItemBloc bloc, ExpenseItemViewState state) {
    return AppFields.buildEnumTextField<ExpenseCategoryType>(
        context,
        ExpenseCategoryType.values,
        state.category,
        Icon(Icons.category),
        "texts.category",
        state.categoryErrorKey,
        (value) => bloc.categoryChanged(value),
        "expense_category_type_enum");
  }

  Widget _buildCommentTextField(
      BuildContext context, ExpenseItemBloc bloc, ExpenseItemViewState state) {
    return AppFields.buildCommentTextField(context, state.comment,
        "texts.comment", (value) => bloc.commentChanged(value));
  }
}
