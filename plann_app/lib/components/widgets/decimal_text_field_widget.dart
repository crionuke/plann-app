import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class DecimalTextFieldWidget extends StatelessWidget {
  final String initialValue;
  final String labelTextKey;
  final String errorKey;
  final ValueChanged<String> onChanged;
  final bool autoFocus;

  DecimalTextFieldWidget(this.initialValue, this.labelTextKey, this.errorKey,
      this.onChanged, this.autoFocus);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autoFocus,
      initialValue: initialValue,
      decoration: InputDecoration(
//        icon: Icon(Icons.account_balance_wallet),
        border: OutlineInputBorder(),
        labelText: FlutterI18n.translate(context, labelTextKey) + "*",
        errorText:
        errorKey != null ? FlutterI18n.translate(context, errorKey) : null,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }
}
