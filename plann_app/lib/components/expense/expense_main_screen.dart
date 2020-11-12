import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
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
  BuildContext _scaffoldContext;

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
          body: Builder(
            builder: (BuildContext context) {
              _scaffoldContext = context;
              return _buildBody(context, bloc);
            },
          )),
    );
  }

  AppBar _buildAppBar(BuildContext context, ExpenseMainBloc bloc) {
    return AppBar(
      title: Text(FlutterI18n.translate(context, "texts.regular_short")),
      elevation: 0,
      flexibleSpace: AppViews.buildAppGradientContainer(context),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (_tabController.index == 0) {
                _addExpense(context, bloc);
              } else if (_tabController.index == 1) {
                _addPlannedExpense(context, bloc);
              }
            }),
      ],
      bottom: TabBar(controller: _tabController, tabs: [
        Tab(text: FlutterI18n.translate(context, "texts.list")),
        Tab(
          text: FlutterI18n.translate(context, "texts.templates"),
        )
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
                _buildListView(context, bloc, state),
                _buildPlannedListView(context, bloc, state.planned),
              ]);
            }
          }

          return AppViews.buildProgressIndicator(context);
        });
  }

  Widget _buildListView(
      BuildContext context, ExpenseMainBloc bloc, ExpenseMainViewState state) {
    if (state.expenseList.isEmpty) {
      return _buildNoExpense(context);
    } else {
      return _buildExpenseList(context, bloc, state);
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
        child: Container(
            width: 300,
            child: Text(
              FlutterI18n.translate(context, "texts.no_expense"),
              textAlign: TextAlign.center,
            )),
      ))
    ]);
  }

  Widget _buildNoPlannedExpense(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
              child: Container(
                  width: 300,
                  child: Text(
                    FlutterI18n.translate(context, "texts.no_planned_expense"),
                    textAlign: TextAlign.center,
                  ))))
    ]);
  }

  Widget _buildExpenseList(
      BuildContext context, ExpenseMainBloc bloc, ExpenseMainViewState state) {
    ColorsMap<ExpenseCategoryType> colorsMap =
        ColorsMap.fromValues(ExpenseCategoryType.values);
    final SlidableController slidableController = SlidableController();

    return GroupedListView<ExpenseModel, String>(
      elements: state.expenseList,
      groupBy: (model) {
        DateTime rounded =
            DateTime(model.date.year, model.date.month, model.date.day);

        Map<CurrencyType, CurrencyValue> currencyMap =
            state.perDayExpenses[rounded];

        if (currencyMap != null) {
          return AppTexts.upFirstLetter(
                  AppTexts.formatDate(context, model.date)) +
              " (" +
              AppTexts.formatCurrencyMap(context, currencyMap) +
              ")";
        } else {
          return AppTexts.upFirstLetter(
              AppTexts.formatDate(context, model.date));
        }
      },
      groupSeparatorBuilder: (String groupByValue) =>
          ListTile(title: Text(groupByValue)),
      itemBuilder: (context, ExpenseModel model) {
        String itemValue =
            AppTexts.formatCurrencyValue(context, model.currency, model.value);
        String itemCategory =
            AppTexts.formatExpenseCategoryType(context, model.category);
        String itemDate = AppTexts.formatDate(context, model.date);

        return Slidable.builder(
            key: Key(model.id.toString()),
            controller: slidableController,
            direction: Axis.horizontal,
            child: ListTile(
              leading:
                  AppViews.buildRoundedBox(colorsMap.getColor(model.category)),
              title: Text(itemValue),
              subtitle: Text(
                  "$itemDate, $itemCategory. ${model.comment != null ? model.comment : ""}"),
              trailing: Icon(Icons.navigate_next),
              onTap: () {
                _editExpense(context, bloc, model);
              },
            ),
            actionPane: SlidableDrawerActionPane(),
            dismissal: SlidableDismissal(
                closeOnCanceled: true,
                onWillDismiss: (actionType) async {
                  HapticFeedback.lightImpact();
                  return await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AppDialogs.buildConfirmDeletionDialog(
                            context,
                            () => Navigator.of(context).pop(false),
                            () => Navigator.of(context).pop(true));
                      });
                },
                onDismissed: (actionType) async {
                  bloc.deleteExpense(model.id);
                },
//                  dragDismissible: false,
                child: SlidableDrawerDismissal()),
            secondaryActionDelegate: SlideActionBuilderDelegate(
                actionCount: 1,
                builder: (context, index, animation, renderingMode) {
                  return IconSlideAction(
                    caption: FlutterI18n.translate(context, "texts.delete"),
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () {
                      var state = Slidable.of(context);
                      state.dismiss();
                    },
                  );
                }));
      },
      sort: false,
    );
  }

  Widget _buildPlannedExpenseList(BuildContext context, ExpenseMainBloc bloc,
      List<PlannedExpenseModel> list) {
    final SlidableController slidableController = SlidableController();

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

          return Slidable.builder(
              key: Key(model.id.toString()),
              controller: slidableController,
              direction: Axis.horizontal,
              child: ListTile(
                title: Text(itemValue),
                subtitle: Text(
                    "$itemCategory. ${model.comment != null ? model.comment : ""}"),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  _editPlannedExpense(context, bloc, model);
                },
              ),
              actionPane: SlidableDrawerActionPane(),
              dismissal: SlidableDismissal(
                  closeOnCanceled: true,
                  onWillDismiss: (actionType) async {
                    HapticFeedback.lightImpact();
                    return await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AppDialogs.buildConfirmDeletionDialog(
                              context,
                              () => Navigator.of(context).pop(false),
                              () => Navigator.of(context).pop(true));
                        });
                  },
                  onDismissed: (actionType) async {
                    bloc.deletePlannedExpense(model.id);
                  },
//                  dragDismissible: false,
                  child: SlidableDrawerDismissal()),
              secondaryActionDelegate: SlideActionBuilderDelegate(
                  actionCount: 2,
                  builder: (context, index, animation, renderingMode) {
                    if (index == 0) {
                      return IconSlideAction(
                        caption: FlutterI18n.translate(context, "texts.add"),
                        color: Colors.blueAccent,
                        icon: Ionicons.md_add,
                        onTap: () async {
                          bloc.instantiateExpense(model.value, model.currency,
                              model.category, model.comment);
                          bloc.requestState();
                          Scaffold.of(_scaffoldContext).hideCurrentSnackBar();
                          Scaffold.of(_scaffoldContext).showSnackBar(SnackBar(
                            content: Text(FlutterI18n.translate(
                                context, "texts.expense_added_to_list",
                                translationParams: {
                                  "value": itemValue,
                                  "category":
                                      AppTexts.lowFirstLetter(itemCategory),
                                })),
//                            action: SnackBarAction(
//                              label:
//                                  FlutterI18n.translate(context, "texts.undo"),
//                              onPressed: () {
//                                bloc.deleteExpense(id);
//                              },
//                            ),
                          ));
                        },
                      );
                    } else {
                      return IconSlideAction(
                        caption: FlutterI18n.translate(context, "texts.delete"),
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () {
                          var state = Slidable.of(context);
                          state.dismiss();
                        },
                      );
                    }
                  }));
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
