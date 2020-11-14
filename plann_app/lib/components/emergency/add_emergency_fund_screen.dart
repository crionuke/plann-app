import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/emergency/add_emergency_fund_bloc.dart';
import 'package:plann_app/components/emergency/emergency_fund_item_bloc.dart';
import 'package:plann_app/components/emergency/emergency_fund_item_view.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class AddEmergencyFundScreen extends StatelessWidget {
  static const routeName = '/emergencyFund/add';

  @override
  Widget build(BuildContext context) {
    final AddEmergencyFundBloc bloc = Provider.of<AddEmergencyFundBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "texts.emergency_fund")),
          elevation: 0,
          flexibleSpace: GradientContainerWidget(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () {
                bloc.done(context);
              },
            )
          ],
        ),
        body: _buildBody(bloc));
  }

  Widget _buildBody(AddEmergencyFundBloc bloc) {
    return StreamBuilder(
        stream: bloc.stream,
        initialData: false,
        builder: (context, snapshot) {
          bool progress = snapshot.data;
          if (progress) {
            return ProgressIndicatorWidget();
          } else {
            return SafeArea(
                child: Provider<EmergencyFundItemBloc>(
                    create: (context) => bloc.itemBloc,
                    dispose: (context, bloc) => bloc.dispose(),
                    child: EmergencyFundItemView()));
          }
        });
  }
}
