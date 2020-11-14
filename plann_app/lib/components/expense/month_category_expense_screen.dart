import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_colors.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/expense/month_category_expense_bloc.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:provider/provider.dart';

class MonthCategoryExpenseScreen extends StatefulWidget {
  static const routeName = '/monthCartegoryExpenseScreen';

  @override
  State createState() => _MonthCategoryExpenseState();
}

class _MonthCategoryExpenseState extends State<MonthCategoryExpenseScreen>
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
    final MonthCategoryExpenseBloc bloc =
        Provider.of<MonthCategoryExpenseBloc>(context);
    return Scaffold(
      appBar: _buildAppBar(context, bloc),
      body: _buildBody(context, bloc),
    );
  }

  AppBar _buildAppBar(BuildContext context, MonthCategoryExpenseBloc bloc) {
    String monthDate = AppTexts.upFirstLetter(
        AppTexts.formatMonthYear(context, bloc.getMonthDate()));
    String headerText = FlutterI18n.translate(context, "texts.regular") +
        " (" +
        AppTexts.formatCurrencyType(bloc.currency) +
        ")";
    return AppBar(
      title: Column(
        children: [
          Text(headerText, textAlign: TextAlign.center),
          Text(
            AppTexts.formatExpenseCategoryType(context, bloc.getCategory()) +
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

  Widget _buildBody(BuildContext context, MonthCategoryExpenseBloc bloc) {
    return StreamBuilder<MonthCategoryExpenseViewState>(
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

  Widget _buildListView(BuildContext context, MonthCategoryExpenseBloc bloc,
      MonthCategoryExpenseViewState state) {
    if (state.list.isEmpty) {
      return _buildNoExpense(context);
    } else {
      return _buildMonthCategoryExpenseView(context, bloc, state);
    }
  }

  Widget _buildNoExpense(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Text(FlutterI18n.translate(context, "texts.no_expense")),
      ))
    ]);
  }

  Widget _buildMonthCategoryExpenseView(BuildContext context,
      MonthCategoryExpenseBloc bloc, MonthCategoryExpenseViewState state) {
    ColorsMap<ExpenseCategoryType> colorsMap =
        ColorsMap.fromValues(ExpenseCategoryType.values);

    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Column(
        children: [
          Expanded(child: _buildExpenseList(context, bloc, state, colorsMap)),
        ],
      ))
    ]);
  }

  Widget _buildExpenseList(
      BuildContext context,
      MonthCategoryExpenseBloc bloc,
      MonthCategoryExpenseViewState state,
      ColorsMap<ExpenseCategoryType> colorsMap) {
    // Make list
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemCount: state.list.length,
        itemBuilder: (context, index) {
          ExpenseModel model = state.list[index].model;

          String itemValue = AppTexts.formatCurrencyValue(
              context, model.currency, model.value);
          String itemCategory =
              AppTexts.formatExpenseCategoryType(context, model.category);
          String itemDate = AppTexts.formatDate(context, model.date);

          return ListTile(
            leading:
                AppViews.buildRoundedBox(colorsMap.getColor(model.category)),
            title: Text("+" + itemValue),
            subtitle: Text(
                "$itemDate, $itemCategory. ${model.comment != null ? model.comment : ""}"),
//            trailing: Icon(Icons.navigate_next),
            onTap: () {
//              _editExpense(context, bloc, model);
            },
          );
        });
  }
}
