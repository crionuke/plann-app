import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
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
          var state = snapshot.data;
          return _buildCarusel(context, bloc, state);
        });
  }

  Widget _buildCarusel(BuildContext context, MonthCaruselBloc bloc,
      MonthCaruselViewState state) {
    AnalyticsData analytics = state.analytics;
    final pageController = PageController(
        initialPage: analytics.currentMonthOffset, viewportFraction: 0.95);
    return PageView.builder(
        itemCount: analytics.monthCount,
        controller: pageController,
        itemBuilder: (BuildContext context, int itemIndex) {
          MonthAnalytics monthAnalytics = state.analytics.monthList[itemIndex];
          return _buildMonthCard(
              context, bloc, pageController, state, monthAnalytics);
        });
  }

  Widget _buildMonthCard(
      BuildContext context,
      MonthCaruselBloc bloc,
      PageController pageController,
      MonthCaruselViewState state,
      MonthAnalytics monthAnalytics) {
    return Container(
        child: Column(children: [
      Card(
          child: Column(children: [
        _buildMonthHeader(context, bloc, pageController, state, monthAnalytics),
        _buildIncomeTitle(context, state.currencyType, monthAnalytics),
        _buildExpenseTitle(context, state.currencyType, monthAnalytics),
        _buildDeltaTitle(context, state.currencyType, monthAnalytics),
      ])),
    ]));
  }

  String _getMonthTitle(BuildContext context, MonthAnalytics monthAnalytics) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat format = DateFormat.yMMMM(locale.toString());
    String monthTitle = format
        .format(
            DateTime(monthAnalytics.year, monthAnalytics.month, 1).toLocal())
        .toString();
    return AppTexts.upFirstLetter(monthTitle);
  }

  Widget _buildMonthHeader(
      BuildContext context,
      MonthCaruselBloc bloc,
      PageController pageController,
      MonthCaruselViewState state,
      MonthAnalytics monthAnalytics) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            onTap: () {
              pageController.animateToPage(pageController.initialPage,
                  duration: Duration(milliseconds: 500), curve: Curves.easeIn);
            },
            title: Text(_getMonthTitle(context, monthAnalytics)),
          ),
        ),
        _buildCurrencySwitch(() => bloc.switchToRubles(), "\u20BD",
            state.currencyType == CurrencyType.rubles),
        _buildCurrencySwitch(() => bloc.switchToDollars(), "\$",
            state.currencyType == CurrencyType.dollars),
        _buildCurrencySwitch(() => bloc.switchToEuro(), "€",
            state.currencyType == CurrencyType.euro),
      ],
    );
  }

  Widget _buildCurrencySwitch(
      GestureTapCallback onTap, String title, bool selected) {
    return Container(
      width: 35,
      child: ListTile(
        onTap: () => onTap(),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: selected
              ? TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline)
              : null,
        ),
      ),
    );
  }

  Widget _buildIncomeTitle(BuildContext context, CurrencyType currencyType,
      MonthAnalytics monthAnalytics) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(FlutterI18n.translate(context, "texts.income_s") + ":"),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                    _prepareCurrencyMapWithPercents(
                        context,
                        currencyType,
                        monthAnalytics.actualIncomeValues,
                        monthAnalytics.incomePercentDiff),
                    textAlign: TextAlign.left)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTitle(BuildContext context, CurrencyType currencyType,
      MonthAnalytics monthAnalytics) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(FlutterI18n.translate(context, "texts.regular") + ":"),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                    _prepareCurrencyMapWithPercents(
                        context,
                        currencyType,
                        monthAnalytics.actualExpenseValues,
                        monthAnalytics.expensePercentDiff),
                    textAlign: TextAlign.left)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeltaTitle(BuildContext context, CurrencyType currencyType,
      MonthAnalytics monthAnalytics) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(FlutterI18n.translate(context, "texts.delta") + ":"),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                    _preparePercentsWithCurrencyMap(
                        context,
                        currencyType,
                        monthAnalytics.deltaPercentDiff,
                        monthAnalytics.deltaValues),
                    textAlign: TextAlign.left)
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _prepareCurrencyMapWithPercents(
      BuildContext context,
      CurrencyType currencyType,
      Map<CurrencyType, double> currencyMap,
      Map<CurrencyType, int> percentMap) {
    double value = currencyMap[currencyType];
    if (value != null) {
      return AppTexts.formatValueAsShorten(context, value) +
          " (" +
          (percentMap[currencyType] > 0
              ? "+" + percentMap[currencyType].toString()
              : percentMap[currencyType].toString()) +
          "%)";
    } else {
      return "-";
    }
  }

  String _preparePercentsWithCurrencyMap(
      BuildContext context,
      CurrencyType currencyType,
      Map<CurrencyType, int> percentMap,
      Map<CurrencyType, double> currencyMap) {
    int value = percentMap[currencyType];
    if (value != null) {
      return value.toString() +
          "% (" +
          AppTexts.formatValueAsShorten(context, currencyMap[currencyType]) +
          ")";
    } else {
      return "-";
    }
  }
}
