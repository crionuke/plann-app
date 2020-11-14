import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/irregular/edit_irregular_bloc.dart';
import 'package:plann_app/components/irregular/irregular_item_bloc.dart';
import 'package:plann_app/components/irregular/irregular_item_view.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class EditIrregularScreen extends StatelessWidget {
  static const routeName = '/irregular/edit';

  @override
  Widget build(BuildContext context) {
    final EditIrregularBloc bloc = Provider.of<EditIrregularBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "texts.irregular_one")),
          elevation: 0,
          flexibleSpace: AppViews.buildAppGradientContainer(context),
          actions: <Widget>[
            PopupMenuButton<int>(
              onSelected: (index) {
                switch (index) {
                  case 0:
                    bloc.done(context);
                    break;
                  case 1:
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(FlutterI18n.translate(
                                context, "texts.deletion")),
                            content: SingleChildScrollView(
                                child: ListBody(
                              children: <Widget>[
                                Text(FlutterI18n.translate(
                                    context, "texts.confirm_deletion")),
                              ],
                            )),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(
                                    FlutterI18n.translate(context, "texts.no")),
                                onPressed: () {
                                  // Hide AlertDialog
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text(FlutterI18n.translate(
                                    context, "texts.yes")),
                                onPressed: () {
                                  // Hide AlertDialog
                                  Navigator.pop(context);
                                  bloc.delete(context);
                                },
                              ),
                            ],
                          );
                        });
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<int>(
                  value: 0,
                  child: ListTile(
                    title: Text(FlutterI18n.translate(context, "texts.save")),
                    leading: Icon(Icons.save),
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: ListTile(
                    title: Text(FlutterI18n.translate(context, "texts.delete")),
                    leading: Icon(Icons.delete),
                  ),
                )
              ],
            ),
          ],
        ),
        body: _buildBody(bloc));
  }

  Widget _buildBody(EditIrregularBloc bloc) {
    return StreamBuilder(
        stream: bloc.stream,
        initialData: false,
        builder: (context, snapshot) {
          bool progress = snapshot.data;
          if (progress) {
            return AppProgressIndicator();
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
