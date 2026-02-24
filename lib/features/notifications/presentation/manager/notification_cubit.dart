import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/core/services/notification_service.dart';
import 'package:system_5210/core/utils/app_tips_data.dart';
import 'package:system_5210/features/notifications/data/models/notification_model.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:system_5210/core/utils/app_routes.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final LocalStorageService localStorageService;
  final NotificationService notificationService;
  String? _userId;

  String get _boxName =>
      _userId != null ? 'notifications_$_userId' : 'notifications';

  String get _deletedBoxName => _userId != null
      ? 'deleted_notifications_$_userId'
      : 'deleted_notifications';

  NotificationCubit({
    required this.localStorageService,
    required this.notificationService,
  }) : super(NotificationInitial());

  DateTime? _userCreatedAt;

  void setUserContext(String? userId, DateTime? createdAt, {String? role}) {
    if (_userId == userId && _userCreatedAt == createdAt) return;
    _userId = userId;
    _userCreatedAt = createdAt;

    if (_userId == null) {
      _broadcastSubscription?.cancel();
      _personalSubscription?.cancel();
      _broadcastSubscription = null;
      _personalSubscription = null;
      emit(const NotificationLoaded([]));
      return;
    }

    _setupNotificationListeners();
    loadNotifications();

    if (role == 'child') {
      scheduleMorningQuest(isAr: true);
    } else if (role == 'parent') {
      scheduleDailyTipsIfNeeded(role!);
    }
  }

  StreamSubscription? _broadcastSubscription;
  StreamSubscription? _personalSubscription;
  final DateTime _sessionStartTime = DateTime.now();

  void _setupNotificationListeners() {
    _broadcastSubscription?.cancel();
    _personalSubscription?.cancel();

    _broadcastSubscription = FirebaseFirestore.instance
        .collection('broadcast_notifications')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) => _processSnapshot(snapshot, isBroadcast: true));

    _personalSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId!)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) => _processSnapshot(snapshot, isBroadcast: false));
  }

  Future<void> _processSnapshot(
    QuerySnapshot snapshot, {
    required bool isBroadcast,
  }) async {
    final notifications = await localStorageService.getAll(_boxName);
    final existingIds = notifications.map((e) => e['id']).toSet();

    final deletedDocs = await localStorageService.getAll(_deletedBoxName);
    final deletedIds = deletedDocs.map((e) => e['id']).toSet();

    bool hasNewItems = false;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final id = doc.id;
      final timestamp =
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

      if (isBroadcast && _userCreatedAt != null) {
        if (timestamp.isBefore(_userCreatedAt!)) continue;
      }

      if (!existingIds.contains(id) && !deletedIds.contains(id)) {
        final notification = AppNotification(
          id: id,
          title: data['titleAr'] ?? data['title'] ?? '',
          body: data['bodyAr'] ?? data['body'] ?? '',
          titleEn: data['titleEn'],
          bodyEn: data['bodyEn'],
          imageUrl: data['imageUrl'],
          actionUrl: data['actionUrl'],
          timestamp: timestamp,
          type: data['type'] ?? (isBroadcast ? 'broadcast' : 'personal'),
        );

        await localStorageService.save(_boxName, id, notification.toMap());
        hasNewItems = true;

        if (timestamp.isAfter(
          _sessionStartTime.subtract(const Duration(seconds: 10)),
        )) {
          notificationService.showImmediateNotification(
            title: notification.title,
            body: notification.body,
            imageUrl: notification.imageUrl,
            actionUrl: notification.actionUrl,
            showAction: true,
            badgeCount: _getUnreadCount(notifications),
          );
        }
      }
    }

    if (hasNewItems || snapshot.docs.isEmpty) {
      loadNotifications();
    }
  }

  @override
  Future<void> close() {
    _broadcastSubscription?.cancel();
    _personalSubscription?.cancel();
    return super.close();
  }

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    try {
      final notifications = await localStorageService.getAll(_boxName);
      final list = notifications
          .map((e) => AppNotification.fromMap(e))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      emit(NotificationLoaded(list));
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }

  int _getUnreadCount(List<Map<String, dynamic>> notifications) {
    return notifications.where((n) => n['isRead'] == false).length;
  }

  Future<void> scheduleMorningQuest({required bool isAr}) async {
    if (_userId == null) return;
    try {
      final key = 'morning_quest_scheduled_$_userId';
      final lastScheduled = await localStorageService.get('settings', key);
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastScheduled != null && lastScheduled['date'] == today) return;

      final title = isAr ? "يا بطل، يوم جديد! ✨" : "Good morning, Champ! ✨";
      final body = isAr
          ? "جاهز لتحدي الـ 5210 النهاردة؟ افتح الأبلكيشن وشوف مهمتك."
          : "Ready for today's 5210 challenge? Open and see your mission.";

      await notificationService.scheduleDailyTip(
        id: 9999,
        title: title,
        body: body,
        scheduledDate: _nextMorning8AM(),
        payload: 'route:${AppRoutes.home}',
      );

      await localStorageService.save('settings', key, {'date': today});
    } catch (e) {
      debugPrint("Error scheduling morning quest: $e");
    }
  }

  DateTime _nextMorning8AM() {
    final now = DateTime.now();
    DateTime scheduled = DateTime(now.year, now.month, now.day, 8, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> scheduleDailyTipsIfNeeded(String role) async {
    if (role != 'parent' || _userId == null) return;

    try {
      final tipKey = 'last_tip_scheduled_date_$_userId';
      final lastScheduled = await localStorageService.get('settings', tipKey);
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastScheduled != null && lastScheduled['date'] == today) return;

      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final scheduledDay = now.add(Duration(days: i));
        final scheduledDate = DateTime(
          scheduledDay.year,
          scheduledDay.month,
          scheduledDay.day,
          10,
          0,
        );

        if (i == 0 && now.hour >= 10) continue;

        final dayOfYear = scheduledDate
            .difference(DateTime(scheduledDate.year, 1, 1))
            .inDays;
        final random = Random(
          dayOfYear + scheduledDate.year + (_userId.hashCode),
        );
        final tipIndex = random.nextInt(AppTipsData.parentTips.length);
        final tip = AppTipsData.parentTips[tipIndex];

        final uniqueIntId =
            1000 +
            (scheduledDate.year % 100 * 10000) +
            (scheduledDate.month * 100) +
            scheduledDate.day;

        await notificationService.scheduleDailyTip(
          id: uniqueIntId,
          title: tip.title,
          body: tip.description,
          scheduledDate: scheduledDate,
          payload: 'route:/daily-tip',
        );

        if (i == 0) {
          final id = "tip_$uniqueIntId";
          final notification = AppNotification(
            id: id,
            title: tip.title,
            body: tip.description,
            timestamp: scheduledDate,
            type: 'tip',
          );
          await localStorageService.save(_boxName, id, notification.toMap());
        }
      }

      await localStorageService.save('settings', tipKey, {'date': today});
      loadNotifications();
    } catch (e) {
      debugPrint("Error scheduling multi-day tips: $e");
    }
  }

  Future<void> addGameRewardNotification({
    required String gameName,
    required int score,
    required String reward,
    bool isAr = true,
  }) async {
    final title = isAr
        ? "مبروك! إنجاز في $gameName"
        : "Congrats! Achievement in $gameName";
    final body = isAr
        ? "حققت $score نقطة وفزت بـ $reward! استمر يا بطل ✨"
        : "You scored $score and won $reward! Keep it up ✨";

    final id = "game_${DateTime.now().millisecondsSinceEpoch}";
    final notification = AppNotification(
      id: id,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: 'challenge',
      actionUrl: 'route:/games-list',
    );

    await _addAndNotify(notification);
  }

  Future<void> _addAndNotify(AppNotification notification) async {
    await localStorageService.save(
      _boxName,
      notification.id,
      notification.toMap(),
    );

    final notifications = await localStorageService.getAll(_boxName);
    notificationService.showImmediateNotification(
      title: notification.title,
      body: notification.body,
      actionUrl: notification.actionUrl,
      showAction: true,
      badgeCount: _getUnreadCount(notifications),
    );

    if (state is NotificationLoaded) {
      final currentList = (state as NotificationLoaded).notifications;
      emit(NotificationLoaded([notification, ...currentList]));
    } else {
      loadNotifications();
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
      await localStorageService.save(_deletedBoxName, id, {'id': id});
      emit(NotificationLoaded(newList));
    }
  }

  Future<void> clearAll() async {
    try {
      final notifications = await localStorageService.getAll(_boxName);
      for (var n in notifications) {
        final id = n['id'];
        await localStorageService.delete(_boxName, id);
        await localStorageService.save(_deletedBoxName, id, {'id': id});
      }
      emit(const NotificationLoaded([]));
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }

  Future<void> toggleLike(String id) async {
    if (state is NotificationLoaded) {
      final currentList = (state as NotificationLoaded).notifications;
      final index = currentList.indexWhere((n) => n.id == id);
      if (index != -1) {
        final updated = currentList[index].copyWith(
          isLiked: !currentList[index].isLiked,
        );
        await localStorageService.save(_boxName, id, updated.toMap());

        final newList = List<AppNotification>.from(currentList);
        newList[index] = updated;
        emit(NotificationLoaded(newList));
      }
    }
  }
}
