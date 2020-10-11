import 'dart:async';

import 'package:package_info/package_info.dart';
import 'package:plann_app/services/purchase/purchase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsBloc {
  final _controller = StreamController<SettingsViewState>();

  Stream get stream => _controller.stream;

  PurchaseService purchaseService;

  SettingsBloc(this.purchaseService);

  @override
  void dispose() {
    _controller.close();
  }

  void requestState() async {
    _controller.sink.add(SettingsViewState.loading());
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (await purchaseService.hasAccessEntitilement()) {
      _controller.sink.add(SettingsViewState.loaded(
          packageInfo.version, packageInfo.buildNumber, null));
    } else {
      _controller.sink.add(SettingsViewState.loaded(packageInfo.version,
          packageInfo.buildNumber, await purchaseService.blockingDate));
    }
  }

  void openTermsAndConditions() {
    launch("https://plannapp.blogspot.com/2020/06/terms-conditions.html");
  }

  void openPrivacyPolicy() {
    launch("https://plannapp.blogspot.com/2020/06/privacy-policy.html");
  }

  void openTelegramChannel() {
    launch("https://t.me/plannapp");
  }
}

class SettingsViewState {
  final bool loaded;
  final String version;
  final String buildNumber;
  final DateTime blockingDate;

  SettingsViewState.loading()
      : loaded = false,
        version = null,
        buildNumber = null,
        blockingDate = null;

  SettingsViewState.loaded(this.version, this.buildNumber, this.blockingDate)
      : loaded = true;
}
