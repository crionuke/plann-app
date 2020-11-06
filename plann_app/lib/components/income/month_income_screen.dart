import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_colors.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/income/month_income_bloc.dart';
import 'package:plann_app/components/widgets/log_chart.dart';
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:provider/provider.dart';

class MonthIncomeScreen extends StatefulWidget {
  static const routeName = '/monthIncomeScreen';

  @override
  State createState() => _MonthIncomeState();
}

class _MonthIncomeState extends State<MonthIncomeScreen>
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
    final MonthIncomeBloc bloc = Provider.of<MonthIncomeBloc>(context);
    return Scaffold(
      appBar: _buildAppBar(context, bloc),
      body: _buildBody(context, bloc),
    );
  }

  AppBar _buildAppBar(BuildContext context, MonthIncomeBloc bloc) {
    String monthDate = AppTexts.upFirstLetter(
        AppTexts.formatMonthYear(context, bloc.getMonthDate()));
    return AppBar(
      title: Text(
        FlutterI18n.translate(context, "texts.income_s") + "\n" + monthDate,
        textAlign: TextAlign.center,
      ),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: AppViews.buildAppGradientContainer(context),
    );
  }

  Widget _buildBody(BuildContext context, MonthIncomeBloc bloc) {
    return StreamBuilder<MonthIncomeViewState>(
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

  Widget _buildListView(
      BuildContext context, MonthIncomeBloc bloc, MonthIncomeViewState state) {
    if (state.actualIncomePerCategory.isEmpty) {
      return _buildNoIncome(context);
    } else {
      return _buildMonthIncomeView(context, bloc, state);
    }
  }

  Widget _buildNoIncome(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Text(FlutterI18n.translate(context, "texts.no_income")),
      ))
    ]);
  }

  Widget _buildMonthIncomeView(
      BuildContext context, MonthIncomeBloc bloc, MonthIncomeViewState state) {
    ColorsMap<IncomeCategoryType> colorsMap =
        ColorsMap.fromValues(IncomeCategoryType.values);

//    List<LogChartBar> bars = List();
//    state.actualIncomePerCategory.keys.forEach((category) {
//      if (state.actualIncomePerCategory[category].isEmpty) {
//        bars.add(LogChartBar.empty(""));
//      } else {
//        List<LogChartItem> items = List();
//        Map<CurrencyType, CurrencyValue> currencyMap =
//            state.actualIncomePerCategory[category];
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
          Expanded(child: _buildIncomeList(context, bloc, state, colorsMap)),
        ],
      ))
    ]);
  }

  Widget _buildIncomeList(BuildContext context, MonthIncomeBloc bloc,
      MonthIncomeViewState state, ColorsMap<IncomeCategoryType> colorsMap) {

    // Make list
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemCount: state.sortedCategories.length,
        itemBuilder: (context, index) {
          IncomeCategoryType category = state.sortedCategories[index];
          Map<CurrencyType, CurrencyValue> currencyMap =
              state.actualIncomePerCategory[category];

          String categoryText =
              AppTexts.formatIncomeCategoryType(context, category);
          String currencyMapText =
              AppTexts.formatCurrencyMap(context, currencyMap);

          return ListTile(
            title: Text(categoryText),
            subtitle: Text(currencyMapText),
            leading: AppViews.buildRoundedBox(colorsMap.getColor(category)),
          );
        });
  }
}
