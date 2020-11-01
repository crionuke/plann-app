import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:plann_app/components/emergency/add_emergency_fund_bloc.dart';
import 'package:plann_app/components/emergency/add_emergency_fund_screen.dart';
import 'package:plann_app/components/emergency/edit_emergency_fund_bloc.dart';
import 'package:plann_app/components/emergency/edit_emergency_fund_screen.dart';
import 'package:plann_app/components/emergency/emergency_fund_main_bloc.dart';
import 'package:plann_app/components/emergency/emergency_fund_main_screen.dart';
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
import 'package:plann_app/components/expense/month_expense_bloc.dart';
import 'package:plann_app/components/expense/month_expense_screen.dart';
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
import 'package:plann_app/components/main/about_app_bloc.dart';
import 'package:plann_app/components/main/about_app_screen.dart';
import 'package:plann_app/components/main/main_bloc.dart';
import 'package:plann_app/components/main/main_screen.dart';
import 'package:plann_app/components/subscriptions/block_bloc.dart';
import 'package:plann_app/components/subscriptions/block_screen.dart';
import 'package:plann_app/components/subscriptions/subscriptions_bloc.dart';
import 'package:plann_app/components/subscriptions/subscriptions_screen.dart';
import 'package:plann_app/services/analytics/analytics_month.dart';
import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/currency/currency_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/expense_model.dart';
import 'package:plann_app/services/db/models/income_model.dart';
import 'package:plann_app/services/db/models/irregular_model.dart';
import 'package:plann_app/services/db/models/planned_expense_model.dart';
import 'package:plann_app/services/db/models/planned_income_model.dart';
import 'package:plann_app/services/db/models/planned_irregular_model.dart';
import 'package:plann_app/services/tracking/tracking_service_appmetrica.dart';
import 'package:provider/provider.dart';

import 'components/income/month_income_bloc.dart';
import 'components/income/month_income_screen.dart';
import 'services/db/models/emergency_fund_model.dart';
import 'services/purchase/purchase_service.dart';
import 'services/values/values_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DbService();
  final trackingService = TrackingService();
  final purchaseService = PurchaseService(trackingService);
  final currencyService = CurrencyService();
  final analyticsService =
      AnalyticsService(dbService, trackingService, currencyService);
  final valuesService = ValuesService(dbService);

  final navigatorKey = GlobalKey<NavigatorState>();

  runApp(MultiProvider(
    providers: [
      Provider<PurchaseService>(create: (context) => purchaseService),
      Provider<DbService>(create: (context) => dbService),
      Provider<AnalyticsService>(create: (context) => analyticsService),
      Provider<TrackingService>(create: (context) => trackingService),
      Provider<ValuesService>(create: (context) => valuesService),
      Provider<CurrencyService>(create: (context) => currencyService),
    ],
    child: App(navigatorKey, trackingService),
  ));

  await dbService.start();
  await trackingService.start();
  await purchaseService.start();
  await analyticsService.start();
  await valuesService.start();
  await currencyService.start();

  if (await purchaseService.hasAccess()) {
    print("[main] change to main screen");
    if (!valuesService.isExist(ValuesService.VALUE_ABOUT_APP_VIEWED)) {
      navigatorKey.currentState
          .pushReplacementNamed(AboutAppScreen.routeName, arguments: true);
    } else {
      print("[main] about app already viewed, skip");
      navigatorKey.currentState.pushReplacementNamed(MainScreen.routeName);
    }
  } else {
    print("[main] change to blocking screen");
    navigatorKey.currentState.pushReplacementNamed(BlockScreen.routeName);
  }
}

class App extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final TrackingService trackingService;

  App(this.navigatorKey, this.trackingService);

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
        onGenerateRoute: (route) {
          print("[main] generate route to " + route.name);

          switch (route.name) {
            case MainScreen.routeName:
              return _buildMainPageRoute();
            case BlockScreen.routeName:
              return _buildBlockPageRoute();

            case AboutAppScreen.routeName:
              return _buildAppScreenPageRoute(route.arguments);

            case IncomeMainScreen.routeName:
              return _buildIncomeListPageRoute();
            case AddIncomeScreen.routeName:
              return _buildAddIncomePageRoute();
            case EditIncomeScreen.routeName:
              return _buildEditIncomePageRoute(route.arguments);
            case AddPlannedIncomeScreen.routeName:
              return _buildAddPlannedIncomePageRoute();
            case EditPlannedIncomeScreen.routeName:
              return _buildEditPlannedIncomePageRoute(route.arguments);
            case MonthIncomeScreen.routeName:
              return _buildMonthIncomePageRoute(route.arguments);

            case ExpenseMainScreen.routeName:
              return _buildExpenseListPageRoute();
            case AddExpenseScreen.routeName:
              return _buildAddExpensePageRoute();
            case EditExpenseScreen.routeName:
              return _buildEditExpensePageRoute(route.arguments);
            case AddPlannedExpenseScreen.routeName:
              return _buildAddPlannedExpensePageRoute();
            case EditPlannedExpenseScreen.routeName:
              return _buildEditPlannedExpensePageRoute(route.arguments);
            case MonthExpenseScreen.routeName:
              return _buildMonthExpensePageRoute(route.arguments);

            case IrregularMainScreen.routeName:
              return _buildIrregularMainScreenPageRoute();
            case AddIrregularScreen.routeName:
              return _buildAddIrregularPageRoute();
            case EditIrregularScreen.routeName:
              return _buildEditIrregularPageRoute(route.arguments);
            case AddPlannedIrregularScreen.routeName:
              return _buildAddPlannedIrregularPageRoute();
            case EditPlannedIrregularScreen.routeName:
              return _buildEditPlannedIrregularPageRoute(route.arguments);

            case EmergencyFundMainScreen.routeName:
              return _buildEmergencyFundMainScreenPageRoute();
            case AddEmergencyFundScreen.routeName:
              return _buildAddEmergencyFundPageRoute();
            case EditEmergencyFundScreen.routeName:
              return _buildEditEmergencyFundPageRoute(route.arguments);

            case SubscriptionsScreen.routeName:
              return _buildSubscriptionsPageRoute();
          }

          throw Exception("Undefined view for route=" + route.name);
        });
  }

  MaterialPageRoute _buildMainPageRoute() {
    return MaterialPageRoute(builder: (context) {
      return Provider<MainBloc>(
          create: (context) => MainBloc(
              Provider.of<PurchaseService>(context, listen: false),
              Provider.of<TrackingService>(context, listen: false)),
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

  MaterialPageRoute _buildAppScreenPageRoute(bool startup) {
    return MaterialPageRoute(builder: (context) {
//      return AboutAppScreen(pageIndex);
      return Provider<AboutAppBloc>(
          create: (context) => AboutAppBloc(
              Provider.of<ValuesService>(context, listen: false),
              Provider.of<TrackingService>(context, listen: false)),
          child: AboutAppScreen(startup));
    });
  }

  // Income routes

  MaterialPageRoute _buildIncomeListPageRoute() {
    return MaterialPageRoute(builder: (context) {
      return Provider<IncomeMainBloc>(
          create: (context) => IncomeMainBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              Provider.of<TrackingService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: IncomeMainScreen());
    });
  }

  MaterialPageRoute _buildAddIncomePageRoute() {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<AddIncomeBloc>(
          create: (context) => AddIncomeBloc(
                Provider.of<DbService>(context, listen: false),
                Provider.of<AnalyticsService>(context, listen: false),
                Provider.of<TrackingService>(context, listen: false),
              ),
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
                Provider.of<TrackingService>(context, listen: false),
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

  MaterialPageRoute _buildMonthIncomePageRoute(AnalyticsMonth month) {
    return MaterialPageRoute(builder: (context) {
      return Provider<MonthIncomeBloc>(
          create: (context) => MonthIncomeBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              month),
          dispose: (context, bloc) => bloc.dispose(),
          child: MonthIncomeScreen());
    });
  }

  // Expense routes

  MaterialPageRoute _buildExpenseListPageRoute() {
    return MaterialPageRoute(builder: (context) {
      return Provider<ExpenseMainBloc>(
          create: (context) => ExpenseMainBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              Provider.of<TrackingService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: ExpenseMainScreen());
    });
  }

  MaterialPageRoute _buildAddExpensePageRoute() {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<AddExpenseBloc>(
          create: (context) => AddExpenseBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              Provider.of<TrackingService>(context, listen: false)),
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
                Provider.of<AnalyticsService>(context, listen: false),
                Provider.of<TrackingService>(context, listen: false),
              ),
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

  MaterialPageRoute _buildMonthExpensePageRoute(AnalyticsMonth month) {
    return MaterialPageRoute(builder: (context) {
      return Provider<MonthExpenseBloc>(
          create: (context) => MonthExpenseBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              month),
          dispose: (context, bloc) => bloc.dispose(),
          child: MonthExpenseScreen());
    });
  }

  // Emergency fund routes

  MaterialPageRoute _buildEmergencyFundMainScreenPageRoute() {
    return MaterialPageRoute(builder: (context) {
      return Provider<EmergencyFundMainBloc>(
          create: (context) => EmergencyFundMainBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              Provider.of<TrackingService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: EmergencyFundMainScreen());
    });
  }

  MaterialPageRoute _buildAddEmergencyFundPageRoute() {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<AddEmergencyFundBloc>(
          create: (context) => AddEmergencyFundBloc(
                Provider.of<DbService>(context, listen: false),
                Provider.of<AnalyticsService>(context, listen: false),
                Provider.of<TrackingService>(context, listen: false),
              ),
          dispose: (context, bloc) => bloc.dispose(),
          child: AddEmergencyFundScreen());
    });
  }

  MaterialPageRoute _buildEditEmergencyFundPageRoute(EmergencyFundModel model) {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<EditEmergencyFundBloc>(
          create: (context) => EditEmergencyFundBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              model),
          dispose: (context, bloc) => bloc.dispose(),
          child: EditEmergencyFundScreen());
    });
  }

  // Irregular routes

  MaterialPageRoute _buildIrregularMainScreenPageRoute() {
    return MaterialPageRoute(builder: (context) {
      return Provider<IrregularMainBloc>(
          create: (context) => IrregularMainBloc(
              Provider.of<DbService>(context, listen: false),
              Provider.of<AnalyticsService>(context, listen: false),
              Provider.of<TrackingService>(context, listen: false),
              Provider.of<CurrencyService>(context, listen: false)),
          dispose: (context, bloc) => bloc.dispose(),
          child: IrregularMainScreen());
    });
  }

  MaterialPageRoute _buildAddIrregularPageRoute() {
    return MaterialPageRoute<bool>(builder: (context) {
      return Provider<AddIrregularBloc>(
          create: (context) => AddIrregularBloc(
                Provider.of<DbService>(context, listen: false),
                Provider.of<AnalyticsService>(context, listen: false),
                Provider.of<TrackingService>(context, listen: false),
              ),
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
                Provider.of<AnalyticsService>(context, listen: false),
                Provider.of<TrackingService>(context, listen: false),
              ),
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
