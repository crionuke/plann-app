import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:plann_app/components/app_dialogs.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/main/month_carusel_bloc.dart';
import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/analytics/month_analytics.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:provider/provider.dart';

class MonthCaruselView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MonthCaruselBloc bloc = Provider.of<MonthCaruselBloc>(context);
    return StreamBuilder<MonthCaruselViewState>(
        stream: bloc.stream,
        initialData: bloc.currentState,
        builder: (context, snapshot) {
          print(snapshot);
          var state = snapshot.data;
          return _buildCarusel(context, state.analytics);
        });
  }

  Widget _buildCarusel(BuildContext context, AnalyticsData analytics) {
    final pageController = PageController(
        initialPage: analytics.currentMonthOffset, viewportFraction: 0.95);
    return PageView.builder(
        itemCount: analytics.monthCount,
        controller: pageController,
        itemBuilder: (BuildContext context, int itemIndex) {
          MonthAnalytics monthAnalytics = analytics.monthList[itemIndex];
          return _buildMonthCard(context, pageController, monthAnalytics);
        });
  }

  Card _buildMonthCard(BuildContext context, PageController pageController,
      MonthAnalytics monthAnalytics) {
    return Card(
        child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
                child: Container(
                    alignment: Alignment.topLeft,
//                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                            onTap: () {
                              pageController.animateToPage(
                                  pageController.initialPage,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeIn);
                            },
                            title: Text(
                              getMonthTitle(context, monthAnalytics),
                            )),
                        _buildIncomeTile(context, monthAnalytics),
                        _buildExpenseTile(context, monthAnalytics),
//                        _buildIrregularTile(context, monthAnalytics),
//                        _buildAccountsTile(context, monthAnalytics),
                      ],
                    )))));
  }

  String getMonthTitle(BuildContext context, MonthAnalytics monthAnalytics) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat format = DateFormat.yMMMM(locale.toString());
    String monthTitle = format
        .format(
            DateTime(monthAnalytics.year, monthAnalytics.month, 1).toLocal())
        .toString();
    return AppTexts.upFirstLetter(monthTitle);
  }

  Widget _buildIncomeTile(BuildContext context, MonthAnalytics monthAnalytics) {
    return ListTile(
      onTap: () {},
      leading: Icon(Icons.arrow_downward),
      title: Text(FlutterI18n.translate(context, "texts.income_s") + ":"),
      subtitle: Text(_prepareCurrencyMapWithPercents(
          context, monthAnalytics.actualIncomeValues,
          monthAnalytics.incomePercentDiff,
          prefix: "+")),
    );
  }

  Widget _buildExpenseTile(
      BuildContext context, MonthAnalytics monthAnalytics) {
    return ListTile(
      onTap: () {},
      leading: Icon(Icons.account_balance_wallet),
      title: Text(FlutterI18n.translate(context, "texts.regular") + ":"),
      subtitle: Text(_prepareCurrencyMapWithPercents(
          context, monthAnalytics.actualExpenseValues,
          monthAnalytics.expensePercentDiff,
          prefix: "-")),
    );
  }

  String _prepareCurrencyMapWithPercents(BuildContext context,
      Map<CurrencyType, double> currencyMap,
      Map<CurrencyType, int> percentMap, {String prefix = ""}) {
    if (currencyMap.isNotEmpty) {
      return currencyMap
          .map((key, value) =>
          MapEntry<CurrencyType, String>(
              key,
              AppTexts.formatCurrencyType(key) + ": " + prefix +
                  AppTexts.formatValueAsShorten(context, value) +
                  " (" +
                  (percentMap[key] >= 0
                      ? "+" + percentMap[key].toString()
                      : percentMap[key].toString()) +
                  "%)"
          ))
          .values
          .join("\n");
    } else {
      return "-";
    }
  }

  Widget _buildIrregularTile(
      BuildContext context, MonthAnalytics monthAnalytics) {
    return ListTile(
      onTap: () {},
      leading: Icon(Icons.all_out),
      title: Text(FlutterI18n.translate(context, "texts.irregular") + ":"),
      subtitle: Text(FlutterI18n.translate(context, "texts.fact") +
          ": " +
          AppTexts.formatCurrencyMap(
              context, monthAnalytics.actualIrregularValues, prefix: "-") +
          "\n" +
          FlutterI18n.translate(context, "texts.plan") +
          ": " +
          AppTexts.formatCurrencyMap(
              context, monthAnalytics.plannedIrregularValues,
              prefix: "-")),
    );
  }

  Widget _buildAccountsTile(
      BuildContext context, MonthAnalytics monthAnalytics) {
    return Row(
      children: <Widget>[
        Expanded(
            child: ListTile(
          onTap: () {},
          leading: Icon(Icons.account_balance),
          title: Text(FlutterI18n.translate(context, "texts.account") + ":"),
          subtitle: Text(FlutterI18n.translate(context, "texts.debet") +
              ": " +
              AppTexts.formatCurrencyMap(context, monthAnalytics.accountDebet,
                  prefix: "+") +
              "\n" +
              FlutterI18n.translate(context, "texts.balance") +
              ": " +
              AppTexts.formatCurrencyMap(
                  context, monthAnalytics.accountBalance)),
        )),
        IconButton(
          icon: Icon(
            Icons.help_outline,
            color: Colors.grey[600],
          ),
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => AppDialogs.buildHelpDialog(
                  context, "texts.account", "texts.account_help")),
        ),
      ],
    );
  }
}
