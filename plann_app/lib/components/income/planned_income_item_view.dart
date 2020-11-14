import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_date_fields.dart';
import 'package:plann_app/components/income/planned_income_item_bloc.dart';
import 'package:plann_app/components/widgets/comment_text_field_widget.dart';
import 'package:plann_app/components/widgets/currency_drop_down_widget.dart';
import 'package:plann_app/components/widgets/enum_drop_down_widget.dart';
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
    const _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data as PlannedIncomeItemViewState;
          return Column(children: [
            _buildValueTextField(context, bloc, state),
            _sizedBox,
            CurrencyDropDownWidget(state.currencyErrorKey,
                state.currency, (value) => bloc.currencyChanged(value)),
            _sizedBox,
            EnumDropDownWidget<SubjectModeType>(
                SubjectModeType.values,
                state.mode,
                Icon(Icons.update),
                "texts.mode",
                state.modeErrorKey,
                    (value) => bloc.modeChanged(value),
                "subject_mode_type_enum"),
            _sizedBox,
            _buildDateTextField(context, bloc, state),
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
          ]);
        });
  }

  Widget _buildValueTextField(BuildContext context, PlannedIncomeItemBloc bloc,
      PlannedIncomeItemViewState state) {
    return TextFormField(
      initialValue: state.value,
      decoration: InputDecoration(
//        icon: Icon(Icons.account_balance_wallet),
        border: const OutlineInputBorder(),
        labelText: FlutterI18n.translate(context, 'texts.value') + '*',
        errorText: state.valueErrorKey != null
            ? FlutterI18n.translate(context, state.valueErrorKey)
            : null,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) => bloc.valueChanged(value),
    );
  }

  Widget _buildDateTextField(BuildContext context, PlannedIncomeItemBloc bloc,
      PlannedIncomeItemViewState state) {
    if (state.mode == SubjectModeType.onetime) {
      return AppDateFields.buildFutureDateTextField(context, state.date,
          "texts.date", state.dateErrorKey, (value) => bloc.dateChanged(value));
    } else {
      return Container();
    }
  }
}
