import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class EnumDropDownWidget<T> extends StatelessWidget {
  final List<T> values;
  final T currentValue;
  final Icon icon;
  final String labelKey;
  final String errorKey;
  final ValueChanged<T> onChanged;
  final String i18nFolder;

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<T>> items =
        values.map<DropdownMenuItem<T>>((value) {
      return DropdownMenuItem<T>(
        value: value,
        child: new Text(
          FlutterI18n.translate(
              context, i18nFolder + "." + value.toString().split(".")[1]),
          style: TextStyle(fontSize: 14),
        ),
      );
    }).toList();
    return FormField<T>(builder: (FormFieldState<T> value) {
      return InputDecorator(
          isEmpty: currentValue == null,
          decoration: InputDecoration(
//            icon: icon,
            border: OutlineInputBorder(),
            labelText: FlutterI18n.translate(context, labelKey) + "*",
            errorText: errorKey != null
                ? FlutterI18n.translate(context, errorKey)
                : null,
          ),
          child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
            value: currentValue,
            isDense: true,
            onChanged: onChanged,
            items: items,
          )));
    });
  }

  EnumDropDownWidget(this.values, this.currentValue, this.icon, this.labelKey,
      this.errorKey, this.onChanged, this.i18nFolder);
}
