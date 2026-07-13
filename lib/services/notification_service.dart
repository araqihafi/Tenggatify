import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    // 1. Inisialisasi Timezone
    await _configureLocalTimeZone();
    
    // 2. Inisialisasi Plugin dengan icon launcher_icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("Notifikasi diklik: ${details.payload}");
      },
    );

    // 3. Buat Channel dengan High Importance (Wajib untuk Android 8+)
    if (Platform.isAndroid) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
        'tenggatify_alarm_v3', // ID baru
        'Alarm Tugas (Tenggatify)',
        description: 'Digunakan untuk alarm tugas mendesak',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
      ));
    }

    // 4. Minta Izin
    await requestPermissions();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final dynamic tzData = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzData.toString()));
      debugPrint("INFO: Timezone diatur ke ${tzData.toString()}");
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // Meminta izin lewat permission_handler agar muncul popup
      await [
        Permission.notification,
        Permission.scheduleExactAlarm,
        Permission.ignoreBatteryOptimizations,
      ].request();
    }
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (!Platform.isAndroid || task.reminderDate == null || task.isCompleted) return;

    final now = tz.TZDateTime.now(tz.local);
    final scheduleTime = tz.TZDateTime.from(task.reminderDate!, tz.local);
    
    if (scheduleTime.isBefore(now)) return;

    final String? customSound = task.alarmSound;
    AndroidNotificationSound? notificationSound;
    
    if (customSound != null && (customSound.contains('/') || customSound.contains('\\'))) {
      notificationSound = UriAndroidNotificationSound(customSound);
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      '⏰ ALARM: ${task.judul}',
      task.deskripsi,
      scheduleTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'tenggatify_alarm_v3',
          'Alarm Tugas',
          importance: Importance.max,
          priority: Priority.max,
          sound: notificationSound,
          playSound: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          additionalFlags: Int32List.fromList([4]), // Looping
          ongoing: true,
          visibility: NotificationVisibility.public,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint("JADWAL: ${task.judul} pada $scheduleTime");
  }

  Future<void> showInstantTestNotification() async {
    if (!Platform.isAndroid) return;
    debugPrint("TEST: Mengirim notifikasi...");
    await flutterLocalNotificationsPlugin.show(
      888,
      'Sistem Alarm Oke! ✅',
      'Jika Anda melihat ini, sistem notifikasi sudah normal.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tenggatify_alarm_v3',
          'Tes',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          fullScreenIntent: true,
        ),
      ),
    );
  }

  Future<void> showPreviewNotification(String soundName) async {
    await showInstantTestNotification();
  }

  Future<void> cancelNotification(String taskId) async {
    if (Platform.isAndroid) await flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
  }
}
