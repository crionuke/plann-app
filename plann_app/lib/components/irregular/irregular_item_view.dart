import 'package:flutter/material.dart';
import 'package:plann_app/components/app_date_fields.dart';
import 'package:plann_app/components/irregular/irregular_item_bloc.dart';
import 'package:plann_app/components/widgets/currency_drop_down_widget.dart';
import 'package:plann_app/components/widgets/decimal_text_field_widget.dart';
import 'package:plann_app/components/widgets/string_text_field_widget.dart';
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
                    child: IrregularItemForm(),
                  )))
        ]));
  }
}

class IrregularItemForm extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final IrregularItemBloc bloc = Provider.of<IrregularItemBloc>(context);
    const _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data as IrregularItemViewState;
          return Column(children: <Widget>[
            DecimalTextFieldWidget(state.value, "texts.value",
                state.valueErrorKey, (value) => bloc.valueChanged(value),
                false),
            _sizedBox,
            CurrencyDropDownWidget(state.currencyErrorKey,
                state.currency, (value) => bloc.currencyChanged(value)),
            _sizedBox,
            StringTextFieldWidget(state.title, "texts.title",
                state.titleErrorKey, (value) => bloc.titleChanged(value)),
            _sizedBox,
            AppDateFields.buildPastDateTextField(
                context, state.date, 'texts.date',
                state.dateTimeErrorKey, (value) => bloc.dateTimeChanged(value)),
          ]);
        });
  }
}
