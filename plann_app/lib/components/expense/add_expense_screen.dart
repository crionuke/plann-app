import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/expense/add_expense_bloc.dart';
import 'package:plann_app/components/expense/expense_item_bloc.dart';
import 'package:plann_app/components/expense/expense_item_view.dart';
import 'package:provider/provider.dart';

class AddExpenseScreen extends StatelessWidget {
  static const routeName = '/expense/add';

  @override
  Widget build(BuildContext context) {
    final AddExpenseBloc bloc = Provider.of<AddExpenseBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "texts.regular_short")),
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

  Widget _buildBody(AddExpenseBloc bloc) {
    return StreamBuilder(
        stream: bloc.stream,
        initialData: false,
        builder: (context, snapshot) {
          bool progress = snapshot.data;
          if (progress) {
            return AppViews.buildProgressIndicator(context);
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
