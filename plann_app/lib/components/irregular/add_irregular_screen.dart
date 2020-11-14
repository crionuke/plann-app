import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/irregular/add_irregular_bloc.dart';
import 'package:plann_app/components/irregular/irregular_item_bloc.dart';
import 'package:plann_app/components/irregular/irregular_item_view.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class AddIrregularScreen extends StatelessWidget {
  static const routeName = '/irregular/add';

  @override
  Widget build(BuildContext context) {
    final AddIrregularBloc bloc = Provider.of<AddIrregularBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
              FlutterI18n.translate(context, "texts.add_actual_irregular")),
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

  Widget _buildBody(AddIrregularBloc bloc) {
    return StreamBuilder(
        stream: bloc.stream,
        initialData: false,
        builder: (context, snapshot) {
          bool progress = snapshot.data;
          if (progress) {
            return ProgressIndicatorWidget();
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
