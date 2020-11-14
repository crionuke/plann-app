import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_fields.dart';
import 'package:plann_app/components/income/income_item_bloc.dart';
import 'package:plann_app/components/widgets/currency_drop_down_widget.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:provider/provider.dart';

class IncomeItemView extends StatelessWidget {
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
                    child: _buildForm(context),
                  )))
        ]));
  }

  Widget _buildForm(BuildContext context) {
    final IncomeItemBloc bloc = Provider.of<IncomeItemBloc>(context);
    const _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data as IncomeItemViewState;
          return Column(children: <Widget>[
            _buildValueTextField(context, bloc, state),
            _sizedBox,
            CurrencyDropDownWidget(state.currencyErrorKey,
                state.currency, (value) => bloc.currencyChanged(value)),
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
      BuildContext context, IncomeItemBloc bloc, IncomeItemViewState state) {
    return TextFormField(
      initialValue: state.value,
      decoration: InputDecoration(
//        icon: Icon(Icons.account_balance_wallet),
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

  Widget _buildDateTextField(
      BuildContext context, IncomeItemBloc bloc, IncomeItemViewState state) {
    return AppFields.buildDateTextFieldPast(
        context,
        state.dateTime,
        'texts.date',
        state.dateTimeErrorKey,
        (value) => bloc.dateTimeChanged(value));
  }

  Widget _buildCategoryDropDownButton(
      BuildContext context, IncomeItemBloc bloc, IncomeItemViewState state) {
    return AppFields.buildEnumTextField<IncomeCategoryType>(
        context,
        IncomeCategoryType.values,
        state.category,
        Icon(Icons.category),
        "texts.category",
        state.categoryErrorKey,
        (value) => bloc.categoryChanged(value),
        "income_category_type_enum");
  }

  Widget _buildCommentTextField(
      BuildContext context, IncomeItemBloc bloc, IncomeItemViewState state) {
    return AppFields.buildCommentTextField(context, state.comment,
        "texts.comment", (value) => bloc.commentChanged(value));
  }
}
