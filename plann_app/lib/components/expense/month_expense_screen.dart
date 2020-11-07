import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_colors.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/expense/month_category_expense_bloc.dart';
import 'package:plann_app/components/expense/month_category_expense_screen.dart';
import 'package:plann_app/components/expense/month_expense_bloc.dart';
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:provider/provider.dart';

class MonthExpenseScreen extends StatefulWidget {
  static const routeName = '/monthExpenseScreen';

  @override
  State createState() => _MonthExpenseState();
}

class _MonthExpenseState extends State<MonthExpenseScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MonthExpenseBloc bloc = Provider.of<MonthExpenseBloc>(context);
    return Scaffold(
      appBar: _buildAppBar(context, bloc),
      body: _buildBody(context, bloc),
    );
  }

  AppBar _buildAppBar(BuildContext context, MonthExpenseBloc bloc) {
    String monthDate = AppTexts.upFirstLetter(
        AppTexts.formatMonthYear(context, bloc.getMonthDate()));
    return AppBar(
      title: Column(
        children: [
          Text(FlutterI18n.translate(context, "texts.regular"),
              textAlign: TextAlign.center),
          Text(
            monthDate,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: AppViews.buildAppGradientContainer(context),
    );
  }

  Widget _buildBody(BuildContext context, MonthExpenseBloc bloc) {
    return StreamBuilder<MonthExpenseViewState>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            bloc.requestState();
          } else {
            var state = snapshot.data;
            if (state.loaded) {
              return _buildListView(context, bloc, state);
            }
          }
          return AppViews.buildProgressIndicator(context);
        });
  }

  Widget _buildListView(BuildContext context, MonthExpenseBloc bloc,
      MonthExpenseViewState state) {
    if (state.actualExpensePerCategory.isEmpty) {
      return _buildNoIncome(context);
    } else {
      return _buildMonthExpenseView(context, bloc, state);
    }
  }

  Widget _buildNoIncome(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Text(FlutterI18n.translate(context, "texts.no_expense")),
      ))
    ]);
  }

  Widget _buildMonthExpenseView(BuildContext context, MonthExpenseBloc bloc,
      MonthExpenseViewState state) {
    ColorsMap<ExpenseCategoryType> colorsMap =
        ColorsMap.fromValues(ExpenseCategoryType.values);

//    List<LogChartBar> bars = List();
//    state.actualExpensePerCategory.keys.forEach((category) {
//      if (state.actualExpensePerCategory[category].isEmpty) {
//        bars.add(LogChartBar.empty(""));
//      } else {
//        List<LogChartItem> items = List();
//        Map<CurrencyType, CurrencyValue> currencyMap =
//            state.actualExpensePerCategory[category];
//
//        currencyMap.keys.forEach((currency) => items.add(LogChartItem(
//            colorsMap.getColor(category),
//            currencyMap[currency].valueInDefaultValue)));
//
//        if (items.isEmpty) {
//          bars.add(LogChartBar.empty(""));
//        } else {
//          bars.add(LogChartBar("", items));
//        }
//      }
//    });
//
//    double height = 120;

    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Column(
        children: [
//          LogChart(height, 30, bars, 1, (context, column) {}),
          Expanded(child: _buildExpenseList(context, bloc, state, colorsMap)),
        ],
      ))
    ]);
  }

  Widget _buildExpenseList(BuildContext context, MonthExpenseBloc bloc,
      MonthExpenseViewState state, ColorsMap<ExpenseCategoryType> colorsMap) {
    // Make list
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemCount: state.sortedCategories.length,
        itemBuilder: (context, index) {
          ExpenseCategoryType category = state.sortedCategories[index];
          Map<CurrencyType, CurrencyValue> currencyMap =
              state.actualExpensePerCategory[category];

          String categoryText =
              AppTexts.formatExpenseCategoryType(context, category);
          String currencyMapText =
              AppTexts.formatCurrencyMap(context, currencyMap);
          String percentsPerCatetgory = AppValues.prepareToDisplay(
              state.actualExpensePercentsPerCategory[category] * 100,
              fixed: 1);

          return ListTile(
              onTap: () {
                Navigator.pushNamed(
                    context, MonthCategoryExpenseScreen.routeName,
                    arguments: MonthCategoryExpenseArguments(
                        bloc.getMonth(), category));
              },
              title: Text(categoryText),
              subtitle: Text(currencyMapText),
              leading: AppViews.buildRoundedBox(colorsMap.getColor(category)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(percentsPerCatetgory + "%"),
                  Icon(Icons.navigate_next)
                ],
              ));
        });
  }
}
