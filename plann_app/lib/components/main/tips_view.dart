import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/main/tips_bloc.dart';
import 'package:provider/provider.dart';

class TipsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TipsBloc bloc = Provider.of<TipsBloc>(context);
    return Container(
        margin: EdgeInsets.all(10),
        height: 85,
        child: _buildTips(context, bloc));
  }

  Widget _buildTips(BuildContext context, TipsBloc bloc) {
    return PageView.builder(itemBuilder: (BuildContext context, int itemIndex) {
      Text title = Text(FlutterI18n.translate(context, bloc.getKey(itemIndex)),
          style: TextStyle(fontSize: 14, color: Colors.black45));
      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ListTile(title: title)],
        ),
      );
    });
  }
}
