import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/services/db/models/currency_model.dart';

class CurrencyDropDownWidget extends StatelessWidget {
  final String errorKey;
  final CurrencyType value;
  final ValueChanged<CurrencyType> onChanged;

  CurrencyDropDownWidget(this.errorKey, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<CurrencyType>> items =
        CurrencyType.values.map<DropdownMenuItem<CurrencyType>>((currency) {
      return DropdownMenuItem<CurrencyType>(
        value: currency,
        child: new Text(FlutterI18n.translate(context,
            "currency_type_enum." + currency.toString().split(".")[1])),
      );
    }).toList();

    return new FormField<CurrencyType>(
        builder: (FormFieldState<CurrencyType> state) {
      return InputDecorator(
          isEmpty: value == null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: FlutterI18n.translate(context, "texts.currency") + "*",
            errorText: errorKey != null
                ? FlutterI18n.translate(context, errorKey)
                : null,
          ),
          child: DropdownButtonHideUnderline(
              child: DropdownButton<CurrencyType>(
            value: value,
            isDense: true,
            onChanged: onChanged,
            items: items,
          )));
    });
  }
}
