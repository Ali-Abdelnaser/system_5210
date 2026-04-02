import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:five2ten/core/services/local_storage_service.dart';

/// Persists FCM token + notification preferences on [users/{uid}] for Cloud Functions.
class FcmTokenService {
  FcmTokenService({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
    LocalStorageService? localStorage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _localStorage = localStorage;

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final LocalStorageService? _localStorage;

  String? _boundUid;
  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> bindToUser(String uid, {String? previousUid}) async {
    if (kIsWeb) return;

    try {
      if (previousUid != null &&
          previousUid.isNotEmpty &&
          previousUid != uid) {
        await _removeTokenFromUserDoc(previousUid);
      }

      _boundUid = uid;
      await _pushTokenToFirestore(uid);
      await syncNotificationPreferences(uid);

      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen((_) async {
        if (_boundUid != null) {
          await _pushTokenToFirestore(_boundUid!);
          await syncNotificationPreferences(_boundUid!);
        }
      });
    } catch (e) {
      debugPrint('FcmTokenService.bindToUser: $e');
    }
  }

  Future<void> unbindAndClearFirestore(String uid) async {
    if (kIsWeb) return;
    _boundUid = null;
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;

    try {
      await _removeTokenFromUserDoc(uid);
    } catch (e) {
      debugPrint('FcmTokenService.unbindAndClearFirestore: $e');
    }
  }

  Future<void> _pushTokenToFirestore(String uid) async {
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;

    await _firestore.collection('users').doc(uid).set(
      {
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'fcmPlatform': Platform.isIOS ? 'ios' : 'android',
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _removeTokenFromUserDoc(String uid) async {
    await _firestore.collection('users').doc(uid).set(
      {
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      },
      SetOptions(merge: true),
    );
  }

  /// Writes the same toggles used in-app so [sendDaily5210ReminderFCM] can filter users.
  Future<void> syncNotificationPreferences(String uid) async {
    if (kIsWeb) return;
    final storage = _localStorage;
    if (storage == null) return;

    try {
      final settings = await storage.get('app_settings', 'notification_settings');
      final all = settings?['all'] ?? true;
      final streak = settings?['streak'] ?? true;
      final tasks = settings?['tasks'] ?? true;
      final insights = settings?['insights'] ?? true;
      final sounds = settings?['sounds'] ?? true;

      final dailyEligible =
          all && (streak || tasks || insights);

      await _firestore.collection('users').doc(uid).set(
        {
          'fcmDailyPushEnabled': dailyEligible,
          'fcmNotifyStreak': streak,
          'fcmNotifyTasks': tasks,
          'fcmNotifyInsights': insights,
          'fcmSoundsEnabled': sounds,
          'fcmPreferencesUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('FcmTokenService.syncNotificationPreferences: $e');
    }
  }
}
