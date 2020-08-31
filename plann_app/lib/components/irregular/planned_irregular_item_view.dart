import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_fields.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/irregular/planned_irregular_item_bloc.dart';
import 'package:provider/provider.dart';

class PlannedIrregularItemView extends StatelessWidget {
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
    final PlannedIrregularItemBloc bloc =
        Provider.of<PlannedIrregularItemBloc>(context);
    final _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data;
          return Column(children: <Widget>[
            _buildCreationDateTextField(context, bloc, state),
            _sizedBox,
            _buildValueTextField(context, bloc, state),
            _sizedBox,
            _buildCurrencyDropDownButton(context, bloc, state),
            _sizedBox,
            _buildTitleTextField(context, bloc, state),
            _sizedBox,
            _buildDateTextField(context, bloc, state),
          ]);
        });
  }

  Widget _buildCreationDateTextField(BuildContext context,
      PlannedIrregularItemBloc bloc, PlannedIrregularItemViewState state) {
    return TextFormField(
      initialValue: AppTexts.formatDate(context, state.creationDate),
      decoration: InputDecoration(
        icon: Icon(Icons.date_range),
        border: OutlineInputBorder(),
        labelText: FlutterI18n.translate(context, "texts.creation_date") + "*",
      ),
      enabled: false,
    );
  }

  Widget _buildValueTextField(BuildContext context,
      PlannedIrregularItemBloc bloc, PlannedIrregularItemViewState state) {
    return AppFields.buildDecimalTextField(context, state.value, "texts.value",
        state.valueErrorKey, (value) => bloc.valueChanged(value));
  }

  Widget _buildCurrencyDropDownButton(BuildContext context,
      PlannedIrregularItemBloc bloc, PlannedIrregularItemViewState state) {
    return AppFields.buildCurrencyDropDownButton(
        context,
        "texts.currency",
        state.currencyErrorKey,
        state.currency,
        (value) => bloc.currencyChanged(value));
  }

  Widget _buildTitleTextField(BuildContext context,
      PlannedIrregularItemBloc bloc, PlannedIrregularItemViewState state) {
    return AppFields.buildStringTextField(context, state.title, "texts.title",
        state.titleErrorKey, (value) => bloc.titleChanged(value));
  }

  Widget _buildDateTextField(BuildContext context,
      PlannedIrregularItemBloc bloc, PlannedIrregularItemViewState state) {
    return AppFields.buildDateTextFieldFrom(
        context,
        state.creationDate,
        state.date,
        'texts.date',
        state.dateErrorKey,
        (value) => bloc.dateChanged(value));
  }
}
