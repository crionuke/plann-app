import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:plann_app/components/app_dialogs.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/expense/month_expense_bloc.dart';
import 'package:plann_app/components/expense/month_expense_screen.dart';
import 'package:plann_app/components/income/month_income_bloc.dart';
import 'package:plann_app/components/income/month_income_screen.dart';
import 'package:plann_app/components/main/month_carusel_bloc.dart';
import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/currency/currency_service.dart';
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
        initialPage: analytics.monthList.currentMonthOffset,
        viewportFraction: 0.95);
    return PageView.builder(
        itemCount: analytics.monthList.currentMonthOffset + 1,
        controller: pageController,
        itemBuilder: (BuildContext context, int itemIndex) {
          AnalyticsMonth month =
              state.analytics.monthList.findMonthByIndex(itemIndex);
          return _buildMonthCard(context, bloc, pageController, state, month);
        });
  }

  Widget _buildMonthCard(
      BuildContext context,
      MonthCaruselBloc bloc,
      PageController pageController,
      MonthCaruselViewState state,
      AnalyticsMonth month) {
    return Container(
        child: Column(children: [
      Card(
          child: Column(children: [
        _buildMonthHeader(context, bloc, pageController, state, month),
        _buildIncomeTitle(context, state.currency, month),
        _buildExpenseTitle(context, state.currency, month),
//        _buildIrregularTitle(context, state.currency, month),
//        ListTile(
//          title: Text(FlutterI18n.translate(context, "texts.budget")),
//        ),
        Divider(
          height: 1,
        ),
        _buildBudgetDeltaTitle(context, state.currency, month),
        _buildBudgetIrregularTitle(context, state.currency, month),
        _buildBudgetBalanceTitle(context, state.currency, month),
      ])),
    ]));
  }

  String _getMonthTitle(BuildContext context, AnalyticsMonth month) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat format = DateFormat.yMMMM(locale.toString());
    String monthTitle = format
        .format(DateTime(month.year, month.month, 1).toLocal())
        .toString();
    return AppTexts.upFirstLetter(monthTitle);
  }

  Widget _buildMonthHeader(
      BuildContext context,
      MonthCaruselBloc bloc,
      PageController pageController,
      MonthCaruselViewState state,
      AnalyticsMonth month) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            onTap: () {
              pageController.animateToPage(pageController.initialPage,
                  duration: Duration(milliseconds: 200), curve: Curves.easeIn);
            },
            title: Text(_getMonthTitle(context, month)),
          ),
        ),
        _buildCurrencySwitch(() => bloc.switchToRubles(), "\u20BD",
            state.currency == CurrencyType.rubles),
        _buildCurrencySwitch(() => bloc.switchToDollars(), "\$",
            state.currency == CurrencyType.dollars),
        _buildCurrencySwitch(() => bloc.switchToEuro(), "€",
            state.currency == CurrencyType.euro),
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

  Widget _buildIncomeTitle(
      BuildContext context, CurrencyType currency, AnalyticsMonth month) {
    bool next = false;
    month.actualIncomePerCategory.values
        .forEach((currencyMap) => next |= currencyMap.containsKey(currency));
    return InkWell(
      onTap: () {
        if (next) {
          Navigator.pushNamed(context, MonthIncomeScreen.routeName,
              arguments: MonthIncomeArguments(currency, month));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
//          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  Text(FlutterI18n.translate(context, "texts.income_s") + ":"),
            ),
            Text(
                _prepareCurrencyMapWithPercents(context, currency,
                    month.actualIncomeValues, month.incomePercentDiff),
                textAlign: TextAlign.left),
            next
                ? Icon(Icons.navigate_next, color: Colors.black45)
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTitle(
      BuildContext context, CurrencyType currency, AnalyticsMonth month) {
    bool next = false;
    month.actualExpensePerCategory.values
        .forEach((currencyMap) => next |= currencyMap.containsKey(currency));
    return InkWell(
      onTap: () {
        if (next) {
          Navigator.pushNamed(context, MonthExpenseScreen.routeName,
              arguments: MonthExpenseArguments(currency, month));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
//          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  Text(FlutterI18n.translate(context, "texts.regular") + ":"),
            ),
            Text(
                _prepareCurrencyMapWithPercents(context, currency,
                    month.actualExpenseValues, month.expensePercentDiff),
                textAlign: TextAlign.left),
            next
                ? Icon(Icons.navigate_next, color: Colors.black45)
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildIrregularTitle(
      BuildContext context, CurrencyType currency, AnalyticsMonth month) {
    CurrencyValue currencyValue = month.actualIrregularValues[currency];
    String valueText = "";
    if (currencyValue != null) {
      valueText = AppTexts.formatValueAsShorten(context, currencyValue.value);
    } else {
      valueText = "-";
    }

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
                  Text(FlutterI18n.translate(context, "texts.irregular") + ":"),
                ],
              ),
            ),
            Column(
              children: [Text(valueText, textAlign: TextAlign.left)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetDeltaTitle(
      BuildContext context, CurrencyType currency, AnalyticsMonth month) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child:
                    Text(FlutterI18n.translate(context, "texts.delta") + ":")),
            Text(
                _preparePercentsWithCurrencyMap(context, currency,
                    month.deltaPercentDiff, month.deltaValues),
                textAlign: TextAlign.left),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetIrregularTitle(
      BuildContext context, CurrencyType currency, AnalyticsMonth month) {
    bool next = false;
    month.plannedIrregularAccount.values.values.forEach(
        (currencyValue) => next |= (currencyValue.currency == currency));

    return InkWell(
      onTap: () {
        if (next) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AppDialogs.buildHelpDialog(
                    context,
                    "texts.irregular",
                    FlutterI18n.translate(
                        context, "texts.irregular_budget_help",
                        translationParams: {
                          "value": AppTexts.formatCurrencyValue(
                              context,
                              currency,
                              month.plannedIrregularAccount.debet[currency]
                                  .value,
                              shorten: true),
                        }));
              });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
//          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  Text(FlutterI18n.translate(context, "texts.irregular") + ":"),
            ),
            Text(
                _prepareValueFromCurrencyMap(
                    context, currency, month.plannedIrregularAccount.debet),
                textAlign: TextAlign.left),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetBalanceTitle(
      BuildContext context, CurrencyType currency, AnalyticsMonth month) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(FlutterI18n.translate(context, "texts.free") + ":"),
            ),
            Text(
                _prepareValueFromCurrencyMap(
                    context, currency, month.balanceValues),
                textAlign: TextAlign.left)
          ],
        ),
      ),
    );
  }

  String _prepareValueFromCurrencyMap(
    BuildContext context,
    CurrencyType currency,
    Map<CurrencyType, CurrencyValue> currencyMap,
  ) {
    CurrencyValue currencyValue = currencyMap[currency];
    if (currencyValue != null) {
      return AppTexts.formatValueAsShorten(context, currencyValue.value);
    } else {
      return "-";
    }
  }

  String _prepareCurrencyMapWithPercents(
      BuildContext context,
      CurrencyType currency,
      Map<CurrencyType, CurrencyValue> currencyMap,
      Map<CurrencyType, int> percentMap) {
    CurrencyValue value = currencyMap[currency];
    if (value != null) {
      return AppTexts.formatValueAsShorten(context, value.value) +
          " (" +
          (percentMap[currency] > 0
              ? "+" + percentMap[currency].toString()
              : percentMap[currency].toString()) +
          "%)";
    } else {
      return "-";
    }
  }

  String _preparePercentsWithCurrencyMap(
      BuildContext context,
      CurrencyType currency,
      Map<CurrencyType, int> percentMap,
      Map<CurrencyType, CurrencyValue> currencyMap) {
    int value = percentMap[currency];
    if (value != null) {
      return value.toString() +
          "% (" +
          AppTexts.formatValueAsShorten(context, currencyMap[currency].value) +
          ")";
    } else {
      return "-";
    }
  }
}
