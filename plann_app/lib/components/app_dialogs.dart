import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class AppDialogs {
  static Widget buildAlertDialog(
      BuildContext context, String titleKey, String contentText) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(context, titleKey)),
      content: SingleChildScrollView(
          child: ListBody(
        children: <Widget>[
          Text(contentText),
        ],
      )),
      actions: <Widget>[
        FlatButton(
          child: Text(FlutterI18n.translate(context, "texts.close")),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  static Widget buildHelpDialog(
      BuildContext context, String titleKey, String contentText) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(16),
      titlePadding: EdgeInsets.all(16),
      title: Text(FlutterI18n.translate(context, titleKey),
          style: TextStyle(fontSize: 18)),
      content: Text(FlutterI18n.translate(context, contentText),
          style: TextStyle(fontSize: 14), textAlign: TextAlign.justify,),
      actions: <Widget>[
        FlatButton(
          child: Text(FlutterI18n.translate(context, "texts.close")),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  static Widget buildConfirmDeletionDialog(
      BuildContext context, VoidCallback noCallback, VoidCallback yesCallback) {
    return AlertDialog(
      title: Text(FlutterI18n.translate(context, "texts.delete")),
      content: SingleChildScrollView(
          child: ListBody(
        children: <Widget>[
          Text(FlutterI18n.translate(context, "texts.confirm_deletion")),
        ],
      )),
      actions: <Widget>[
        FlatButton(
          child: Text(FlutterI18n.translate(context, "texts.no")),
          onPressed: noCallback,
        ),
        FlatButton(
          child: Text(FlutterI18n.translate(context, "texts.yes")),
          onPressed: yesCallback,
        ),
      ],
    );
  }
}
