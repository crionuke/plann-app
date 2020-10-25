import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/irregular/irregular_month_panel_bloc.dart';
import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:provider/provider.dart';

class IrregularMonthPanelView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final IrregularMonthPanelBloc bloc =
        Provider.of<IrregularMonthPanelBloc>(context, listen: false);

    bloc.setCurrentMonth();

    return SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: StreamBuilder(
            stream: bloc.stream,
            initialData: bloc.currentState,
            builder: (context, snapshot) {
              var state = snapshot.data as IrregularMonthPanelViewState;
              return _buildCard(context, state.month);
            }));
  }

  Widget _buildCard(BuildContext context, AnalyticsMonth month) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Container(
        child: ListTile(
//              leading: Icon(Icons.account_balance),
          title: Text(AppTexts.upFirstLetter(
                  AppTexts.formatMonthYear(context, month.date)) +
              ":"),
          subtitle: Text(FlutterI18n.translate(context, "texts.debet") +
              ": " +
              AppTexts.formatCurrencyMap(
                  context, month.plannedIrregularAccount.debet, prefix: "+") +
              "\n" +
              FlutterI18n.translate(context, "texts.expense") +
              ": " +
              AppTexts.formatCurrencyMap(context, month.plannedIrregularValues,
                  prefix: "-") +
              "\n" +
              FlutterI18n.translate(context, "texts.balance") +
              ": " +
              AppTexts.formatCurrencyMap(
                  context, month.plannedIrregularAccount.balance)),
        ),
      ),
    );
  }
}
