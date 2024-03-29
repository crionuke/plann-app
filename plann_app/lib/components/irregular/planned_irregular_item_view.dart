import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_date_fields.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/irregular/planned_irregular_item_bloc.dart';
import 'package:plann_app/components/widgets/currency_drop_down_widget.dart';
import 'package:plann_app/components/widgets/decimal_text_field_widget.dart';
import 'package:plann_app/components/widgets/string_text_field_widget.dart';
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
                    child: _buildForm(context),
                  )))
        ]));
  }

  Widget _buildForm(BuildContext context) {
    final PlannedIrregularItemBloc bloc =
        Provider.of<PlannedIrregularItemBloc>(context);
    const _sizedBox = SizedBox(height: 10);
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data;
          return Column(children: <Widget>[
            _buildCreationDateTextField(context, bloc, state),
            _sizedBox,
            DecimalTextFieldWidget(state.value, "texts.value",
                state.valueErrorKey, (value) => bloc.valueChanged(value),
                false),
            _sizedBox,
            CurrencyDropDownWidget(state.currencyErrorKey,
                state.currency, (value) => bloc.currencyChanged(value)),
            _sizedBox,
            StringTextFieldWidget(state.title, "texts.title",
                state.titleErrorKey, (value) => bloc.titleChanged(value),
                false),
            _sizedBox,
            AppDateFields.buildFromDateTextField(
                context,
                state.creationDate,
                state.date,
                'texts.date',
                state.dateErrorKey,
                    (value) => bloc.dateChanged(value))
          ]);
        });
  }

  Widget _buildCreationDateTextField(BuildContext context,
      PlannedIrregularItemBloc bloc, PlannedIrregularItemViewState state) {
    return TextFormField(
      initialValue: AppTexts.formatDate(context, state.creationDate),
      decoration: InputDecoration(
//        icon: Icon(Icons.date_range),
        border: const OutlineInputBorder(),
        labelText: FlutterI18n.translate(context, "texts.creation_date") + "*",
      ),
      enabled: false,
    );
  }
}
