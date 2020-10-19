import 'package:plann_app/services/tracking/tracking_service.dart';
import 'package:plann_app/services/values/values_service.dart';

class AboutAppBloc {

  final ValuesService valuesService;
  final TrackingService trackingService;

  AboutAppBloc(this.valuesService, this.trackingService);

  void markAsViewed() async {
    if (!valuesService.isExist(ValuesService.VALUE_ABOUT_APP_VIEWED)) {
      valuesService.addValue(ValuesService.VALUE_ABOUT_APP_VIEWED, "true");
      trackingService.aboutAppViewed();
    } else {
      valuesService.editValue(ValuesService.VALUE_ABOUT_APP_VIEWED, "true");
    }
  }
}
