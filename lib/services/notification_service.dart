// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../repositories/notification_repository.dart';
import '../models/parking.dart';
import '../models/vehicle.dart';
import '../models/parking_space.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final NotificationRepository _notificationRepository = NotificationRepository();
  
  // Default reminder time (in minutes before parking expires)
  static const int defaultReminderMinutes = 15;

  // Initialize the service
  Future<void> initialize() async {
    await _notificationRepository.initialize();
  }

  // Schedule notification for when parking time is about to expire
  Future<String?> scheduleParkingReminder({
    required Vehicle vehicle,
    required ParkingSpace parkingSpace,
    required DateTime startTime,
    required int durationHours,
    int reminderMinutesBefore = defaultReminderMinutes,
  }) async {
    try {
      // Calculate when parking will end
      final endTime = startTime.add(Duration(hours: durationHours));
      
      // Calculate when to send reminder
      final reminderTime = endTime.subtract(Duration(minutes: reminderMinutesBefore));
      
      // Don't schedule if reminder time is in the past
      if (reminderTime.isBefore(DateTime.now())) {
        print('⚠️ Reminder time is in the past, not scheduling notification');
        return null;
      }

      // Create descriptive vehicle info
      final vehicleInfo = '${vehicle.type} (${vehicle.registrationNumber})';
      
      // Schedule the notification
      return await _notificationRepository.scheduleParkingReminder(
        vehicleInfo: vehicleInfo,
        parkingLocation: parkingSpace.adress,
        reminderTime: reminderTime,
      );
    } catch (e) {
      print('❌ Failed to schedule parking reminder: $e');
      return null;
    }
  }

  // Schedule notification for active parking (using current time as start)
  Future<String?> scheduleActiveParkingReminder({
    required Vehicle vehicle,
    required ParkingSpace parkingSpace,
    required int estimatedDurationHours,
    int reminderMinutesBefore = defaultReminderMinutes,
  }) async {
    return scheduleParkingReminder(
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      startTime: DateTime.now(),
      durationHours: estimatedDurationHours,
      reminderMinutesBefore: reminderMinutesBefore,
    );
  }

  // Cancel parking reminder
  Future<void> cancelParkingReminder(String notificationId) async {
    await _notificationRepository.cancelNotification(notificationId);
  }

  // Cancel all parking reminders
  Future<void> cancelAllParkingReminders() async {
    await _notificationRepository.cancelAllNotifications();
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    return await _notificationRepository.requestPermissions();
  }

  // Show test notification (for debugging)
  Future<void> showTestNotification() async {
    await _notificationRepository.showImmediateNotification(
      title: '🚗 Test Notification',
      body: 'Notifikationer fungerar korrekt!',
      payload: 'test_notification',
    );
  }

  // Get pending notifications for debugging
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationRepository.getPendingNotifications();
  }

  // Calculate human-readable time until parking expires
  String getTimeUntilExpiry(DateTime startTime, int durationHours) {
    final endTime = startTime.add(Duration(hours: durationHours));
    final now = DateTime.now();
    
    if (endTime.isBefore(now)) {
      return 'Parkering har gått ut';
    }
    
    final timeLeft = endTime.difference(now);
    
    if (timeLeft.inDays > 0) {
      return '${timeLeft.inDays} dagar ${timeLeft.inHours % 24} timmar kvar';
    } else if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours} timmar ${timeLeft.inMinutes % 60} minuter kvar';
    } else {
      return '${timeLeft.inMinutes} minuter kvar';
    }
  }

  // Parse start time string to DateTime (assuming format "HH:MM")
  DateTime parseStartTime(String startTimeString) {
    final parts = startTimeString.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $startTimeString');
    }
    
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // Schedule reminder for existing parking with string time
  Future<String?> scheduleReminderForExistingParking({
    required Vehicle vehicle,
    required ParkingSpace parkingSpace,
    required String startTimeString,
    int estimatedDurationHours = 2, // Default parking duration
    int reminderMinutesBefore = defaultReminderMinutes,
  }) async {
    try {
      final startTime = parseStartTime(startTimeString);
      
      return await scheduleParkingReminder(
        vehicle: vehicle,
        parkingSpace: parkingSpace,
        startTime: startTime,
        durationHours: estimatedDurationHours,
        reminderMinutesBefore: reminderMinutesBefore,
      );
    } catch (e) {
      print('❌ Failed to schedule reminder for existing parking: $e');
      return null;
    }
  }
}