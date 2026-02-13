import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  /// Requests all necessary initial permissions for the app.
  static Future<void> requestInitialPermissions() async {
    List<Permission> permissions = [Permission.camera, Permission.notification];

    // Storage permissions handling based on Platform/Version
    if (Platform.isAndroid) {
      // For Android 13+ (API 33), we use photos permission
      // For older versions, we use storage
      permissions.add(Permission.photos);
      permissions.add(Permission.storage);
    } else {
      permissions.add(Permission.photos);
    }

    // Request multiple permissions at once
    await permissions.request();

    // You can log or handle statuses if needed
    // statuses.forEach((permission, status) {
    //   print('${permission.toString()}: $status');
    // });
  }
}
