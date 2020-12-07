import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/expense/month_tag_expense_bloc.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:provider/provider.dart';

class MonthTagExpenseScreen extends StatefulWidget {
  static const routeName = '/monthTagExpenseScreen';

  @override
  State createState() => _MonthTagExpenseState();
}

class _MonthTagExpenseState extends State<MonthTagExpenseScreen>
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
    final MonthTagExpenseBloc bloc = Provider.of<MonthTagExpenseBloc>(context);
    return Scaffold(
      appBar: _buildAppBar(context, bloc),
      body: _buildBody(context, bloc),
    );
  }

  AppBar _buildAppBar(BuildContext context, MonthTagExpenseBloc bloc) {
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
            bloc.getTagName() + "/" + monthDate,
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

  Widget _buildBody(BuildContext context, MonthTagExpenseBloc bloc) {
    return StreamBuilder<MonthTagExpenseViewState>(
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

  Widget _buildListView(BuildContext context, MonthTagExpenseBloc bloc,
      MonthTagExpenseViewState state) {
    if (state.list.isEmpty) {
      return _buildNoExpense(context);
    } else {
      return _buildMonthTagExpenseView(context, bloc, state);
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

  Widget _buildMonthTagExpenseView(BuildContext context,
      MonthTagExpenseBloc bloc, MonthTagExpenseViewState state) {
    return CustomScrollView(slivers: <Widget>[
      SliverFillRemaining(
          child: Column(
        children: [
          Expanded(child: _buildExpenseList(context, bloc, state)),
        ],
      ))
    ]);
  }

  Widget _buildExpenseList(BuildContext context, MonthTagExpenseBloc bloc,
      MonthTagExpenseViewState state) {
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
