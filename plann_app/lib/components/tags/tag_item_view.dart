import 'package:flutter/material.dart';
import 'package:plann_app/components/tags/tag_item_bloc.dart';
import 'package:plann_app/components/widgets/string_text_field_widget.dart';
import 'package:provider/provider.dart';

class TagItemView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TagItemBloc bloc = Provider.of<TagItemBloc>(context);

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: CustomScrollView(slivers: <Widget>[
          SliverFillRemaining(
              child: SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Form(
                    child: TagItemForm(bloc),
                  )))
        ]));
  }
}

class TagItemForm extends StatelessWidget {
  final TagItemBloc bloc;

  TagItemForm(this.bloc);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          var state = snapshot.data as TagItemViewState;
          return Column(children: <Widget>[
            StringTextFieldWidget(state.name, "texts.title", state.nameErrorKey,
                (value) => bloc.nameChanged(value), true),
          ]);
        });
  }
}
