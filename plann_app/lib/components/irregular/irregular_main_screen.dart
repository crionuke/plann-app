import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/irregular/add_irregular_screen.dart';
import 'package:plann_app/components/irregular/add_planned_irregular_screen.dart';
import 'package:plann_app/components/irregular/edit_irregular_screen.dart';
import 'package:plann_app/components/irregular/edit_planned_irregular_screen.dart';
import 'package:plann_app/components/irregular/irregular_main_bloc.dart';
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
        body: _buildBody(context, bloc),
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
                _buildPlannedListView(context, bloc, state.planned),
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

  Widget _buildPlannedListView(BuildContext context, IrregularMainBloc bloc,
      List<PlannedIrregularModel> list) {
    if (list.isEmpty) {
      return _buildNoPlannedIrregular(context);
    } else {
      return _buildPlannedIrregularList(context, bloc, list);
    }
  }

  Widget _buildNoIrregular(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Text(FlutterI18n.translate(context, "texts.no_expense")),
      ))
    ]);
  }

  Widget _buildNoPlannedIrregular(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Text(FlutterI18n.translate(context, "texts.no_planned_expense")),
      ))
    ]);
  }

  Widget _buildIrregularList(
      BuildContext context, IrregularMainBloc bloc, List<IrregularModel> list) {
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemBuilder: (context, index) {
          IrregularModel model = list[index];
          String itemValue = AppTexts.formatCurrencyValue(
              context, model.currency, model.value);
          String itemDate = AppTexts.formatDate(context, model.date);

          return ListTile(
            title: Text(model.title),
            subtitle: Text("$itemDate, $itemValue"),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              _editIrregular(context, bloc, model);
            },
          );
        },
        itemCount: list.length);
  }

  Widget _buildPlannedIrregularList(BuildContext context,
      IrregularMainBloc bloc, List<PlannedIrregularModel> list) {
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemBuilder: (context, index) {
          PlannedIrregularModel model = list[index];
          String itemValue = AppTexts.formatCurrencyValue(
              context, model.currency, model.value);
          String itemDate = AppTexts.formatDate(context, model.date);

          return ListTile(
            title: Text(model.title),
            subtitle: Text("$itemDate, $itemValue"),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              _editPlannedIrregular(context, bloc, model);
            },
          );
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
