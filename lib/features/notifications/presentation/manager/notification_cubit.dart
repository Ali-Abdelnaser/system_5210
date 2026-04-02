import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:five2ten/core/constants/notification_categories.dart';
import 'package:five2ten/core/services/fcm_token_service.dart';
import 'package:five2ten/core/services/local_storage_service.dart';
import 'package:five2ten/core/services/notification_service.dart';
import 'package:five2ten/features/notifications/data/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final LocalStorageService localStorageService;
  final NotificationService notificationService;
  final FcmTokenService fcmTokenService;
  String? _userId;
  String _languageCode = 'ar';

  String get _boxName =>
      _userId != null ? 'notifications_$_userId' : 'notifications';

  String get _deletedBoxName => _userId != null
      ? 'deleted_notifications_$_userId'
      : 'deleted_notifications';

  NotificationCubit({
    required this.localStorageService,
    required this.notificationService,
    required this.fcmTokenService,
  }) : super(NotificationInitial());

  DateTime? _userCreatedAt;

  void setUserContext(String? userId, DateTime? createdAt, {String? role, String? langCode}) {
    if (langCode != null) _languageCode = langCode;

    final sameUser = _userId == userId && _userCreatedAt == createdAt;

    if (!sameUser) {
      final previousUid = _userId;
      _userId = userId;
      _userCreatedAt = createdAt;

      if (_userId == null) {
        if (previousUid != null) {
          fcmTokenService.unbindAndClearFirestore(previousUid);
        }
        _broadcastSubscription?.cancel();
        _personalSubscription?.cancel();
        _broadcastSubscription = null;
        _personalSubscription = null;
        emit(const NotificationLoaded([]));
        return;
      }

      fcmTokenService.bindToUser(_userId!, previousUid: previousUid);
      _setupNotificationListeners();
      loadNotifications();
    }
  }

  /// Re-register FCM token after user re-enables notifications (local schedules removed; FCM handles daily push).
  Future<void> syncFcmAfterReenableNotifications({
    String? userId,
    required String role,
  }) async {
    if (userId != null) _userId = userId;
    if (_userId == null) return;
    if (role != 'child' && role != 'parent') return;
    try {
      await fcmTokenService.bindToUser(_userId!);
    } catch (e) {
      debugPrint('syncFcmAfterReenableNotifications: $e');
    }
  }

  StreamSubscription? _broadcastSubscription;
  StreamSubscription? _personalSubscription;
  final DateTime _sessionStartTime = DateTime.now();
  bool _initialBroadcastProcessed = false;
  bool _initialPersonalProcessed = false;
  bool _wasBoxEmptyOnStart = false;

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
    final notificationsData = await localStorageService.getAll(_boxName);
    final existingIds = notificationsData.map((e) => e['id']).toSet();

    if (existingIds.isEmpty &&
        !(_initialBroadcastProcessed || _initialPersonalProcessed)) {
      _wasBoxEmptyOnStart = true;
    }

    final deletedDocs = await localStorageService.getAll(_deletedBoxName);
    final deletedIds = deletedDocs.map((e) => e['id']).toSet();

    bool hasNewItems = false;
    final bool isStreamInitial = isBroadcast
        ? !_initialBroadcastProcessed
        : !_initialPersonalProcessed;

    // On fresh install, anything already in DB is "Read" unless DB explicitly says otherwise
    final bool isPureInitialLoad = _wasBoxEmptyOnStart && isStreamInitial;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final id = doc.id;
      final timestamp =
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

      if (isBroadcast && _userCreatedAt != null) {
        if (timestamp.isBefore(_userCreatedAt!)) continue;
      }

      if (!existingIds.contains(id) && !deletedIds.contains(id)) {
        final isOld = timestamp.isBefore(
          DateTime.now().subtract(const Duration(hours: 24)),
        );

        final bool isReadValue =
            data['isRead'] ?? (isPureInitialLoad ? true : isOld);

        final notification = AppNotification(
          id: id,
          title: data['titleAr'] ?? data['title'] ?? '',
          body: data['bodyAr'] ?? data['body'] ?? '',
          titleEn: data['titleEn'],
          bodyEn: data['bodyEn'],
          imageUrl: data['imageUrl'],
          actionUrl: data['actionUrl'],
          timestamp: timestamp,
          isRead: isReadValue,
          type: data['type'] ?? (isBroadcast ? 'broadcast' : 'personal'),
        );

        await localStorageService.save(_boxName, id, notification.toMap());
        hasNewItems = true;

        if (!isPureInitialLoad &&
            timestamp.isAfter(
              _sessionStartTime.subtract(const Duration(seconds: 10)),
            )) {
          final isAr = _languageCode == 'ar';
          final category = notification.type == 'challenge'
              ? NotificationCategories.tasks
              : NotificationCategories.insights;
          notificationService.showImmediateNotification(
            title: isAr ? notification.title : (notification.titleEn ?? notification.title),
            body: isAr ? notification.body : (notification.bodyEn ?? notification.body),
            imageUrl: notification.imageUrl,
            actionUrl: notification.actionUrl,
            showAction: true,
            badgeCount: _getUnreadCount(notificationsData),
            category: category,
          );
        }
      }
    }

    if (isBroadcast) {
      _initialBroadcastProcessed = true;
    } else {
      _initialPersonalProcessed = true;
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
          .where(
            (n) => n.timestamp.isBefore(
              DateTime.now().add(const Duration(minutes: 1)),
            ),
          )
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      emit(NotificationLoaded(list));
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }

  int _getUnreadCount(List<dynamic> notifications) {
    return notifications.where((n) => n['isRead'] == false).length;
  }

  Future<void> addGameRewardNotification({
    required String gameName,
    required int score,
    required String reward,
  }) async {
    const titleAr = "مبروك! إنجاز جديد";
    final bodyAr = "لقد حققت $score نقطة في $gameName وفزت بـ $reward! ✨";
    
    const titleEn = "Congrats! New Achievement";
    final bodyEn = "You scored $score in $gameName and won $reward! ✨";

    final id = "game_${DateTime.now().millisecondsSinceEpoch}";
    final notification = AppNotification(
      id: id,
      title: titleAr,
      body: bodyAr,
      titleEn: titleEn,
      bodyEn: bodyEn,
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
    final isAr = _languageCode == 'ar';
    final category = notification.type == 'challenge'
        ? NotificationCategories.tasks
        : NotificationCategories.insights;
    notificationService.showImmediateNotification(
      title: isAr ? notification.title : (notification.titleEn ?? notification.title),
      body: isAr ? notification.body : (notification.bodyEn ?? notification.body),
      actionUrl: notification.actionUrl,
      showAction: true,
      badgeCount: _getUnreadCount(notifications),
      category: category,
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

        // Sync with Firestore for personal notifications
        if (updated.type != 'broadcast' && _userId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_userId)
              .collection('notifications')
              .doc(id)
              .update({'isRead': true})
              .catchError((e) => debugPrint("Firestore Update Error: $e"));
        }

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

      // Sync with Firestore for personal notifications
      if (_userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('notifications')
            .doc(id)
            .delete()
            .catchError((e) => debugPrint("Firestore Delete Error: $e"));
      }

      emit(NotificationLoaded(newList));
    }
  }

  Future<void> clearAll() async {
    try {
      final notifications = await localStorageService.getAll(_boxName);
      for (var n in notifications) {
        final id = n['id'];
        final type = n['type'];
        await localStorageService.delete(_boxName, id);
        await localStorageService.save(_deletedBoxName, id, {'id': id});

        // Sync with Firestore
        if (type != 'broadcast' && _userId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_userId)
              .collection('notifications')
              .doc(id)
              .delete()
              .catchError(
                (e) => debugPrint("Firestore Batch Delete Error: $e"),
              );
        }
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
