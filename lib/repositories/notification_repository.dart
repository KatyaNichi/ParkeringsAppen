// lib/repositories/notification_repository.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:uuid/uuid.dart';

class NotificationRepository {
  static final NotificationRepository _instance = NotificationRepository._internal();
  factory NotificationRepository() => _instance;
  NotificationRepository._internal();

  FlutterLocalNotificationsPlugin? _plugin;
  bool _isInitialized = false;
  final Uuid _uuid = const Uuid();

  // Initialize the notification system
  Future<void> initialize() async {
    if (_isInitialized) return;

    _plugin = FlutterLocalNotificationsPlugin();
    
    // Configure timezone
    await _configureLocalTimeZone();
    
    // Initialize the plugin
    await _initializeNotifications();
    
    _isInitialized = true;
    print('✅ Notification system initialized');
  }

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    
    tz.initializeTimeZones();
    
    if (Platform.isWindows) {
      return;
    }
    
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print('🌍 Timezone configured: $timeZoneName');
    } catch (e) {
      print('⚠️ Failed to configure timezone: $e');
      // Fallback to UTC
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification'
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
    // Handle notification tap - could navigate to specific parking or app section
  }

  // Request permissions for notifications
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    bool? granted;

    if (Platform.isIOS || Platform.isMacOS) {
      final impl = _plugin!.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      granted = await impl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    if (Platform.isAndroid) {
      final impl = _plugin!.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      granted = await impl?.requestNotificationsPermission();
    }

    print('🔔 Notification permissions granted: $granted');
    return granted ?? false;
  }

  // Schedule a parking reminder notification
  Future<String?> scheduleParkingReminder({
  required String vehicleInfo,
  required String parkingLocation,
  required DateTime reminderTime,
  int? customNotificationId,
}) async {
    if (!_isInitialized) await initialize();

    // Request permissions first
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      print('❌ No notification permission granted');
      return null;
    }

    // Generate unique ID for this notification
     final notificationId = customNotificationId ?? 
    (reminderTime.millisecondsSinceEpoch % 2147483647);
    final channelId = _uuid.v4();

    const String channelName = "Parking Reminders";
    const String channelDescription = "Notifications for parking time reminders";

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Parkeringstid går snart ut',
      color: const Color(0xFF0078D7),
      when: reminderTime.millisecondsSinceEpoch,
      chronometerCountDown: false,
      usesChronometer: false,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      subtitle: 'Parkeringstid',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _plugin!.zonedSchedule(
        notificationId,
        '🚗 Parkeringstid går snart ut!',
        '$vehicleInfo parkerad på $parkingLocation',
        tz.TZDateTime.from(reminderTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'parking_reminder:$notificationId',
      );

      final notificationIdString = notificationId.toString();
      print('📅 Parking reminder scheduled for $reminderTime with ID: $notificationIdString');
      return notificationIdString;
    } catch (e) {
      print('❌ Failed to schedule notification: $e');
      return null;
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(String notificationId) async {
    if (!_isInitialized) return;

    try {
      final id = int.parse(notificationId);
      await _plugin!.cancel(id);
      print('🗑️ Cancelled notification: $notificationId');
    } catch (e) {
      print('❌ Failed to cancel notification $notificationId: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    await _plugin!.cancelAll();
    print('🗑️ Cancelled all notifications');
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];
    return await _plugin!.pendingNotificationRequests();
  }

  // Show immediate notification (for testing)
Future<void> showImmediateNotification({
  required String title,
  required String body,
  String? payload,
}) async {
  if (!_isInitialized) await initialize();

  const androidDetails = AndroidNotificationDetails(
    'immediate_channel',
    'Immediate Notifications',
    channelDescription: 'For immediate test notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  const notificationDetails = NotificationDetails(android: androidDetails);

  // FIX: Use a smaller ID instead of timestamp
  final notificationId = DateTime.now().millisecondsSinceEpoch % 2147483647; // Keep within 32-bit range

  await _plugin!.show(
    notificationId, // Use the smaller ID
    title,
    body,
    notificationDetails,
    payload: payload,
  );
}
}