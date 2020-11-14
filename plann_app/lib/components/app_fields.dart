import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:plann_app/services/db/models/currency_model.dart';

class AppFields {

  static Widget buildDateTextField(BuildContext context, DateTime initialValue,
      String labelKey, String errorKey, Function(DateTime value) onChanged) {
    DateTime now = DateTime.now();
    return _buildDateTextField(context, initialValue, labelKey, errorKey,
        DateTime(1900), now, DateTime(2100), onChanged);
  }

  static Widget buildDateTextFieldPast(
      BuildContext context,
      DateTime initialValue,
      String labelKey,
      String errorKey,
      Function(DateTime value) onChanged) {
    DateTime now = DateTime.now();
    return _buildDateTextField(context, initialValue, labelKey, errorKey,
        DateTime(1900), now, now, onChanged);
  }

  static Widget buildDateTextFieldFrom(
      BuildContext context,
      DateTime from,
      DateTime initialValue,
      String labelKey,
      String errorKey,
      Function(DateTime value) onChanged) {
    if (initialValue != null) {
      if (initialValue.compareTo(from) < 0) {
        initialValue = from;
      }
    }

    return _buildDateTextField(context, initialValue, labelKey, errorKey, from,
        initialValue != null ? initialValue : from, DateTime(2100), onChanged);
  }

  static Widget buildDateTextFieldFuture(
      BuildContext context,
      DateTime initialValue,
      String labelKey,
      String errorKey,
      Function(DateTime value) onChanged) {
    DateTime firstDate = DateTime.now().add(Duration(days: 1));
    if (initialValue != null) {
      if (initialValue.compareTo(firstDate) < 0) {
        firstDate = initialValue;
      }
    }

    return _buildDateTextField(
        context,
        initialValue,
        labelKey,
        errorKey,
        firstDate,
        initialValue != null ? initialValue : firstDate,
        DateTime(2100),
        onChanged);
  }

  static Widget _buildDateTextField(
      BuildContext context,
      DateTime initialValue,
      String labelKey,
      String errorKey,
      DateTime firstDate,
      DateTime initialDate,
      DateTime lastDate,
      Function(DateTime value) onChanged) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat format = DateFormat.yMMMMd(locale.toString());

    return DateTimeField(
        initialValue: initialValue,
        decoration: InputDecoration(
//          icon: Icon(Icons.date_range),
          border: OutlineInputBorder(),
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

  static Widget buildCommentTextField(BuildContext context, String initialValue,
      String labelKey, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
//        icon: Icon(Icons.comment),
        border: OutlineInputBorder(),
        labelText: FlutterI18n.translate(context, labelKey),
      ),
      onChanged: onChanged,
      minLines: 5,
      maxLines: 5,
      maxLength: 256,
    );
  }

  static Widget buildEnumTextField<T>(
      BuildContext context,
      List<T> values,
      currentValue,
      Icon icon,
      String labelKey,
      String errorKey,
      ValueChanged<T> onChanged,
      String i18nFolder) {
    return new FormField<T>(builder: (FormFieldState<T> value) {
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
            items: values.map<DropdownMenuItem<T>>((category) {
              return DropdownMenuItem<T>(
                value: category,
                child: new Text(
                  FlutterI18n.translate(context,
                      i18nFolder + "." + category.toString().split(".")[1]),
                  style: TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          )));
    });
  }
}
