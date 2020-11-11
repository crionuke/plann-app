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
        height: 140,
        child: _buildTips(context, bloc));
  }

  Widget _buildTips(BuildContext context, TipsBloc bloc) {
    return PageView.builder(itemBuilder: (BuildContext context, int itemIndex) {
      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(FlutterI18n.translate(context, "tips.header")),
            ),
            ListTile(
                subtitle: Text(
                    FlutterI18n.translate(context, bloc.getKey(itemIndex)) +
                        "\n")),
          ],
        ),
      );
    });
  }
}
