import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../network/network_info.dart';
import 'app_alerts.dart';
import 'injection_container.dart';

class AppUtils {
  static Future<bool> checkInternet(BuildContext context) async {
    final networkInfo = sl<NetworkInfo>();
    if (!await networkInfo.isConnected) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppAlerts.showAlert(
          context,
          message: l10n.noInternetDesc,
          type: AlertType.error,
        );
      }
      return false;
    }
    return true;
  }
}
