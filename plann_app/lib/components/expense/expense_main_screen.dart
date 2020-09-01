import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:plann_app/components/app_colors.dart';
import 'package:plann_app/components/app_dialogs.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/expense/add_expense_screen.dart';
import 'package:plann_app/components/expense/add_planned_expense_screen.dart';
import 'package:plann_app/components/expense/edit_expense_screen.dart';
import 'package:plann_app/components/expense/edit_planned_expense_screen.dart';
import 'package:plann_app/components/expense/expense_main_bloc.dart';
import 'package:plann_app/services/db/models/expense_category_model.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:provider/provider.dart';

class ExpenseMainScreen extends StatefulWidget {
  static const routeName = '/expenseMainScreen';

  @override
  State createState() => _ExpenseMainState();
}

class _ExpenseMainState extends State<ExpenseMainScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseMainBloc bloc = Provider.of<ExpenseMainBloc>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(context, bloc),
        body: _buildBody(context, bloc),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ExpenseMainBloc bloc) {
    return AppBar(
      title: Text(FlutterI18n.translate(context, "texts.regular_short")),
      elevation: 0,
      flexibleSpace: AppViews.buildAppGradientContainer(context),
      actions: <Widget>[
        PopupMenuButton<int>(
          onSelected: (index) {
            switch (index) {
              case 0:
                _addExpense(context, bloc);
                break;
              case 1:
                _addPlannedExpense(context, bloc);
                break;
              case 2:
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AppDialogs.buildHelpDialog(
                          context, "texts.regular", "texts.regular_help");
                    });
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<int>(
              value: 0,
              child: ListTile(
                title: Text(FlutterI18n.translate(context, "texts.add")),
                leading: Icon(Ionicons.md_add),
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: ListTile(
                title: Text(FlutterI18n.translate(context, "texts.to_plan")),
                leading: Icon(FontAwesome5.calendar_alt),
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: ListTile(
                title: Text(FlutterI18n.translate(context, "texts.help")),
                leading: Icon(Icons.help_outline),
              ),
            )
          ],
        ),
      ],
      bottom: TabBar(controller: _tabController, tabs: [
        Tab(icon: Icon(FontAwesome5.list_alt)),
        Tab(icon: Icon(FontAwesome5.calendar_alt)),
      ]),
    );
  }

  Widget _buildBody(BuildContext context, ExpenseMainBloc bloc) {
    return StreamBuilder<ExpenseMainViewState>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            bloc.requestState();
          } else {
            var state = snapshot.data;
            if (state.loaded) {
              return TabBarView(controller: _tabController, children: [
                _buildListView(context, bloc, state.fact),
                _buildPlannedListView(context, bloc, state.planned),
              ]);
            }
          }

          return AppViews.buildProgressIndicator(context);
        });
  }

  Widget _buildListView(
      BuildContext context, ExpenseMainBloc bloc, List<ExpenseModel> list) {
    if (list.isEmpty) {
      return _buildNoExpense(context);
    } else {
      return _buildExpenseList(context, bloc, list);
    }
  }

  Widget _buildPlannedListView(BuildContext context, ExpenseMainBloc bloc,
      List<PlannedExpenseModel> list) {
    if (list.isEmpty) {
      return _buildNoPlannedExpense(context);
    } else {
      return _buildPlannedExpenseList(context, bloc, list);
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

  Widget _buildNoPlannedExpense(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Text(FlutterI18n.translate(context, "texts.no_planned_expense")),
      ))
    ]);
  }

  Widget _buildExpenseList(
      BuildContext context, ExpenseMainBloc bloc, List<ExpenseModel> list) {

    ColorsMap<ExpenseCategoryType> colorsMap = ColorsMap();
    list.forEach((model) => colorsMap.assign(model.category));

    return GroupedListView<ExpenseModel, String>(
      elements: list,
      groupBy: (model) {
        return AppTexts.upFirstLetter(
            AppTexts.formatDate(context, model.date));
      },
      groupSeparatorBuilder: (String groupByValue) =>
          ListTile(title: Text(groupByValue)),
      itemBuilder: (context, ExpenseModel model) {
        String itemValue =
            AppTexts.formatCurrencyValue(context, model.currency, model.value);
        String itemCategory =
            AppTexts.formatExpenseCategoryType(context, model.category);
        String itemDate = AppTexts.formatDate(context, model.date);

        return ListTile(
          leading: AppViews.buildRoundedBox(colorsMap.getColor(model.category)),
          title: Text(itemValue),
          subtitle: Text(
              "$itemDate, $itemCategory. ${model.comment != null ? model.comment : ""}"),
          trailing: Icon(Icons.navigate_next),
          onTap: () {
            _editExpense(context, bloc, model);
          },
        );
      },
      sort: false,
    );
  }

  Widget _buildPlannedExpenseList(BuildContext context, ExpenseMainBloc bloc,
      List<PlannedExpenseModel> list) {
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemBuilder: (context, index) {
          PlannedExpenseModel model = list[index];
          String itemValue = AppTexts.formatCurrencyValue(
              context, model.currency, model.value);
          String itemCategory =
              AppTexts.formatExpenseCategoryType(context, model.category);

          return ListTile(
            title: Text(itemValue),
            subtitle: Text(
                "$itemCategory. ${model.comment != null ? model.comment : ""}"),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              _editPlannedExpense(context, bloc, model);
            },
          );
        },
        itemCount: list.length);
  }

  void _addExpense(BuildContext context, ExpenseMainBloc bloc) async {
    _tabController.index = 0;
    bool listChanged =
        await Navigator.pushNamed<bool>(context, AddExpenseScreen.routeName);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }

  void _addPlannedExpense(BuildContext context, ExpenseMainBloc bloc) async {
    _tabController.index = 1;
    bool listChanged = await Navigator.pushNamed<bool>(
        context, AddPlannedExpenseScreen.routeName);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }

  void _editExpense(
      BuildContext context, ExpenseMainBloc bloc, ExpenseModel model) async {
    _tabController.index = 0;
    bool listChanged = await Navigator.pushNamed<bool>(
        context, EditExpenseScreen.routeName,
        arguments: model);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }

  void _editPlannedExpense(BuildContext context, ExpenseMainBloc bloc,
      PlannedExpenseModel model) async {
    _tabController.index = 1;
    bool listChanged = await Navigator.pushNamed<bool>(
        context, EditPlannedExpenseScreen.routeName,
        arguments: model);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }
}
