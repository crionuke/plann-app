import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:plann_app/components/app_dialogs.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/emergency/add_emergency_fund_screen.dart';
import 'package:plann_app/components/emergency/edit_emergency_fund_screen.dart';
import 'package:plann_app/components/emergency/emergency_fund_main_bloc.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:plann_app/services/db/models/emergency_fund_model.dart';
import 'package:provider/provider.dart';

class EmergencyFundMainScreen extends StatefulWidget {
  static const routeName = '/emergencyFundMainScreen';

  @override
  State createState() => _EmergencyFundMainState();
}

class _EmergencyFundMainState extends State<EmergencyFundMainScreen>
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
    final EmergencyFundMainBloc bloc =
        Provider.of<EmergencyFundMainBloc>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(context, bloc),
        body: Builder(
          builder: (BuildContext context) {
            return _buildBody(context, bloc);
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, EmergencyFundMainBloc bloc) {
    return AppBar(
        title: Text(FlutterI18n.translate(context, "texts.emergency_fund")),
        elevation: 0,
        flexibleSpace: GradientContainerWidget(),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _addEmergencyFund(context, bloc);
            },
            icon: Icon(Icons.add),
          )
        ]);
  }

  Widget _buildBody(BuildContext context, EmergencyFundMainBloc bloc) {
    return StreamBuilder<EmergencyFundMainViewState>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            bloc.requestState();
          } else {
            var state = snapshot.data;

            if (state.loaded) {
              return _buildListView(context, bloc, state.emergencyFunds);
            }
          }

          return ProgressIndicatorWidget();
        });
  }

  Widget _buildListView(BuildContext context, EmergencyFundMainBloc bloc,
      List<EmergencyFundModel> emergencyFunds) {
    if (emergencyFunds.isEmpty) {
      return _buildNoEmergencyFund(context);
    } else {
      return _buildEmergencyFundList(context, bloc, emergencyFunds);
    }
  }

  Widget _buildNoEmergencyFund(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Center(
        child: Text(FlutterI18n.translate(context, "texts.no_emergency_fund")),
      ))
    ]);
  }

  Widget _buildEmergencyFundList(BuildContext context,
      EmergencyFundMainBloc bloc, List<EmergencyFundModel> list) {

    final SlidableController slidableController = SlidableController();
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(height: 1);
        },
        itemBuilder: (context, index) {
          EmergencyFundModel model = list[index];
          String itemCurrentValue = AppTexts.formatCurrencyValue(
              context, model.currency, model.currentValue);
          String itemTargetValue = AppTexts.formatCurrencyValue(
              context, model.currency, model.targetValue);
          String itemStartDate = AppTexts.formatDate(context, model.startDate);
          String itemFinishDate = AppTexts.formatDate(context, model.finishDate);

          return Slidable.builder(
              key: Key(model.id.toString()),
              controller: slidableController,
              direction: Axis.horizontal,
              child: ListTile(
                title: Text("$itemCurrentValue -> $itemTargetValue"),
                subtitle: Text("$itemStartDate, $itemFinishDate"),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  _editEmergencyFund(context, bloc, model);
                },
              ),
              actionPane: SlidableDrawerActionPane(),
              dismissal: SlidableDismissal(
                  closeOnCanceled: true,
                  onWillDismiss: (actionType) async {
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
                    bloc.deleteEmergencyFund(model.id);
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

  void _addEmergencyFund(
      BuildContext context, EmergencyFundMainBloc bloc) async {
    bool listChanged = await Navigator.pushNamed<bool>(
        context, AddEmergencyFundScreen.routeName);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }

  void _editEmergencyFund(BuildContext context, EmergencyFundMainBloc bloc,
      EmergencyFundModel model) async {
    bool listChanged = await Navigator.pushNamed<bool>(
        context, EditEmergencyFundScreen.routeName,
        arguments: model);
    if (listChanged != null && listChanged) {
      bloc.requestState();
    }
  }
}
