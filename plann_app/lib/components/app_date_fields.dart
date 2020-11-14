import 'package:flutter/material.dart';
import 'package:plann_app/components/widgets/date_text_field_widget.dart';

class AppDateFields {

  static Widget buildPastDateTextField(
      BuildContext context,
      DateTime initialValue,
      String labelKey,
      String errorKey,
      Function(DateTime value) onChanged) {
    DateTime now = DateTime.now();
    return DateTextFieldWidget(
        initialValue,
        labelKey,
        errorKey,
        DateTime(1900),
        now,
        now,
        onChanged);
  }

  static Widget buildFutureDateTextField(BuildContext context,
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
    return DateTextFieldWidget(
        initialValue,
        labelKey,
        errorKey,
        firstDate,
        initialValue != null ? initialValue : firstDate,
        DateTime(2100),
        onChanged);
  }

  static Widget buildFromDateTextField(
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
    return DateTextFieldWidget(
        initialValue,
        labelKey,
        errorKey,
        from,
        initialValue != null ? initialValue : from,
        DateTime(2100),
        onChanged);
  }
}
