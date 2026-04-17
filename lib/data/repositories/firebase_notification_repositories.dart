import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'package:bus_seat_booking/domain/entities/app_notification.dart';
import 'package:bus_seat_booking/domain/interface/notification_repository_interface.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class FirebaseNotificationRepository implements INotificationRepository {
  FirebaseNotificationRepository() {
    _initStreams();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Dio _dio = Dio();

  
  final _foregroundController = StreamController<AppNotification>.broadcast();
  final _openedAppController = StreamController<AppNotification>.broadcast();

  void _initStreams() {
    FirebaseMessaging.onMessage.listen((message) {
      _foregroundController.add(_toAppNotification(message));
    });


    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openedAppController.add(_toAppNotification(message));
    });
  }

  @override
  Stream<AppNotification> get onForegroundMessage => _foregroundController.stream;

  @override
  Stream<AppNotification> get onMessageOpenedApp => _openedAppController.stream;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  @override
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  @override
  Future<void> sendNotification({
    required String targetToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final accessToken = await _getAccessToken();
    final projectId = await _getProjectId();

    final response = await _dio.post(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      }),
      data: {
        'message': {
          'token': targetToken,
          'notification': {'title': title, 'body': body},
          'data': data ?? {},
        },
      },
    );
    debugPrint('FCM send success: ${response.statusCode} ${response.data}');
  }

  AppNotification _toAppNotification(RemoteMessage message) {
    return AppNotification(
      title: message.notification?.title ?? 'Notifikasi Baru',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }

  Future<String> _getAccessToken() async {
    final jsonString = await rootBundle.loadString('assets/serviceAccountKey.json');
    final credentials = ServiceAccountCredentials.fromJson(
      json.decode(jsonString),
    );
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(credentials, scopes);
    try {
      debugPrint('access token: ${client.credentials.accessToken.data}');
      return client.credentials.accessToken.data;
    } finally {
      client.close();
    }
  }

  Future<String> _getProjectId() async {
    final jsonString = await rootBundle.loadString('assets/serviceAccountKey.json');
    final payload = json.decode(jsonString) as Map<String, dynamic>;
    final projectId = payload['project_id'] as String?;
    if (projectId == null || projectId.isEmpty) {
      throw Exception('project_id tidak ditemukan di serviceAccountKey.json');
    }
    return projectId;
  }
}