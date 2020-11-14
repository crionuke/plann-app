import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_dialogs.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/expense/edit_expense_bloc.dart';
import 'package:plann_app/components/expense/expense_item_bloc.dart';
import 'package:plann_app/components/expense/expense_item_view.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class EditExpenseScreen extends StatelessWidget {
  static const routeName = '/expense/edit';

  @override
  Widget build(BuildContext context) {
    final EditExpenseBloc bloc = Provider.of<EditExpenseBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "texts.expense")),
          elevation: 0,
          flexibleSpace: GradientContainerWidget(),
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
                          return AppDialogs.buildConfirmDeletionDialog(
                              context, () => Navigator.of(context).pop(), () {
                            // Hide AlertDialog
                            Navigator.pop(context);
                            bloc.delete(context);
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

  Widget _buildBody(EditExpenseBloc bloc) {
    return StreamBuilder(
        stream: bloc.stream,
        initialData: false,
        builder: (context, snapshot) {
          bool progress = snapshot.data;
          if (progress) {
            return ProgressIndicatorWidget();
          } else {
            return SafeArea(
                child: Provider<ExpenseItemBloc>(
                    create: (context) => bloc.itemBloc,
                    dispose: (context, bloc) => bloc.dispose(),
                    child: ExpenseItemView()));
          }
        });
  }
}
