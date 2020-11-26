import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:plann_app/components/app_dialogs.dart';
import 'package:plann_app/components/tags/add_tag_screen.dart';
import 'package:plann_app/components/tags/edit_tag_screen.dart';
import 'package:plann_app/components/tags/tag_selection_bloc.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:plann_app/services/db/models/tag_model.dart';
import 'package:provider/provider.dart';

class TagSelectionScreen extends StatelessWidget {
  static const routeName = '/tags/select';

  @override
  Widget build(BuildContext context) {
    final TagSelectionBloc bloc = Provider.of<TagSelectionBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "texts.tag_selection")),
          elevation: 0,
          actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  bool added = await Navigator.pushNamed<bool>(
                      context, AddTagScreen.routeName);
                  if (added != null && added) {
                    bloc.requestState();
                  }
                })
          ],
          flexibleSpace: GradientContainerWidget(),
        ),
        body: _buildBody(bloc));
  }

  Widget _buildBody(TagSelectionBloc bloc) {
    return StreamBuilder(
        stream: bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            bloc.requestState();
          } else {
            var state = snapshot.data;
            if (state.loaded) {
              return _buildListView(context, bloc, state);
            }
          }
          return ProgressIndicatorWidget();
        });
  }

  Widget _buildListView(BuildContext context, TagSelectionBloc bloc,
      TagSelectionViewState state) {
    if (state.tags.isEmpty) {
      return _buildNoTags(context);
    } else {
      return _buildTagsView(context, bloc, state);
    }
  }

  Widget _buildNoTags(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Text(FlutterI18n.translate(context, "texts.no_tags")),
      ))
    ]);
  }

  Widget _buildTagsView(BuildContext context, TagSelectionBloc bloc,
      TagSelectionViewState state) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Column(
        children: [
          Expanded(child: _buildTagList(context, bloc, state)),
        ],
      ))
    ]);
  }

  Widget _buildTagList(BuildContext context, TagSelectionBloc bloc,
      TagSelectionViewState state) {
    final SlidableController slidableController = SlidableController();
    // Make list
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemCount: state.tags.length,
        itemBuilder: (context, index) {
          TagModel model = state.tags[index];
          return Slidable.builder(
              key: Key(model.id.toString()),
              controller: slidableController,
              direction: Axis.horizontal,
              child: ListTile(
                  onTap: () {
                    Navigator.pop(context, model.id);
                  },
                  title: Text(model.name),
                  trailing: Icon(Icons.navigate_next)),
              actionPane: SlidableDrawerActionPane(),
              dismissal: SlidableDismissal(
                  closeOnCanceled: true,
                  onWillDismiss: (actionType) async {
                    HapticFeedback.lightImpact();
                    return await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AppDialogs.buildConfirmDeletionDialog(
                              context,
                              () => Navigator.of(context).pop(false),
                              () => Navigator.of(context).pop(true));
                        });
                  },
                  onDismissed: (actionType) async {
                    bloc.deleteTag(model.id);
                  },
//                  dragDismissible: false,
                  child: SlidableDrawerDismissal()),
              secondaryActionDelegate: SlideActionBuilderDelegate(
                  actionCount: 2,
                  builder: (context, index, animation, renderingMode) {
                    if (index == 0) {
                      return IconSlideAction(
                        caption: FlutterI18n.translate(context, "texts.edit"),
                        color: Colors.blueAccent,
                        icon: Icons.edit,
                        onTap: () async {
                          await Navigator.pushNamed(
                              context, EditTagScreen.routeName,
                              arguments: model);
                          bloc.requestState();
                        },
                      );
                    } else {
                      return IconSlideAction(
                        caption: FlutterI18n.translate(context, "texts.delete"),
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () {
                          var state = Slidable.of(context);
                          state.dismiss();
                        },
                      );
                    }
                  }));
        });
  }
}
