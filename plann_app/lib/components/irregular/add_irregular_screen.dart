import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/irregular/add_irregular_bloc.dart';
import 'package:plann_app/components/irregular/irregular_item_bloc.dart';
import 'package:plann_app/components/irregular/irregular_item_view.dart';
import 'package:provider/provider.dart';

class AddIrregularScreen extends StatelessWidget {
  static const routeName = '/irregular/add';

  @override
  Widget build(BuildContext context) {
    final AddIrregularBloc bloc = Provider.of<AddIrregularBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "texts.irregular_one")),
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

  Widget _buildBody(AddIrregularBloc bloc) {
    return StreamBuilder(
        stream: bloc.stream,
        initialData: false,
        builder: (context, snapshot) {
          bool progress = snapshot.data;
          if (progress) {
            return AppViews.buildProgressIndicator(context);
          } else {
            return SafeArea(
                child: Provider<IrregularItemBloc>(
                    create: (context) => bloc.itemBloc,
                    dispose: (context, bloc) => bloc.dispose(),
                    child: IrregularItemView()));
          }
        });
  }
}
