import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_colors.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/income/month_category_income_bloc.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:provider/provider.dart';

class MonthCategoryIncomeScreen extends StatefulWidget {
  static const routeName = '/monthCartegoryIncomeScreen';

  @override
  State createState() => _MonthCategoryIncomeState();
}

class _MonthCategoryIncomeState extends State<MonthCategoryIncomeScreen>
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
    final MonthCategoryIncomeBloc bloc =
        Provider.of<MonthCategoryIncomeBloc>(context);
    return Scaffold(
      appBar: _buildAppBar(context, bloc),
      body: _buildBody(context, bloc),
    );
  }

  AppBar _buildAppBar(BuildContext context, MonthCategoryIncomeBloc bloc) {
    String monthDate = AppTexts.upFirstLetter(
        AppTexts.formatMonthYear(context, bloc.getMonthDate()));
    return AppBar(
      title: Column(
        children: [
          Text(FlutterI18n.translate(context, "texts.income_s"),
              textAlign: TextAlign.center),
          Text(
            AppTexts.formatIncomeCategoryType(context, bloc.getCategory()) +
                "/" +
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

  Widget _buildBody(BuildContext context, MonthCategoryIncomeBloc bloc) {
    return StreamBuilder<MonthCategoryIncomeViewState>(
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

  Widget _buildListView(BuildContext context, MonthCategoryIncomeBloc bloc,
      MonthCategoryIncomeViewState state) {
    if (state.list.isEmpty) {
      return _buildNoIncome(context);
    } else {
      return _buildMonthCategoryIncomeView(context, bloc, state);
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

  Widget _buildMonthCategoryIncomeView(BuildContext context,
      MonthCategoryIncomeBloc bloc, MonthCategoryIncomeViewState state) {
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

  Widget _buildIncomeList(
      BuildContext context,
      MonthCategoryIncomeBloc bloc,
      MonthCategoryIncomeViewState state,
      ColorsMap<IncomeCategoryType> colorsMap) {
    // Make list
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemCount: state.list.length,
        itemBuilder: (context, index) {
          IncomeModel model = state.list[index].model;

          String itemValue = AppTexts.formatCurrencyValue(
              context, model.currency, model.value);
          String itemCategory =
              AppTexts.formatIncomeCategoryType(context, model.category);
          String itemDate = AppTexts.formatDate(context, model.date);

          return ListTile(
            leading:
                AppViews.buildRoundedBox(colorsMap.getColor(model.category)),
            title: Text("+" + itemValue),
            subtitle: Text(
                "$itemDate, $itemCategory. ${model.comment != null ? model.comment : ""}"),
//            trailing: Icon(Icons.navigate_next),
            onTap: () {
//              _editIncome(context, bloc, model);
            },
          );
        });
  }
}