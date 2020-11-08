import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:plann_app/components/expense/add_expense_screen.dart';
import 'package:plann_app/components/expense/expense_main_screen.dart';
import 'package:plann_app/components/income/add_income_screen.dart';
import 'package:plann_app/components/income/income_main_screen.dart';
import 'package:plann_app/components/irregular/add_irregular_screen.dart';
import 'package:plann_app/components/irregular/irregular_main_screen.dart';
import 'package:plann_app/components/main/month_carusel_bloc.dart';
import 'package:plann_app/components/main/month_carusel_view.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:provider/provider.dart';

class FinancesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: SingleChildScrollView(
        child: _buildColumn(context),
      ))
    ]);
  }

  Widget _buildColumn(BuildContext context) {
    final DbService dbService = Provider.of<DbService>(context);
    final AnalyticsService analyticsService =
        Provider.of<AnalyticsService>(context);
    final MonthCaruselBloc monthCaruselBloc =
        MonthCaruselBloc(dbService, analyticsService);
    final Divider divider1 = Divider(height: 1);
    final SlidableController slidableController = SlidableController();
    return Column(children: <Widget>[
      Container(
          margin: EdgeInsets.all(10),
          height: 325,
          child: Provider<MonthCaruselBloc>(
              create: (context) => monthCaruselBloc,
              dispose: (context, bloc) => bloc.dispose(),
              child: MonthCaruselView())),
      _buildTile1(context, monthCaruselBloc, slidableController),
      divider1,
      _buildTile2(context, monthCaruselBloc, slidableController),
      divider1,
      _buildTile3(context, monthCaruselBloc, slidableController),
//      divider1,
      Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          FlutterI18n.translate(context, "texts.safety_info"),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      ),
    ]);
  }

  Widget _buildTile1(BuildContext context, MonthCaruselBloc monthCaruselBloc,
      SlidableController slidableController) {
    return Slidable.builder(
        key: Key("income_s"),
        controller: slidableController,
        direction: Axis.horizontal,
        child: ListTile(
          title: Text(FlutterI18n.translate(context, "texts.income_s")),
          trailing: Icon(Icons.navigate_next),
          onTap: () async {
            await Navigator.pushNamed(context, IncomeMainScreen.routeName);
            monthCaruselBloc.requestState();
          },
        ),
        actionPane: SlidableDrawerActionPane(),
        dismissal: SlidableDismissal(
            closeOnCanceled: true,
            onWillDismiss: (actionType) async {
              HapticFeedback.lightImpact();
              await Navigator.pushNamed<bool>(
                  context, AddIncomeScreen.routeName);
              monthCaruselBloc.requestState();
              return false;
            },
            child: SlidableDrawerDismissal()),
        secondaryActionDelegate: SlideActionBuilderDelegate(
            actionCount: 1,
            builder: (context, index, animation, renderingMode) {
              return IconSlideAction(
                caption: FlutterI18n.translate(context, "texts.add"),
                color: Colors.blueAccent,
                icon: Ionicons.md_add,
                onTap: () async {
                  var state = Slidable.of(context);
                  state.dismiss();
                },
              );
            }));
  }

  Widget _buildTile2(BuildContext context, MonthCaruselBloc monthCaruselBloc,
      SlidableController slidableController) {
    return Slidable.builder(
        key: Key("regular"),
        controller: slidableController,
        direction: Axis.horizontal,
        child: ListTile(
          title: Text(FlutterI18n.translate(context, "texts.regular")),
          trailing: Icon(Icons.navigate_next),
          onTap: () async {
            await Navigator.pushNamed(context, ExpenseMainScreen.routeName);
            monthCaruselBloc.requestState();
          },
        ),
        actionPane: SlidableDrawerActionPane(),
        dismissal: SlidableDismissal(
            closeOnCanceled: true,
            onWillDismiss: (actionType) async {
              HapticFeedback.lightImpact();
              await Navigator.pushNamed<bool>(
                  context, AddExpenseScreen.routeName);
              monthCaruselBloc.requestState();
              return false;
            },
            child: SlidableDrawerDismissal()),
        secondaryActionDelegate: SlideActionBuilderDelegate(
            actionCount: 1,
            builder: (context, index, animation, renderingMode) {
              return IconSlideAction(
                caption: FlutterI18n.translate(context, "texts.add"),
                color: Colors.blueAccent,
                icon: Ionicons.md_add,
                onTap: () async {
                  var state = Slidable.of(context);
                  state.dismiss();
                },
              );
            }));
  }

  Widget _buildTile3(BuildContext context, MonthCaruselBloc monthCaruselBloc,
      SlidableController slidableController) {
    return Slidable.builder(
        key: Key("irregular"),
        controller: slidableController,
        direction: Axis.horizontal,
        child: ListTile(
          title: Text(FlutterI18n.translate(context, "texts.irregular")),
          trailing: Icon(Icons.navigate_next),
          onTap: () async {
            await Navigator.pushNamed(context, IrregularMainScreen.routeName);
            monthCaruselBloc.requestState();
          },
        ),
        actionPane: SlidableDrawerActionPane(),
        dismissal: SlidableDismissal(
            closeOnCanceled: true,
            onWillDismiss: (actionType) async {
              HapticFeedback.lightImpact();
              await Navigator.pushNamed<bool>(
                  context, AddIrregularScreen.routeName);
              monthCaruselBloc.requestState();
              return false;
            },
            child: SlidableDrawerDismissal()),
        secondaryActionDelegate: SlideActionBuilderDelegate(
            actionCount: 1,
            builder: (context, index, animation, renderingMode) {
              return IconSlideAction(
                caption: FlutterI18n.translate(context, "texts.add"),
                color: Colors.blueAccent,
                icon: Ionicons.md_add,
                onTap: () async {
                  var state = Slidable.of(context);
                  state.dismiss();
                },
              );
            }));
  }
}
