import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:five2ten/core/constants/notification_categories.dart';
import 'package:five2ten/core/services/fcm_background_handler.dart';
import 'package:five2ten/core/utils/app_routes.dart';
import 'package:five2ten/core/services/notification_deep_link.dart';
import 'package:five2ten/core/services/local_storage_service.dart';
import 'package:five2ten/core/utils/injection_container.dart' as di;

/// Local: immediate toasts only. Daily engagement: **FCM** (see Cloud Function).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_stat_name');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      await _initFirebaseMessaging();

      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.requestNotificationsPermission();

      await NotificationDeepLink.captureFromTerminatedState(
        localNotifications: flutterLocalNotificationsPlugin,
      );
    } catch (e) {
      debugPrint("Error in Notification Init: $e");
    }
  }

  Future<void> _initFirebaseMessaging() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null) {
          final category =
              message.data['category'] ?? NotificationCategories.daily;
          showImmediateNotification(
            title: notification.title ?? '',
            body: notification.body ?? '',
            imageUrl: android?.imageUrl,
            showAction: true,
            actionUrl: message.data['route'] != null
                ? 'route:${message.data['route']}'
                : null,
            category: category,
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final route = message.data['route'];
        if (route != null && route.isNotEmpty) {
          AppRoutes.navigatorKey.currentState?.pushNamed(route);
        }
      });

      final token = await _firebaseMessaging.getToken();
      debugPrint("FCM Token: $token");
    } catch (e) {
      debugPrint("Error initializing Firebase Messaging: $e");
    }
  }

  void _handleNotificationTap(NotificationResponse details) async {
    final String? payload = details.payload;
    if (payload == null) return;

    if (payload.startsWith('http')) {
      final uri = Uri.parse(payload);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Error launching from notification: $e');
      }
      return;
    }

    if (payload.startsWith('route:')) {
      final route = payload.replaceFirst('route:', '');
      AppRoutes.navigatorKey.currentState?.pushNamed(route);
      return;
    }

    if (details.actionId == 'go_action') {
      AppRoutes.navigatorKey.currentState?.pushNamed(AppRoutes.notifications);
    }
  }

  /// [category] matches notification settings: [NotificationCategories].
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? imageUrl,
    String? actionUrl,
    bool showAction = false,
    String? actionTitle,
    int? badgeCount,
    String category = NotificationCategories.insights,
  }) async {
    try {
      if (!await _shouldShowForCategory(category)) return;

      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000 % 0x7FFFFFFF;

      final String finalActionTitle = actionTitle ??
          (title.contains(RegExp(r'[أ-ي]')) ? 'مشاهدة الآن' : 'View Now');

      BigPictureStyleInformation? bigPictureStyleInformation;
      if (imageUrl != null && imageUrl.startsWith('http')) {
        try {
          final String filePath = await _downloadAndSaveFile(
            imageUrl,
            'notification_img_$id',
          );
          bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(filePath),
            largeIcon: FilePathAndroidBitmap(filePath),
            contentTitle: title,
            summaryText: body,
          );
        } catch (e) {
          debugPrint("Error downloading notification image: $e");
        }
      }

      final playSound = await _shouldPlaySound();

      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'broadcast_channel',
            '5210 Notifications',
            channelDescription: 'Updates, tips, and achievements',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'ic_stat_name',
            playSound: playSound,
            enableVibration: true,
            styleInformation: bigPictureStyleInformation,
            number: badgeCount,
            actions: showAction
                ? [
                    AndroidNotificationAction(
                      'go_action',
                      finalActionTitle,
                      showsUserInterface: true,
                    ),
                  ]
                : null,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: playSound,
            badgeNumber: badgeCount,
            attachments: imageUrl != null
                ? [DarwinNotificationAttachment(imageUrl)]
                : null,
          ),
        ),
        payload: actionUrl,
      );
    } catch (e) {
      debugPrint("Error showing immediate notification: $e");
    }
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final HttpClient httpClient = HttpClient();
    final HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    final HttpClientResponse response = await request.close();
    final File file = File(filePath);
    await response.pipe(file.openWrite());
    return filePath;
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<bool> _shouldShowForCategory(String category) async {
    final storage = di.sl<LocalStorageService>();
    final settings = await storage.get('app_settings', 'notification_settings');
    if (settings == null) return true;

    final allEnabled = settings['all'] ?? true;
    if (!allEnabled) return false;

    if (category == NotificationCategories.daily) {
      final streak = settings['streak'] ?? true;
      final tasks = settings['tasks'] ?? true;
      final insights = settings['insights'] ?? true;
      return streak || tasks || insights;
    }

    return settings[category] ?? true;
  }

  Future<bool> _shouldPlaySound() async {
    final storage = di.sl<LocalStorageService>();
    final settings = await storage.get('app_settings', 'notification_settings');
    if (settings == null) return true;
    return settings['sounds'] ?? true;
  }
}
