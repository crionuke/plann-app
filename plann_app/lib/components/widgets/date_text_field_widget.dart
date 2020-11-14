import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';

class DateTextFieldWidget extends StatelessWidget {
  final DateTime initialValue;
  final String labelKey;
  final String errorKey;
  final DateTime firstDate;
  final DateTime initialDate;
  final DateTime lastDate;
  final Function(DateTime value) onChanged;

  DateTextFieldWidget(this.initialValue, this.labelKey, this.errorKey,
      this.firstDate, this.initialDate, this.lastDate, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat format = DateFormat.yMMMMd(locale.toString());

    return DateTimeField(
        initialValue: initialValue,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: FlutterI18n.translate(context, labelKey) + '*',
          errorText: errorKey != null
              ? FlutterI18n.translate(context, errorKey)
              : null,
        ),
        format: format,
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: firstDate,
              initialDate: currentValue ?? initialDate,
              lastDate: lastDate);
        },
        onChanged: onChanged);
  }
}
