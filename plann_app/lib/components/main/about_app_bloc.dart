import 'dart:async';

import 'package:plann_app/services/purchase/purchase_service.dart';
import 'package:plann_app/services/values/values_service.dart';

class AboutAppBloc {
  final ValuesService valuesService;

  AboutAppBloc(this.valuesService);

  void markAsViewed() async {
    if (!valuesService.isExist(ValuesService.VALUE_ABOUT_APP_VIEWED)) {
      valuesService.addValue(ValuesService.VALUE_ABOUT_APP_VIEWED, "true");
    }
  }
}
