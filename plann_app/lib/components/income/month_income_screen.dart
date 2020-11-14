import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_colors.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/income/month_category_income_bloc.dart';
import 'package:plann_app/components/income/month_category_income_screen.dart';
import 'package:plann_app/components/income/month_income_bloc.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
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
        AppTexts.formatMonthYear(context, bloc.month.date));
    String headerText = FlutterI18n.translate(context, "texts.income_s") +
        " (" +
        AppTexts.formatCurrencyType(bloc.currency) +
        ")";

    return AppBar(
      title: Column(
        children: [
          Text(headerText, textAlign: TextAlign.center),
          Text(
            monthDate,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      flexibleSpace: GradientContainerWidget(),
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
          return ProgressIndicatorWidget();
        });
  }

  Widget _buildListView(
      BuildContext context, MonthIncomeBloc bloc, MonthIncomeViewState state) {
    if (state.values.isEmpty) {
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

    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Column(
        children: [
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

          String categoryText =
              AppTexts.formatIncomeCategoryType(context, category);
          String valueText = AppTexts.formatCurrencyValue(
              context, bloc.currency, state.values[category].value,
              shorten: true);

          String percentsPerCatetgory =
              AppValues.prepareToDisplay(state.percents[category], fixed: 1);

          return ListTile(
              onTap: () {
                Navigator.pushNamed(
                    context, MonthCategoryIncomeScreen.routeName,
                    arguments: MonthCategoryIncomeArguments(
                        bloc.currency, bloc.month, category));
              },
              title: Text(categoryText),
              subtitle: Text(valueText),
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
