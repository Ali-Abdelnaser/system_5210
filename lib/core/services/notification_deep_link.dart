import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:five2ten/core/utils/app_routes.dart';

/// Captures FCM [RemoteMessage.getInitialMessage] and local notification
/// launch details so navigation can run after splash/auth when the shell is ready.
class NotificationDeepLink {
  NotificationDeepLink._();

  static String? _pendingRoute;

  /// Call after [FlutterLocalNotificationsPlugin.initialize] and Firebase init.
  static Future<void> captureFromTerminatedState({
    required FlutterLocalNotificationsPlugin localNotifications,
  }) async {
    if (kIsWeb) return;
    try {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        final r = initial.data['route'];
        if (r is String && r.isNotEmpty) {
          _pendingRoute ??= r;
        }
      }

      final launch = await localNotifications.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true) {
        final payload = launch!.notificationResponse?.payload;
        final fromPayload = _routeFromPayload(payload);
        if (fromPayload != null) {
          _pendingRoute ??= fromPayload;
        }
      }
    } catch (e) {
      debugPrint('NotificationDeepLink.captureFromTerminatedState: $e');
    }
  }

  static String? _routeFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    if (payload.startsWith('route:')) {
      return payload.substring('route:'.length);
    }
    return null;
  }

  /// Call when [MainLayoutView] (logged-in home shell) is mounted.
  static void consumePendingIfAny() {
    final route = _pendingRoute;
    if (route == null || route.isEmpty) return;
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    if (route == AppRoutes.home) {
      _pendingRoute = null;
      return;
    }

    Route<dynamic>? generated;
    try {
      generated = AppRoutes.onGenerateRoute(RouteSettings(name: route));
    } catch (e) {
      debugPrint('NotificationDeepLink: invalid route $route: $e');
    }
    if (generated == null) {
      _pendingRoute = null;
      return;
    }

    _pendingRoute = null;

    final toPush = generated;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = AppRoutes.navigatorKey.currentState;
      if (nav == null) return;
      try {
        nav.push(toPush);
      } catch (e) {
        debugPrint('NotificationDeepLink.push: $e');
      }
    });
  }
}
