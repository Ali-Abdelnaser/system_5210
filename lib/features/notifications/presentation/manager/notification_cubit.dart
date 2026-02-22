import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/core/services/notification_service.dart';
import 'package:system_5210/core/utils/app_tips_data.dart';
import 'package:system_5210/features/notifications/data/models/notification_model.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final LocalStorageService localStorageService;
  final NotificationService notificationService;
  String? _userId;

  String get _boxName =>
      _userId != null ? 'notifications_$_userId' : 'notifications';

  NotificationCubit({
    required this.localStorageService,
    required this.notificationService,
  }) : super(NotificationInitial());

  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;

    if (_userId == null) {
      _broadcastSubscription?.cancel();
      _broadcastSubscription = null;
      emit(const NotificationLoaded([]));
      return;
    }

    // Restart broadcast listener for the new user-specific box
    listenToBroadcastNotifications();

    // Reload UI
    loadNotifications();
  }

  StreamSubscription? _broadcastSubscription;
  final DateTime _listenerStartTime = DateTime.now();

  void listenToBroadcastNotifications() {
    _broadcastSubscription?.cancel();
    _broadcastSubscription = FirebaseFirestore.instance
        .collection('broadcast_notifications')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) async {
          final notifications = await localStorageService.getAll(_boxName);
          final existingIds = notifications.map((e) => e['id']).toSet();

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final id = doc.id;

            if (!existingIds.contains(id)) {
              // New broadcast notification found
              final timestamp =
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

              // We'll store both but the model might need to stay constant.
              // For now let's just use the current language or store it in a way we can choose.
              // Usually we store the raw data and the UI handles l10n.

              final notification = AppNotification(
                id: id,
                title: data['titleAr'] ?? '',
                body: data['bodyAr'] ?? '',
                titleEn: data['titleEn'],
                bodyEn: data['bodyEn'],
                imageUrl: data['imageUrl'],
                actionUrl: data['actionUrl'],
                timestamp: timestamp,
                type: 'broadcast',
              );

              await localStorageService.save(
                _boxName,
                notification.id,
                notification.toMap(),
              );

              // Show immediate local notification for new broadcast messages
              // only if the notification is recent (after app start)
              if (timestamp.isAfter(
                _listenerStartTime.subtract(const Duration(minutes: 1)),
              )) {
                notificationService.showImmediateNotification(
                  title: notification.title,
                  body: notification.body,
                  imageUrl: notification.imageUrl,
                  actionUrl: notification.actionUrl,
                );
              }
            }
          }

          // Reload UI
          loadNotifications();
        });
  }

  @override
  Future<void> close() {
    _broadcastSubscription?.cancel();
    return super.close();
  }

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    try {
      final notifications = await localStorageService.getAll(_boxName);
      final list = notifications
          .map((e) => AppNotification.fromMap(e))
          .toList();
      // Sort by timestamp descending
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      emit(NotificationLoaded(list));
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }

  Future<void> scheduleDailyTipsIfNeeded(String role) async {
    if (role != 'parent') return;

    try {
      final tipKey = 'last_tip_scheduled_date_$_userId';
      final lastScheduled = await localStorageService.get('settings', tipKey);
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastScheduled == null || lastScheduled['date'] != today) {
        // ... (previous logic for picking tip) ...
        final now = DateTime.now();
        final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

        final random = Random(dayOfYear + now.year);
        final tipIndex = random.nextInt(AppTipsData.parentTips.length);
        final tip = AppTipsData.parentTips[tipIndex];

        await notificationService.scheduleDailyTip(
          title: tip.title,
          body: tip.description,
        );

        final notification = AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: tip.title,
          body: tip.description,
          timestamp: DateTime(now.year, now.month, now.day, 10),
          type: 'tip',
        );

        await localStorageService.save(
          _boxName,
          notification.id,
          notification.toMap(),
        );
        await localStorageService.save('settings', tipKey, {'date': today});

        if (state is NotificationLoaded) {
          final currentList = (state as NotificationLoaded).notifications;
          emit(NotificationLoaded([notification, ...currentList]));
        } else {
          loadNotifications();
        }
      }
    } catch (e) {
      print("Error scheduling daily tips: $e");
    }
  }

  Future<void> markAsRead(String id) async {
    if (state is NotificationLoaded) {
      final currentList = (state as NotificationLoaded).notifications;
      final index = currentList.indexWhere((n) => n.id == id);
      if (index != -1) {
        final updated = currentList[index].copyWith(isRead: true);
        await localStorageService.save(_boxName, id, updated.toMap());

        final newList = List<AppNotification>.from(currentList);
        newList[index] = updated;
        emit(NotificationLoaded(newList));
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    if (state is NotificationLoaded) {
      final currentList = (state as NotificationLoaded).notifications;
      final newList = currentList.where((n) => n.id != id).toList();

      await localStorageService.delete(_boxName, id);
      emit(NotificationLoaded(newList));
    }
  }

  Future<void> clearAll() async {
    try {
      final notifications = await localStorageService.getAll(_boxName);
      for (var n in notifications) {
        await localStorageService.delete(_boxName, n['id']);
      }
      emit(const NotificationLoaded([]));
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }
}
