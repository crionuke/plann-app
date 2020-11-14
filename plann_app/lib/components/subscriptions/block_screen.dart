import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_views.dart';
import 'package:plann_app/components/subscriptions/block_bloc.dart';
import 'package:plann_app/components/subscriptions/purchase_result_view.dart';
import 'package:plann_app/components/subscriptions/subscriptions_view.dart';
import 'package:plann_app/components/widgets/progress_indicator_widget.dart';
import 'package:plann_app/services/purchase/purchase_service.dart';
import 'package:provider/provider.dart';

class BlockScreen extends StatelessWidget {
  static const routeName = '/block';

  @override
  Widget build(BuildContext context) {
    final BlockBloc bloc = Provider.of<BlockBloc>(context);
    return Scaffold(
        appBar: _buildAppBar(context),
        body: CustomScrollView(slivers: <Widget>[
          SliverFillRemaining(
              child: StreamBuilder<BlockScreenState>(
                  stream: bloc.stream,
                  builder: (context, snapshot) {
                    print("[BlockScreen] $snapshot");
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      bloc.requestState();
                    } else {
                      var state = snapshot.data;
                      if (state.purchased) {
                        return PurchaseResultView(state.purchaseResult,
                            (context) {
                          if (state.purchaseResult.completed) {
                            bloc.navigate();
                          } else {
                            bloc.requestState();
                          }
                        });
                      } else if (state.loaded) {
                        return SubscriptionsView(
                            state.purchaseList, state.basePurchaseItem,
                            (context, purchaseItem) {
                          bloc.purchase(context, purchaseItem);
                        }, (context) {
                          bloc.restorePurchases();
                        });
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

                    return AppProgressIndicator();
                  }))
        ]));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(FlutterI18n.translate(context, "texts.blocking")),
      elevation: 0,
      flexibleSpace: AppViews.buildAppGradientContainer(context),
    );
  }

  Widget _buildPurchaseResult(PurchaseResult purchaseResult) {}
}
