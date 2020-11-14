import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/income/add_income_bloc.dart';
import 'package:plann_app/components/income/income_item_bloc.dart';
import 'package:plann_app/components/income/income_item_view.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class AddIncomeScreen extends StatelessWidget {
  static const routeName = '/income/add';

  @override
  Widget build(BuildContext context) {
    final AddIncomeBloc bloc = Provider.of<AddIncomeBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title:
              Text(FlutterI18n.translate(context, "texts.add_actual_income")),
          elevation: 0,
          flexibleSpace: AppViews.buildAppGradientContainer(context),
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

  Widget _buildBody(AddIncomeBloc bloc) {
    return StreamBuilder(
        stream: bloc.stream,
        initialData: false,
        builder: (context, snapshot) {
          bool progress = snapshot.data;
          if (progress) {
            return AppProgressIndicator();
          } else {
            return SafeArea(
                child: Provider<IncomeItemBloc>(
                    create: (context) => bloc.itemBloc,
                    dispose: (context, bloc) => bloc.dispose(),
                    child: IncomeItemView()));
          }
        });
  }
}
