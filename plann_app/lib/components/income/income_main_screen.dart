import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/income/add_income_screen.dart';
import 'package:plann_app/components/income/add_planned_income_screen.dart';
import 'package:plann_app/components/income/edit_income_screen.dart';
import 'package:plann_app/components/income/edit_planned_income_screen.dart';
import 'package:plann_app/components/income/income_main_bloc.dart';
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
    final IncomeMainBloc bloc = Provider.of<IncomeMainBloc>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(context, bloc),
        body: _buildBody(context, bloc),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, IncomeMainBloc bloc) {
    return AppBar(
      title: Text(FlutterI18n.translate(context, "texts.income_s")),
      elevation: 0,
      flexibleSpace: AppViews.buildAppGradientContainer(context),
      actions: <Widget>[
        PopupMenuButton<int>(
          onSelected: (index) {
            switch (index) {
              case 0:
                _addIncome(context, bloc);
                break;
              case 1:
                _addPlannedIncome(context, bloc);
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
                _buildListView(context, bloc, state.fact),
                _buildPlannedListView(context, bloc, state.planned),
              ]);
            }
          }

          return AppViews.buildProgressIndicator(context);
        });
  }

  Widget _buildListView(
      BuildContext context, IncomeMainBloc bloc, List<IncomeModel> list) {
    if (list.isEmpty) {
      return _buildNoIncome(context);
    } else {
      return _buildIncomeList(context, bloc, list);
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
        child: Text(FlutterI18n.translate(context, "texts.no_income")),
      ))
    ]);
  }

  Widget _buildNoPlannedIncome(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Text(FlutterI18n.translate(context, "texts.no_planned_income")),
      ))
    ]);
  }

  Widget _buildIncomeList(
      BuildContext context, IncomeMainBloc bloc, List<IncomeModel> list) {
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemBuilder: (context, index) {
          IncomeModel model = list[index];
          String itemValue = AppTexts.formatCurrencyValue(
              context, model.currency, model.value);
          String itemCategory =
              AppTexts.formatIncomeCategoryType(context, model.category);
          String itemDate = AppTexts.formatDate(context, model.date);

          return ListTile(
            title: Text("+" + itemValue),
            subtitle: Text(
                "$itemDate, $itemCategory. ${model.comment != null ? model.comment : ""}"),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              _editIncome(context, bloc, model);
            },
          );
        },
        itemCount: list.length);
  }

  Widget _buildPlannedIncomeList(BuildContext context, IncomeMainBloc bloc,
      List<PlannedIncomeModel> list) {
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

          return ListTile(
            title: Text(itemValue),
            subtitle: Text(
                "$itemDate, $itemCategory. ${model.comment != null ? model.comment : ""}"),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              _editPlannedIncome(context, bloc, model);
            },
          );
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
