import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_dialogs.dart';
import 'package:plann_app/components/tags/edit_tag_bloc.dart';
import 'package:plann_app/components/tags/tag_item_bloc.dart';
import 'package:plann_app/components/tags/tag_item_view.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class EditTagScreen extends StatelessWidget {
  static const routeName = '/tag/edit';

  @override
  Widget build(BuildContext context) {
    final EditTagBloc bloc = Provider.of<EditTagBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "texts.tag")),
          elevation: 0,
          flexibleSpace: GradientContainerWidget(),
          actions: <Widget>[
            PopupMenuButton<int>(
              onSelected: (index) async {
                switch (index) {
                  case 0:
                    if (await bloc.done()) {
                      Navigator.pop(context);
                    }
                    break;
                  case 1:
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AppDialogs.buildConfirmDeletionDialog(
                              context, () => Navigator.of(context).pop(),
                              () async {
                            // Hide AlertDialog
                            Navigator.pop(context);
                            await bloc.delete();
                            Navigator.pop(context, true);
                          });
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

  Widget _buildBody(EditTagBloc bloc) {
    return StreamBuilder(
        stream: bloc.stream,
        initialData: false,
        builder: (context, snapshot) {
          bool progress = snapshot.data;
          if (progress) {
            return ProgressIndicatorWidget();
          } else {
            return SafeArea(
                child: Provider<TagItemBloc>(
                    create: (context) => bloc.itemBloc,
                    dispose: (context, bloc) => bloc.dispose(),
                    child: TagItemView()));
          }
        });
  }
}
