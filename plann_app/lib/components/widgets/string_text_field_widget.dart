import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class StringTextFieldWidget extends StatelessWidget {
  final String initialValue;
  final String labelTextKey;
  final String errorKey;
  final ValueChanged<String> onChanged;

  StringTextFieldWidget(
      this.initialValue, this.labelTextKey, this.errorKey, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
//        icon: Icon(Icons.account_balance_wallet),
        border: OutlineInputBorder(),
        labelText: FlutterI18n.translate(context, labelTextKey) + "*",
        errorText:
            errorKey != null ? FlutterI18n.translate(context, errorKey) : null,
      ),
      onChanged: onChanged,
      maxLength: 128,
    );
  }
}
