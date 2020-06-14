import 'package:flutter/material.dart';
import 'package:plann_app/components/app_fields.dart';
import 'package:plann_app/components/irregular/irregular_item_bloc.dart';
import 'package:provider/provider.dart';

class IrregularItemView extends StatelessWidget {
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
    final IrregularItemBloc bloc = Provider.of<IrregularItemBloc>(context);
    final _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data as IrregularItemViewState;
          return Column(children: <Widget>[
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

  Widget _buildValueTextField(BuildContext context, IrregularItemBloc bloc,
      IrregularItemViewState state) {
    return AppFields.buildDecimalTextField(context, state.value, "texts.value",
        state.valueErrorKey, (value) => bloc.valueChanged(value));
  }

  Widget _buildCurrencyDropDownButton(BuildContext context,
      IrregularItemBloc bloc, IrregularItemViewState state) {
    return AppFields.buildCurrencyDropDownButton(
        context,
        "texts.currency",
        state.currencyErrorKey,
        state.currency,
        (value) => bloc.currencyChanged(value));
  }

  Widget _buildTitleTextField(BuildContext context, IrregularItemBloc bloc,
      IrregularItemViewState state) {
    return AppFields.buildStringTextField(context, state.title, "texts.title",
        state.titleErrorKey, (value) => bloc.titleChanged(value));
  }

  Widget _buildDateTextField(BuildContext context, IrregularItemBloc bloc,
      IrregularItemViewState state) {
    return AppFields.buildDateTextFieldPast(context, state.date, 'texts.date',
        state.dateTimeErrorKey, (value) => bloc.dateTimeChanged(value));
  }
}
