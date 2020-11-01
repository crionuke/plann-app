import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_fields.dart';
import 'package:plann_app/components/income/planned_income_item_bloc.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/subject_mode_model.dart';
import 'package:provider/provider.dart';

class PlannedIncomeItemView extends StatelessWidget {
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
    final PlannedIncomeItemBloc bloc =
        Provider.of<PlannedIncomeItemBloc>(context);
    final _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data as PlannedIncomeItemViewState;
          return Column(children: [
            _buildValueTextField(context, bloc, state),
            _sizedBox,
            _buildCurrencyDropDownButton(context, bloc, state),
            _sizedBox,
            _buildModeDropDownButton(context, bloc, state),
            _sizedBox,
            _buildDateTextField(context, bloc, state),
            _sizedBox,
            _buildCategoryDropDownButton(context, bloc, state),
            _sizedBox,
            _buildCommentTextField(context, bloc, state),
          ]);
        });
  }

  Widget _buildValueTextField(BuildContext context, PlannedIncomeItemBloc bloc,
      PlannedIncomeItemViewState state) {
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

  Widget _buildCurrencyDropDownButton(BuildContext context,
      PlannedIncomeItemBloc bloc, PlannedIncomeItemViewState state) {
    return AppFields.buildCurrencyDropDownButton(
        context,
        "texts.currency",
        state.currencyErrorKey,
        state.currency,
        (value) => bloc.currencyChanged(value));
  }

  Widget _buildModeDropDownButton(BuildContext context,
      PlannedIncomeItemBloc bloc, PlannedIncomeItemViewState state) {
    return AppFields.buildEnumTextField<SubjectModeType>(
        context,
        SubjectModeType.values,
        state.mode,
        Icon(Icons.update),
        "texts.mode",
        state.modeErrorKey,
        (value) => bloc.modeChanged(value),
        "subject_mode_type_enum");
  }

  Widget _buildDateTextField(BuildContext context, PlannedIncomeItemBloc bloc,
      PlannedIncomeItemViewState state) {
    if (state.mode == SubjectModeType.onetime) {
      return AppFields.buildDateTextFieldFuture(context, state.date,
          "texts.date", state.dateErrorKey, (value) => bloc.dateChanged(value));
    } else {
      return Container();
    }
  }

  Widget _buildCategoryDropDownButton(BuildContext context,
      PlannedIncomeItemBloc bloc, PlannedIncomeItemViewState state) {
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

  Widget _buildCommentTextField(BuildContext context,
      PlannedIncomeItemBloc bloc, PlannedIncomeItemViewState state) {
    return AppFields.buildCommentTextField(context, state.comment,
        "texts.comment", (value) => bloc.commentChanged(value));
  }
}
