import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/tags/add_tag_bloc.dart';
import 'package:plann_app/components/tags/tag_item_bloc.dart';
import 'package:plann_app/components/tags/tag_item_view.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class AddTagScreen extends StatelessWidget {
  static const routeName = '/tag/add';

  @override
  Widget build(BuildContext context) {
    final AddTagBloc bloc = Provider.of<AddTagBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "texts.tag")),
          elevation: 0,
          flexibleSpace: GradientContainerWidget(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () async {
                if (await bloc.done()) {
                  Navigator.pop(context, true);
                }
              },
            )
          ],
        ),
        body: _buildBody(bloc));
  }

  Widget _buildBody(AddTagBloc bloc) {
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
