import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/subscriptions/access_etitlement_view.dart';
import 'package:plann_app/components/subscriptions/purchase_result_view.dart';
import 'package:plann_app/components/subscriptions/subscriptions_bloc.dart';
import 'package:plann_app/components/subscriptions/subscriptions_view.dart';
import 'package:plann_app/components/widgets/gradient_container_widget.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:provider/provider.dart';

class SubscriptionsScreen extends StatelessWidget {
  static const routeName = '/settings/subscriptions';

  @override
  Widget build(BuildContext context) {
    final SubscriptionsBloc bloc = Provider.of<SubscriptionsBloc>(context);
    return Scaffold(
        appBar: _buildAppBar(context),
        body: CustomScrollView(slivers: <Widget>[
          SliverFillRemaining(
              child: StreamBuilder<SubscriptionsViewState>(
                  stream: bloc.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      bloc.requestState();
                    } else {
                      var state = snapshot.data;
                      if (state.purchased) {
                        return PurchaseResultView(state.purchaseResult,
                            (context) {
                          bloc.requestState();
                        });
                      } else if (state.loaded) {
                        if (state.accessEntitlement != null) {
                          return AccessEntitlementView(state.accessEntitlement);
                        } else {
                          return SubscriptionsView(
                              state.purchaseList, state.basePurchaseItem,
                              (context, purchaseItem) {
                            bloc.purchase(context, purchaseItem);
                          }, (context) {
                            bloc.restorePurchases();
                          });
                        }
                      } else if (state.failed) {
                        return Column(
                          children: [
                            ListTile(
                                title: Text(FlutterI18n.translate(context,
                                    "texts.subscriptions_not_available"))),
                            RaisedButton(
                              child: Text(FlutterI18n.translate(
                                  context, "texts.try_again")),
                              onPressed: () {
                                bloc.requestState();
                              },
                            )
                          ],
                        );
                      }
                    }

                    return ProgressIndicatorWidget();
                  }))
        ]));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(FlutterI18n.translate(context, "texts.subscriptions")),
      elevation: 0,
      flexibleSpace: GradientContainerWidget(),
    );
  }
}
