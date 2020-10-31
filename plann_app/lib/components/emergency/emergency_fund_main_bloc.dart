import 'dart:async';

import 'package:plann_app/services/analytics/analytics_service.dart';
import 'package:plann_app/services/db/db_service.dart';
import 'package:plann_app/services/db/models/emergency_fund_model.dart';
import 'package:plann_app/services/tracking/tracking_service_appmetrica.dart';

class EmergencyFundMainBloc {
  final _controller = StreamController<EmergencyFundMainViewState>();

  Stream get stream => _controller.stream;

  final DbService dbService;
  final AnalyticsService analyticsService;
  final TrackingService trackingService;

  EmergencyFundMainBloc(
      this.dbService, this.analyticsService, this.trackingService);

  void dispose() {
    _controller.close();
  }

  Future<void> requestState() async {
    _controller.sink.add(EmergencyFundMainViewState.loading());
    List<EmergencyFundModel> emergencyFunds = await dbService.getEmergencyFundList();
    if (!_controller.isClosed) {
      _controller.sink
          .add(EmergencyFundMainViewState.loaded(emergencyFunds));
    }
  }

  void deleteEmergencyFund(int id) async {
    await dbService.deleteEmergencyFund(id);
    await analyticsService.analyze();
    requestState();
  }
}

class EmergencyFundMainViewState {
  final bool loaded;
  final List<EmergencyFundModel> emergencyFunds;

  EmergencyFundMainViewState.loading()
      : loaded = false,
        emergencyFunds = null;

  EmergencyFundMainViewState.loaded(
      this.emergencyFunds)
      : loaded = true;
}
