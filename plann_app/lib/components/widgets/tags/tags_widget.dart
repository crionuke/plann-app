import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/tags/tag_selection_bloc.dart';
import 'package:plann_app/components/tags/tag_selection_screen.dart';
import 'package:plann_app/components/widgets/tags/tags_bloc.dart';
import 'package:provider/provider.dart';

typedef TagTapCallback = void Function(
    BuildContext context, int tagId, bool state);

class TagsWidget extends StatelessWidget {
  TagsWidget();

  @override
  Widget build(BuildContext context) {
    final TagsBloc bloc = Provider.of<TagsBloc>(context);
    return StreamBuilder(
        stream: bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            bloc.requestState();
          } else {
            var state = snapshot.data;
            if (state.loaded) {
              var state = snapshot.data as TagsViewState;
              List<Widget> chips = List();
              List<Widget> userChips = state.tags.values
                  .map((tag) => Chip(
                        label: Text(tag.name),
                        onDeleted: () {
                          bloc.tagRemoved(tag.id);
                        },
                      ))
                  .toList();
              chips.addAll(userChips);
              chips.add(InputChip(
                avatar: Icon(Icons.add),
                label: Text(FlutterI18n.translate(context, "texts.add_tag")),
                onPressed: () async {
                  int tagId = await Navigator.pushNamed<int>(
                      context, TagSelectionScreen.routeName,
                      arguments: TagSelectionArguments(state.tags));
                  if (tagId != null) {
                    bloc.tagSelected(tagId);
                  }
                },
              ));

              return Container(
                  child: Align(
                      child: Wrap(spacing: 4, children: chips),
                      alignment: Alignment.topLeft));
            }
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}
