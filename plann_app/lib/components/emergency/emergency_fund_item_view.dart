import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_date_fields.dart';
import 'package:plann_app/components/emergency/emergency_fund_item_bloc.dart';
import 'package:plann_app/components/widgets/currency_drop_down_widget.dart';
import 'package:provider/provider.dart';

class EmergencyFundItemView extends StatelessWidget {
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
    final EmergencyFundItemBloc bloc =
        Provider.of<EmergencyFundItemBloc>(context);
    const _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data as EmergencyFundItemViewState;
          return Column(children: <Widget>[
            CurrencyDropDownWidget(state.currencyErrorKey,
                state.currency, (value) => bloc.currencyChanged(value)),
            _sizedBox,
            _buildCurrentValueTextField(context, bloc, state),
            _sizedBox,
            _buildTargetValueTextField(context, bloc, state),
            _sizedBox,
            AppDateFields.buildPastDateTextField(
                context,
                state.startDate,
                'texts.date',
                state.startDateErrorKey,
                    (value) => bloc.startDateChanged(value)),
            _sizedBox,
            AppDateFields.buildFutureDateTextField(
                context,
                state.finishDate,
                "texts.date",
                state.finishDateErrorKey,
                    (value) => bloc.finishDateChanged(value))
          ]);
        });
  }

  Widget _buildCurrentValueTextField(BuildContext context,
      EmergencyFundItemBloc bloc, EmergencyFundItemViewState state) {
    return TextFormField(
      initialValue: state.currentValue,
      decoration: InputDecoration(
        icon: Icon(Icons.account_balance_wallet),
        border: OutlineInputBorder(),
        labelText: FlutterI18n.translate(context, 'texts.value') + '*',
        errorText: state.currentValueErrorKey != null
            ? FlutterI18n.translate(context, state.currentValueErrorKey)
            : null,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) => bloc.currentValueChanged(value),
    );
  }

  Widget _buildTargetValueTextField(BuildContext context,
      EmergencyFundItemBloc bloc, EmergencyFundItemViewState state) {
    return TextFormField(
      initialValue: state.targetValue,
      decoration: InputDecoration(
        icon: Icon(Icons.account_balance_wallet),
        border: OutlineInputBorder(),
        labelText: FlutterI18n.translate(context, 'texts.value') + '*',
        errorText: state.targetValueErrorKey != null
            ? FlutterI18n.translate(context, state.targetValueErrorKey)
            : null,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) => bloc.targetValueChanged(value),
    );
  }
}
