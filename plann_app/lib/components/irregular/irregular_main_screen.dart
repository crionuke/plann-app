import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:plann_app/components/app_colors.dart';
import 'package:plann_app/components/app_dialogs.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/irregular/add_irregular_screen.dart';
import 'package:plann_app/components/irregular/add_planned_irregular_screen.dart';
import 'package:plann_app/components/irregular/edit_irregular_screen.dart';
import 'package:plann_app/components/irregular/edit_planned_irregular_screen.dart';
import 'package:plann_app/components/irregular/irregular_main_bloc.dart';
import 'package:plann_app/components/irregular/irregular_month_panel_bloc.dart';
import 'package:plann_app/components/irregular/irregular_month_panel_view.dart';
import 'package:plann_app/components/widgets/log_chart.dart';
import 'package:plann_app/services/analytics/analytics_data.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:provider/provider.dart';

class IrregularMainScreen extends StatefulWidget {
  static const routeName = '/irregularMainScreen';

  @override
  State createState() => _IrregularMainState();
}

class _IrregularMainState extends State<IrregularMainScreen>
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
    final IrregularMainBloc bloc = Provider.of<IrregularMainBloc>(context);
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

  AppBar _buildAppBar(BuildContext context, IrregularMainBloc bloc) {
    return AppBar(
      title: Text(FlutterI18n.translate(context, "texts.irregular_short")),
      elevation: 0,
      flexibleSpace: AppViews.buildAppGradientContainer(context),
      actions: <Widget>[
        PopupMenuButton<int>(
          onSelected: (index) {
            switch (index) {
              case 0:
                _addIrregular(context, bloc);
                break;
              case 1:
                _addPlannedIrregular(context, bloc);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<int>(
              value: 0,
              child: ListTile(
                title:
                    Text(FlutterI18n.translate(context, "texts.add_to_list")),
                leading: Icon(Ionicons.md_add),
              ),
            ),
            PopupMenuItem<int>(
              value: 1,
              child: ListTile(
                title: Text(FlutterI18n.translate(context, "texts.to_plan")),
                leading: Icon(FontAwesome5.calendar_alt),
              ),
            )
          ],
        ),
      ],
      bottom: TabBar(controller: _tabController, tabs: [
        Tab(text: FlutterI18n.translate(context, "texts.list")),
        Tab(text: FlutterI18n.translate(context, "texts.plan_noun")),
      ]),
    );
  }

  Widget _buildBody(BuildContext context, IrregularMainBloc bloc) {
    return StreamBuilder<IrregularMainViewState>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            bloc.requestState();
          } else {
            var state = snapshot.data;
            if (state.loaded) {
              return TabBarView(controller: _tabController, children: [
                _buildListView(context, bloc, state.fact),
                _buildPlannedView(context, bloc, state),
              ]);
            }
          }

          return AppViews.buildProgressIndicator(context);
        });
  }

  Widget _buildListView(
      BuildContext context, IrregularMainBloc bloc, List<IrregularModel> list) {
    if (list.isEmpty) {
      return _buildNoIrregular(context);
    } else {
      return _buildIrregularList(context, bloc, list);
    }
  }

  Widget _buildPlannedView(BuildContext context, IrregularMainBloc bloc,
      IrregularMainViewState state) {
    if (state.planned.isEmpty) {
      return _buildNoPlannedIrregular(context);
    } else {
      double height = 120;

      ColorsMap<int> colorsMap = ColorsMap();
      state.analytics.analyticsPlannedIrregularList
          .forEach((item) => colorsMap.assign(item.model.id));

      List<LogChartBar> bars = List();
      state.analytics.monthList.forEach((month) {
        if (month.plannedIrregularAccount.values.length == 0) {
          bars.add(LogChartBar.empty(AppTexts.upFirstLetter(
              AppTexts.formatShortMonth(context, month.date))));
        } else {
          bars.add(LogChartBar(
              AppTexts.upFirstLetter(
                  AppTexts.formatShortMonth(context, month.date)),
              month.plannedIrregularAccount.values.entries
                  .map((e) {
                    AnalyticsItem<PlannedIrregularModel> item = e.key;
                    return LogChartItem(colorsMap.getColor(item.model.id),
                        e.value.valueInDefaultValue);
                  })
                  .toList()
                  .reversed
                  .toList()));
        }
      });

      return CustomScrollView(slivers: <Widget>[
        SliverFillRemaining(
            child: Column(
          children: [
            Provider<IrregularMonthPanelBloc>(
                create: (context) => bloc.monthPanelBloc,
                child: IrregularMonthPanelView()),
            LogChart(
                height, 60, bars, state.analytics.monthList.currentMonthOffset,
                (context, column) {
              bloc.monthPanelBloc.setMonthByIndex(column);
            }),
            Expanded(
                child: _buildPlannedIrregularList(
                    context, bloc, state.planned, colorsMap, state.analytics)),
          ],
        ))
      ]);
    }
  }

  Widget _buildNoIrregular(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Container(
            width: 300,
            child: Text(
              FlutterI18n.translate(context, "texts.no_irregular"),
              textAlign: TextAlign.center,
            )),
      ))
    ]);
  }

  Widget _buildNoPlannedIrregular(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Container(
            width: 300,
            child: Text(
              FlutterI18n.translate(context, "texts.no_irregular_planned"),
              textAlign: TextAlign.center,
            )),
      ))
    ]);
  }

  Widget _buildIrregularList(
      BuildContext context, IrregularMainBloc bloc, List<IrregularModel> list) {
    final SlidableController slidableController = SlidableController();
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemBuilder: (context, index) {
          IrregularModel model = list[index];
          String itemValue = AppTexts.formatCurrencyValue(
              context, model.currency, model.value);
          String itemDate = AppTexts.formatDate(context, model.date);

          return Slidable.builder(
              key: Key(model.id.toString()),
              controller: slidableController,
              direction: Axis.horizontal,
              child: ListTile(
                title: Text(model.title),
                subtitle: Text("$itemDate, $itemValue"),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  _editIrregular(context, bloc, model);
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
                    bloc.deleteIrregular(model.id);
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
        itemCount: list.length);
  }

  Widget _buildPlannedIrregularList(
      BuildContext context,
      IrregularMainBloc bloc,
      List<PlannedIrregularModel> list,
      ColorsMap<int> colorsMap,
      AnalyticsData analyticsData) {
    final SlidableController slidableController = SlidableController();
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemBuilder: (context, index) {
          PlannedIrregularModel model = list[index];

          String itemValue = AppTexts.formatCurrencyValue(
              context, model.currency, model.value,
              shorten: true);

          String sizeInfo = FlutterI18n.translate(
              context, "texts.irregular_size_info",
              translationParams: {
                "value": itemValue,
                "date": AppTexts.formatDate(context, model.date),
              });

          String perMonthInfo = FlutterI18n.translate(
              context, "texts.irregular_per_month_info",
              translationParams: {
                "value": AppTexts.formatCurrencyValue(context, model.currency,
                    analyticsData.monthList.perMonthValue(model),
                    shorten: true),
              });

          return Slidable.builder(
              key: Key(model.id.toString()),
              controller: slidableController,
              direction: Axis.horizontal,
              child: ListTile(
                leading: AppViews.buildRoundedBox(colorsMap.getColor(model.id)),
                title: Text(model.title),
//            isThreeLine: true,
                subtitle: Text("$sizeInfo\n${perMonthInfo}"),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  _editPlannedIrregular(context, bloc, model);
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
                    bloc.deletePlannedIrregular(model.id);
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
                          bloc.instantiateIrregular(
                              model.value, model.currency, model.title);
                          bloc.requestState();
                          Scaffold.of(_scaffoldContext).hideCurrentSnackBar();
                          Scaffold.of(_scaffoldContext).showSnackBar(SnackBar(
                            content: Text(FlutterI18n.translate(
                                context, "texts.irregular_added_to_list",
                                translationParams: {
                                  "title": AppTexts.lowFirstLetter(model.title),
                                  "value": itemValue,
                                })),
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

  void _addIrregular(BuildContext context, IrregularMainBloc bloc) async {
    _tabController.index = 0;
    bool listChanged =
        await Navigator.pushNamed<bool>(context, AddIrregularScreen.routeName);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }

  void _addPlannedIrregular(
      BuildContext context, IrregularMainBloc bloc) async {
    _tabController.index = 1;
    bool listChanged = await Navigator.pushNamed<bool>(
        context, AddPlannedIrregularScreen.routeName);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }

  void _editIrregular(BuildContext context, IrregularMainBloc bloc,
      IrregularModel model) async {
    _tabController.index = 0;
    bool listChanged = await Navigator.pushNamed<bool>(
        context, EditIrregularScreen.routeName,
        arguments: model);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }

  void _editPlannedIrregular(BuildContext context, IrregularMainBloc bloc,
      PlannedIrregularModel model) async {
    _tabController.index = 1;
    bool listChanged = await Navigator.pushNamed<bool>(
        context, EditPlannedIrregularScreen.routeName,
        arguments: model);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }
}
