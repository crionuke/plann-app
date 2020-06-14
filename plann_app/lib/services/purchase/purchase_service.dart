import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:plann_app/components/app_texts.dart';
import 'package:plann_app/components/app_values.dart';
import 'package:plann_app/services/db/models/currency_model.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  static const API_KEY = "QcsNMFNHlhaJmTxHTCXMoaglosdSUCXo";
  static const FREE_PERIOD_DAYS = 14;

  final List<PurchaseItem> purchaseList = List();

  PurchaseItem _basePurchaseItem;

  Future<void> start() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup(API_KEY);

    Offerings offerings = await Purchases.getOfferings();
    print("[PurchaseService] ${offerings}");
    if (offerings.current != null) {
      for (Package package in offerings.current.availablePackages) {
        purchaseList.add(PurchaseItem(package));
      }

      _basePurchaseItem = PurchaseItem(offerings.current.monthly);
    }
  }

  PurchaseItem get basePurchaseItem => _basePurchaseItem;

  Future<DateTime> get blockingDate async {
    PurchaserInfo purchaserInfo = await _getPurchaseInfo();
    DateTime result = purchaserInfo != null
        ? DateTime.parse(purchaserInfo.firstSeen)
            .add(Duration(days: FREE_PERIOD_DAYS))
        : null;
    print("[PurchaseService] blockingDate=$result");
    return result;
  }

  Future<bool> hasAccess() async {
    PurchaserInfo purchaserInfo = await _getPurchaseInfo();
    bool result = purchaserInfo != null
        ? _checkAccessEntitlement(purchaserInfo) ||
            DateTime.now().millisecondsSinceEpoch <
                (await blockingDate).millisecondsSinceEpoch
        : true;
    print("[PurchaseService] hasAccess=$result");
    return result;
  }

  Future<AccessEntitlement> getAccessEntitlement() async {
    PurchaserInfo purchaserInfo = await _getPurchaseInfo();
    if (purchaserInfo != null) {
      EntitlementInfo entitlementInfo =
          purchaserInfo.entitlements.all["Access"];
      if (entitlementInfo != null && entitlementInfo.isActive) {
        return AccessEntitlement(entitlementInfo);
      }
    }
    return null;
  }

  Future<bool> hasAccessEntitilement() async {
    return (await getAccessEntitlement() != null);
  }

  Future<bool> restorePurchases() async {
    try {
      PurchaserInfo purchaserInfo = await Purchases.restoreTransactions();
      print("[PurchaseService] restorePurchases=$purchaserInfo");
      return true;
    } on PlatformException catch (e) {
      print("[PurchaseService] restorePurchases() failed with $e");
      return false;
    }
  }

  bool _checkAccessEntitlement(PurchaserInfo purchaserInfo) {
    EntitlementInfo result = purchaserInfo.entitlements.all["Access"];
    if (result != null) {
      return result.isActive;
    } else {
      return false;
    }
  }

  Future<PurchaserInfo> _getPurchaseInfo() async {
    try {
      PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
      print("[PurchaseService] purchaserInfo=$purchaserInfo");
      return purchaserInfo;
    } on PlatformException catch (e) {
      print("[PurchaseService] getPurchaserInfo failed with $e");
      return null;
    }
  }
}

class AccessEntitlement {
  EntitlementInfo _entitlementInfo;

  AccessEntitlement(EntitlementInfo entitlementInfo) {
    _entitlementInfo = entitlementInfo;
  }

  String buildTitle(BuildContext context) {
    final String originalPurchaseDate = AppTexts.formatDate(
        context, DateTime.parse(_entitlementInfo.originalPurchaseDate));
    return FlutterI18n.translate(context, "texts.entitlement_original_date",
        translationParams: {"date": "$originalPurchaseDate"});
  }

  String buildSubTitle(BuildContext context) {
    if (_entitlementInfo.expirationDate != null) {
      if (_entitlementInfo.willRenew) {
        final String expirationDate = AppTexts.formatDateTime(
            context, DateTime.parse(_entitlementInfo.expirationDate));
        return FlutterI18n.translate(context, "texts.entitlement_renew_date",
            translationParams: {"date": "$expirationDate"});
      } else {
        final String expirationDate = AppTexts.formatDateTime(
            context, DateTime.parse(_entitlementInfo.expirationDate));
        return FlutterI18n.translate(context, "texts.entitlement_ending_date",
            translationParams: {"date": "$expirationDate"});
      }
    } else {
      return "";
    }
  }
}

class PurchaseItem {
  Package _package;
  String _title;
  String _priceString;
  String _type;

  double _price;

  PurchaseItem(Package package) {
    _package = package;
    _title = package.product.title;
    _type = package.packageType.toString().split(".")[1];
    _priceString = package.product.priceString;
    _price = package.product.price;
  }

  String get title => _title;

  String get priceString => _priceString;

  String get type => _type;

  double get price => _price;

  String buildTitle(BuildContext context) {
    return FlutterI18n.translate(context, "texts.purchase_title",
        translationParams: {
          "title": _title,
          "price": _priceString,
          "period": _buildPeriod(context)
        });
  }

  String buildSubTitle(BuildContext context, double basePrice) {
    if (_package.packageType == PackageType.annual) {
      double perMonthPrice = _package.product.price / 12;
      double saveValue = (basePrice * 12 / _package.product.price - 1) * 100;

      String perMonthPriceString = "UNKNOWN";
      if (_package.product.currencyCode == "RUB") {
        perMonthPriceString = AppTexts.formatCurrencyValue(
            context, CurrencyType.rubles, perMonthPrice);
      } else if (_package.product.currencyCode == "USD") {
        perMonthPriceString = AppTexts.formatCurrencyValue(
            context, CurrencyType.dollars, perMonthPrice);
      } else if (_package.product.currencyCode == "EUR") {
        perMonthPriceString = AppTexts.formatCurrencyValue(
            context, CurrencyType.euro, perMonthPrice);
      } else {
        perMonthPriceString = perMonthPrice.toStringAsFixed(2) +
            " " +
            _package.product.currencyCode;
      }

      return FlutterI18n.translate(context, "texts.purchase_annual_subtitle",
          translationParams: {
            "per_month_price": perMonthPriceString,
            "save_value": saveValue.toStringAsFixed(0),
          });
    } else {
      return "";
    }
  }

  Future<PurchaseResult> makePurchase() async {
    try {
      PurchaserInfo purchaserInfo = await Purchases.purchasePackage(_package);
      print("[PurchaseService] purchaserInfo=$purchaserInfo");
      return PurchaseResult.completed();
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled();
      } else {
        return PurchaseResult.failed(e);
      }
    }
  }

  String _buildPeriod(BuildContext context) {
    return FlutterI18n.translate(context, "package_type." + type);
  }
}

class PurchaseResult {
  final bool completed;
  final bool cancelled;
  final bool failed;
  final PlatformException platformException;

  PurchaseResult.completed()
      : completed = true,
        cancelled = false,
        failed = false,
        platformException = null;

  PurchaseResult.cancelled()
      : completed = false,
        cancelled = true,
        failed = false,
        platformException = null;

  PurchaseResult.failed(this.platformException)
      : completed = false,
        cancelled = false,
        failed = true;

  @override
  String toString() {
    return "PurchaseResult(completed=$completed, cancelled=$cancelled, "
        "failed=$failed, platformException=$platformException)";
  }
}
