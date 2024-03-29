import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:plann_app/components/app_colors.dart';
import 'package:plann_app/components/app_dialogs.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/income/add_income_screen.dart';
import 'package:plann_app/components/income/add_planned_income_screen.dart';
import 'package:plann_app/components/income/edit_income_screen.dart';
import 'package:plann_app/components/income/edit_planned_income_screen.dart';
import 'package:plann_app/components/income/income_main_bloc.dart';
import 'package:plann_app/components/income/income_month_panel_bloc.dart';
import 'package:plann_app/components/income/income_month_panel_view.dart';
import 'package:plann_app/components/widgets/chart_widget.dart';
import 'package:plann_app/components/widgets/color_rounded_box_widget.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:plann_app/services/db/models/income_category_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/subject_mode_model.dart';
import 'package:provider/provider.dart';

class IncomeMainScreen extends StatefulWidget {
  static const routeName = '/incomeMainScreen';

  @override
  State createState() => _IncomeMainState();
}

class _IncomeMainState extends State<IncomeMainScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  BuildContext _scaffoldContext;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IncomeMainBloc bloc = Provider.of<IncomeMainBloc>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(context, bloc),
        body: Builder(
          builder: (BuildContext context) {
            _scaffoldContext = context;
            return _buildBody(context, bloc);
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, IncomeMainBloc bloc) {
    return AppBar(
      title: Text(FlutterI18n.translate(context, "texts.income_s")),
      elevation: 0,
      flexibleSpace: GradientContainerWidget(),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (_tabController.index == 0) {
                _addIncome(context, bloc);
              } else if (_tabController.index == 1) {
                _addPlannedIncome(context, bloc);
              }
            }),
      ],
      bottom: TabBar(controller: _tabController, tabs: [
        Tab(text: FlutterI18n.translate(context, "texts.list")),
        Tab(text: FlutterI18n.translate(context, "texts.plan_noun")),
      ]),
    );
  }

  Widget _buildBody(BuildContext context, IncomeMainBloc bloc) {
    return StreamBuilder<IncomeMainViewState>(
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

          return ProgressIndicatorWidget();
        });
  }

  Widget _buildListView(
      BuildContext context, IncomeMainBloc bloc, IncomeMainViewState state) {
    if (state.incomeList.isEmpty) {
      return _buildNoIncome(context);
    } else {
      double height = 100;

      List<ChartBar> bars = List();

      state.monthList.forEach((month) {
        if (month.index > state.monthList.currentMonthIndex) {
          return;
        }

        Map<CurrencyType, CurrencyValue> currencyMap = month.actualIncomeValues;

        if (currencyMap.isEmpty) {
          bars.add(ChartBar.empty(AppTexts.upFirstLetter(
              AppTexts.formatShortMonth(context, month.date))));
        } else {
          bars.add(ChartBar(
              AppTexts.upFirstLetter(
                  AppTexts.formatShortMonth(context, month.date)),
              currencyMap.values
                  .map((currencyValue) => ChartItem(
                      AppColors.APP_COLOR_2, currencyValue.valueInDefaultValue))
                  .toList()
                  .reversed
                  .toList()));
        }
      });

      return CustomScrollView(slivers: <Widget>[
        SliverFillRemaining(
            child: Column(
          children: [
            Provider<IncomeMonthPanelBloc>(
                create: (context) => bloc.incomeMonthPanelBloc,
                child: IncomeMonthPanelView()),
            ChartWidget(height, 60, bars, state.monthList.currentMonthOffset,
                (context, column) {
              bloc.incomeMonthPanelBloc.setMonthByIndex(column);
            }),
            Expanded(child: _buildIncomeList(context, bloc, state)),
          ],
        ))
      ]);
    }
  }

  Widget _buildPlannedListView(BuildContext context, IncomeMainBloc bloc,
      List<PlannedIncomeModel> list) {
    if (list.isEmpty) {
      return _buildNoPlannedIncome(context);
    } else {
      return _buildPlannedIncomeList(context, bloc, list);
    }
  }

  Widget _buildNoIncome(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Container(
            width: 300,
            child: Text(
              FlutterI18n.translate(context, "texts.no_income"),
              textAlign: TextAlign.center,
            )),
      ))
    ]);
  }

  Widget _buildNoPlannedIncome(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Container(
            width: 300,
            child: Text(
              FlutterI18n.translate(context, "texts.no_planned_income"),
              textAlign: TextAlign.center,
            )),
      ))
    ]);
  }

  Widget _buildIncomeList(
      BuildContext context, IncomeMainBloc bloc, IncomeMainViewState state) {
    ColorsMap<IncomeCategoryType> colorsMap =
        ColorsMap.fromValues(IncomeCategoryType.values);
    final SlidableController slidableController = SlidableController();

    return GroupedListView<IncomeModel, String>(
      elements: state.incomeList,
      groupBy: (model) {
        Map<CurrencyType, CurrencyValue> currencyMap =
            state.monthList.findMonthByDate(model.date).actualIncomeValues;
        if (currencyMap != null) {
          return AppTexts.upFirstLetter(
                  AppTexts.formatMonth(context, model.date)) +
              " (" +
              AppTexts.formatCurrencyMap(context, currencyMap) +
              ")";
        } else {
          return AppTexts.upFirstLetter(
              AppTexts.formatMonth(context, model.date));
        }
      },
      groupSeparatorBuilder: (String groupByValue) =>
          ListTile(title: Text(groupByValue)),
      itemBuilder: (context, IncomeModel model) {
        String itemValue =
            AppTexts.formatCurrencyValue(context, model.currency, model.value);
        String itemCategory =
            AppTexts.formatIncomeCategoryType(context, model.category);
        String itemDate = AppTexts.formatDate(context, model.date);

        return Slidable.builder(
            key: Key(model.id.toString()),
            controller: slidableController,
            direction: Axis.horizontal,
            child: ListTile(
              leading:
                  ColorRoundedBoxWidget(colorsMap.getColor(model.category)),
              title: Text(itemValue),
              subtitle: Text(
                  "$itemDate, $itemCategory. ${model.comment != null ? model.comment : ""}"),
              trailing: Icon(Icons.navigate_next),
              onTap: () {
                _editIncome(context, bloc, model);
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
                  bloc.deleteIncome(model.id);
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

  Widget _buildPlannedIncomeList(BuildContext context, IncomeMainBloc bloc,
      List<PlannedIncomeModel> list) {
    final SlidableController slidableController = SlidableController();
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemBuilder: (context, index) {
          PlannedIncomeModel model = list[index];
          String itemValue = AppTexts.formatCurrencyValue(
              context, model.currency, model.value);
          String itemCategory =
              AppTexts.formatIncomeCategoryType(context, model.category);
          String itemDate;
          if (model.mode == SubjectModeType.monthly) {
            itemDate = AppTexts.formatSubjectModeType(
                context, SubjectModeType.monthly);
          } else {
            itemDate = AppTexts.formatDate(context, model.date);
          }

          return Slidable.builder(
              key: Key(model.id.toString()),
              controller: slidableController,
              direction: Axis.horizontal,
              child: ListTile(
                title: Text(itemValue),
                subtitle: Text(
                    "$itemDate, $itemCategory. ${model.comment != null ? model.comment : ""}"),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  _editPlannedIncome(context, bloc, model);
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
                    bloc.deletePlannedIncome(model.id);
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
                          bloc.instantiateIncome(model.value, model.currency,
                              model.category, model.comment);
                          bloc.requestState();
                          Scaffold.of(_scaffoldContext).hideCurrentSnackBar();
                          Scaffold.of(_scaffoldContext).showSnackBar(SnackBar(
                            content: Text(FlutterI18n.translate(
                                context, "texts.income_added_to_list",
                                translationParams: {
                                  "value": itemValue,
                                  "category":
                                      AppTexts.lowFirstLetter(itemCategory),
                                })),
//                            action: SnackBarAction(
//                              label:
//                                  FlutterI18n.translate(context, "texts.undo"),
//                              onPressed: () {
//                                bloc.deleteIncome(id);
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

  void _addIncome(BuildContext context, IncomeMainBloc bloc) async {
    _tabController.index = 0;
    bool listChanged =
        await Navigator.pushNamed<bool>(context, AddIncomeScreen.routeName);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }

  void _addPlannedIncome(BuildContext context, IncomeMainBloc bloc) async {
    _tabController.index = 1;
    bool listChanged = await Navigator.pushNamed<bool>(
        context, AddPlannedIncomeScreen.routeName);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }

  void _editIncome(
      BuildContext context, IncomeMainBloc bloc, IncomeModel model) async {
    _tabController.index = 0;
    bool listChanged = await Navigator.pushNamed<bool>(
        context, EditIncomeScreen.routeName,
        arguments: model);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }

  void _editPlannedIncome(BuildContext context, IncomeMainBloc bloc,
      PlannedIncomeModel model) async {
    _tabController.index = 1;
    bool listChanged = await Navigator.pushNamed<bool>(
        context, EditPlannedIncomeScreen.routeName,
        arguments: model);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }
}
