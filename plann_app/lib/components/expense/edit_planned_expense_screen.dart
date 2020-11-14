import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_dialogs.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/expense/edit_planned_expense_bloc.dart';
import 'package:plann_app/components/expense/planned_expense_item_bloc.dart';
import 'package:plann_app/components/expense/planned_expense_item_view.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class EditPlannedExpenseScreen extends StatelessWidget {
  static const routeName = '/plannedExpense/edit';

  @override
  Widget build(BuildContext context) {
    final EditPlannedExpenseBloc bloc =
        Provider.of<EditPlannedExpenseBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "texts.template")),
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
                          return AppDialogs.buildConfirmDeletionDialog(context,
                              () {
                            // Hide AlertDialog
                            Navigator.of(context).pop();
                          }, () {
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

  Widget _buildBody(EditPlannedExpenseBloc bloc) {
    return StreamBuilder(
        stream: bloc.stream,
        initialData: false,
        builder: (context, snapshot) {
          bool progress = snapshot.data;
          if (progress) {
            return AppProgressIndicator();
          } else {
            return SafeArea(
                child: Provider<PlannedExpenseItemBloc>(
                    create: (context) => bloc.itemBloc,
                    dispose: (context, bloc) => bloc.dispose(),
                    child: PlannedExpenseItemView()));
          }
        });
  }
}
