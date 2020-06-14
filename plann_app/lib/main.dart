import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:plann_app/components/expense/add_expense_bloc.dart';
import 'package:plann_app/components/expense/add_expense_screen.dart';
import 'package:plann_app/components/expense/add_planned_expense_bloc.dart';
import 'package:plann_app/components/expense/add_planned_expense_screen.dart';
import 'package:plann_app/components/expense/edit_expense_bloc.dart';
import 'package:plann_app/components/expense/edit_expense_screen.dart';
import 'package:plann_app/components/expense/edit_planned_expense_bloc.dart';
import 'package:plann_app/components/expense/edit_planned_expense_screen.dart';
import 'package:plann_app/components/expense/expense_main_bloc.dart';
import 'package:plann_app/components/expense/expense_main_screen.dart';
import 'package:plann_app/components/income/add_income_bloc.dart';
import 'package:plann_app/components/income/add_income_screen.dart';
import 'package:plann_app/components/income/add_planned_income_bloc.dart';
import 'package:plann_app/components/income/add_planned_income_screen.dart';
import 'package:plann_app/components/income/edit_income_bloc.dart';
import 'package:plann_app/components/income/edit_income_screen.dart';
import 'package:plann_app/components/income/edit_planned_income_bloc.dart';
import 'package:plann_app/components/income/edit_planned_income_screen.dart';
import 'package:plann_app/components/income/income_main_bloc.dart';
import 'package:plann_app/components/income/income_main_screen.dart';
import 'package:plann_app/components/irregular/add_irregular_bloc.dart';
import 'package:plann_app/components/irregular/add_irregular_screen.dart';
import 'package:plann_app/components/irregular/add_planned_irregular_bloc.dart';
import 'package:plann_app/components/irregular/add_planned_irregular_screen.dart';
import 'package:plann_app/components/irregular/edit_irregular_bloc.dart';
import 'package:plann_app/components/irregular/edit_irregular_screen.dart';
import 'package:plann_app/components/irregular/edit_planned_irregular_bloc.dart';
import 'package:plann_app/components/irregular/edit_planned_irregular_screen.dart';
import 'package:plann_app/components/irregular/irregular_main_bloc.dart';
import 'package:plann_app/components/irregular/irregular_main_screen.dart';
import 'package:plann_app/components/loading/loading_screen.dart';
import 'package:plann_app/components/main/main_bloc.dart';
import 'package:plann_app/components/main/main_screen.dart';
import 'package:plann_app/components/subscriptions/block_bloc.dart';
import 'package:plann_app/components/subscriptions/block_screen.dart';
import 'package:plann_app/components/subscriptions/subscriptions_bloc.dart';
import 'package:plann_app/components/subscriptions/subscriptions_screen.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:provider/provider.dart';

import 'services/purchase/purchase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DbService();
  final purchaseService = PurchaseService();
  final analyticsService = AnalyticsService();

  final navigatorKey = GlobalKey<NavigatorState>();

  runApp(MultiProvider(
    providers: [
      Provider<PurchaseService>(create: (context) => purchaseService),
      Provider<DbService>(create: (context) => dbService),
      Provider<AnalyticsService>(create: (context) => analyticsService),
    ],
    child: App(navigatorKey),
  ));

  await purchaseService.start();
  await dbService.start();
  await analyticsService.start(dbService);
//  await Future.delayed(Duration(seconds: 100));

  if (await purchaseService.hasAccess()) {
    print("[main] change to main screen");
    navigatorKey.currentState.pushReplacementNamed(MainScreen.routeName);
  } else {
    print("[main] change to blocking screen");
    navigatorKey.currentState.pushReplacementNamed(BlockScreen.routeName);
  }
}

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  App(this.navigatorKey);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: <LocalizationsDelegate>[
          FlutterI18nDelegate(
              translationLoader: FileTranslationLoader(
                  basePath: 'res/locales', forcedLocale: Locale("ru"))),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: [
          Locale('ru'),
        ],
        title: 'PLANN',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorKey: navigatorKey,
        home: LoadingScreen(),
        onGenerateRoute: (settings) {
          print("[main] generate route to " + settings.name);
          switch (settings.name) {
            case MainScreen.routeName:
              return _buildMainPageRoute();
            case BlockScreen.routeName:
              return _buildBlockPageRoute();

            case IncomeMainScreen.routeName:
              return _buildIncomeListPageRoute();
            case AddIncomeScreen.routeName:
              return _buildAddIncomePageRoute();
            case EditIncomeScreen.routeName:
              return _buildEditIncomePageRoute(settings.arguments);
            case AddPlannedIncomeScreen.routeName:
              return _buildAddPlannedIncomePageRoute();
            case EditPlannedIncomeScreen.routeName:
              return _buildEditPlannedIncomePageRoute(settings.arguments);

            case ExpenseMainScreen.routeName:
              return _buildExpenseListPageRoute();
            case AddExpenseScreen.routeName:
              return _buildAddExpensePageRoute();
            case EditExpenseScreen.routeName:
              return _buildEditExpensePageRoute(settings.arguments);
            case AddPlannedExpenseScreen.routeName:
              return _buildAddPlannedExpensePageRoute();
            case EditPlannedExpenseScreen.routeName:
              return _buildEditPlannedExpensePageRoute(settings.arguments);

            case IrregularMainScreen.routeName:
              return _buildIrregularMainScreenPageRoute();
            case AddIrregularScreen.routeName:
              return _buildAddIrregularPageRoute();
            case EditIrregularScreen.routeName:
              return _buildEditIrregularPageRoute(settings.arguments);
            case AddPlannedIrregularScreen.routeName:
              return _buildAddPlannedIrregularPageRoute();
            case EditPlannedIrregularScreen.routeName:
              return _buildEditPlannedIrregularPageRoute(settings.arguments);

            case SubscriptionsScreen.routeName:
              return _buildSubscriptionsPageRoute();
          }

          throw Exception("Undefined view for route=" + settings.name);
        });
  }

  MaterialPageRoute _buildMainPageRoute() {
    return MaterialPageRoute(builder: (context) {
      return Provider<MainBloc>(
          create: (context) =>
              MainBloc(Provider.of<PurchaseService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: MainScreen());
    });
  }

  MaterialPageRoute _buildBlockPageRoute() {
    return MaterialPageRoute(builder: (context) {
      return Provider<BlockBloc>(
          create: (context) => BlockBloc(
              Provider.of<PurchaseService>(context, listen: false),
              navigatorKey),
          dispose: (context, bloc) => bloc.dispose(),
          child: BlockScreen());
    });
  }

  // Income routes

  MaterialPageRoute _buildIncomeListPageRoute() {
    return MaterialPageRoute(builder: (context) {
      return Provider<IncomeMainBloc>(
          create: (context) =>
              IncomeMainBloc(Provider.of<DbService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: IncomeMainScreen());
    });
  }

  MaterialPageRoute _buildAddIncomePageRoute() {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<AddIncomeBloc>(
          create: (context) => AddIncomeBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: AddIncomeScreen());
    });
  }

  MaterialPageRoute _buildEditIncomePageRoute(IncomeModel model) {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<EditIncomeBloc>(
          create: (context) => EditIncomeBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              model),
          dispose: (context, bloc) => bloc.dispose(),
          child: EditIncomeScreen());
    });
  }

  MaterialPageRoute _buildAddPlannedIncomePageRoute() {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<AddPlannedIncomeBloc>(
          create: (context) => AddPlannedIncomeBloc(
                Provider.of<DbService>(context, listen: false),
                Provider.of<AnalyticsService>(context, listen: false),
              ),
          dispose: (context, bloc) => bloc.dispose(),
          child: AddPlannedIncomeScreen());
    });
  }

  MaterialPageRoute _buildEditPlannedIncomePageRoute(PlannedIncomeModel model) {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<EditPlannedIncomeBloc>(
          create: (context) => EditPlannedIncomeBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              model),
          dispose: (context, bloc) => bloc.dispose(),
          child: EditPlannedIncomeScreen());
    });
  }

  // Expense routes

  MaterialPageRoute _buildExpenseListPageRoute() {
    return MaterialPageRoute(builder: (context) {
      return Provider<ExpenseMainBloc>(
          create: (context) =>
              ExpenseMainBloc(Provider.of<DbService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: ExpenseMainScreen());
    });
  }

  MaterialPageRoute _buildAddExpensePageRoute() {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<AddExpenseBloc>(
          create: (context) => AddExpenseBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: AddExpenseScreen());
    });
  }

  MaterialPageRoute _buildEditExpensePageRoute(ExpenseModel model) {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<EditExpenseBloc>(
          create: (context) => EditExpenseBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              model),
          dispose: (context, bloc) => bloc.dispose(),
          child: EditExpenseScreen());
    });
  }

  MaterialPageRoute _buildAddPlannedExpensePageRoute() {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<AddPlannedExpenseBloc>(
          create: (context) => AddPlannedExpenseBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: AddPlannedExpenseScreen());
    });
  }

  MaterialPageRoute _buildEditPlannedExpensePageRoute(
      PlannedExpenseModel model) {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<EditPlannedExpenseBloc>(
          create: (context) => EditPlannedExpenseBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              model),
          dispose: (context, bloc) => bloc.dispose(),
          child: EditPlannedExpenseScreen());
    });
  }

  // Irregular routes

  MaterialPageRoute _buildIrregularMainScreenPageRoute() {
    return MaterialPageRoute(builder: (context) {
      return Provider<IrregularMainBloc>(
          create: (context) =>
              IrregularMainBloc(Provider.of<DbService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: IrregularMainScreen());
    });
  }

  MaterialPageRoute _buildAddIrregularPageRoute() {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<AddIrregularBloc>(
          create: (context) => AddIrregularBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: AddIrregularScreen());
    });
  }

  MaterialPageRoute _buildEditIrregularPageRoute(IrregularModel model) {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<EditIrregularBloc>(
          create: (context) => EditIrregularBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              model),
          dispose: (context, bloc) => bloc.dispose(),
          child: EditIrregularScreen());
    });
  }

  MaterialPageRoute _buildAddPlannedIrregularPageRoute() {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<AddPlannedIrregularBloc>(
          create: (context) => AddPlannedIrregularBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: AddPlannedIrregularScreen());
    });
  }

  MaterialPageRoute _buildEditPlannedIrregularPageRoute(
      PlannedIrregularModel model) {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<EditPlannedIrregularBloc>(
          create: (context) => EditPlannedIrregularBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              model),
          dispose: (context, bloc) => bloc.dispose(),
          child: EditPlannedIrregularScreen());
    });
  }

  MaterialPageRoute _buildSubscriptionsPageRoute() {
    return MaterialPageRoute(builder: (context) {
      return Provider<SubscriptionsBloc>(
          create: (context) => SubscriptionsBloc(
              Provider.of<PurchaseService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: SubscriptionsScreen());
    });
  }
}
