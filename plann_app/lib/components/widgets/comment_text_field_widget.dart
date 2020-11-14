import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class CommentTextFieldWidget extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  CommentTextFieldWidget(this.initialValue, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
//        icon: Icon(Icons.comment),
        border: OutlineInputBorder(),
        labelText: FlutterI18n.translate(context, "texts.comment"),
      ),
      onChanged: onChanged,
      minLines: 5,
      maxLines: 5,
      maxLength: 256,
    );
  }
}
