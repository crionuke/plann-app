import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class StringTextFieldWidget extends StatelessWidget {
  final String initialValue;
  final String labelTextKey;
  final String errorKey;
  final ValueChanged<String> onChanged;
  final bool autoFocus;

  StringTextFieldWidget(this.initialValue, this.labelTextKey, this.errorKey,
      this.onChanged, this.autoFocus);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autoFocus,
      initialValue: initialValue,
      decoration: InputDecoration(
//        icon: Icon(Icons.account_balance_wallet),
        border: const OutlineInputBorder(),
        labelText: FlutterI18n.translate(context, labelTextKey) + "*",
        errorText:
        errorKey != null ? FlutterI18n.translate(context, errorKey) : null,
      ),
      onChanged: onChanged,
      maxLength: 128,
    );
  }
}
