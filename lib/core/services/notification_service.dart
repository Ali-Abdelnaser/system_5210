import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system_5210/core/utils/app_routes.dart';
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/core/utils/injection_container.dart' as di;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return; // Not supported on web without complex setup
    try {
      tz_data.initializeTimeZones();

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

      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint("Error in Notification Init: $e");
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

  Future<void> scheduleDailyReminder({
    required String title,
    required String body,
  }) async {
    if (!await _shouldShowNotification('streak')) return;
    final playSound = await _shouldPlaySound();

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0,
        title: title,
        body: body,
        scheduledDate: _nextInstance1015PM(),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_streak_channel',
            'Daily Streak Reminders',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'ic_stat_name',
            playSound: playSound,
          ),
          iOS: DarwinNotificationDetails(presentSound: playSound),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Error scheduling daily reminder: $e");
    }
  }

  Future<void> scheduleDailyTip({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String category = 'insights',
    String? payload,
  }) async {
    try {
      if (!await _shouldShowNotification(category)) return;
      final playSound = await _shouldPlaySound();

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint("Skipping scheduling for past date: $tzScheduledDate");
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_tips_channel',
            'Daily Tips',
            channelDescription: 'Daily healthy tips for parents',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'ic_stat_name',
            playSound: playSound,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: playSound,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      debugPrint("Notification scheduled successfully at: $tzScheduledDate");
    } catch (e) {
      debugPrint("Error scheduling daily tip: $e");
    }
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? imageUrl,
    String? actionUrl,
    bool showAction = false,
    int? badgeCount,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000 % 0x7FFFFFFF;

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

      if (!await _shouldShowNotification('all')) return;
      final playSound = await _shouldPlaySound();

      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'broadcast_channel',
            'Broadcast Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'ic_stat_name',
            playSound: playSound,
            enableVibration: true,
            styleInformation: bigPictureStyleInformation,
            number: badgeCount,
            actions: showAction
                ? [
                    const AndroidNotificationAction(
                      'go_action',
                      'مشاهدة الآن',
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

  tz.TZDateTime _nextInstance1015PM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      22,
      15,
      0,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<bool> _shouldShowNotification(String category) async {
    final storage = di.sl<LocalStorageService>();
    final settings = await storage.get('app_settings', 'notification_settings');
    if (settings == null) return true;

    final allEnabled = settings['all'] ?? true;
    if (!allEnabled) return false;

    if (category == 'all') return true;
    return settings[category] ?? true;
  }

  Future<bool> _shouldPlaySound() async {
    final storage = di.sl<LocalStorageService>();
    final settings = await storage.get('app_settings', 'notification_settings');
    if (settings == null) return true;
    return settings['sounds'] ?? true;
  }
}
