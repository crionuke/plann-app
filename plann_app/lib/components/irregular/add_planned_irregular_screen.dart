import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/irregular/add_planned_irregular_bloc.dart';
import 'package:plann_app/components/irregular/planned_irregular_item_bloc.dart';
import 'package:plann_app/components/irregular/planned_irregular_item_view.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class AddPlannedIrregularScreen extends StatelessWidget {
  static const routeName = '/plannedIrregular/add';

  @override
  Widget build(BuildContext context) {
    final AddPlannedIrregularBloc bloc =
        Provider.of<AddPlannedIrregularBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
              FlutterI18n.translate(context, "texts.add_planned_irregular")),
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

  Widget _buildBody(AddPlannedIrregularBloc bloc) {
    return StreamBuilder(
        stream: bloc.stream,
        initialData: false,
        builder: (context, snapshot) {
          bool progress = snapshot.data;
          if (progress) {
            return ProgressIndicatorWidget();
          } else {
            return SafeArea(
                child: Provider<PlannedIrregularItemBloc>(
                    create: (context) => bloc.itemBloc,
                    dispose: (context, bloc) => bloc.dispose(),
                    child: PlannedIrregularItemView()));
          }
        });
  }
}
