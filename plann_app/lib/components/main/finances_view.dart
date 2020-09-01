import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/expense/expense_main_screen.dart';
import 'package:plann_app/components/income/income_main_screen.dart';
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
    return Column(children: <Widget>[
      Container(
          margin: EdgeInsets.all(10),
          height: 280,
          child: Provider<MonthCaruselBloc>(
              create: (context) => monthCaruselBloc,
              dispose: (context, bloc) => bloc.dispose(),
              child: MonthCaruselView())),
      _buildTile1(context, monthCaruselBloc),
      divider1,
      _buildTile2(context, monthCaruselBloc),
      divider1,
      _buildTile3(context, monthCaruselBloc),
    ]);
  }

  ListTile _buildTile1(
      BuildContext context, MonthCaruselBloc monthCaruselBloc) {
    return ListTile(
      title: Text(FlutterI18n.translate(context, "texts.income_s")),
      trailing: Icon(Icons.navigate_next),
      onTap: () async {
        await Navigator.pushNamed(context, IncomeMainScreen.routeName);
        monthCaruselBloc.requestState();
      },
    );
  }

  ListTile _buildTile2(
      BuildContext context, MonthCaruselBloc monthCaruselBloc) {
    return ListTile(
      title: Text(FlutterI18n.translate(context, "texts.regular")),
      trailing: Icon(Icons.navigate_next),
      onTap: () async {
        await Navigator.pushNamed(context, ExpenseMainScreen.routeName);
        monthCaruselBloc.requestState();
      },
    );
  }

  ListTile _buildTile3(
      BuildContext context, MonthCaruselBloc monthCaruselBloc) {
    return ListTile(
      title: Text(FlutterI18n.translate(context, "texts.irregular")),
      trailing: Icon(Icons.navigate_next),
      onTap: () async {
        await Navigator.pushNamed(context, IrregularMainScreen.routeName);
        monthCaruselBloc.requestState();
      },
    );
  }
}
